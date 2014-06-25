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
    //Batch node to use spritesheet.
    CCSpriteBatchNode *_batchNode;
    
    //Reference to hunter game object in the scene.
    Hunter *_hunter;
    
    //Reference to bird game object object.
    Bird    *_bird;
}

-(instancetype)init
{
    if (self = [super init])
    {
        self.userInteractionEnabled = YES;
        
        [self createBatchNode];
        
        [self addBackground];
        [self addHunter];
        [self addBird];
    }
    
    return self;
}

-(void)createBatchNode
{
    //Loading spritesheet sprite frames from .plist
    [[CCSpriteFrameCache sharedSpriteFrameCache]
     addSpriteFramesWithFile:@"Cocohunt.plist"];
    
    //Creating batchnode using spritesheet image.
    _batchNode = [CCSpriteBatchNode
                  batchNodeWithFile:@"Cocohunt.png"];
    
    //Adding batch node to the scene (at z:1 to make sure its on top of background)
    [self addChild:_batchNode z:1];
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
    
    //Calculating hunter position relative to center, to make sure he
    //is placed at the same position on 3.5 and 4 inch wide displays.
    float hunterPositionX =
      viewSize.width * 0.5f - 180.0f;
    
    float hunterPositionY =
      viewSize.height * 0.3f;
    
    _hunter.position = ccp(hunterPositionX,
                           hunterPositionY);
    
    [_batchNode addChild:_hunter];
}

-(void)addBird
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    _bird = [[Bird alloc] initWithBirdType:BirdTypeSmall];
    
    _bird.position = ccp(viewSize.width * 0.5f,
                         viewSize.height * 0.9f);
    [_batchNode addChild:_bird];
}

-(void)update:(CCTime)dt
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    //Checking if bird reached left edge of the screen and flipping it.
    if (_bird.position.x < 0)
        _bird.flipX = YES;
    
    //If bird reached right edge of the screen, flipping it back.
    if (_bird.position.x > viewSize.width)
        _bird.flipX = NO;
    
    //Calculating distance the bird travaled.
    float birdSpeed = 50;
    float distanceToMove = birdSpeed * dt;
    
    //Finding out direction
    float direction = _bird.flipX ? 1 : -1;
    
    //Calculating new position using direction and distance.
    float newX = _bird.position.x + direction * distanceToMove;
    float newY = _bird.position.y;
    
    //Moving the bird.
    _bird.position = ccp(newX, newY);
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    [_hunter aimAtPoint:touchLocation];
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    [_hunter aimAtPoint:touchLocation];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCLOG(@"finger up at : (%f, %f)",
          touch.locationInWorld.x,
          touch.locationInWorld.y);
}

@end
