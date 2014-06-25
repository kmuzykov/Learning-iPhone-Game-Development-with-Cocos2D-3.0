//
//  AudioManager.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 13/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioManager : NSObject

-(void)playSoundEffect:(NSString *)soundFile;

+(instancetype)sharedAudioManager;

@end
