//
//  ReplayValue.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 8/7/24.
//

import SwiftUI
import Combine
import CombineExt

struct ReplayValueView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Non-Working Replay", action: viewModel.nonWorkingReplay)
            Button("Replay One", action: viewModel.replayOne)
            Button("Replay Many", action: viewModel.replayMany)
        }
    }
}

extension ReplayValueView {
    final class ViewModel {
        private var cancellables = Set<AnyCancellable>()

        let passthru = PassthroughSubject<String, Never>()
        func nonWorkingReplay() {
            cancellables = []

            let replay = passthru
                .buffer(size: 3, prefetch: .keepFull, whenFull: .dropOldest)

            passthru.send("konichiwa")
            passthru.send("hi")
            passthru.send("bonjour")
            passthru.send("blademail")

            replay
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("value did finish")
                    case .failure(let error):
                        print("value did fail with \(error)")
                    }
                }, receiveValue: { value in
                    print(value)
                })
                .store(in: &cancellables)
        }

        let value = CurrentValueSubject<String?, Never>(nil)
        func replayOne() {
            cancellables = []

            let replay = value
                .compactMap { $0 }

            // First subscriber
            print("First subscribing")
            replay
                .sink { value in
                    print("First subscriber", value)
                }
                .store(in: &cancellables)

            // Delay 1s
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                print("Emit value")
                self.value.send("Value")

                // Second subscriber
                print("Second subscribing")
                replay
                    .sink { value in
                        print("Second subscriber", value)
                    }
                    .store(in: &self.cancellables)
            }
        }

        let replayManySubject = ReplaySubject<Int, Never>(bufferSize: 3)
        func replayMany() {
            cancellables = []

            replayManySubject.send(1)
            replayManySubject.send(2)
            replayManySubject.send(3)
            replayManySubject.send(4)

            replayManySubject
                .sink { value in
                    print("1st subscriber", value)
                }
                .store(in: &cancellables)
        }
    }
}

#Preview("ReplayValue") {
    ReplayValueView()
        .buttonStyle(.main)
}
