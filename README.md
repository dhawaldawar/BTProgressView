# BTProgressView

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/DialogBox.svg?style=flat)](http://cocoapods.org/pods/DialogBox)
[![Platform](https://img.shields.io/cocoapods/p/DialogBox.svg?style=flat)](http://cocoapods.org/pods/DialogBox)

This framework provides a way to build spring based progress bar animation by writing view lines of code with easy theme customization.

## Example

<img src="example.gif" width="368" height="502"/>

```swift
let progressView = BTProgressView()
// Add autolayout constraints.
view.addSubview(progressView)
progressView.load()
```

Following customization options available:
```swift
progressView.barColor
progressView.progressColor
progressView.iconBgColor
progressView.iconColor
progressView.doneTitleColor
progressView.failedTitleColor
```

## Installation
### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. A minimum version of `0.17` is required.

To install, simply add the following lines to your Cartfile:

```ruby
github "dhawaldawar/BTProgressView" ~> 1.0.0
```

## Author

Dhawal Dawar, dawar.dhawal@gmail.com

## License

BTProgressView is available under the MIT license. See the LICENSE file for more info.
