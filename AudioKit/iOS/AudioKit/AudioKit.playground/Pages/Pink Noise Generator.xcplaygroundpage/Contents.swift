//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Pink Noise
//: 
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
var noise = AKPinkNoise(amplitude: 0.0)
audiokit.audioOutput = noise
audiokit.start()
noise.start()

//: This is a timer that will change the amplitude of the pink noise


var t = 0.0
let timeStep = 0.02

AKPlaygroundLoop(every: timeStep) {
    
    //: Vary the amplitude between zero and 1 in a sinusoid at 0.5Hz
    let amplitudeModulationHz = 0.5
    let amp = (1.0 - cos(2 * 3.14 * amplitudeModulationHz * t)) * 0.5 // Click the eye to see a graph view
    noise.amplitude = amp
    
    t = t + timeStep
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
