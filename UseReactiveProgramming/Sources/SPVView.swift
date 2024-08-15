//
//  SPVView.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 14/8/24.
//

import SwiftUI
import Combine

struct SPVView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        Text("Hello, World!")
    }
}

extension SPVView {
    final class ViewModel {
        enum State {
            case initial
            case preparing
            case updating(Int, Int)
            case inserting(Int, Int)
            case success
            case error(Error)
        }

        @Published var state = State.initial

        func backup() {
            let photos = loadAllPhotos()
            let optionalBackupInfo = getBackupInfo().share()
            let files = optionalBackupInfo.flatMap(getFiles)
            let backupInfo = optionalBackupInfo.flatMap(createBackupInfoIfNeeded)

            Publishers.CombineLatest3(photos, files, backupInfo)
                .flatMap { [unowned self] photos, files, backupInfo -> AnyPublisher<State, Error> in
                    let uploadInfo = getUploadInfo(photos, files, backupInfo)
                    guard !uploadInfo.hasExceededUploadQuota else {
                        return Fail(error: BackupError.quotaReached).eraseToAnyPublisher()
                    }

                    let upload = upload(info: uploadInfo, backupInfo: backupInfo)
                    let updateBackupInfo = updateBackupInfo((), photoCount: uploadInfo.totalCount)
                        .map { _ in State.success }

                    return upload
                        .append(updateBackupInfo)
                        .append(.initial)
                        .eraseToAnyPublisher()
                }
                .catch { error -> AnyPublisher<State, Never> in
                        .just(.error(error))
                }
                .prepend(.preparing)
                .registerBackupState()
                .assign(to: &$state)
        }
    }
}

extension SPVView {
    enum BackupError: Error {
        case quotaReached
    }
}

// MARK: - Helpers
private extension SPVView.ViewModel {
    struct UploadInfo {
        let hasExceededUploadQuota: Bool
        let totalCount: Int
    }

    func loadAllPhotos() -> Future<Void, Error> {
        .just(()) // From core data
    }

    func getFiles() -> Future<Void, Error> {
        .just(()) // File infos from GG Drive
    }

    func getBackupInfo() -> AnyPublisher<Void, Error> {
        getDriveFileList() // getDriveFileList then countFiles
            .flatMap(countFiles)
            .eraseToAnyPublisher()
    }

    func getDriveFileList() -> Future<Void, Error> {
        .just(()) // Backup folder info from GG Drive
    }

    func countFiles() -> Future<Void, Error> {
        .just(()) // Count total files from GG Drive
    }

    func createBackupInfoIfNeeded() -> Future<Void, Error> {
        .just(())
    }

    func updateBackupInfo(_ backupInfo: Void, photoCount: Int) -> Future<Void, Error> {
        .just(())
    }

    func getUploadInfo(_ v1: Void, _ v2: Void, _ v3: Void) -> UploadInfo {
        UploadInfo(hasExceededUploadQuota: false, totalCount: .max)
    }

    func upload(info: UploadInfo, backupInfo: Void) -> AnyPublisher<State, Error> {
        .just(.updating(0, 100))
    }
}

extension Publisher {
    func registerBackupState() -> AnyPublisher<Output, Failure> {
        handleEvents(receiveSubscription: { _ in
            UserDefaults.standard.setValue(true, forKey: "backup")
        }, receiveCompletion: { _ in
            UserDefaults.standard.setValue(false, forKey: "backup")
        }, receiveCancel: {
            UserDefaults.standard.setValue(false, forKey: "backup")
        })
        .eraseToAnyPublisher()
    }
}

// MARK: Helpers
extension Future {
    static func just(_ value: Output) -> Future<Output, Failure> {
        Future { promise in promise(.success(value) )}
    }
}

extension AnyPublisher {
    static func just(_ value: Output) -> AnyPublisher<Output, Failure> {
        Future.just(value).eraseToAnyPublisher()
    }
}

#Preview {
    SPVView()
}
