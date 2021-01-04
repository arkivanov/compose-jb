import SwiftUI
import Todo
import RxSwift

struct RootView: View {
    @ObservedObject
    private var routerStates: ObservableValue<RouterState<AnyObject, TodoRootChild>>
    
    init(_ component: TodoRoot) {
        self.routerStates = ObservableValue(component.routerState)
    }
    
    var body: some View {
        let m = MyTest()
        
        
        let child = self.routerStates.value.activeChild.component
        
        switch child {
        case let main as TodoRootChild.Main:
            MainView(main.component)

        case let edit as TodoRootChild.Edit:
            EditView(edit.component)
                .transition(
                    .asymmetric(
                        insertion: AnyTransition.move(edge: .trailing),
                        removal: AnyTransition.move(edge: .trailing)
                    )
                )
                .animation(.easeInOut)
            
        default: EmptyView()
        }
    }
}

func load(ds: SharedDataSource) {
    let disposable = ds.load().subscribe(isThreadLocal: false) { result in
        // Handle the result
    }
    
    // At some point later
    disposable.dispose()
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(StubTodoRoot())
    }
    
    class StubTodoRoot : TodoRoot {
        let routerState: Value<RouterState<AnyObject, TodoRootChild>> =
            simpleRouterState(TodoRootChild.Main(component: MainView_Previews.StubTodoMain()))
    }
}

extension RxSwift.Observable where Element : AnyObject {
    static func from(_ observable: ObservableWrapper<Element>) -> RxSwift.Observable<Element> {
        return RxSwift.Observable<Element>.create { observer in
            let disposable = observable.subscribe(
                isThreadLocal: false,
                onError: { observer.onError(KotlinError($0)) },
                onComplete: observer.onCompleted,
                onNext: observer.onNext
            )
            
            return Disposables.create(with: disposable.dispose)
        }
    }
}

extension RxSwift.Single where Element : AnyObject {
    static func from(_ single: SingleWrapper<Element>) -> RxSwift.Single<Element> {
        return RxSwift.Single<Element>.create { observer in
            let disposable = single.subscribe(
                isThreadLocal: false,
                onError: { observer(.failure(KotlinError($0))) },
                onSuccess: { observer(.success($0)) }
            )
            
            return Disposables.create(with: disposable.dispose)
        }
    }
}

extension RxSwift.Maybe where Element : AnyObject {
    static func from(_ maybe: MaybeWrapper<Element>) -> RxSwift.Maybe<Element> {
        return RxSwift.Maybe<Element>.create { observer in
            let disposable = maybe.subscribe(
                isThreadLocal: false,
                onError: { observer(.error(KotlinError($0))) },
                onComplete: { observer(.completed) },
                onSuccess: { observer(.success($0)) }
            )
            
            return Disposables.create(with: disposable.dispose)
        }
    }
}

extension RxSwift.Completable {
    static func from(_ completable: CompletableWrapper) -> RxSwift.Completable {
        return RxSwift.Completable.create { observer in
            let disposable = completable.subscribe(
                isThreadLocal: false,
                onError: { observer(.error(KotlinError($0))) },
                onComplete: { observer(.completed) }
            )
            
            return Disposables.create(with: disposable.dispose)
        }
    }
}

struct KotlinError : Error {
    let throwable: KotlinThrowable
    
    init (_ throwable: KotlinThrowable) {
        self.throwable = throwable
    }
}
