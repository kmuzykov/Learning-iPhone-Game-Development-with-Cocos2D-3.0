//
//  PhysicsScene.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "PhysicsScene.h"
#import "PhysicsHunter.h"
#import "PhysicsBird.h"

#define kBackgroundZ    10
#define kGroundZ        15
#define kObjectsZ       20

@implementation PhysicsScene
{
    CCPhysicsNode *_physicsNode;
    
    //Batchnode for physics_level.png spritsheet
    CCSpriteBatchNode *_batchNodeMain;
    
    CCSprite *_ground;
    PhysicsHunter *_hunter;
    
    NSObject *_stoneGroundCollisionGroup;
    
    float _timeUntilNextStone;
    NSMutableArray *_stones;
    
    //Batchnode for Cocohunt.png spritesheet (which we've added in Chapter 4)
    CCSpriteBatchNode *_batchNodeBirds;
}

-(void)onEnter
{
    [super onEnter];
    
    _stones = [NSMutableArray array];
    _timeUntilNextStone = 2.0f;
    _stoneGroundCollisionGroup = [[NSObject alloc] init];
    
    [self createPhysicsNode];
    [self createBatchNodes];
    [self addBackground];
    [self addGround];
}

-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [self createHunter];
    [self spawnStone]; //make sure it is after createHunter
    
    [self addBoundaries];
}

-(void)createPhysicsNode
{
    //Creating physics node, a parent node to all nodes with physics bodies.
    _physicsNode = [CCPhysicsNode node];
    
    //Setting gravity
    _physicsNode.gravity = ccp(0,-250);
    
    //Getting notified about collisions
    _physicsNode.collisionDelegate = self;
    
    //This will cause physics node to draw physics shapes, coliisions and so on.
    _physicsNode.debugDraw = YES;
    
    //Adding it to the scene. All other objects, inluding batch nodes will be added to it.
    [self addChild:_physicsNode];
}

-(void)createBatchNodes
{
    //Make sure _batchNodeMain is added before _batchNodeBirds
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"physics_level.plist"];
    _batchNodeMain = [CCSpriteBatchNode batchNodeWithFile:@"physics_level.png"];
    [_physicsNode addChild:_batchNodeMain];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]  addSpriteFramesWithFile:@"Cocohunt.plist"];
    _batchNodeBirds = [CCSpriteBatchNode batchNodeWithFile:@"Cocohunt.png"];
    [_physicsNode addChild:_batchNodeBirds];
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
    //Creating a sprite.
    _ground = [CCSprite spriteWithImageNamed:@"ground.png"];
    
    //Creating rectangle equal to the ground sprite.
    CGRect groundRect;
    groundRect.origin = CGPointZero;
    groundRect.size = _ground.contentSize;
    
    //Creating physics body using the rectangle above.
    CCPhysicsBody *groundBody = [CCPhysicsBody bodyWithRect:groundRect cornerRadius:0];
    
    //Setting collision related properties
    groundBody.collisionType = @"ground";
    groundBody.collisionGroup = _stoneGroundCollisionGroup;
    
    //Ground shouldn't move, so making it static.
    groundBody.type = CCPhysicsBodyTypeStatic;
    
    //Setting bouncines of the ground.
    groundBody.elasticity = 1.5f;
    
    //Linking ground sprite with physics body.
    _ground.physicsBody = groundBody;
    
    //Placing ground at the bottom of the screen.
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    _ground.anchorPoint = ccp(0.5f, 0);
    _ground.position = ccp(viewSize.width * 0.5f, 0);
    
    //Addint to batch node since it uses sprite from batch node.
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
    leftBody.collisionGroup = _stoneGroundCollisionGroup;
    leftBound.physicsBody = leftBody;
    
    [_physicsNode addChild:leftBound];
    
    CCNode *rightBound = [CCNode node];
    rightBound.contentSize = boundRect.size;
    rightBound.anchorPoint = ccp(1.0f, 0);
    rightBound.position = ccp(viewSize.width, leftBound.position.y);
    
    CCPhysicsBody *rightBody = [CCPhysicsBody bodyWithRect:boundRect cornerRadius:0];
    rightBody.type = CCPhysicsBodyTypeStatic;
    rightBody.collisionGroup = _stoneGroundCollisionGroup;
    rightBound.physicsBody = rightBody;
    
    [_physicsNode addChild:rightBound];
}

