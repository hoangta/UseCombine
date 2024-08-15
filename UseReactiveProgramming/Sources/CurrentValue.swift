//
//  CurrentValue.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 8/7/24.
//

import SwiftUI
import Combine

struct CurrentValueView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Next", action: viewModel.next)
            Button("Reset") {
                viewModel = ViewModel()
            }
        }
    }
}

extension CurrentValueView {
    final class ViewModel {
        private let value = CurrentValueSubject<String, Never>("Hey")
        private var valueCancellable: AnyCancellable?

        // RxSwift counterpart:
        // private let value = BehaviorSubject<String>(value: "Hey")

        init() {
            valueCancellable = value
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
        }

        func next() {
            let next = ["hi", "konichiwa", "bonjour", "blademail"].randomElement()!
            value.send(next)
        }
    }
}

#Preview("CurrentValue") {
    CurrentValueView()
        .buttonStyle(.main)
}
