//
//  Future.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 14/8/24.
//

import SwiftUI
import Combine

struct FutureView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Test Future", action: viewModel.testFuture)
            Button("Test Preparing Future", action: viewModel.testPreparingFuture)
            Button("Test Preparing Deferred Future", action: viewModel.testPreparingDeferredFuture)
            Button("Test Deferred Future", action: viewModel.testDeferredFuture)
            Button("Test Shared Deferred Future", action: viewModel.testSharedDeferredFuture)
            Button("Test Shared Deferred Future 2", action: viewModel.testSharedDeferredFuture2)
            Button("Test Shared Deferred Future 3", action: viewModel.testSharedDeferredFuture3)
        }
    }
}

extension FutureView {
    final class ViewModel {
        private var cancellables = Set<AnyCancellable>()

        func testFuture() {
            let publisher = Future<Int, Never> { future in
                print("future is coming.")
                future(.success(Int.random(in: 0...100)))
            }

            publisher
                .sink { print ("received 1: \($0)")}
                .store(in: &cancellables)

            publisher
                .sink { print ("received 2: \($0)")}
                .store(in: &cancellables)
        }

        func testPreparingFuture() {
            _ = Future<Int, Never> { future in
                print("future is coming.")
                future(.success(Int.random(in: 0...100)))
            }
        }

        func testPreparingDeferredFuture() {
            _ = Deferred {
                Future<Int, Never> { future in
                    print("future is coming.")
                    future(.success(Int.random(in: 0...100)))
                }
            }
            print("Waiting for future...")
        }

        func testDeferredFuture() {
            let publisher = Deferred {
                Future<Int, Never> { future in
                    print("future is coming.")
                    future(.success(Int.random(in: 0...100)))
                }
            }
            publisher
                .sink { print ("received 1: \($0)")}
                .store(in: &cancellables)

            publisher
                .sink { print ("received 2: \($0)")}
                .store(in: &cancellables)
        }

        func testSharedDeferredFuture() {
            let publisher = Deferred {
                Future<Int, Never> { future in
                    print("future is coming.")
                    future(.success(Int.random(in: 0...100)))
                }
            }.share()

            publisher
                .sink { print ("received 1: \($0)")}
                .store(in: &cancellables)

            publisher
                .sink { print ("received 2: \($0)")}
                .store(in: &cancellables)
        }

        func testSharedDeferredFuture2() {
            let publisher = Deferred {
                Future<Int, Never> { future in
                    print("future is coming.")
                    future(.success(Int.random(in: 0...100)))
                }
            }.share()

            publisher
                .sink { completion in
                    print ("received completion 1: \(completion)")
                } receiveValue: { value in
                    print ("received value 1: \(value)")
                }
                .store(in: &cancellables)

            publisher
                .sink { completion in
                    print ("received completion 2: \(completion)")
                } receiveValue: { value in
                    print ("received value 2: \(value)")
                }
                .store(in: &cancellables)
        }

        func testSharedDeferredFuture3() {
            let publisher = Deferred {
                Future<Int, Never> { future in
                    print("future is coming.")
                    future(.success(Int.random(in: 0...100)))
                }
            }.share().makeConnectable()

            publisher
                .sink { completion in
                    print ("received completion 1: \(completion)")
                } receiveValue: { value in
                    print ("received value 1: \(value)")
                }
                .store(in: &cancellables)

            publisher
                .sink { completion in
                    print ("received completion 2: \(completion)")
                } receiveValue: { value in
                    print ("received value 2: \(value)")
                }
                .store(in: &cancellables)

            publisher.connect()
                .store(in: &cancellables)
        }
    }
}

#Preview {
    FutureView()
        .buttonStyle(.main)
}
