//
//  Hunter.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 30/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCSprite.h"

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

@property (nonatomic, assign) HunterState hunterState;

-(void)aimAtPoint:(CGPoint)point;

-(CCSprite*)shootAtPoint:(CGPoint)point;

-(void)getReadyToShootAgain;

-(CGPoint)torsoCenterInWorldCoordinates;

-(float)torsoRotation;

@end
