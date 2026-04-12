// https://c3-lang.org/language-overview/examples/
//	merged various snippets, to see more highlighting

import std::io;

struct Foo
{
    int a;
    double b;
    int* ptr;
}

macro print_fields($Type)
{
    $foreach $field : $Type.membersof:
        io::printfn("Field %s, offset: %s, size: %s, type: %s",
                $field.nameof, $field.offsetof, $field.sizeof, $field.typeid.nameof);
    $endforeach
}


fn void main()
{
    print_fields(Foo);
}

fn void if_example(int a)
{
    if (a > 0)
    {
        // ..
    }
    else
    {
        // ..
    }
}
// Prints the values in the slice.
fn void example_foreach(float[] values)
{
    foreach (index, value : values)
    {
        io::printfn("%d: %f", index, value);
    }
}

// Updates each value in the slice
// by multiplying it by 2.
fn void example_foreach_by_ref(float[] values)
{
    foreach (&value : values)
    {
        *value *= 2;
    }
}

enum Height : uint
{
    LOW,
    MEDIUM,
    HIGH,
}

fn void demo_enum(Height h)
{
    switch (h)
    {
        case LOW:
        case MEDIUM:
            io::printn("Not high");
            // Implicit break.
        case HIGH:
            io::printn("High");
    }

    // This also works
    switch (h)
    {
        case LOW:
        case MEDIUM:
            io::printn("Not high");
            // Implicit break.
        case Height.HIGH:
            io::printn("High");
    }

    // Completely empty cases are not allowed.
    switch (h)
    {
        case LOW:
            break; // Explicit break required, since switches can't be empty.
        case MEDIUM:
            io::printn("Medium");
        case HIGH:
            break;
    }

    // special checking of switching on enum types
    switch (h)
    {
        case LOW:
        case MEDIUM:
        case HIGH:
            break;
        default:    // warning: default label in switch which covers all enumeration value
            break;
    }

    // Using "nextcase" will fallthrough to the next case statement,
    // and each case statement starts its own scope.
    switch (h)
    {
        case LOW:
            int a = 1;
            io::printn("A");
            nextcase;
        case MEDIUM:
            int a = 2;
            io::printn("B");
            nextcase;
        case HIGH:
            // a is not defined here
            io::printn("C");
    }
}

fn void duff(int* to, int* from, int count)
{
    int n = (count + 7) / 8;
    switch (count % 8)
    {
        case 0: *to++ = *from++; nextcase;
        case 7: *to++ = *from++; nextcase;
        case 6: *to++ = *from++; nextcase;
        case 5: *to++ = *from++; nextcase;
        case 4: *to++ = *from++; nextcase;
        case 3: *to++ = *from++; nextcase;
        case 2: *to++ = *from++; nextcase;
        case 1: *to++ = *from++; if (--n > 0) nextcase 0;
    }
}

alias Callback = fn int(char c);

enum Status : int
{
    IDLE,
    BUSY,
    DONE,
}

struct MyData
{
    char* name;
    Callback open;
    Callback close;
    Status status;

    // named sub-structs (x.other.value)
    struct other
    {
        int value;
        int status;   // ok, no name clash with other status
    }

    // anonymous sub-structs (x.value)
    struct
    {
        int value;
        int status;   // error, name clash with other status in MyData
    }

    // anonymous union (x.person)
    union
    {
        Person* person;
        Company* company;
    }

    // named sub-unions (x.either.this)
    union either
    {
        int this;
        bool  or;
        char* that;
    }
}

module demo;

alias Callback = fn int(char* text, int value);

fn int my_callback(char* text, int value)
{
    return 0;
}

Callback cb = &my_callback;

fn void example_cb()
{
    int result = cb("demo", 123);
    // ..
}

<*
 @param foo : "the number of foos"
 @require foo > 0, foo < 1000
 @return "number of foos x 10"
 @ensure return < 10000, return > 0
*>
fn int test_foo(int foo)
{
    return foo * 10;
}

<*
 @param array : "the array to test"
 @param length : "length of the array"
 @require length > 0
*>
fn int get_last_element(int* array, int length)
{
    return array[length - 1];
}


macro foo(a, b)
{
    return a(b);
}

fn int square(int x)
{
    return x * x;
}

fn int test()
{
    int a = 2;
    int b = 3;
    return foo(&square, 2) + a + b; // 9
    // return foo(square, 2) + a + b;
    // Error: function should be followed by (...) or prefixed by &.
}

macro @foo(#a, b, #c)
{
    #c = #a(b) * b;
}

macro @foo2(#a)
{
    return #a * #a;
}

fn int square(int x)
{
    return x * x;
}

fn int test1()
{
    int a = 2;
    int b = 3;
    @foo(square, a + 1, b);
    return b; // 27
}

fn int printme(int a)
{
    io::printn(a);
    return a;
}

fn int test2()
{
    return @foo2(printme(2)); // Returns 4 and prints "2" twice.
}


macro long fib(long $n)
{
    $if $n <= 1:
        return $n;
    $else
        return fib($n - 1) + fib($n - 2);
    $endif
}

const long FIB19 = fib(19);
// Same as const long FIB19 = 4181;


struct Vec2
{
    int x, y;
}

fn Vec2 Vec2.add(self, Vec2 other) @operator(+)
{
    return { self.x + other.x, self.y + other.y };
}

fn Vec2 Vec2.sub(self, Vec2 other) @operator(-)
{
    return { self.x - other.x, self.y - other.y };
}

fn void main()
{
    Vec2 v1 = { 1, 2 };
    Vec2 v2 = { 100, 4 };
    Vec2 v3 = v1 + v2;    // v3 = { 101, 6 }
}

module stack;

struct Stack <Type>
{
    usz capacity;
    usz size;
    Type* elems;
}


fn void Stack.push(Stack* this, Type element)
{
    if (this.capacity == this.size)
    {
        this.capacity = this.capacity ? this.capacity * 2 : 16;
        this.elems = realloc(this.elems, Type.sizeof * this.capacity);
    }
    this.elems[this.size++] = element;
}

fn Type Stack.pop(Stack* this)
{
    assert(this.size > 0);
    return this.elems[--this.size];
}

fn bool Stack.empty(Stack* this)
{
    return !this.size;
}
