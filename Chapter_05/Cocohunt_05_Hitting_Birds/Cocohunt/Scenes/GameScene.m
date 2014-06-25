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
    
    float _timeUntilNextBird;
    NSMutableArray *_birds;
    
    NSMutableArray *_arrows;
}

-(instancetype)init
{
    if (self = [super init])
    {
        _arrows = [NSMutableArray array];
        
        _timeUntilNextBird = 0;
        _birds = [NSMutableArray array];
        
        self.userInteractionEnabled = YES;
        
        [self createBatchNode];
        
        [self addBackground];
        [self addHunter];
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

-(void)update:(CCTime)dt
{
    //1
    _timeUntilNextBird -= dt;
    
    //2
    if (_timeUntilNextBird <= 0)
    {
        //3
        [self spawnBird];
        
        //4
        int nextBirdTimeMax = 5;
        int nextBirdTimeMin = 2;
        int nextBirdTime = nextBirdTimeMin + arc4random_uniform(nextBirdTimeMax - nextBirdTimeMin);
        _timeUntilNextBird = nextBirdTime;
    }
    
    //1
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CGRect viewBounds = CGRectMake(0,0,
                                   viewSize.width, viewSize.height);
    
    //2
    for (int i = _birds.count - 1; i >= 0; i--)
    {
        Bird *bird = _birds[i];
        
        //3
        BOOL birdFlewOffScreen =
        (bird.position.x + (bird.contentSize.width * 0.5f))
        > viewSize.width;
        
        //4
        if (bird.flipX == YES && birdFlewOffScreen)
        {
            [bird removeBird:NO];
            [_birds removeObject:bird];
            continue;
        }
        
        //5
        for (int j = _arrows.count - 1; j >= 0; j--)
        {
            CCSprite* arrow = _arrows[j];
            
            //6
            if (!CGRectContainsPoint(viewBounds,
                                     arrow.position))
            {
                [arrow removeFromParentAndCleanup:YES];
                [_arrows removeObject:arrow];
                continue;
            }
            
            //7
            if (CGRectIntersectsRect(arrow.boundingBox,
                                     bird.boundingBox))
            {
                [arrow removeFromParentAndCleanup:YES];
                [_arrows removeObject:arrow];
                
                [bird removeBird:YES];
                [_birds removeObject:bird];
                
                break;
            }
        }
    }
}

-(void)spawnBird
{
    //1
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    //2
    int maxY = viewSize.height * 0.9f;
    int minY = viewSize.height * 0.6f;
    int birdY = minY + arc4random_uniform(maxY - minY);
    int birdX = viewSize.width * 1.3f;
    CGPoint birdStart = ccp(birdX, birdY);
    
    //3
    BirdType birdType = (BirdType)(arc4random_uniform(3));
    
    //4
    Bird* bird = [[Bird alloc] initWithBirdType:birdType];
    bird.position = birdStart;
    
    //5
    [_batchNode addChild:bird];
    
    //6
    [_birds addObject:bird];
    
    //7
    int maxTime = 20;
    int minTime = 10;
    int birdTime =
    minTime + (arc4random() % (maxTime - minTime));
    CGPoint screenLeft = ccp(0, birdY);
    
    //8
    CCActionMoveTo *moveToLeftEdge =
    [CCActionMoveTo actionWithDuration:birdTime
                              position:screenLeft];
    CCActionFlipX  *turnaround =
    [CCActionFlipX actionWithFlipX:YES];
    CCActionMoveTo *moveBackOffScreen =
    [CCActionMoveTo actionWithDuration:birdTime
                              position:birdStart];
    
    //9
    CCActionSequence *moveLeftThenBack =
    [CCActionSequence actions: moveToLeftEdge,
     turnaround,
     moveBackOffScreen,
     nil];
    //10
    [bird runAction:moveLeftThenBack];
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
    CGPoint touchLocation = [touch locationInNode:self];

    CCSprite *arrow =
        [_hunter shootAtPoint:touchLocation];
    
    [_arrows addObject:arrow];
}

@end
