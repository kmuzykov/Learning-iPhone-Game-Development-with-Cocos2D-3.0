//
//  BirdScene.m
//  FrameSizeIssues
//
//  Created by Kirill Muzykov on 11/01/14.
//  Copyright (c) 2014 Packt Publishing. All rights reserved.
//

#import "BirdScene.h"

#import "cocos2d.h"
#import "CCAnimation.h"

@implementation BirdScene

-(void)onEnter
{
    [super onEnter];
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    float height = viewSize.height * 0.5f;
    
    //Changing background color to see the bird
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
    [self addChild:background];
    
    //Adding bird
    CCSprite *bird = [CCSprite spriteWithImageNamed:@"bird_big_0.png"];
    bird.position = ccp(viewSize.width, height);
    [self addChild:bird];
    
    //Setting up movement from one side of the screen to anothr
    CCActionMoveTo *moveLeft = [CCActionMoveTo actionWithDuration:2.0f position:ccp(0, height)];
    CCActionFlipX *flipYES = [CCActionFlipX actionWithFlipX:YES];
    CCActionMoveTo *moveRight = [CCActionMoveTo actionWithDuration:2.0f position:ccp(viewSize.width, height)];
    CCActionFlipX *flipNO = [CCActionFlipX actionWithFlipX:NO];
    
    CCActionSequence *moveLeftThenRight = [CCActionSequence actions:moveLeft, flipYES, moveRight, flipNO,  nil];
    CCActionRepeatForever *repeatMovement = [CCActionRepeatForever actionWithAction:moveLeftThenRight];
    [bird runAction:repeatMovement];
    
    //Setting up animation
    NSMutableArray *frames = [NSMutableArray array];
    for (int i = 0; i <= 6; i++)
    {
        [frames addObject:[CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"bird_big_%d.png", i]]];
    }
    
    CCAnimation *anim = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
    CCActionAnimate *animate = [CCActionAnimate actionWithAnimation:anim];
    CCActionRepeatForever *flyForever = [CCActionRepeatForever actionWithAction:animate];
    
    [bird runAction:flyForever];
}

@end
