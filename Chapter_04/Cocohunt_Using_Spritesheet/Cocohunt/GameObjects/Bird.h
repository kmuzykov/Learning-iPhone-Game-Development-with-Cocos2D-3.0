//
//  Bird.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 30/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCSprite.h"

typedef enum BirdType
{
    BirdTypeBig,
    BirdTypeMedium,
    BirdTypeSmall
} BirdType;


@interface Bird : CCSprite


@property (nonatomic, assign) BirdType birdType;

-(instancetype)initWithBirdType:(BirdType)typeOfBird;

@end
