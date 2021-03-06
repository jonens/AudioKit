AudioKit V3
===

[![Build Status](https://travis-ci.org/audiokit/AudioKit.svg)](https://travis-ci.org/audiokit/AudioKit)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](http://cocoadocs.org/docsets/AudioKit)


*This document was last updated: January 20, 2016*

AudioKit is an audio synthesis, processing, and analysis platform for OS X, iOS, and tvOS. This document serves as a one-page introduction to AudioKit, but we have much more information available on the AudioKit website at http://audiokit.io/

### Version 3.0
The third major revision of AudioKit has been completely rewritten to offer the following improvements over previous versions:

* Installation as a framework
* Integrated with CoreAudio audio units from Apple
* No external dependencies
* Can use opcodes from Faust, Chuck, STK, Csound, and others
* Many included Xcode Swift playgrounds

and quite a bit more. There are things that version 2 had that are not yet part of version 3, but rather than trying to support version 2, let us know what you need to do, and we'll port it over to version 3 upon request.

## Key Concepts

### Nodes
Nodes are interconnectable signal processing components.  Each node has at least an ouput and most likely also has parameters.  If it is processing another signal, the node will also have an input.

### Operations
Operations are similar to nodes, except that they are a series of signal processing components that exist inside of a single node.  Operations can be used as parameters to other operations to create very complex processing results.

## Installation

Installation can be achieved in the usual ways for a framework.  This is explained in more detail in the INSTALL.md file in the Frameworks directory.

Installation with CocoaPods and Carthage is also planned but may not come with the first release.

## Example Code
There are three Hello World projects, one for each of the Apple platforms: OSX, iOS, and tvOS. They simply play an oscillator and display the waveform.  Hello World basically consists of just a few sections of code:

Setting up AudioKit:

    let audiokit = AKManager.sharedInstance

Creating the sound, in this case an oscillator:

    var oscillator = AKOscillator()

Telling AudioKit where to get its audio from (ie. the oscillator):

    audiokit.audioOutput = oscillator

Starting AudioKit:

        audiokit.start()

And then responding to the UI by changing the oscillator:

        if oscillator.isPlaying {
            oscillator.stop()
        } else {
            oscillator.amplitude = random(0.5, 1)
            oscillator.frequency = random(220, 880)
            oscillator.start()
        }

## Playgrounds

Because Playgrounds have very different capabilities depending on whether they are for OSX or iOS, we have two sets of playgrounds for each OS.  At this point tvOS behaves very much like iOS so there is no set of playgrounds explicitly for tvOS.

### AudioKit for iOS Playgrounds
There are many playground pages within the AudioKit for iOS Playground.  Each playground includes a demo of a node or operation or an example of sound design.  The first playground is a Table of Contents in which the playgrounds are organized via markup.  The playground may also be opened up to view the playgrounds alphabetically.

### AudioKit for OS X Playgrounds
OS X Playgrounds are able to launch NSWindows that can be used to control the AudioKit effects processors, so these playgrounds have a UI that allow you to adjust the parameters of an effect very easily.  However, OS X playgrounds at this point do not support AudioKit nodes that do not use Apple AudioUnit processors, so there are fewer things that we can demonstrate in OSX playgrounds.  Hopefully this will be fixed in the future - it is unclear whether the problem is in AudioKit or within the Xcode playground audio implementation.

## Tests

So far, the only testing that we do automatically through Travis is to ensure that all of the projects included with AudioKit build successfully.  AudioKit version 2 was heavily tested, but at the time of this writing AudioKit 3 does not have a test suite in place.  This is high on our priority list after an initial release.

## About Us

AudioKit was created by the following team whose contributions are fully chronicled in Github, and summarized below in alphabetical order by first name:

* Aurelius Prochazka: Primary programmer of AudioKit. Lives for this stuff.  Your life line if you need help.
* Jeff Cooper: Rearchitected all things MIDI, sampler, and sequencer related in AudioKit 3.
* Matthew Fecher: Sound design, graphic design, and programming of the Swift Synth example.
* Nicholas Arner: Longtime contributor to AudioKit and AudioKit's web site.
* Paul Batchelor: The author of [Soundpipe](https://www.github.com/paulbatchelor/soundpipe), and [Sporth](http://www.github.com/paulbatchelor/sporth), which serve as two primary audio engines in AudioKit 3.
* Simon Gladman: Longtime user of AudioKit, contributed his AudioKitParticles project to AudioKit 3.
* Stephane Peter: Installation and configuration czar and code reviewer.
* Syed Haris Ali: The author of EZAudio which is AudioKit's included waveform plotter and FFT analysis engine.
