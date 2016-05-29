#import "Superpowered.h"
#import "SuperpoweredAdvancedAudioPlayer.h"
#import "SuperpoweredReverb.h"
#import "SuperpoweredFilter.h"
#import "Superpowered3BandEQ.h"
#import "SuperpoweredEcho.h"
#import "SuperpoweredRoll.h"
#import "SuperpoweredFlanger.h"
#import "SuperpoweredMixer.h"
#import "SuperpoweredIOSAudioOutput.h"
#import "fftTest.h"
#import "SuperpoweredBandpassFilterbank.h"
#import <mach/mach_time.h>

/*
 This is a .mm file, meaning it's Objective-C++. 
 You can perfectly mix it with Objective-C or Swift, until you keep the member variables and C++ related includes here.
 Yes, the header file (.h) isn't the only place for member variables.
 */
@implementation Superpowered {
    SuperpoweredAdvancedAudioPlayer *player;
    SuperpoweredFX *effects[NUMFXUNITS];
    SuperpoweredStereoMixer *mixer;
    SuperpoweredIOSAudioOutput *output;
    SuperpoweredBandpassFilterbank *filters;
    float *stereoBuffer;
    bool started;
    uint64_t timeUnitsProcessed, maxTime;
    pthread_mutex_t mutex;
    float bands[16];
    unsigned int lastPositionSeconds, lastSamplerate, samplesProcessed,samplesProcessedForOneDisplayFrame;
}

- (void)dealloc {
    delete player;
    delete mixer;
    for (int n = 2; n < NUMFXUNITS; n++) delete effects[n];
    free(stereoBuffer);
#if !__has_feature(objc_arc)
    [output release];
    [super dealloc];
#endif
}

// Called periodically by ViewController to update the user interface.
- (void)updatePlayerLabel:(UILabel *)label slider:(UISlider *)slider button:(UIButton *)button {
    bool tracking = slider.tracking;
    unsigned int positionSeconds = tracking ? int(float(player->durationSeconds) * slider.value) : player->positionSeconds;
    
    if (positionSeconds != lastPositionSeconds) {
        lastPositionSeconds = positionSeconds;
        NSString *str = [[NSString alloc] initWithFormat:@"%02d:%02d %02d:%02d", player->durationSeconds / 60, player->durationSeconds % 60, positionSeconds / 60, positionSeconds % 60];
        label.text = str;
#if !__has_feature(objc_arc)
        [str release];
#endif
    };

    if (!button.tracking && (button.selected != player->playing)) button.selected = player->playing;
    if (!tracking && (slider.value != player->positionPercent)) slider.value = player->positionPercent;
}

- (bool)toggleFx:(int)index {
    if (index == TIMEPITCHINDEX) {
        bool enabled = (player->tempo != 1.0f);
        player->setTempo(enabled ? 1.0f : 1.1f, true);
        return !enabled;
    } else if (index == PITCHSHIFTINDEX) {
        bool enabled = (player->pitchShift != 0);
        player->setPitchShift(enabled ? 0 : 1);
        return !enabled;
    } else {
        bool enabled = effects[index]->enabled;
        effects[index]->enable(!enabled);
        return !enabled;
    };
}

- (void)togglePlayback { // Play/pause. 
    player->togglePlayback();
}

- (void)seekTo:(float)percent {
    player->seek(percent);
}

- (void)toggle {
    if (started) [output stop]; else [output start];
    started = !started;
}

- (void)interruptionEnded {
    player->onMediaserverInterrupt(); // If the player plays Apple Lossless audio files, then we need this. Otherwise unnecessary.
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    return self;
}

