//
//  GameStats.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 05/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Class to store current game stats */
@interface GameStats : NSObject

/** Points scored by hitting birds */
@property (nonatomic, assign) int score;

/** Amount of birds still to be spawned */
@property (nonatomic, assign) int birdsLeft;

/** Amount of birds can fly away until the player loses the game */
@property (nonatomic, assign) int lives;

@end