-(void)spawnStone
{
    //Stone sprite
    CCSprite *stone = [CCSprite spriteWithImageNamed:@"stone.png"];
    
    //We'll use circle shape of this radious for simulation
    float radius = stone.contentSizeInPoints.width * 0.5f;
    
    //Creating body usin circular shape
    CCPhysicsBody *stoneBody = [CCPhysicsBody bodyWithCircleOfRadius: radius
                                                           andCenter: stone.anchorPointInPoints];
    
    //Setting collision related properties
    stoneBody.collisionType = @"stone";
    stoneBody.collisionGroup = _stoneGroundCollisionGroup;
    
    //Setting stone mass
    stoneBody.mass = 10.0f;
    
    //Stone will be affected by gravity and other forces, so setting it to dynamic.
    stoneBody.type = CCPhysicsBodyTypeDynamic;
    
    //Linking sprite with physics body.
    stone.physicsBody = stoneBody;
    
    //Adding to batch node, because sprite uses frame from batchnode.
    [_batchNodeMain addChild:stone z:kObjectsZ];
    
    //This code is removed in Time for Action – Launching stones and replaced by...
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    stone.position = ccp(viewSize.width * 0.5f, viewSize.height * 0.9f);
    
    //... this one
    [_stones addObject:stone];
    [self launchBirdWithStone:stone];
}

-(void)launchStone:(CCSprite *)stone
{
    //1: Setting all stones in their starting position. Same for all stones.
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    stone.position = ccp (viewSize.width * 0.5f, viewSize.height * 0.9f);
    
    //2: Calculating random impulse
    float xImpulseMin = -1200.0f;
    float xImpulseMax = 1200.0f;
    float yImpulse = 2000.0f;
    float xImpulse = xImpulseMin + 2.0f * arc4random_uniform(xImpulseMax);
    
    //3: Applying impulse
    [stone.physicsBody applyImpulse:ccp(xImpulse, yImpulse)];
}

-(void)launchBirdWithStone:(CCSprite *)stone
{
    //1: Creating bird sprite
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    PhysicsBird *bird = [[PhysicsBird alloc] initWithBirdType:BirdTypeBig];
    bird.position = ccp(viewSize.width * 1.1f, viewSize.height * 0.9f);
    [_batchNodeBirds addChild:bird]; //note that we add it to _batchNodeBirds
    
    //2: Aiming at the hunter at his current position
    CGPoint targetPosition = _hunter.position;
    
    //3: Giving the stone to the bird and making it fly into the scene
    [bird flyAndDropStoneAt:targetPosition stone:stone];
}


-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //This is just to restart the game when hunter dies by touching the screen
    if (_hunter.state ==  PhysicsHunterStateDead)
    {
        [[CCDirector sharedDirector]
         replaceScene:[PhysicsScene node]];
        return;
    }
    
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


-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair
                        hunter:(CCNode *)hunter
                         stone:(CCNode *)stone
{
    [_hunter die];
    return YES;
}

-(void)fixedUpdate:(CCTime)dt
{
    for (CCSprite *stone in [_stones copy])
    {
        if (stone.position.y < -10)
        {
            [_stones removeObject:stone];
            [stone removeFromParentAndCleanup:YES];
        }
    }
    
    if (_hunter.state != PhysicsHunterStateDead)
    {
        _timeUntilNextStone -= dt;
        if (_timeUntilNextStone <= 0)
        {
            _timeUntilNextStone = 1.0f + arc4random_uniform(1.0f);
            [self spawnStone];
        }
    }
}

@end
