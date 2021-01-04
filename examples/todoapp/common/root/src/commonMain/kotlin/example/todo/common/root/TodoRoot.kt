package example.todo.common.root

import com.arkivanov.decompose.ComponentContext
import com.arkivanov.decompose.RouterState
import com.arkivanov.decompose.value.Value
import com.arkivanov.mvikotlin.core.store.StoreFactory
import com.badoo.reaktive.completable.CompletableWrapper
import com.badoo.reaktive.completable.completableOfEmpty
import com.badoo.reaktive.completable.wrap
import com.badoo.reaktive.maybe.MaybeWrapper
import com.badoo.reaktive.maybe.maybeOf
import com.badoo.reaktive.maybe.wrap
import com.badoo.reaktive.observable.ObservableWrapper
import com.badoo.reaktive.observable.observableOf
import com.badoo.reaktive.observable.wrap
import com.badoo.reaktive.single.SingleWrapper
import com.badoo.reaktive.single.singleOf
import com.badoo.reaktive.single.wrap
import example.todo.common.edit.TodoEdit
import example.todo.common.main.TodoMain
import example.todo.common.root.TodoRoot.Dependencies
import example.todo.common.root.integration.TodoRootImpl
import example.todo.database.TodoDatabase

interface TodoRoot {

    val routerState: Value<RouterState<*, Child>>

    sealed class Child {
        data class Main(val component: TodoMain) : Child()
        data class Edit(val component: TodoEdit) : Child()
    }

    interface Dependencies {
        val storeFactory: StoreFactory
        val database: TodoDatabase
    }
}

@Suppress("FunctionName") // Factory function
fun TodoRoot(componentContext: ComponentContext, dependencies: Dependencies): TodoRoot =
    TodoRootImpl(componentContext, dependencies)

class MyTest {

    fun obs(): ObservableWrapper<Int> =
            observableOf(3, 4, 5).wrap()

    fun sin(): SingleWrapper<Int> =
            singleOf(3).wrap()

    fun may(): MaybeWrapper<Int> =
            maybeOf(4).wrap()

    fun com(): CompletableWrapper =
            completableOfEmpty().wrap()
}

class SharedDataSource {

    fun load(): SingleWrapper<String> = TODO()
}
