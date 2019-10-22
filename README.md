# NotarizeProcess

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)

Utility object to launch `xcrun altool` to get notarization information.

## Notarize app

```swift
let process = NotarizeProcess(username: username, password: password)
let upload = try process.notarize(app: appArchiveURL, bundleID: "your.app.bundle.id")
```

## Get information about notarized app

```swift
let info = try process.notarizationInfo(for: upload) // or upload.requestUUID
```

## Get history and full information

```
let history = try process.notarizationHistory() // page: i
for item in history.items {
    let info = try process.notarizationInfo(for: item)
    print("\(info)")
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

![Dependencies graph](https://g.gravizo.com/svg?
 digraph DependenciesGraph {
 node [shape = box]
 "https://github.com/phimage/NotarizeProcess"[label="NotarizeProcess"]
 "https://github.com/phimage/NotarizationInfo"[label="NotarizationInfo"]
 "https://github.com/phimage/NotarizeProcess" -> "https://github.com/phimage/NotarizationInfo"
 "https://github.com/phimage/NotarizationAuditLog"[label="NotarizationAuditLog"]
 "https://github.com/phimage/NotarizeProcess" -> "https://github.com/phimage/NotarizationAuditLog"
}
)
