//
//  Bird.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 30/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCSprite.h"

/** 
 * There are 3 different types of bird can be created. 
 * Each uses a different sprite 
 */
typedef enum BirdType
{
    BirdTypeBig,
    BirdTypeMedium,
    BirdTypeSmall
} BirdType;

/**
 * States of the bird.
 */
typedef enum BirdState
{
    BirdStateFlyingIn,
    BirdStateFlyingOut,
    BirdStateFlewOut,
    BirdStateDead
} BirdState;

/**
 * Target/Enemy class for hunter to shoot at.
 */
@interface Bird : CCSprite


/** Type of the bird (which sprite used) */
@property (nonatomic, assign) BirdType birdType;

/** 
 * Current state of the bird. Used to check if the bird should be removed
 * when leaves the screen.
 */
@property (nonatomic, assign) BirdState birdState;

/** Create bird of given type (using one of the 3 sprites) */
-(instancetype)initWithBirdType:(BirdType)typeOfBird;

/** Remove the bird */
-(void)removeBird:(BOOL)hitByArrow;

/** Flip the bird and decrease visits counter */
-(void)turnaround;

@end
