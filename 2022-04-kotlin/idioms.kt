fun main() {
    val kotlin = "🙂"
    println(kotlin)

    // data class AKA DTO / POJO / POCO

    data class Customer(val name: String, val age: Int)

    val nick = Customer("Nick", 32)

    println(nick)

    /**
     provides a data class with the following functionality:
        * getters (and setters in case of vars) for all properties
     * equals()
     * hashCode()
     * toString()
     * copy()
     */

    // default values for function parameters
    fun applyMagic(customer: Customer, age: Int = 42): Customer = Customer(customer.name, age)

    val magicNick = applyMagic(nick)

    println(magicNick)

    // filter a list
    val list = (-10..10)//.toList()

    println("list is of type ${list::class.simpleName}")

    val positivesV1 = list.filter { x -> x > 0 }
    val positivesV2 = list.filter { it > 0 }

    println("$positivesV1 is of type ${positivesV1::class.simpleName}, $positivesV2")

    // check the presence of an element in a collection
    if (5 in positivesV2) {
        println("5 is in positives")
    }

    // immutable map
    val map = mapOf("a" to 1, "b" to 2, "c" to 3)
    println(map)

    // mutable map
    var map2 = mutableMapOf("a" to 1, "b" to 2, "c" to 3)
    println(map2["a"])
    println(map2["key"])
    map2["key"] = 10 // null
    println(map2["key"])

    // itrate and ranges
    for (i in 1..100) { }  // closed range: includes 100
    for (i in 1 until 100) { } // half-open range: does not include 100
    for (x in 2..10 step 2) { }
    for (x in 10 downTo 1) { }
    (1..10).forEach { }

    // lazy
    val p: String by lazy {
        println("Computing the lazy string")

        "LAZY"
    }

    println("haven't accessed lazy p yet")
    println("accessing p")
    println(p)

    // extensioin function

    fun Customer.makeMagic(age: Int = 42): Customer = applyMagic(this, age)

    val evenMoreMagicalNick = nick.makeMagic()
    println(evenMoreMagicalNick)

    // instantiate an abstract class
    abstract class MyAbstractClass {
        abstract fun doSomething()
        abstract fun sleep()
    }

    val myObject = object : MyAbstractClass() {
        override fun doSomething() {
            // ...
            println("did something")
        }

        override fun sleep() {
            // ...
            println("did sleep")
        }
    }
    myObject.doSomething()


    // if-not-null-else shorthand

    val files: List<String>? = null

    println(files?.size ?: "empty") // if files is null, this prints "empty"

    // To calculate the fallback value in a code block, use `run`
    // val filesSize = files?.size ?: run {
    //    return 42
    //}
    //println(filesSize)

    println("Resource.name = ${Resource.name}")

    // safe first item
    val first = list.firstOrNull()
    println(first)

    // call multiple method on an instance with `with`
    class Turtle {
        fun penDown() {}
        fun penUp() {}
        fun turn(degrees: Double) {}
        fun forward(pixels: Double) {}
    }

    val myTurtle = Turtle()
    with(myTurtle) { //draw a 100 pix square
                     penDown()
                     for (i in 1..4) {
                         forward(100.0)
                         turn(90.0)
                     }
                     penUp()
    }

    fun calcTaxes(): Int = TODO("Waiting for feedback from accounting")
}

// singleton (cannot be nested in a function aka. cannot be "local")
object Resource {
    val name = "name"
}
