//
//  Share.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 8/8/24.
//

import SwiftUI
import Combine

struct ShareView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("Test", action: viewModel.test1)
        }
    }
}

extension ShareView {
    final class ViewModel {
        private var cancellables = Set<AnyCancellable>()

        func test1() {
//            let publisher = Just(Int.random(in: 0...100))
//                .map( { _ in Int.random(in: 0...100) } )

            let publisher = (1...1).publisher
                .delay(for: 0, scheduler: DispatchQueue.main)
                .map( { _ in Int.random(in: 0...100) } )
//                .share()

            publisher
                .sink { print ("Stream 1 received: \($0)")}
                .store(in: &cancellables)
            publisher
                .sink { print ("Stream 2 received: \($0)")}
                .store(in: &cancellables)
        }
    }
}

#Preview {
    ShareView()
        .buttonStyle(.main)
}
