//
//  AKRolandTB303Filter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Emulation of the Roland TB-303 filter
///
/// - parameter input: Input node to process
/// - parameter cutoffFrequency: Cutoff frequency. (in Hertz)
/// - parameter resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
/// - parameter distortion: Distortion. Value is typically 2.0; deviation from this can cause stability issues.
/// - parameter resonanceAsymmetry: Asymmetry of resonance. Value is between 0-1
///
public class AKRolandTB303Filter: AKNode, AKToggleable {

    // MARK: - Properties


    internal var internalAU: AKRolandTB303FilterAudioUnit?
    internal var token: AUParameterObserverToken?

    private var cutoffFrequencyParameter: AUParameter?
    private var resonanceParameter: AUParameter?
    private var distortionParameter: AUParameter?
    private var resonanceAsymmetryParameter: AUParameter?

    /// Cutoff frequency. (in Hertz)
    public var cutoffFrequency: Double = 500 {
        willSet(newValue) {
            if cutoffFrequency != newValue {
                cutoffFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    public var resonance: Double = 0.5 {
        willSet(newValue) {
            if resonance != newValue {
                resonanceParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Distortion. Value is typically 2.0; deviation from this can cause stability issues.
    public var distortion: Double = 2.0 {
        willSet(newValue) {
            if distortion != newValue {
                distortionParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Asymmetry of resonance. Value is between 0-1
    public var resonanceAsymmetry: Double = 0.5 {
        willSet(newValue) {
            if resonanceAsymmetry != newValue {
                resonanceAsymmetryParameter?.setValue(Float(newValue), originator: token!)
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
    /// - parameter cutoffFrequency: Cutoff frequency. (in Hertz)
    /// - parameter resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    /// - parameter distortion: Distortion. Value is typically 2.0; deviation from this can cause stability issues.
    /// - parameter resonanceAsymmetry: Asymmetry of resonance. Value is between 0-1
    ///
    public init(
        _ input: AKNode,
        cutoffFrequency: Double = 500,
        resonance: Double = 0.5,
        distortion: Double = 2.0,
        resonanceAsymmetry: Double = 0.5) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.distortion = distortion
        self.resonanceAsymmetry = resonanceAsymmetry

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x74623366 /*'tb3f'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKRolandTB303FilterAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKRolandTB303Filter",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKRolandTB303FilterAudioUnit

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        cutoffFrequencyParameter    = tree.valueForKey("cutoffFrequency")    as? AUParameter
        resonanceParameter          = tree.valueForKey("resonance")          as? AUParameter
        distortionParameter         = tree.valueForKey("distortion")         as? AUParameter
        resonanceAsymmetryParameter = tree.valueForKey("resonanceAsymmetry") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.cutoffFrequencyParameter!.address {
                    self.cutoffFrequency = Double(value)
                } else if address == self.resonanceParameter!.address {
                    self.resonance = Double(value)
                } else if address == self.distortionParameter!.address {
                    self.distortion = Double(value)
                } else if address == self.resonanceAsymmetryParameter!.address {
                    self.resonanceAsymmetry = Double(value)
                }
            }
        }
        cutoffFrequencyParameter?.setValue(Float(cutoffFrequency), originator: token!)
        resonanceParameter?.setValue(Float(resonance), originator: token!)
        distortionParameter?.setValue(Float(distortion), originator: token!)
        resonanceAsymmetryParameter?.setValue(Float(resonanceAsymmetry), originator: token!)
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
