//
//  Debugging.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 15/8/24.
//

import SwiftUI
import Combine

struct Debugging: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Test Breakpoint", action: viewModel.testBreakpoint)
            Button("Test Print", action: viewModel.testPrint)
            Button("Test Handle Events", action: viewModel.testHandleEvents)
        }
    }
}

extension Debugging {
    final class ViewModel {
        private var cancellables = Set<AnyCancellable>()

        func testBreakpoint() {
            cancellables = []
            let sub1 = PassthroughSubject<Int, Error>()

            sub1
                .breakpoint(receiveSubscription: { sub in
                    return false
                }, receiveOutput: { value in
                    return true
                }, receiveCompletion: { completion in
                    return false
                })
                .sink(receiveCompletion: { completion in
                    print("received:", completion)
                }, receiveValue: { value in
                    print("received:", value)
                })
                .store(in: &cancellables)

            sub1.send(2)
        }

        func testPrint() {
            cancellables = []
            let seq1 = (0...1).publisher

            seq1
                .print("Seq 1")
                .sink(receiveCompletion: { completion in
                    print("received:", completion)
                }, receiveValue: { value in
                    print("received:", value)
                })
                .store(in: &cancellables)
        }


        func testHandleEvents() {
            cancellables = []
            let seq1 = (0...1).publisher

            seq1
                .handleEvents(receiveSubscription: { sub in
                    print("receiveSubscription:", sub)
                }, receiveOutput: { output in
                    print("receiveOutput:", output)
                }, receiveCompletion: { completion in
                    print("receiveCompletion:", completion)
                }, receiveCancel: {
                    print("receiveCancel:")
                }, receiveRequest: { demand in
                    print("receiveRequest:", demand)
                })
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
    Debugging()
        .buttonStyle(.main)
}
