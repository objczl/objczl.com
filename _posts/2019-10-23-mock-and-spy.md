---
layout: post
title: Test Double in Swift - Mock and Spy
date: 2019-09-19
author: # see _config.yml
categories: []
---

> Mock and Spy, use to test interactions between objects. We capture the
> indirect outputs or inputs of the SUT as they occur and compare.

![Could you make it as a spy?](https://cl.ly/36cff650e1b4/mock-and-spy.jpg)

* How do we make tests self-checking when there is no state to verify?
* How do we implement behavior verification for indirect outputs of the SUT?
* How can we verify logic independently when sut depends on indirect inputs from
  dependency?

Replace an object the system under test (SUT) depends on with a test-specific
object that verifies it is being used correctly by the SUT. They are useful
in cases where there are no other visible state changes or return results that
you can verify.

> You should begin with the state vs behavior verification.

The difference between a `Test Spy` and a `Mock Object` is where the assertions
live. Spy's verification is placed in the test case. Let’s create a verification
method inside the Test Double that calls the assertions for us that is mock.

## Spy

A Test Spy records the method calls it receives. It lets us verify the
communication between components.


### 1. Extracting a Protocol to Support Test Doubles

```swift
protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}
```

### 2. Write a test spy that implement the protocol `URLSessionProtocol`

```swift
// Create a Test Spy which records how it's called
//
// A test spy records calls to its method. Tests can then confirm whether the
// `SUT` made the expected call.
//
// For each method in a test spy:
//
// * Capture the call count by incrementing an integer.
// * Capture any arguments by appending them to array
class SpyURLSession: URLSessionProtocol {
    var dataTaskCallCount: Int = 0
    var dataTaskArgsRequest: [URLRequest] = []
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(request)
        return DummyURLSessionDataTask()
    }
}
```

```swift
class DummyURLSessionDataTask: URLSessionDataTask {
    override func resume() { }
}
```

### 3. Verify `Spy` communication with `SUT`

```swift
let sessionSpy: SpyURLSession = SpyURLSession()
sut.session = sessionSpy

sut.doSomething()

XCTAssertEqual(sessionSpy.dataTaskCallCount, 1, "call count")
XCTAssertEqual(sessionSpy.dataTaskArgsRequest.first, URLRequest(url: URL(string: "https://foo")!), "request")
```

## Mock

A Mock Object is a Test Spy that does its assertions. It also gives us
opportunities to improve failure reporting.


> Difference between a test spy and a mock object is where the assertions live.

### 1. Promoting the Test Spy into a Mock Object

```swift
class MockURLSession: URLSessionProtocol {
  ...
}
```

### 2. Add verification method inside the test double (call the assertions for us)

```swift
class MockURLSession: URLSessionProtocol {
    func verifyDataTask(with request: URLRequest,
                        file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(dataTaskCallCount, 1, "call count", file: file, line: line)
        XCTAssertEqual(dataTaskArgsURLRequest.first, request, "request", file: file, line: line)
    }
}
```

### 3. Improve mock object reporting

```swift
class MockURLSession: URLSessionProtocol {
    func verifyDataTask(with request: URLRequest,
                        file: StaticString = #file, line: UInt = #line) {
        guard dataTaskWasCalledOnce(file: file, line: line) else { return }
        XCTAssertEqual(dataTaskArgsURLRequest.first, request, "request", file: file, line: line)
    }

    private func dataTaskWasCalledOnce(
            file: StaticString = #file, line: UInt = #line) -> Bool {
        return verifyMethodCalledOnce(
                methodName: "dataTask(with:completionHandler:)",
                callCount: dataTaskCallCount,
                describeArguments: "request: \(dataTaskArgsURLRequest)",
                file: file,
                line: line)
    }
}
```

```swift
func verifyMethodCalledOnce(
        methodName: String,
        callCount: Int,
        describeArguments: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line) -> Bool {
    if callCount == 0 {
        XCTFail("Wanted but not invoked: \(methodName)",
                file: file, line: line)
        return false
    }
    if callCount > 1 {
        XCTFail("Wanted 1 time but was called \(callCount) times. " +
                "\(methodName) with \(describeArguments())",
                file: file, line: line)
        return false
    }
    return true
}
```

### 4. Verify communication according to verification method in the `Mock`

```swift
let mockSession: MockURLSession = MockURLSession()
sut.session = mockSession

sut.doSomething()

mockSession.verifyDataTask(with: URLRequest(url: URL(string: "https://foo")!))
```
## References

[Mocks Aren't Stubs](https://martinfowler.com/articles/mocksArentStubs.html),
[Mock Object](http://xunitpatterns.com/Mock%20Object.html),
[Behavior Verification](http://xunitpatterns.com/Behavior%20Verification.html)

