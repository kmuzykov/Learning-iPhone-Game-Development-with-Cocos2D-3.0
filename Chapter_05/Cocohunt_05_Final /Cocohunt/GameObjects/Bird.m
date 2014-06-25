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
{
    //Times the bird will return to the screen before flying away (and the player loses life)
    int _timesToVisit;
}

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
        _timesToVisit = 3;
        self.birdState = BirdStateFlyingIn;
        
        //Saving bird type in case we need to know which bird type is this.
        self.birdType = typeOfBird;
        
        //Starting animation straight away.
        [self animateFly];
    }
    
    return self;
}

-(void)animateFly
{
    //Finding out frames format, depending on current bird type.
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
    
    //Creating mutable array (we know that there will be 7 frames)
    NSMutableArray *animFrames = [NSMutableArray arrayWithCapacity:7];
    
    //Generating frame names, by using stringWithFormat and getting corresponding frames.
    for (int i = 0; i < 7 ; i++)
    {
        NSString *currentFrameName  = [NSString stringWithFormat:animFrameNameFormat, i];
        CCSpriteFrame *animationFrame = [CCSpriteFrame frameWithImageNamed:currentFrameName];
        [animFrames addObject:animationFrame];
    }
    
    //Creating animation.
    CCAnimation* flyAnimation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.1f];
    
    //Creating action that will play the animation.
    CCActionAnimate *flyAnimateAction = [CCActionAnimate actionWithAnimation:flyAnimation];
    
    //Wrapping animate action with action that will repeat it forever.
    CCActionRepeatForever *flyForever = [CCActionRepeatForever actionWithAction:flyAnimateAction];
    
    //Running action.
    [self runAction:flyForever];
}

-(void)removeBird:(BOOL)hitByArrow
{
    //Removing from partent. This also stops all actions.
    [self removeFromParentAndCleanup:YES];
    
    if (hitByArrow)
    {
        self.birdState = BirdStateDead;
    }
    else
    {
        self.birdState = BirdStateFlewOut;
    }
}

-(void)turnaround
{
    //Fliping the bird.
    self.flipX = !self.flipX;
    
    //Decreasing counter.
    if (self.flipX)
        _timesToVisit--;
    
    //If visited enough times, setting the bird to fly away.
    if (_timesToVisit <= 0)
        self.birdState = BirdStateFlyingOut;
}

@end
