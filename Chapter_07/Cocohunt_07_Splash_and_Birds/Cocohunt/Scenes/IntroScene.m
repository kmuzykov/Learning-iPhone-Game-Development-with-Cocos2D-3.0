//
//  IntroScene.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 07/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "IntroScene.h"

#import "GameScene.h"
#import "cocos2d.h"
#import "CCAnimation.h"

@implementation IntroScene
{
    CCSprite* _explodingCoconut;
}

-(instancetype)init
{
    if (self = [super init])
    {
        CGSize viewSize =
        [CCDirector sharedDirector].viewSize;
        
        _explodingCoconut =
        [CCSprite spriteWithImageNamed:
         @"Exploding_Coconut_0.png"];
        _explodingCoconut.position =
        ccp(viewSize.width * 0.5f,viewSize.height * 0.5f);
        
        [self addChild:_explodingCoconut];
    }
    
    return self;
}

-(void)onEnter
{
    [super onEnter];
    [self animateCoconutExplosion];
}

-(void)animateCoconutExplosion
{
    NSMutableArray *frames = [NSMutableArray array];
    int lastFrameNumber= 34;
    for (int i =0; i <= lastFrameNumber; i++)
    {
        NSString *frameName =
        [NSString
         stringWithFormat:@"Exploding_Coconut_%d.png", i];
        CCSpriteFrame *frame =
        [CCSpriteFrame frameWithImageNamed:frameName];
        [frames addObject:frame];
    }
    
    CCAnimation *explosion =
    [CCAnimation animationWithSpriteFrames:frames
                                     delay:0.15f];
    CCActionAnimate *animateExplosion =
    [CCActionAnimate actionWithAnimation:explosion];
    CCActionEaseIn *easedExplosion =
    [CCActionEaseIn actionWithAction:animateExplosion
                                rate:1.5f];
    
    CCActionCallFunc *proceedToGameScene =
    [CCActionCallFunc actionWithTarget:self
                              selector:@selector(proceedToGameScene)];
    CCActionSequence *sequence =
    [CCActionSequence actions:easedExplosion,
     proceedToGameScene,
     nil];
    [_explodingCoconut runAction:sequence];
}

-(void)proceedToGameScene
{
    [[CCDirector sharedDirector]
     replaceScene:[[GameScene alloc] init]];
}

@end
