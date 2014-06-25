//
//  AudioManager.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 13/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation.AVAudioPlayer;

#define kSoundArrowShot @"arrow_shot.wav"
#define kSoundBirdHit   @"bird_hit.mp3"
#define kSoundWin       @"win.wav"
#define kSoundLose      @"lose.wav"

/** Class to play sound effects and music */
@interface AudioManager : NSObject<AVAudioPlayerDelegate>

/** Play sound effect with default parameters */
-(void)playSoundEffect:(NSString *)soundFile;

/** 
* Play sound effect with adjusting pan (stereo position)
* parameter using the bird position 
 */
-(void)playSoundEffect:(NSString *)soundFile
          withPosition:(CGPoint)pos;

/** Play 1 background track */
-(void)playBackgroundSound:(NSString *)soundFile;

/** Start playing music tracks in random order */
-(void)playMusic;

/** Stop playing music */
-(void)stopMusic;

/** Preload all sound effects (#define's above) */
-(void)preloadSoundEffects;

+(instancetype)sharedAudioManager;

@end
