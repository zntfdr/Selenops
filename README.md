# Selenops
<p align="center">
    <img src="logo.png" width="580" max-width="90%" alt="Swift Web Crawler in action" />
    <br/>
    <img src="https://img.shields.io/badge/swift-5.1-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
     <img src="https://img.shields.io/badge/platforms-macOS+iOS+iPadOS+tvOS-brightgreen.svg?style=flat" alt="MacOS + iOS + iPadOS + tvOS + watchOS"/>
    <a href="https://twitter.com/zntfdr">
        <img src="https://img.shields.io/badge/twitter-@zntfdr-blue.svg?style=flat" alt="Twitter: @zntfdr" />
    </a>
</p>

Welcome to **Selenops**, a simple Swift Web Crawler.

## Installation

Selenops is distributed via the [Swift Package Manager](https://swift.org/package-manager):  

- to use it into an app, follow [this tutorial](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) and use this repository URL: `https://github.com/zntfdr/Selenops.git`.

- to use it in a package, add it as a dependency in your `Package.swift`:
```swift
 let package = Package(
     ...
     dependencies: [
         .package(url: "https://github.com/zntfdr/Selenops.git", from: "1.0.0")
     ],
     targets: [
        .target(
            ...
            dependencies: ["SelenopsCore"])
     ],
     ...
 )
```
  and then use `import SelenopsCore` whenever necessary.

## How to Run Selenops 🕷
<p align="center">
    <img src="screenshot.png" width="680" max-width="90%" alt="Swift Web Crawler in action" />
</p>

* Xcode Swift Playground  
  Open the ``.playground`` project with Xcode.
  
* Swift Script  
  Make ``Script/Selenops.swift`` executable: ``$ chmod +x Script/Selenops.swift``  
  
  Run it: ``$ Script/Selenops.swift``.  
  
  

## Author 🕸
[Federico Zanetello](https://github.com/zntfdr) ([@zntfdr](https://twitter.com/zntfdr))
