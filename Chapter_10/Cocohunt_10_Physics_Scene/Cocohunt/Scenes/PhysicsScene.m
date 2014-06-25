//
//  PhysicsScene.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "PhysicsScene.h"
#import "PhysicsHunter.h"

#define kBackgroundZ    10
#define kGroundZ        15
#define kObjectsZ       20

@implementation PhysicsScene
{
    CCPhysicsNode *_physicsNode;
    CCSpriteBatchNode *_batchNodeMain;
    
    CCSprite *_ground;
    PhysicsHunter *_hunter;
}

-(void)onEnter
{
    [super onEnter];
    
    [self createPhysicsNode];
    [self createBatchNodes];
    [self addBackground];
    [self addGround];
}

-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [self spawnStone];
    
    [self createHunter];
    
    [self addBoundaries];
}

-(void)createPhysicsNode
{
    //1: Creating physics node, a parent node to all nodes with physics bodies.
    _physicsNode = [CCPhysicsNode node];
    
    //2: Setting gravity
    _physicsNode.gravity = ccp(0,-250);
    
    //3: This will cause physics node to draw physics shapes, coliisions and so on.
    _physicsNode.debugDraw = YES;
    
    //4: Adding it to the scene. All other objects, inluding batch nodes will be added to it.
    [self addChild:_physicsNode];
}

-(void)createBatchNodes
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"physics_level.plist"];
    _batchNodeMain = [CCSpriteBatchNode batchNodeWithFile:@"physics_level.png"];
    [_physicsNode addChild:_batchNodeMain];
}

-(void)createHunter
{
    _hunter = [[PhysicsHunter alloc] init];
    
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    _hunter.anchorPoint = ccp(0.5f, 0);
    _hunter.position = ccp(viewSize.width * 0.5f,
                           _ground.contentSizeInPoints.height + 10);
    
    [_batchNodeMain addChild:_hunter z:kObjectsZ];
    
    self.userInteractionEnabled = YES;
}

-(void)addBackground
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    CCSprite *bg = [CCSprite spriteWithImageNamed:@"physics_level_bg.png"];
    bg.position = ccp(viewSize.width * 0.5f, viewSize.height * 0.5f);
    [_batchNodeMain addChild:bg z:kBackgroundZ];
}

-(void)addGround
{
    //1: Creating a sprite.
    _ground = [CCSprite spriteWithImageNamed:@"ground.png"];
    
    //2: Creating rectangle equal to the ground sprite.
    CGRect groundRect;
    groundRect.origin = CGPointZero;
    groundRect.size = _ground.contentSize;
    
    //3: Creating physics body using the rectangle above.
    CCPhysicsBody *groundBody = [CCPhysicsBody bodyWithRect:groundRect cornerRadius:0];
    
    //4: Ground shouldn't move, so making it static.
    groundBody.type = CCPhysicsBodyTypeStatic;
    
    //5: Setting bouncines of the ground.
    groundBody.elasticity = 1.5f;
    
    //6: Linking ground sprite with physics body.
    _ground.physicsBody = groundBody;
    
    //7: Placing ground at the bottom of the screen.
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    _ground.anchorPoint = ccp(0.5f, 0);
    _ground.position = ccp(viewSize.width * 0.5f, 0);
    
    //8: Addint to batch node since it uses sprite from batch node.
    [_batchNodeMain addChild:_ground z:kGroundZ];
}

-(void)addBoundaries
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CGRect boundRect = CGRectMake(0, 0, 20, viewSize.height * 0.25f);
    
    CCNode *leftBound = [CCNode node];
    leftBound.position = ccp(0, _ground.contentSize.height + 30);
    leftBound.contentSize = boundRect.size;
    
    CCPhysicsBody *leftBody = [CCPhysicsBody bodyWithRect:boundRect cornerRadius:0];
    leftBody.type = CCPhysicsBodyTypeStatic;
    leftBound.physicsBody = leftBody;
    
    [_physicsNode addChild:leftBound];
    
    CCNode *rightBound = [CCNode node];
    rightBound.contentSize = boundRect.size;
    rightBound.anchorPoint = ccp(1.0f, 0);
    rightBound.position = ccp(viewSize.width, leftBound.position.y);
    
    CCPhysicsBody *rightBody = [CCPhysicsBody bodyWithRect:boundRect cornerRadius:0];
    rightBody.type = CCPhysicsBodyTypeStatic;
    rightBound.physicsBody = rightBody;
    
    [_physicsNode addChild:rightBound];
}

-(void)spawnStone
{
    //1: Stone sprite
    CCSprite *stone = [CCSprite spriteWithImageNamed:@"stone.png"];
    
    //2: We'll use circle shape of this radious for simulation
    float radius = stone.contentSizeInPoints.width * 0.5f;
    
    //3: Creating body usin circular shape
    CCPhysicsBody *stoneBody = [CCPhysicsBody bodyWithCircleOfRadius: radius
                                                           andCenter: stone.anchorPointInPoints];
    
    //4: Setting stone mass
    stoneBody.mass = 10.0f;
    
    //5: Stone will be affected by gravity and other forces, so setting it to dynamic.
    stoneBody.type = CCPhysicsBodyTypeDynamic;
    
    //6: Linking sprite with physics body.
    stone.physicsBody = stoneBody;
    
    //7: Adding to batch node, because sprite uses frame from batchnode.
    [_batchNodeMain addChild:stone z:kObjectsZ];
    
    //8: Placing in its initial position (it will start its falling from here)
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    stone.position = ccp(viewSize.width * 0.5f, viewSize.height * 0.9f);
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    if (touchLocation.x >= viewSize.width * 0.5f)
        [_hunter
         runAtDirection:PhysicsHunterRunDirectionRight];
    else
        [_hunter runAtDirection:PhysicsHunterRunDirectionLeft];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [_hunter stop];
}

@end
