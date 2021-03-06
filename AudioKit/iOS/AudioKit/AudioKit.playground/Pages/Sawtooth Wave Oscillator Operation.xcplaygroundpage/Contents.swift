//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sawtooth Wave Oscillator Operation
//: ### Maybe the most annoying sound ever. Sorry.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Set up the operations that will be used to make a generator node

let freq = AKOperation.jitter(amplitude: 200, minimumFrequency: 1, maximumFrequency: 10) + 200
let amp  = AKOperation.randomVertexPulse(minimum: 0, maximum: 1, updateFrequency: 1)
let oscillator = AKOperation.sawtoothWave(frequency: freq, amplitude: amp)

//: Set up the nodes
let generator = AKOperationGenerator(operation: oscillator)

audiokit.audioOutput = generator
audiokit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
