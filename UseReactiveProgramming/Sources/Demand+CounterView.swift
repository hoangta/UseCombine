//
//  CounterView.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 14/8/24.
//

import SwiftUI
import Combine

struct CounterView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Send", action: viewModel.test1)
            Button("Send 2", action: viewModel.test2)
        }
    }
}

extension CounterView {
    final class ViewModel {
        private var cancellables = Set<AnyCancellable>()
        private let counter = Counter()

        func test1() {
            counter.subscribe(CounterSubscriber(number: 5))
        }

        func test2() {
            counter
                .counterSink(number: 5) { completion in
                    print("completion", completion)
                } receiveValue: { value in
                    print("value", value)
                }
                .store(in: &cancellables)
        }
    }
}

extension CounterView {
    struct Counter: Publisher {
        typealias Output = Int
        typealias Failure = Never

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            Swift.print("subscriber")
            let subscription = CounterView.CounterSubscription(subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }

    class CounterSubscription<Target: Subscriber>: Subscription where Target.Input == Int {
        private let subscriber: Target
        private var timer: Timer?

        init(subscriber: Target) {
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
            Swift.print("request demand", demand)
            scheduleEmittingValue(demand: demand)
        }

        private func scheduleEmittingValue(demand: Subscribers.Demand) {
            guard demand > 0 else {
                subscriber.receive(completion: .finished)
                return
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [self] _ in
                let demand = subscriber.receive(Int.random(in: 0...100))
                scheduleEmittingValue(demand: demand)
            }
        }

        func cancel() {
            timer?.invalidate()
        }
    }

    class CounterSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never

        private var demand: Subscribers.Demand

        init(number: Int) {
            self.demand = .max(number)
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            Swift.print("receive input", input)
            demand -= 1
            return demand
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            Swift.print("receive completion")
        }

        func receive(subscription: any Subscription) {
            Swift.print("receive subscription")
            subscription.request(demand)
        }
    }
}

extension CounterView {
    class SinkableSubscriber: Subscriber, Cancellable {
        typealias Input = Int
        typealias Failure = Never


        private var demand: Subscribers.Demand
        private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
        private let receiveValue: (Input) -> Void

        private var subscription: Subscription?

        init(
            number: Int,
            receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
            receiveValue: @escaping (Input) -> Void
        ) {
            self.demand = .max(number)
            self.receiveCompletion = receiveCompletion
            self.receiveValue = receiveValue
        }

        func receive(_ input: Input) -> Subscribers.Demand {
            receiveValue(input)
            demand -= 1
            return demand
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            receiveCompletion(completion)
        }

        func receive(subscription: any Subscription) {
            self.subscription = subscription
            subscription.request(demand)
        }

        func cancel() {
            subscription?.cancel()
        }
    }
}

extension Publisher where Output == Int, Failure == Never {
    func counterSink(
        number: Int,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
        receiveValue: @escaping (Int) -> Void
    ) -> AnyCancellable {
        let subscriber = CounterView.SinkableSubscriber(
            number: number,
            receiveCompletion: receiveCompletion,
            receiveValue: receiveValue
        )
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}

#Preview {
    CounterView()
        .buttonStyle(.main)
}
