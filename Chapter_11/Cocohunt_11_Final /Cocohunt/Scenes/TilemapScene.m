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
    
    CCParallaxNode *_parallaxNode;
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
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Cocohunt.plist"];
    _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Cocohunt.png"];
    [self addChild:_batchNode z:zOrderObjects];
}

-(void)addBackground
{
    CCSprite *bg = [CCSprite spriteWithImageNamed:@"tile_level_bg.png"];
    bg.positionType = CCPositionTypeNormalized;
    bg.position = ccp(0.5f, 0.5f);
    [self addChild:bg z:zOrderBackground];
}

-(void)addTilemap
{
    _tileMap = [CCTiledMap tiledMapWithFile:@"tilemap.tmx"];
    _worldSize = _tileMap.contentSizeInPoints.width;
    
    //1: Getting individual  layers of the tile map
    CCTiledMapLayer *bushes = [_tileMap layerNamed:@"Bushes"];
    CCTiledMapLayer *trees = [_tileMap layerNamed:@"Trees"];
    CCTiledMapLayer *ground = [_tileMap layerNamed:@"Ground"];
    
    //2: Creating parallax node
    _parallaxNode = [CCParallaxNode node];
    
    //3: Removing layers from tile map, but not deallocating (passing NO)
    [bushes removeFromParentAndCleanup:NO];
    [trees removeFromParentAndCleanup:NO];
    [ground removeFromParentAndCleanup:NO];
    
    //4: Adding layers to parallax node using different parallaxRatio
    [_parallaxNode addChild:bushes z:0
              parallaxRatio:ccp(0.2, 0)
             positionOffset:ccp(0,0)];
    
    [_parallaxNode addChild:trees z:1
              parallaxRatio:ccp(0.5, 0)
             positionOffset:ccp(0,0)];
    
    [_parallaxNode addChild:ground z:2
              parallaxRatio:ccp(1,0)
             positionOffset:ccp(0,0)];
    
    //5: Adding parallax node to the scene
    [self addChild:_parallaxNode z:zOrderTilemap];
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
    
    CGPoint newPos = _parallaxNode.position;
    newPos.x = newPos.x - distance;
    
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    float endX = -1 * _worldSize + viewSize.width;
    
    if (newPos.x > endX )
        _parallaxNode.position = newPos;
}

@end
