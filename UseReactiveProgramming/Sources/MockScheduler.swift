//
//  MockScheduler.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 14/8/24.
//

import SwiftUI
import Combine

struct MockScheduler: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            TextField("Search", text: $viewModel.search)
            ForEach(viewModel.items, id: \.self) { item in
                Text("\(item)")
            }
        }
        .padding()
    }
}

extension MockScheduler {
    final class ViewModel: ObservableObject {
        @Published var search = ""
        @Published var items: [Int] = []

        init<S: Scheduler>(
            debounce: Debounce<S> = .init(dueTime: 0.5, scheduler: DispatchQueue.main)
        ) {
            $search
                .debounce(for: debounce.dueTime, scheduler: debounce.scheduler)
                .removeDuplicates()
                .map { [unowned self] _ in fetchItems() }
                .switchToLatest()
                .assign(to: &$items)
        }

        private func fetchItems() -> Future<[Int], Never> {
            Future { future in
                let items = (0...9).map { _ in Int.random(in: 0...100) }
                future(.success(items))
            }
        }
    }
}

struct Debounce<S: Scheduler> {
    let dueTime: S.SchedulerTimeType.Stride
    let scheduler: S
}

#Preview {
    MockScheduler(viewModel:.init(
        debounce: .init(
            dueTime: 0.5,
            scheduler: ImmediateScheduler.shared
        )
    ))
}
