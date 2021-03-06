//
//  AKCombFilterReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This filter reiterates input with an echo density determined by
/// loopDuration. The attenuation rate is independent and is determined by
/// reverbDuration, the reverberation duration (defined as the time in seconds
/// for a signal to decay to 1/1000, or 60dB down from its original amplitude).
/// Output from a comb filter will appear only after loopDuration seconds.
///
/// - parameter input: Input node to process
/// - parameter reverbDuration: The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
/// - parameter loopDuration: The loop time of the filter, in seconds. This can also be thought of as the delay time. Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2.
///
public class AKCombFilterReverb: AKNode, AKToggleable {

    // MARK: - Properties


    internal var internalAU: AKCombFilterReverbAudioUnit?
    internal var token: AUParameterObserverToken?

    private var reverbDurationParameter: AUParameter?

    /// The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
    public var reverbDuration: Double = 1.0 {
        willSet(newValue) {
            if reverbDuration != newValue {
                reverbDurationParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter reverbDuration: The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
    /// - parameter loopDuration: The loop time of the filter, in seconds. This can also be thought of as the delay time. Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2.
    ///
    public init(
        _ input: AKNode,
        reverbDuration: Double = 1.0,
        loopDuration: Double = 0.1) {

        self.reverbDuration = reverbDuration

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x636f6d62 /*'comb'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKCombFilterReverbAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKCombFilterReverb",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKCombFilterReverbAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
            self.internalAU!.setLoopDuration(Float(loopDuration))
        }

        guard let tree = internalAU?.parameterTree else { return }

        reverbDurationParameter = tree.valueForKey("reverbDuration") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.reverbDurationParameter!.address {
                    self.reverbDuration = Double(value)
                }
            }
        }
        reverbDurationParameter?.setValue(Float(reverbDuration), originator: token!)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}
