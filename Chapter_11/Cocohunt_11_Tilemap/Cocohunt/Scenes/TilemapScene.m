//
//  TilemapScene.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 27/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "TilemapScene.h"

#import "cocos2d.h"
#import "Bird.h"

typedef NS_ENUM(NSUInteger, zOrder)
{
    zOrderBackground,
    zOrderTilemap,
    zOrderObjects
};

@implementation TilemapScene
{
    float       _worldSize;
    CCTiledMap *_tileMap;
    Bird       *_bird;
    CCSpriteBatchNode *_batchNode;
}

-(void)onEnter
{
    [super onEnter];
    
    [self createBatchNode];
    
    [self addBackground];
    [self addTilemap];
    [self addBird];
}

-(void)createBatchNode
{
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     addSpriteFramesWithFile:@"Cocohunt.plist"];
    _batchNode = [CCSpriteBatchNode
                  batchNodeWithFile:@"Cocohunt.png"];
    [self addChild:_batchNode z:zOrderObjects];
}

-(void)addBackground
{
    CCSprite *bg =
    [CCSprite spriteWithImageNamed:@"tile_level_bg.png"];
    bg.positionType = CCPositionTypeNormalized;
    bg.position = ccp(0.5f, 0.5f);
    [self addChild:bg z:zOrderBackground];
}

-(void)addTilemap
{
    _tileMap = [CCTiledMap tiledMapWithFile:@"tilemap.tmx"];
    _worldSize = _tileMap.contentSizeInPoints.width;
    [self addChild:_tileMap z:zOrderTilemap];
}

-(void)addBird
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    _bird = [[Bird alloc] initWithBirdType:BirdTypeSmall];
    _bird.flipX = YES;
    _bird.position = ccp(viewSize.width * 0.2f,
                         viewSize.height * 0.2f);
    [_batchNode addChild:_bird];
}

-(void)update:(CCTime)dt
{
    float distance = 150.0f * dt;
    
    CGPoint newTilemapPos = _tileMap.position;
    newTilemapPos.x = newTilemapPos.x - distance;
    
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    float endPosition = -1 * _worldSize + viewSize.width;
    
    if (newTilemapPos.x > endPosition)
        _tileMap.position = newTilemapPos;
}
@end
