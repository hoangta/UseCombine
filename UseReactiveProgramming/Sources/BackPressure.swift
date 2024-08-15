//
//  BackPressure.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 14/8/24.
//

import SwiftUI
import Combine

struct BackPressureView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Test Void", action: viewModel.test1)
            Button("Test Fetch Something", action: viewModel.test2)
            Button("Test Update Progress", action: viewModel.test3)
            Button("Test Update Progress", action: viewModel.test3)
            Button("Test Urgent Extensive Work", action: viewModel.test4)
            Button(
                "Test Fetch Something But Cancel To Fetch Something Else Instead",
                action: viewModel.test5
            )
            .multilineTextAlignment(.center)
            Button("Cancel", action: viewModel.cancel)
        }
    }
}

extension BackPressureView {
    final class ViewModel {
        private let passthru = PassthroughSubject<Void, Never>()
        private var cancellables = Set<AnyCancellable>()
        private var timer: Timer?

        func test1() {
            cancellables = []
            timer?.invalidate()

            passthru
                .sink {
                    print("New value!")
                }
                .store(in: &cancellables)

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] _ in
                print("Sending new value:", Date())
                passthru.send(())
            }
        }

        func test2() {
            cancellables = []
            timer?.invalidate()

            passthru
                .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
                .flatMap(fetchSomething)
                .sink { value in
                    print("New value!", value)
                }
                .store(in: &cancellables)

            var count = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] timer in
                count += 1
                guard count <= 30 else {
                    timer.invalidate()
                    return
                }
                print("Sending new value:", count)
                passthru.send(())
            }
        }

        func test3() {
            cancellables = []
            timer?.invalidate()

            var count = 0
            passthru
                .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: true)
                .sink {
                    print("Progress \(count)%")
                }
                .store(in: &cancellables)

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] timer in
                passthru.send(())

                count += 1
                if count >= 100 {
                    timer.invalidate()
                }
            }
        }

        func test4() {
            cancellables = []
            timer?.invalidate()

            var count = 0
            passthru
                .map {
                    let data = NSDataAsset(name: "test")!.data
                    print(count)
                    return UIImage(data: data)!
                }
//                .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
                .flatMap(maxPublishers: .max(1), processImage)
                .sink { image in
                    print("Did progress image!")
                }
                .store(in: &cancellables)

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] timer in
                passthru.send(())

                count += 1
                if count >= 100 {
                    timer.invalidate()
                }
            }
        }

        func test5() {
            cancellables = []
            timer?.invalidate()

            passthru
                .map { _ in self.fetchSomethingAsynchronously() }
                .switchToLatest()
                .sink {
                    print("Fetched something!")
                }
                .store(in: &cancellables)

            var count = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [unowned self] timer in
                count += 1
                guard count <= 30 else {
                    timer.invalidate()
                    return
                }
                passthru.send(())
            }
        }

        func cancel() {
            timer?.invalidate()
        }
    }
}

// MARK: - Helpers
private extension BackPressureView.ViewModel {
    func fetchSomething() -> AnyPublisher<Int, Never> {
        Just(Int.random(in: 0...100)).eraseToAnyPublisher()
    }

    func processImage(_ image: UIImage) -> AnyPublisher<UIImage, Never> {
        Just(image)
            .delay(for: .seconds(2), scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
    }

    func fetchSomethingAsynchronously() -> AnyPublisher<(), Never> {
        Just(())
            .delay(for: .seconds(2), scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}

#Preview {
    BackPressureView()
        .buttonStyle(.main)
}
