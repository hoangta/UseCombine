//
//  Publisher.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 16/7/24.
//

import SwiftUI
import Combine

struct PublisherView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Button("A publisher", action: viewModel.aPublisher)
            Button("Cancel", action: viewModel.cancel)
        }
    }
}

extension PublisherView {
    final class ViewModel {
        private var cancellables = Set<AnyCancellable>()
        private let publisher = Publisher()

        func aPublisher() {
            publisher
                .sink { value in
                    print("value:", value)
                }
                .store(in: &cancellables)
        }

        func cancel() {
            cancellables = []
        }
    }
}

extension PublisherView {
    struct Publisher: Combine.Publisher {
        typealias Output = Int
        typealias Failure = Never

        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Int == S.Input {
            Swift.print("new subscription!")
            let subscription = Subscription(target: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension PublisherView.Publisher {
    class Subscription<Target: Subscriber>: Combine.Subscription where Target.Input == Int {
        private let timer: Timer

        init(target: Target) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                _ = target.receive(Int.random(in: 0..<100))
            }
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            timer.invalidate()
        }
    }
}

#Preview {
    PublisherView()
        .buttonStyle(.main)
}
