//
//  AKFlatFrequencyResponseReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFlatFrequencyResponseReverbDSPKernel_hpp
#define AKFlatFrequencyResponseReverbDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "soundpipe.h"
}

enum {
    reverbDurationAddress = 0
};

class AKFlatFrequencyResponseReverbDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKFlatFrequencyResponseReverbDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_allpass_create(&allpass);
        sp_allpass_init(sp, allpass, internalLoopDuration);
        allpass->revtime = 0.5;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_allpass_destroy(&allpass);
        sp_destroy(&sp);
    }

    void reset() {
    }
    void setLoopDuration(float duration) {
        internalLoopDuration = duration;
    }
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case reverbDurationAddress:
                reverbDurationRamper.set(clamp(value, (float)0, (float)10));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case reverbDurationAddress:
                return reverbDurationRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case reverbDurationAddress:
                reverbDurationRamper.startRamp(clamp(value, (float)0, (float)10), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            double reverbDuration = double(reverbDurationRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            allpass->revtime = (float)reverbDuration;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_allpass_compute(sp, allpass, in, out);
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = 2;
    float sampleRate = 44100.0;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_allpass *allpass;
    
    float internalLoopDuration = 0.1;

public:
    bool started = true;
    AKParameterRamper reverbDurationRamper = 0.5;
};

#endif /* AKFlatFrequencyResponseReverbDSPKernel_hpp */
