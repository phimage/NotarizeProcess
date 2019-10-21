# NotarizeProcess

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)

Utility object to launch `xcrun altool` to get notarization information.

```swift
let process = NotarizeProcess(username: username, password: password)

let history = try process.notarizationHistory()
for item in history.items {
   if let id = item.requestUUID {
       let info = try process.notarizationInfo(for: id)
       print("\(info)")
   }
}
```
