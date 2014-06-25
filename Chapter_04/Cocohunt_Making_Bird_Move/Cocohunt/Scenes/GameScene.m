//
//  GameScene.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 28/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//
#import "GameScene.h"
#import "cocos2d.h"

#import "Hunter.h"
#import "Bird.h"

@implementation GameScene
{
    Hunter *_hunter;
    Bird    *_bird;
}

-(instancetype)init
{
    if (self = [super init])
    {
        [self addBackground];
        
        [self addHunter];
        
        [self addBird];
    }
    
    return self;
}

-(void)addBackground
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    CCSprite *background =
    [CCSprite spriteWithImageNamed:@"game_scene_bg.png"];
    
    background.position = ccp(viewSize.width  * 0.5f,
                              viewSize.height * 0.5f);
    
    [self addChild:background];
}

-(void)addHunter
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    _hunter = [[Hunter alloc] init];
    
    float hunterPositionX =
      viewSize.width * 0.5f - 180.0f;
    
    float hunterPositionY =
      viewSize.height * 0.3f;
    
    _hunter.position = ccp(hunterPositionX,
                           hunterPositionY);
    
    [self addChild:_hunter];
}

-(void)addBird
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    _bird = [[Bird alloc]
			 initWithBirdType:BirdTypeSmall];
    
    _bird.position = ccp(viewSize.width * 0.5f,
                         viewSize.height * 0.9f);
    [self addChild:_bird];
}

-(void)update:(CCTime)dt
{
    //1
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    //2
    if (_bird.position.x < 0)
        _bird.flipX = YES;
    
    //3
    if (_bird.position.x > viewSize.width)
        _bird.flipX = NO;
    
    //4
    float birdSpeed = 50;
    float distanceToMove = birdSpeed * dt;
    
    //5
    float direction = _bird.flipX ? 1 : -1;
    
    //6
    float newX = _bird.position.x + direction * distanceToMove;
    float newY = _bird.position.y;
    
    //7
    _bird.position = ccp(newX, newY);
}

@end
