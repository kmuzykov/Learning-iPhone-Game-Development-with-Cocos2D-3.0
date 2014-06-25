//
//  Bird.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 30/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "Bird.h"
#import "cocos2d.h"
#import "CCAnimation.h"

@implementation Bird

-(instancetype)initWithBirdType:(BirdType)typeOfBird
{
    //Setting sprite name depending on bird type.
    NSString *birdImageName;
    switch (typeOfBird) {
        case BirdTypeBig:
            birdImageName = @"bird_big_0.png";
            break;
        case BirdTypeMedium:
            birdImageName = @"bird_middle_0.png";
            break;
        case BirdTypeSmall:
            birdImageName = @"bird_small_0.png";
            break;
        default:
            CCLOG(@"Unknown bird type, using small bird!");
            birdImageName = @"bird_small_0.png";
            break;
    }
    
    //Using CCSprite's super method, since we want to reuse
    //CCSprite's functionality to draw ourselves(bird),
    //but want to add some functionality, and thus subclassed CCSprite.
    if (self = [super initWithImageNamed:birdImageName])
    {
        //Saving bird type in case we need to know which bird type is this.
        self.birdType = typeOfBird;
        
        //Starting animation straight away.
        [self animateFly];
    }
    
    return self;
}

-(void)animateFly
{
    //1: Finding out frames format, depending on current bird type.
    NSString *animFrameNameFormat;
    switch (self.birdType) {
        case BirdTypeBig:
            animFrameNameFormat = @"bird_big_%d.png";
            break;
        case BirdTypeMedium:
            animFrameNameFormat = @"bird_middle_%d.png";
            break;
        case BirdTypeSmall:
            animFrameNameFormat = @"bird_small_%d.png";
            break;
        default:
            CCLOG(@"Unknown bird type, using small bird animation!");
            animFrameNameFormat = @"bird_small_%d.png";
            break;
    }
    
    //2: Creating mutable array (we know that there will be 7 frames)
    NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:7];
    
    //3: Generating frame names, by using stringWithFormat and getting corresponding frames.
    for (int i = 0; i < 7 ; i++)
    {
        //4
        NSString *currentFrameName  = [NSString stringWithFormat:animFrameNameFormat, i];
        
        //5
        CCSpriteFrame *animationFrame = [CCSpriteFrame frameWithImageNamed:currentFrameName];
        
        //6
        [animFrames addObject:animationFrame];
    }
    
    //7: Creating animation.
    CCAnimation* flyAnimation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.1f];
    
    //8: Creating action that will play the animation.
    CCActionAnimate *flyAnimateAction = [CCActionAnimate actionWithAnimation:flyAnimation];
    
    //9: Wrapping animate action with action that will repeat it forever.
    CCActionRepeatForever *flyForever = [CCActionRepeatForever actionWithAction:flyAnimateAction];
    
    //10: Running action.
    [self runAction:flyForever];
}

-(void)removeBird:(BOOL)hitByArrow
{
    if (hitByArrow)
    {
        CCLOG(@"Bird hit by arrow");
    }
    else
    {
        CCLOG(@"Bird flew away");
    }
    
    [self removeFromParentAndCleanup:YES];
}


@end