-(void) addSongWithName: (NSString*)songName fileType:(NSString*) type{
    SuperpoweredFFTTest();
    
    started = false;
    lastPositionSeconds = lastSamplerate = samplesProcessed = timeUnitsProcessed = maxTime = avgUnitsPerSecond = maxUnitsPerSecond = 0;
    if (posix_memalign((void **)&stereoBuffer, 16, 4096 + 128) != 0) abort(); // Allocating memory, aligned to 16.
    
    // Create the Superpowered units we'll use.
    player = new SuperpoweredAdvancedAudioPlayer(NULL, NULL, 44100, 0);
    player->open([[[NSBundle mainBundle] pathForResource:songName ofType:type] fileSystemRepresentation]);
    player->play(false);
    player->setBpm(124.0f);
    self.bpm = player->currentBpm;
    
    SuperpoweredFilter *filter = new SuperpoweredFilter(SuperpoweredFilter_Resonant_Lowpass, 44100);
    filter->setResonantParameters(1000.0f, 0.1f);
    effects[FILTERINDEX] = filter;
    
    effects[ROLLINDEX] = new SuperpoweredRoll(44100);
    effects[FLANGERINDEX] = new SuperpoweredFlanger(44100);
    
    SuperpoweredEcho *delay = new SuperpoweredEcho(44100);
    delay->setMix(0.8f);
    effects[DELAYINDEX] = delay;
    
    SuperpoweredReverb *reverb = new SuperpoweredReverb(44100);
    reverb->setRoomSize(0.5f);
    reverb->setMix(0.3f);
    effects[REVERBINDEX] = reverb;
    
    Superpowered3BandEQ *eq = new Superpowered3BandEQ(44100);
    eq->bands[0] = 2.0f;
    eq->bands[1] = 0.5f;
    eq->bands[2] = 2.0f;
    effects[EQINDEX] = eq;
    
    mixer = new SuperpoweredStereoMixer();
    
    float frequencies[16] = { 55,77, 110,155, 220,311, 440, 622, 880,1244, 1760,2489, 3520,4978, 7040,9956 };
    float widths[16] = { 1, 1, 1, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1, 1, 1 };
    filters = new SuperpoweredBandpassFilterbank(16, frequencies, widths, 44100);
    
    output = [[SuperpoweredIOSAudioOutput alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredMinimumSamplerate:44100 audioSessionCategory:AVAudioSessionCategoryPlayback multiChannels:2 fixReceiver:true];
    
}

-(void)playSongWithUrl:(NSURL *)url{
    NSData *temp = [NSData dataWithContentsOfURL:url];
    NSLog(@"Data - %@",temp);
    player->open([url fileSystemRepresentation]);
}

// This is where the Superpowered magic happens.
- (bool)audioProcessingCallback:(float **)buffers inputChannels:(unsigned int)inputChannels outputChannels:(unsigned int)outputChannels numberOfSamples:(unsigned int)numberOfSamples samplerate:(unsigned int)samplerate hostTime:(UInt64)hostTime {
    
    
    uint64_t startTime = mach_absolute_time();

    if (samplerate != lastSamplerate) { // Has samplerate changed?
        lastSamplerate = samplerate;
        player->setSamplerate(samplerate);
        filters->setSamplerate(samplerate);
        for (int n = 2; n < NUMFXUNITS; n++) effects[n]->setSamplerate(samplerate);
    };
    
// We're keeping our Superpowered time-based effects in sync with the player... with one line of code. Not bad, eh?
    ((SuperpoweredRoll *)effects[ROLLINDEX])->bpm = ((SuperpoweredFlanger *)effects[FLANGERINDEX])->bpm = ((SuperpoweredEcho *)effects[DELAYINDEX])->bpm = player->currentBpm;
    
/*
 Let's process some audio.
 If you'd like to change connections or tap into something, no abstract connection handling and no callbacks required!
*/
    bool silence = !player->process(stereoBuffer, false, numberOfSamples, 1.0f, 0.0f, -1.0);
    if (effects[ROLLINDEX]->process(silence ? NULL : stereoBuffer, stereoBuffer, numberOfSamples)) silence = false;
    effects[FILTERINDEX]->process(stereoBuffer, stereoBuffer, numberOfSamples);
    effects[EQINDEX]->process(stereoBuffer, stereoBuffer, numberOfSamples);
    effects[FLANGERINDEX]->process(stereoBuffer, stereoBuffer, numberOfSamples);
    if (effects[DELAYINDEX]->process(silence ? NULL : stereoBuffer, stereoBuffer, numberOfSamples)) silence = false;
    if (effects[REVERBINDEX]->process(silence ? NULL : stereoBuffer, stereoBuffer, numberOfSamples)) silence = false;
    
// CPU measurement code to show some nice numbers for the business guys.
    uint64_t elapsedUnits = mach_absolute_time() - startTime;
    if (elapsedUnits > maxTime) maxTime = elapsedUnits;
    timeUnitsProcessed += elapsedUnits;
    samplesProcessed += numberOfSamples;
    if (samplesProcessed >= samplerate) {
        avgUnitsPerSecond = timeUnitsProcessed;
        maxUnitsPerSecond = (double(samplerate) / double(numberOfSamples)) * maxTime;
        samplesProcessed = timeUnitsProcessed = maxTime = 0;
    };
    
// The stereoBuffer is ready now, let's put the finished audio into the requested buffers.
    float *mixerInputs[4] = { stereoBuffer, NULL, NULL, NULL };
    float mixerInputLevels[8] = { 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
    float mixerOutputLevels[2] = { 1.0f, 1.0f };
    if (!silence) mixer->process(mixerInputs, buffers, mixerInputLevels, mixerOutputLevels, NULL, NULL, numberOfSamples);

    for (int n = 0; n < numberOfSamples; n++) if (!isfinite(buffers[0][n]) || !isfinite(buffers[1][n])) printf("%i ", n);

    //Frequency Stuff
    float interleaved[numberOfSamples * 2 + 16];
    float *inputs[4] = { buffers[0], buffers[1], NULL, NULL };
    float *outputs[2] = { interleaved, NULL };
    float inputLevels[8] = { 1, 1, 0, 0, 0, 0, 0, 0 };
    mixer->process(inputs, outputs, inputLevels, inputLevels, NULL, NULL, numberOfSamples);
    
    
    float peak, sum;
    pthread_mutex_lock(&mutex);
    samplesProcessedForOneDisplayFrame += numberOfSamples;
    filters->process(interleaved, bands, &peak, &sum, numberOfSamples);
    pthread_mutex_unlock(&mutex);
	
	//self.speakerValue = sum;
    
    
    
    
    playing = player->playing;
    return !silence;
}
- (void)getFrequencies:(NSMutableArray *)freqs {
    pthread_mutex_lock(&mutex);
    if (samplesProcessedForOneDisplayFrame > 0) {
        for (int n = 0; n < 16; n++) [freqs setObject:[NSNumber numberWithFloat: bands[n] / float(samplesProcessedForOneDisplayFrame) ] atIndexedSubscript:n];
        

        self.frequenciesArr = [[NSMutableArray alloc]init];
        
        for (int n = 0; n < 16; n++){
            [self.frequenciesArr addObject:[freqs objectAtIndex:n]];
        }
        
        memset(bands, 0, 16 * sizeof(float));
        samplesProcessedForOneDisplayFrame = 0;
    } else freqs = [[NSMutableArray alloc]initWithCapacity:16];
    pthread_mutex_unlock(&mutex);
}



@end
