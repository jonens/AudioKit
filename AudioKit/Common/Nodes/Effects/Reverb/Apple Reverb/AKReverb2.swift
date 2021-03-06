//
//  AKReverb2.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's Reverb2 Audio Unit
///
/// - parameter input: Input node to process
/// - parameter dryWetMix: Dry Wet Mix (CrossFade) ranges from 0 to  (Default: 0.5)
/// - parameter gain: Gain (Decibels) ranges from -20 to 20 (Default: 0)
/// - parameter minDelayTime: Min Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.008)
/// - parameter maxDelayTime: Max Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.050)
/// - parameter decayTimeAt0Hz: Decay Time At0 Hz (Secs) ranges from 0.001 to 20.0 (Default: 1.0)
/// - parameter decayTimeAtNyquist: Decay Time At Nyquist (Secs) ranges from 0.001 to 20.0 (Default: 0.5)
/// - parameter randomizeReflections: Randomize Reflections (Integer) ranges from 1 to 1000 (Default: 1)
///
public class AKReverb2: AKNode, AKToggleable {

    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_Reverb2,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU = AudioUnit()

    private var lastKnownMix: Double = 50
    
    /// Dry Wet Mix (CrossFade) ranges from 0 to 1 (Default: 0.5)
    public var dryWetMix: Double = 0.5 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }            
            if dryWetMix > 1 {
                dryWetMix = 1
            }
            AudioUnitSetParameter(
                internalAU,
                kReverb2Param_DryWetMix,
                kAudioUnitScope_Global, 0,
                Float(dryWetMix * 100.0), 0)
        }
    }

    /// Gain (Decibels) ranges from -20 to 20 (Default: 0)
    public var gain: Double = 0 {
        didSet {
            if gain < -20 {
                gain = -20
            }            
            if gain > 20 {
                gain = 20
            }
            AudioUnitSetParameter(
                internalAU,
                kReverb2Param_Gain,
                kAudioUnitScope_Global, 0,
                Float(gain), 0)
        }
    }

    /// Min Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.008)
    public var minDelayTime: Double = 0.008 {
        didSet {
            if minDelayTime < 0.0001 {
                minDelayTime = 0.0001
            }            
            if minDelayTime > 1.0 {
                minDelayTime = 1.0
            }
            AudioUnitSetParameter(
                internalAU,
                kReverb2Param_MinDelayTime,
                kAudioUnitScope_Global, 0,
                Float(minDelayTime), 0)
        }
    }

    /// Max Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.050)
    public var maxDelayTime: Double = 0.050 {
        didSet {
            if maxDelayTime < 0.0001 {
                maxDelayTime = 0.0001
            }            
            if maxDelayTime > 1.0 {
                maxDelayTime = 1.0
            }
            AudioUnitSetParameter(
                internalAU,
                kReverb2Param_MaxDelayTime,
                kAudioUnitScope_Global, 0,
                Float(maxDelayTime), 0)
        }
    }

    /// Decay Time At0 Hz (Secs) ranges from 0.001 to 20.0 (Default: 1.0)
    public var decayTimeAt0Hz: Double = 1.0 {
        didSet {
            if decayTimeAt0Hz < 0.001 {
                decayTimeAt0Hz = 0.001
            }            
            if decayTimeAt0Hz > 20.0 {
                decayTimeAt0Hz = 20.0
            }
            AudioUnitSetParameter(
                internalAU,
                kReverb2Param_DecayTimeAt0Hz,
                kAudioUnitScope_Global, 0,
                Float(decayTimeAt0Hz), 0)
        }
    }

    /// Decay Time At Nyquist (Secs) ranges from 0.001 to 20.0 (Default: 0.5)
    public var decayTimeAtNyquist: Double = 0.5 {
        didSet {
            if decayTimeAtNyquist < 0.001 {
                decayTimeAtNyquist = 0.001
            }            
            if decayTimeAtNyquist > 20.0 {
                decayTimeAtNyquist = 20.0
            }
            AudioUnitSetParameter(
                internalAU,
                kReverb2Param_DecayTimeAtNyquist,
                kAudioUnitScope_Global, 0,
                Float(decayTimeAtNyquist), 0)
        }
    }

    /// Randomize Reflections (Integer) ranges from 1 to 1000 (Default: 1)
    public var randomizeReflections: Double = 1 {
        didSet {
            if randomizeReflections < 1 {
                randomizeReflections = 1
            }            
            if randomizeReflections > 1000 {
                randomizeReflections = 1000
            }
            AudioUnitSetParameter(
                internalAU,
                kReverb2Param_RandomizeReflections,
                kAudioUnitScope_Global, 0,
                Float(randomizeReflections), 0)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the reverb2 node
    ///
    /// - parameter input: Input node to process
    /// - parameter dryWetMix: Dry Wet Mix (CrossFade) ranges from 0 to 1 (Default: 0.5)
    /// - parameter gain: Gain (Decibels) ranges from -20 to 20 (Default: 0)
    /// - parameter minDelayTime: Min Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.008)
    /// - parameter maxDelayTime: Max Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.050)
    /// - parameter decayTimeAt0Hz: Decay Time At0 Hz (Secs) ranges from 0.001 to 20.0 (Default: 1.0)
    /// - parameter decayTimeAtNyquist: Decay Time At Nyquist (Secs) ranges from 0.001 to 20.0 (Default: 0.5)
    /// - parameter randomizeReflections: Randomize Reflections (Integer) ranges from 1 to 1000 (Default: 1)
    ///
    public init(
        _ input: AKNode,
        dryWetMix: Double = 0.5,
        gain: Double = 0,
        minDelayTime: Double = 0.008,
        maxDelayTime: Double = 0.050,
        decayTimeAt0Hz: Double = 1.0,
        decayTimeAtNyquist: Double = 0.5,
        randomizeReflections: Double = 1) {

            self.dryWetMix = dryWetMix
            self.gain = gain
            self.minDelayTime = minDelayTime
            self.maxDelayTime = maxDelayTime
            self.decayTimeAt0Hz = decayTimeAt0Hz
            self.decayTimeAtNyquist = decayTimeAtNyquist
            self.randomizeReflections = randomizeReflections

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            
            super.init()
            self.avAudioNode = internalEffect
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
            internalAU = internalEffect.audioUnit

            AudioUnitSetParameter(internalAU, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, Float(dryWetMix * 100.0), 0)
            AudioUnitSetParameter(internalAU, kReverb2Param_Gain, kAudioUnitScope_Global, 0, Float(gain), 0)
            AudioUnitSetParameter(internalAU, kReverb2Param_MinDelayTime, kAudioUnitScope_Global, 0, Float(minDelayTime), 0)
            AudioUnitSetParameter(internalAU, kReverb2Param_MaxDelayTime, kAudioUnitScope_Global, 0, Float(maxDelayTime), 0)
            AudioUnitSetParameter(internalAU, kReverb2Param_DecayTimeAt0Hz, kAudioUnitScope_Global, 0, Float(decayTimeAt0Hz), 0)
            AudioUnitSetParameter(internalAU, kReverb2Param_DecayTimeAtNyquist, kAudioUnitScope_Global, 0, Float(decayTimeAtNyquist), 0)
            AudioUnitSetParameter(internalAU, kReverb2Param_RandomizeReflections, kAudioUnitScope_Global, 0, Float(randomizeReflections), 0)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }
}
