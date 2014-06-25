//
//  Hunter.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 30/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCSprite.h"

/**
 * State of the hunter.
 */
typedef enum HunterState
{
    HunterStateIdle,
    HunterStateAiming,
    HunterStateReloading
} HunterState;

/**
 * Player character class.
 */
@interface Hunter : CCSprite

/** 
 * State of the hunter. Used to determine if the hunter can shoot.
 */
@property (nonatomic, assign) HunterState hunterState;

/** Rotates the hunter torso to aim at given point */
-(void)aimAtPoint:(CGPoint)point;

/** Spawns an arrow that moves through a given point */
-(CCSprite*)shootAtPoint:(CGPoint)point;

/** Resets the hunter stated to Idle */
-(void)getReadyToShootAgain;

/** Gets the coordinates of the torso center (hunter hand and arrow tail point) in world space */
-(CGPoint)torsoCenterInWorldCoordinates;

/** Returns rotation of the torso child sprite */
-(float)torsoRotation;

@end
