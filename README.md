![](header.png)

### Overview

TuningFork is a simple utility for processing microphone input and interpreting pitch, frequency, amplitude, etc. 

# Usage 

### Quick Start

##### Cocoa Pods

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
