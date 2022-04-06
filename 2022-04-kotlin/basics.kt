/**
 * You can edit, run, and share this code.
 * play.kotlinlang.org
 */

fun main() {
    println("Hello, world!!!")

    // classes

    open class Shape

    class Rectangle(var height: Double, var length: Double): Shape() {
        val perimeter = (height + length) * 2
    }

    val rectangle = Rectangle(5.0, 2.0)

  println("The perimeter is ${rectangle.perimeter}")

    val a = 10
    val b = 11

    // if func
    fun maxOf(a: Int, b: Int) = if (a > b) a else b

    println("Max of ${a} and ${b} is ${maxOf(a, b)}")

    // list / collections basic
    val items = listOf("apple", "banana", "kiwifruit")
    for (item in items) {
        println(item)
    }

    when {
        "orange" in items -> println("juicy")
        "apple" in items -> println("apple is fine too")
    }

    val items2 = listOf("apple", "banana", "kiwifruit")
    for (index in items2.indices) {
        println("item at $index is ${items[index]}")
    }

  // when func
    fun describe(obj: Any): String =
        when (obj) {
            1          -> "One"
            "Hello"    -> "Greeting"
            is Long    -> "Long"
            is String  -> "String"
            !is Int    -> "Not Int"
            else       -> "Unknown"
        }

    val something = "Some string"
    println("The description of ${something} is ${describe(something)}")

    // ranges
    val x = 10
    val y = 9
    if (x in 1..y+1) {
        println("${x} fits in range(${1}, ${y+1})")
    }

    // iterate over a range
    for (i in 1..5) {
        print(i)
    }
    println()
    // progression all inclusive
    for (i in 9 downTo 0 step 3) {
        print(i)
    }
    println()

    // advanced collections
    // yelling a* fruits
    val fruits = listOf("banana", "avocado", "apple", "kiwifruit")
    fruits
        .filter { it.startsWith("a") }
        .sortedBy { it }
        .map { it.uppercase() }
        .forEach { println(it) }

    // nullable and automatic cast
    fun parseInt(str: String): Int? {
        return str.toIntOrNull()
    }

    fun printProduct(arg1: String, arg2: String) {
        val x = parseInt(arg1)
        val y = parseInt(arg2)

        // Using `x * y` yields error because they may hold nulls.
        if (x != null && y != null) {
            // x and y are automatically cast to non-nullable after null check
            println(x * y)
        }
        else {
            println("'$arg1' or '$arg2' is not a number")
        }
    }

    printProduct("6", "7")
    printProduct("a", "7")
    printProduct("a", "b")

    fun printProductGuardStyle(arg1: String, arg2: String) {
        val x = parseInt(arg1)
        val y = parseInt(arg2)

        // ...
        if (x == null) {
            println("Wrong number format in arg1: '$arg1'")
            return
        }
        if (y == null) {
            println("Wrong number format in arg2: '$arg2'")
            return
        }

        // x and y are automatically cast to non-nullable after null check
        println(x * y)
    }

    printProductGuardStyle("6", "7")
    printProductGuardStyle("a", "7")
    printProductGuardStyle("a", "b")

    // type check and automatic cast
    fun getStringLength(obj: Any): Int? {
        // `obj` is automatically cast to `String` on the right-hand side of `&&`
        if (obj is String && obj.length > 0) {
            return obj.length
        }

        return null
    }

    fun getStringLengthGuardStyle(obj: Any): Int? {
        if (obj !is String) return null

        // `obj` is automatically cast to `String` in this branch
        return obj.length
    }
}
