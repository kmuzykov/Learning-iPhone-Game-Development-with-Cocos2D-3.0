//
//  AudioManager.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 13/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "AudioManager.h"
#import "OALSimpleAudio.h"

@implementation AudioManager

-(void)playSoundEffect:(NSString *)soundFile
{
    [[OALSimpleAudio sharedInstance] playEffect:soundFile];
}

+(AudioManager *)sharedAudioManager
{
    static dispatch_once_t pred;
    static AudioManager * _sharedInstance;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

@end
