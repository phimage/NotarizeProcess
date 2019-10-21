# NotarizeProcess

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)

Utility object to launch `xcrun altool` to get notarization information.


## Get history or information

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

## Get audit log from information

```swift
let info = try process.notarizationInfo(for: id)
let publisher = info.auditLogPublisher() // using Combine framework

_ = publisher.sink(receiveCompletion: { completion in
...
}) { auditLog in
...
}
```

## Dependencies

* [NotarizationInfo](https://github.com/phimage/NotarizationInfo)
* [NotarizationAuditLog](https://github.com/phimage/NotarizationAuditLog)
