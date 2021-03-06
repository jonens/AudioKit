//
//  AKWhiteNoiseDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKWhiteNoiseDSPKernel_hpp
#define AKWhiteNoiseDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "soundpipe.h"
}

enum {
    amplitudeAddress = 0
};

class AKWhiteNoiseDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKWhiteNoiseDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_noise_create(&noise);
        sp_noise_init(sp, noise);
        noise->amp = 1;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_noise_destroy(&noise);
        sp_destroy(&sp);
    }

    void reset() {
    }
    
    void setAmplitude(float amp) {
        amplitude = amp;
        amplitudeRamper.set(clamp(amp, (float)0, (float)10));
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case amplitudeAddress:
                amplitudeRamper.set(clamp(value, (float)0, (float)1));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case amplitudeAddress:
                return amplitudeRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

        }
    }

    void setBuffer(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            double amplitude = double(amplitudeRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            noise->amp = (float)amplitude;

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_noise_compute(sp, noise, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = 2;
    float sampleRate = 44100.0;

    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_noise *noise;
    
    float amplitude = 1;

public:
    bool started = false;
    AKParameterRamper amplitudeRamper = 1;
};

#endif /* AKWhiteNoiseDSPKernel_hpp */
