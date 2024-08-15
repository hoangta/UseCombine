//
//  Observable.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 16/7/24.
//

import SwiftUI
import RxSwift

struct ObservableView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Button("An observable", action: viewModel.test1)
            Button("An observable that will finish", action: viewModel.test2)
            Button("An observable that will err", action: viewModel.test3)
            Button("An cancellable observable", action: viewModel.test4)
        }
    }
}

extension ObservableView {
    final class ViewModel {
        private var disposeBag = DisposeBag()

        // MARK: Test 1
        func test1() {
            disposeBag = DisposeBag()

            someRandomInt
                .subscribe(onNext: { value in
                    print(value)
                }, onCompleted: {
                    print("someRandomInt did finish") // This will never be called
                })
                .disposed(by: disposeBag)
        }

        var someRandomInt: Observable<Int> {
            Observable.create { observer in
                for _ in 0..<5 {
                    observer.onNext(Int.random(in: 0..<100))
                }
                return Disposables.create()
            }
        }

        // MARK: Test 2
        func test2() {
            disposeBag = DisposeBag()

            someRandomIntThenFinish
                .subscribe(onNext: { value in
                    print(value)
                }, onCompleted: {
                    print("someRandomInt did finish")
                })
                .disposed(by: disposeBag)
        }

        var someRandomIntThenFinish: Observable<Int> {
            let values = (0..<5).map { _ in Int.random(in: 0..<100) }
            return Observable.from(values)

            /* The same as:
            Observable.create { observer in
                for i in 0..<5 {
                    observer.onNext(Int.random(in: 0..<100))
                }
                observer.onCompleted()
                observer.onNext(Int.random(in: 0..<100)) // Not emitting anything.
                return Disposables.create()
            }
             */
        }

        // MARK: Test 3
        func test3() {
            disposeBag = DisposeBag()

            someRandomIntThenError
                .subscribe(onNext: { value in
                    print(value)
                }, onError: { error in
                    print("someRandomInt did err: \(error)")
                })
                .disposed(by: disposeBag)
        }

        var someRandomIntThenError: Observable<Int> {
            Observable.create { observer in
                for _ in 0..<3 {
                    observer.onNext(Int.random(in: 0..<100))
                }
                observer.onError(ObservableError.justAnError)
                return Disposables.create()
            }
        }

        enum ObservableError: Error {
            case justAnError
        }

        // MARK: Test 4
        func test4() {
            disposeBag = DisposeBag()

            someCancellableRandomInt
                .subscribe(onNext: { value in
                    print(value)
                })
                .disposed(by: disposeBag)
        }

        var someCancellableRandomInt: Observable<Int> {
            Observable.create { observer in
                let timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                    print("Next value:")
                    observer.onNext(Int.random(in: 0..<100))
                }
                return Disposables.create {
                    // Memory leak potential
                    timer.invalidate()
                }
            }
        }
    }
}

#Preview("ObservableView") {
    ObservableView()
        .buttonStyle(.main)
}
