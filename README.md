# DebugView

[![CI Status](https://img.shields.io/travis/dankinsoid/DebugView.svg?style=flat)](https://travis-ci.org/dankinsoid/DebugView)
[![Version](https://img.shields.io/cocoapods/v/DebugView.svg?style=flat)](https://cocoapods.org/pods/DebugView)
[![License](https://img.shields.io/cocoapods/l/DebugView.svg?style=flat)](https://cocoapods.org/pods/DebugView)
[![Platform](https://img.shields.io/cocoapods/p/DebugView.svg?style=flat)](https://cocoapods.org/pods/DebugView)


## Description
This repository provides

## Example

```swift

```
## Usage

 
## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/DebugView.git", from: "0.1.0")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["DebugView"])
  ]
)
```
```ruby
$ swift build
```

2.  [CocoaPods](https://cocoapods.org)

Add the following line to your Podfile:
```ruby
pod 'DebugView'
```
and run `pod update` from the podfile directory first.

## Author

dankinsoid, voidilov@gmail.com

## License

DebugView is available under the MIT license. See the LICENSE file for more info.
