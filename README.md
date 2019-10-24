# NotarizeProcess

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)

Utility object to launch `xcrun altool` to notarize app and get notarization information.

## Notarize app

```swift
let process = NotarizeProcess(username: username, password: password)
let upload = try process.notarize(app: appArchiveURL, bundleID: "your.app.bundle.id")
```

### or for .app

An archive will be created using ditto.

```swift
let upload = try process.notarize(app: appURL, bundleID: "")
```
If the `bundleID` argument is empty, we extract it from the .app Info.plist.
 
## Get information about notarized app

```swift
let info = try process.notarizationInfo(for: upload) // or upload.requestUUID
```

You can also wait for the final result

```swift
let info = try process.waitForNotarizationInfo(for: upload, timeout: 30 * 60)
```

## Get history

```swift
let history = try process.notarizationHistory() // page: i
```

### and full information

```swift
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

## Stapler

### Staple

```swift
try process.staple(app: appURL)
```
### Validate

```swift
try process.validate(app: appURL)
```

## All in one

```swift
try process.run(action: [.notarize, .wait, .staple] /*.all*/, on: appURL)
try process.run(action: .all, on: appURL)
try process.run(on: appURL)
```

## Dependencies

![Dependencies graph](https://g.gravizo.com/svg?%20digraph%20DependenciesGraph%20{%20node%20[shape%20=%20box]%20%22https://github.com/phimage/NotarizeProcess%22[label=%22NotarizeProcess%22]%20%22https://github.com/phimage/NotarizationInfo%22[label=%22NotarizationInfo%22]%20%22https://github.com/phimage/NotarizeProcess%22%20-%3E%20%22https://github.com/phimage/NotarizationInfo%22%20%22https://github.com/phimage/NotarizationAuditLog%22[label=%22NotarizationAuditLog%22]%20%22https://github.com/phimage/NotarizeProcess%22%20-%3E%20%22https://github.com/phimage/NotarizationAuditLog%22%20})

* [NotarizationInfo](https://github.com/phimage/NotarizationInfo)
* [NotarizationAuditLog](https://github.com/phimage/NotarizationAuditLog)
