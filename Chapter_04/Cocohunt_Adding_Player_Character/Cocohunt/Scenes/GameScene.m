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

@implementation GameScene
{
    Hunter *_hunter;
}

-(instancetype)init
{
    if (self = [super init])
    {
        [self addBackground];
        
        [self addHunter];
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
    
    //1
    _hunter = [[Hunter alloc] init];
    
    //2
    float hunterPositionX =
      viewSize.width * 0.5f - 180.0f;
    
    float hunterPositionY =
      viewSize.height * 0.3f;
    
    _hunter.position = ccp(hunterPositionX,
                           hunterPositionY);
    
    //3
    [self addChild:_hunter];
}

@end
