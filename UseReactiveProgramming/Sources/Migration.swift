//
//  Migration.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 15/8/24.
//

import SwiftUI
import Combine

struct MigrationView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

extension MigrationView {
    final class ViewModel {
        private var cancellables = Set<AnyCancellable>()

        func testNotificationCenter() {
            NotificationCenter.default
                .publisher(for: UIDevice.orientationDidChangeNotification)
                .sink { value in
                    print("received:", value)
                }
                .store(in: &cancellables)
        }

        func testTimer() {
            Timer.publish(every: 1, on: .main, in: .default)
                .autoconnect()
                .sink { value in
                    print("received:", value)
                }
                .store(in: &cancellables)
        }

        class UserInfo: NSObject {
            @objc dynamic var lastLogin: Date = Date(timeIntervalSince1970: 0)
        }

        func testKVO() {
            UserInfo()
                .publisher(for: \.lastLogin)
                .sink { value in
                    print("received:", value)
                }
                .store(in: &cancellables)
        }

        func testAsyncAwait() async {
            for await value in UserInfo().publisher(for: \.lastLogin).values {
                print("received:", value)
            }
        }
    }
}

#Preview {
    MigrationView()
        .buttonStyle(.main)
}
