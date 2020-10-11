---
layout: post
title: Test Dependency Injection in iOS Unit Testing
date: 2020-09-26
categories: [tdd]
---

> Software development compose of small components to a big one, like lego. So
> when a component needs another component another one is the dependent one.
> We call the component has a dependency.

## What is Dependency

Sometimes when you install programs, they rely on other programs to work. These
other programs are called dependencies.

For example, if I write a messaging application, and I want my messages to be
encrypted, instead of creating a way to encrypt the messages myself, I'll use a
package that someone else has written, which will do the encryption for me. Now
when you want to install my program, you need my program, but you also need the
package I used to encrypt the messages. My program depends on the other program.

```
Program X uses Library Y.
X depends on Y. Y is X's dependency.
```

The system under test (SUT) depends-on components (DOC) which maybe is a network, or
database.

## How to unit test sut which has depends-on components

When System Under Test (SUT) Depends-On Components (DOC) which maybe is a network,
or database hard to test affect the test speed. We need to be able to replace
DOC with a test double whenever we want to make it easy to test our code.

Test double for three types of the unit test:

* Return value (fake)
* State value (stub)
* Interaction (mock and spy)

When we install the dependency into sut that is dependency injection. There are
four types of dependency inject into sut:

1. Constructor injection
1. Property injection
1. Method injection
1. Ambient Context *e.g [OHHTTPStubs](https://v.gd/iOP6bp)*
1. Extract and override

## Swift injection example for each type

```swift
protocol Service {
  func hello(_ name: String) -> String
}
```

```swift
class StubService: Service {
  var greeting: String?

  init(_ greeting: String) { self.greeting = greeting }

  func hello(_ name: String) -> String { return greeting ?? "" }
}
```

### 1. Constructor injection

```swift
class Greet {
  let service: Service

  init(_ service: Service) {
    self.service = service
  }

  func greeting(_ name: String) -> String {
    return service.hello(name)
  }
}
```

```swift
func test_greeting_withService_shouldReturnFoo() {
    let sut = Greet(StubService("foo"))

    let resut = sut.greeting("dummy")

    XCTAssertEqual(resut, "foo")
}
```

### 2. Property injection

```swift
class Greet {
  var service: Service?

  func greeting(_ name: String) -> String? {
    guard let service = service else { return nil }
    return service.hello(name)
  }
}

func test_greeting_withService_shouldReturnFoo() {
  let sut = Greet()
  sut.service = StubService("foo")

  let resut = sut.greeting("dummy")

  XCTAssertEqual(resut, "foo")
}
```

### 3. Method injection

```swift
class Greet {
  func greeting(_ name: String, with service: Service) -> String? {
    return service.hello(name)
  }
}

func test_greeting_withService_shouldReturnFoo() {
  let sut = Greet()

  let resut = sut.greeting("dummy", with: StubService("foo"))

  XCTAssertEqual(resut, "foo")
}
```

### 4. Ambient Context OHHTTPStubs

> It's mixed test code and productive code that not a good practice,
> prefer Constructor injection and Property injection first.

```swift
class Greet {
  #if DEBUG
  var stubService: Service?
  #endif

  func greeting(_ name: String) -> String {
    #if DEBUG
    if let service = stubService {
      return service.hello(name)
    }
    #endif
    let service = ServiceImpl()
    return service.hello(name)
  }
}

func test_greeting_withService_shouldReturnFoo() {
  let sut = Greet()
  sut.stubService = StubService("foo")

  let resut = sut.greeting("dummy")

  XCTAssertEqual(resut, "foo")
}

```

### 5. Extract and override

```swift
class Greet {
  func greeting(_ name: String) -> String? {
    return service().hello(name)
  }

  func service() -> Service {
    return ServiceImpl.shared
  }
}

class TestGreet: Greet {
  override func service() -> Service {
    return StubService("foo")
  }
}

func test_greeting_withService_shouldReturnFoo() {
  let sut = TestGreet()

  let resut = sut.greeting("dummy")

  XCTAssertEqual(resut, "foo")
}

```
