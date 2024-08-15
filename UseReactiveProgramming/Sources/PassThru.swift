//
//  PassThru.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 8/7/24.
//

import SwiftUI
import Combine

struct PassThruView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Next", action: viewModel.next)
            Button("Finish", action: viewModel.finish)
            Button("Error", action: viewModel.error)
            Button("Reset") {
                viewModel = ViewModel()
            }
        }
    }
}

extension PassThruView {
    final class ViewModel {
        private let passthru = PassthroughSubject<Int, Error>()
        private var passthruCancellable: AnyCancellable?

        // RxSwift counterpart:
        // private let passthru = PublishSubject<Int>()

        init() {
            passthruCancellable = passthru
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("passthru did finish")
                        
                    case .failure(let error):
                        print("passthru did fail with \(error)")
                    }
                }, receiveValue: { value in
                    print(value)
                })
        }

        func next() {
            passthru.send(Int.random(in: 0..<255))
        }

        func finish() {
            passthru.send(completion: .finished)
        }

        func error() {
            passthru.send(completion: .failure(SubjectError()))
        }
    }

    struct SubjectError: Error {}
}

#Preview("Passthru") {
    PassThruView()
        .buttonStyle(.main)
}
