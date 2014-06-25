//
//  GameScene.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 28/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCScene.h"

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

@property (nonatomic, assign) GameState gameState;

@end
