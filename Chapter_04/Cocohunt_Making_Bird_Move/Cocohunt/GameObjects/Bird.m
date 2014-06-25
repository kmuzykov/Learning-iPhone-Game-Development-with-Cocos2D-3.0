//
//  Bird.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 30/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "Bird.h"

@implementation Bird

-(instancetype)initWithBirdType:(BirdType)typeOfBird
{
    //1
    NSString *birdImageName;
    
    switch (typeOfBird) {
        case BirdTypeBig:
            birdImageName = @"bird_big.png";
            break;
        case BirdTypeMedium:
            birdImageName = @"bird_middle.png";
            break;
        case BirdTypeSmall:
            birdImageName = @"bird_small.png";
            break;
        default:
            CCLOG(@"Unknown bird type, using small bird!");
            birdImageName = @"bird_small.png";
            break;
    }
    
    //2
    if (self = [super initWithImageNamed:birdImageName])
    {
        //3
        self.birdType = typeOfBird;
    }
    
    return self;
}

@end
