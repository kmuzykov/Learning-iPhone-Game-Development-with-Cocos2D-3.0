//
//  GameScene.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 28/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCScene.h"

/** State of the game */
typedef enum GameState
{
    GameStateUninitialized,
    GameStatePlaying,
    GameStatePaused,
    GameStateWon,
    GameStateLost
    
} GameState;

/** Game scene for the level where hunter shoots birds */
@interface GameScene : CCScene

/** 
 * The state the game is currently in. 
 * Used to check what you can do right now (e.g. can't shoot when paused) 
 */
@property (nonatomic, assign) GameState gameState;

@end
