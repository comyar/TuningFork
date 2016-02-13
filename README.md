![](header.png)

### Overview
[![Build Status](https://travis-ci.org/comyarzaheri/TuningFork.svg?branch=master)](https://travis-ci.org/comyarzaheri/TuningFork)
[![Version](http://img.shields.io/cocoapods/v/TuningFork.svg)](http://cocoapods.org/?q=TuningFork)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/comyarzaheri/TuningFork)
[![License](http://img.shields.io/cocoapods/l/TuningFork.svg)](https://github.com/comyarzaheri/TuningFork/blob/master/LICENSE)

TuningFork is a simple utility for processing microphone input and interpreting pitch, frequency, amplitude, etc. 

TuningFork powers the [Partita](https://github.com/comyarzaheri/Partita) instrument tuner app.

# Usage 

### Quick Start

##### CocoaPods

Add the following to your Podfile:

```ruby
pod 'TuningFork'
```
##### Carthage 

Add the following to your Cartfile:

```ruby
github "comyarzaheri/TuningFork" "master"
```

### Using a Tuner

```swift
import TuningFork

class MyTunerDelegate: TunerDelegate {
	func tunerDidUpdate(tuner: Tuner, output: TunerOutput) {
		// Dreams come true here
		print(output.pitch, output.octave) 
	}
}

let tuner = Tuner()
let delegate = MyTunerDelegate()
tuner.delegate = delegate
tuner.start()
```

# License 

TuningFork is available under the [MIT License](LICENSE).

# Contributors

* [@comyarzaheri](https://github.com/comyarzaheri)
