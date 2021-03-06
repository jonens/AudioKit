//
//  AKTesterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTesterDSPKernel_hpp
#define AKTesterDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "soundpipe.h"
#include "md5.h"
#include "test.h"
}


class AKTesterDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKTesterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);
    }

    void setSamples(UInt32 numberOfSamples)  {
        totalSamples = numberOfSamples;
        sp_test_create(&sp_test, numberOfSamples);
    }
    
    NSString *getMD5() {
        md5 = [@"" cStringUsingEncoding:NSUTF8StringEncoding];
        sp_test_compare(sp_test, md5);
        return [NSString stringWithCString:sp_test->md5 encoding:NSUTF8StringEncoding];
    }
    int getSamples() {
        return samples;
    }
    
    void start() {
        started = true;
    }
    
    void stop() {
        started = false;
    }
    
    void destroy() {
        sp_test_destroy(&sp_test);
    }
    
    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);
            
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started && samples < totalSamples) {
                    sp_test_add_sample(sp_test, (SPFLOAT)*in);
                    samples++;
                }
                // Suppress output
                *out = 0;
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = 2;
    float sampleRate = 44100.0;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_test *sp_test = nil;
    UInt32 samples = 0;
    UInt32 totalSamples = 0;
    const char *md5;
    
public:
    bool started = true;
};

#endif /* AKTesterDSPKernel_hpp */
