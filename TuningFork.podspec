
Pod::Spec.new do |s|
  s.name          = "TuningFork"
  s.version       = "0.2.0"
  s.summary       = "A Simple Tuner"
  s.description = <<-DESC
                  Allows for easy reading of pitch, frequency, amplitude, etc. from a device's microphone.
                  DESC
  s.homepage      = "https://github.com/comyarzaheri/TuningFork"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Comyar Zaheri" => "" }
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"
  s.source        = { :git => "https://github.com/comyarzaheri/TuningFork.git", :tag => s.version.to_s }
  s.source_files  = "TuningFork/*.{h,swift}", "TuningFork/**/*.{h,swift}"
  s.module_name   = "TuningFork"
  s.requires_arc  = true
  s.dependency 'AudioKit', '~> 4.1'
  s.dependency 'Chronos-Swift', '~> 0.3.0'
end
