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
    //Sprite that will play animation.
    CCSprite* _explodingCoconut;
}

-(instancetype)init
{
    if (self = [super init])
    {
        CGSize viewSize = [CCDirector sharedDirector].viewSize;
        
        //Creating sprite using full screen image and placing it in the center of the screen.
        _explodingCoconut = [CCSprite spriteWithImageNamed:@"Exploding_Coconut_0.png"];
        _explodingCoconut.position = ccp(viewSize.width * 0.5f,viewSize.height * 0.5f);
        
        [self addChild:_explodingCoconut];
    }
    
    return self;
}

-(void)onEnter
{
    [super onEnter];
    
    //Starting animation when scene becomes visible.
    [self animateCoconutExplosion];
}

-(void)animateCoconutExplosion
{
    //Loading frames of animation. They differ only by number in name.
    NSMutableArray *frames = [NSMutableArray array];
    int lastFrameNumber= 34;
    for (int i =0; i <= lastFrameNumber; i++)
    {
        NSString *frameName = [NSString stringWithFormat:@"Exploding_Coconut_%d.png", i];
        CCSpriteFrame *frame =[CCSpriteFrame frameWithImageNamed:frameName];
        [frames addObject:frame];
    }
    
    //Creating coconut explision animation.
    CCAnimation *explosion = [CCAnimation animationWithSpriteFrames:frames delay:0.15f];
    
    //Creating animate action (to play animation)
    CCActionAnimate *animateExplosion =[CCActionAnimate actionWithAnimation:explosion];
    
    //Easing animation a bit to make explision more realistic.
    CCActionEaseIn *easedExplosion = [CCActionEaseIn actionWithAction:animateExplosion rate:1.5f];
    
    //When animation is done we want to call proceedToGameScene method to move to the next scene.
    CCActionCallFunc *proceedToGameScene = [CCActionCallFunc actionWithTarget:self selector:@selector(proceedToGameScene)];
    
    //Creating and running sequence.
    CCActionSequence *sequence = [CCActionSequence actions:easedExplosion, proceedToGameScene, nil];
    [_explodingCoconut runAction:sequence];
}

-(void)proceedToGameScene
{
    //Moving to next scene when animation is done.
    [[CCDirector sharedDirector] replaceScene:[[GameScene alloc] init]];
}

@end
