//
//  RealReplayValue.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 13/8/24.
//

import SwiftUI
import Combine

struct RealReplayValue: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("A publisher", action: viewModel.aReplay)
            Button("Next value", action: viewModel.nextValue)
            Button("Cancel", action: viewModel.cancel)
        }
    }
}

extension RealReplayValue {
    final class ViewModel {
        private var cancellables = Set<AnyCancellable>()
        private let subject = ReplaySubject<Int, Never>(bufferSize: 3)

        func aReplay() {
            subject
                .sink { value in
                    print("value:", value)
                }
                .store(in: &cancellables)
        }

        func nextValue() {
            subject.send(Int.random(in: 0...100))
        }

        func cancel() {
            cancellables = []
        }
    }
}

extension RealReplayValue {
    class ReplaySubject<Output, Failure: Error>: Subject {
        private var values: [Output] = []
        private let bufferSize: Int
        private var subscriptions = [Subscription<AnySubscriber<Output, Failure>>]()

        init(bufferSize: Int) {
            self.bufferSize = bufferSize
        }

        func send(_ value: Output) {
            values.append(value)
            if values.count > bufferSize {
                values.removeFirst()
            }
            subscriptions.forEach { _ = $0.target.receive(value) }
        }

        func send(subscription: Combine.Subscription) {}

        func send(completion: Subscribers.Completion<Failure>) {
            subscriptions.forEach { $0.target.receive(completion: completion) }
        }

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = Subscription(target: AnySubscriber(subscriber))
            subscription.didCancel = {
                self.subscriptions.removeAll { $0 === subscription }
            }
            subscriber.receive(subscription: subscription)
            subscriptions.append(subscription)
            values.forEach { _ = subscriber.receive($0) }
        }
    }
}

extension RealReplayValue.ReplaySubject {
    class Subscription<Target: Subscriber>: Combine.Subscription {
        let target: Target
        var didCancel: (() -> Void)?

        init(target: Target) {
            self.target = target
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            didCancel?()
        }
    }
}

#Preview {
    RealReplayValue()
        .buttonStyle(.main)
}
