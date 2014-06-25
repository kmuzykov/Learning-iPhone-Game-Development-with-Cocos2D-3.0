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
 * Target/Enemy class for hunter to shoot at.
 */
@interface Bird : CCSprite


/** Type of the bird (which sprite used) */
@property (nonatomic, assign) BirdType birdType;

/** Create bird of given type (using one of the 3 sprites) */
-(instancetype)initWithBirdType:(BirdType)typeOfBird;

-(void)removeBird:(BOOL)hitByArrow;

@end
