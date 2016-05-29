// This object handles Superpowered.
// Compare the source to CoreAudio.mm and see how much easier it is to understand.

@interface Superpowered: NSObject {
@public
    bool playing;
    uint64_t avgUnitsPerSecond, maxUnitsPerSecond;
}

// Updates the user interface according to the file player's state.
- (void)updatePlayerLabel:(UILabel *)label slider:(UISlider *)slider button:(UIButton *)button;

- (void)togglePlayback; // Play/pause.
- (void)seekTo:(float)percent; // Jump to a specific position.
-(void) addSongWithName:(NSString*)songName fileType:(NSString*) type;
- (void)toggle; // Start/stop Superpowered.
- (bool)toggleFx:(int)index; // Enable/disable fx.
- (void)getFrequencies:(NSMutableArray *)freqs;
-(void)playSongWithUrl:(NSURL *)url;
-(float)positionPercent;
-(void)dealloc;
@property NSMutableArray *frequenciesArr;
@property int speakerValue;
@property	int bpm;
@end
