//
//  CombineView.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 15/8/24.
//

import SwiftUI
import Combine

struct CombineView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Test Merge", action: viewModel.testMerge)
            Button("Test Zip", action: viewModel.testZip)
            Button("Test CombineLatest", action: viewModel.testCombineLatest)
            Button("Test FlatMap", action: viewModel.testFlatMap)
            Button("Test Concatenate", action: viewModel.testConcatenate)
            Button("Test Concatenate 3", action: viewModel.testConcatenate3)
        }
    }
}

extension CombineView {
    final class ViewModel {
        private var cancellables = Set<AnyCancellable>()

        func testMerge() {
            cancellables = []
            let sub1 = PassthroughSubject<Int, Error>()
            let sub2 = PassthroughSubject<Int, Error>()

            sub1.merge(with: sub2)
                .sink(receiveCompletion: { completion in
                    print("received:", completion)
                }, receiveValue: { value in
                    print("received:", value)
                })
                .store(in: &cancellables)

            sub1.send(1)
            sub2.send(2)
            sub2.send(4)
            sub1.send(3)

            sub1.send(completion: .finished)
//            sub2.send(completion: .finished)
            sub2.send(completion: .failure(NSError(domain: "", code: 1)))
        }

        func testZip() {
            cancellables = []
            let seq1 = (0...1).publisher
            let seq2 = (2...3).publisher

            seq1.zip(seq2) // Publishers.Zip(seq1, seq2)
                .sink(receiveCompletion: { completion in
                    print("received:", completion)
                }, receiveValue: { value in
                    print("received:", value)
                })
                .store(in: &cancellables)
        }

        func testCombineLatest() {
            cancellables = []

            let sub1 = PassthroughSubject<Int, Error>()
            let sub2 = PassthroughSubject<Int, Error>()

            sub1.combineLatest(with: sub2)
                .sink(receiveCompletion: { completion in
                    print("received:", completion)
                }, receiveValue: { value in
                    print("received:", value)
                })
                .store(in: &cancellables)

            sub1.send(1)
            sub1.send(3)
            sub2.send(2)
            sub2.send(4)
            sub1.send(5)
        }

        func testFlatMap() {
            cancellables = []

            let seq1 = (0...1).publisher
            let seq2 = (2...3).publisher

            seq1
                .flatMap { _ in seq2 }
                .sink(receiveCompletion: { completion in
                    print("received:", completion)
                }, receiveValue: { value in
                    print("received:", value)
                })
                .store(in: &cancellables)
        }

        func testConcatenate() {
            cancellables = []

            let seq1 = (0...1).publisher
            let seq2 = (2...3).publisher

            Publishers.Concatenate(prefix: seq1, suffix: seq2)
                .sink(receiveCompletion: { completion in
                    print("received:", completion)
                }, receiveValue: { value in
                    print("received:", value)
                })
                .store(in: &cancellables)
        }

        func testConcatenate3() {
            cancellables = []

            let seq1 = (0...1).publisher
            let seq2 = (2...3).publisher
            let seq3 = (4...5).publisher

            seq1
                .append(seq2)
                .append(seq3)
                .sink(receiveCompletion: { completion in
                    print("received:", completion)
                }, receiveValue: { value in
                    print("received:", value)
                })
                .store(in: &cancellables)
        }
    }
}

#Preview {
    CombineView()
        .buttonStyle(.main)
}
