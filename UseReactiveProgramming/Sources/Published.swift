//
//  Published.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 8/8/24.
//

import SwiftUI
import Combine

struct PublishedView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Text(String(viewModel.value))
        }
    }
}

extension PublishedView {
    final class ViewModel: ObservableObject {
        @Published var value = 0
        private var cancellables = Set<AnyCancellable>()

        init() {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.value = Int.random(in: 0...1000)
            }
            $value
                .sink { newValue in
                    print("current:", self.value, "next:", newValue)
                    self.unexpectedMethod()
                }
                .store(in: &cancellables)
        }

        private func unexpectedMethod() {
            print(value)
        }
    }
}

#Preview("PublishedView") {
    PublishedView()
        .buttonStyle(.main)
}

struct AnotherCurrentValueView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        Text("Placeholder")
    }
}

extension AnotherCurrentValueView {
    final class ViewModel {
        let value = CurrentValueSubject<Int, Never>(0)

        private var cancellables = Set<AnyCancellable>()

        init() {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.value.send(Int.random(in: 0...1000))
            }
            value
                .sink { newValue in
                    print("current:", self.value.value, "next:", newValue)
                    self.expectedMethod()
                }
                .store(in: &cancellables)
        }

        private func expectedMethod() {
            print(value.value)
        }
    }
}

#Preview("AnotherCurrentValueView") {
    AnotherCurrentValueView()
        .buttonStyle(.main)
}
