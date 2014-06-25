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

//Needed to use gyro.
@import CoreMotion;

#import "HUDLayer.h"

typedef NS_ENUM(NSUInteger, Z_ORDER)
{
    Z_BACKGROUND,
    Z_BATCH_NODE,
    Z_HUD
};

@implementation GameScene
{
    //Batch node to use spritesheet.
    CCSpriteBatchNode *_batchNode;
    
    //Reference to hunter game object in the scene.
    Hunter *_hunter;
    
    //Timer to spawn birds.
    float _timeUntilNextBird;
    
    //Arrays to store birds and arrows,
    //check intersection and remove when not needed.
    NSMutableArray *_birds;
    NSMutableArray *_arrows;
    
    //How many birds to spawn and how many birds
    //can fly away before the player loses the game.
    int _birdsToSpawn;
    int _birdsToLose;
    
    //Aiming indicator related.
    int _maxAimingRadius;
    CCSprite *_aimingIndicator;
    
    //Gyroscope related.
    BOOL _useGyroToAim;
    CMMotionManager *_motionManager;
    
    HUDLayer *_hud;
    
    GameStats *_gameStats;
}

-(instancetype)init
{
    if (self = [super init])
    {
        //If we should use gyro to aim. Set to NO if you test on simulator.
        _useGyroToAim = NO;
        
        //Starting uninitialized (the game is not started yet)
        self.gameState = GameStateUninitialized;
        
        //Default values for (wining/losing)
        _birdsToSpawn = 20;
        _birdsToLose = 3;
        
        //Time until first bird is spawned.
        _timeUntilNextBird = 0;
        
        //Initializing arrays.
        _birds = [NSMutableArray array];
        _arrows = [NSMutableArray array];
        
        //We want to handle touches.
        self.userInteractionEnabled = YES;
        
        [self createBatchNode];
        [self addBackground];
        [self addHunter];
        
        [self setupAimingIndicator];
        
        [self initializeHUD];
        
        //Note: always call this method AFTER initializeHUD
        [self initializeStats];
    }
    
    return self;
}

-(void)initializeHUD
{
    _hud = [[HUDLayer alloc] init];
    [self addChild:_hud z:Z_HUD];
}

-(void)initializeStats
{
    _gameStats = [[GameStats alloc] init];
    _gameStats.birdsLeft = _birdsToSpawn;
    _gameStats.lives = _birdsToLose;
    
    [_hud updateStats:_gameStats];
}

-(void)initializeControls
{
    if (_useGyroToAim)
    {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1.0/60;
        [_motionManager startDeviceMotionUpdates];
    }
}

-(void)onEnter
{
    //Don't forget this!
    [super onEnter];
    
    //Starting the game.
    self.gameState = GameStatePlaying;
    
    //If using gyro this will initialize it.
    [self initializeControls];
}

-(void)setupAimingIndicator
{
    //Aiming radius (i.e. how close to the hunter we should tap to be able to shoot)
    _maxAimingRadius = 100;
    
    //Aiming indicator sprite.
    _aimingIndicator =  [CCSprite  spriteWithImageNamed:@"power_meter.png"];
    _aimingIndicator.opacity = 0.3f;
    _aimingIndicator.anchorPoint = ccp(0,0.5f);
    _aimingIndicator.visible = NO;
    
    [_batchNode addChild:_aimingIndicator];
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
    [self addChild:_batchNode z:Z_BATCH_NODE];
}

-(void)addBackground
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CCSprite *background = [CCSprite spriteWithImageNamed:@"game_scene_bg.png"];
    background.position = ccp(viewSize.width  * 0.5f, viewSize.height * 0.5f);
    
    [self addChild:background z:Z_BACKGROUND];
}

-(void)addHunter
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    _hunter = [[Hunter alloc] init];
    
    //Calculating hunter position relative to center, to make sure he
    //is placed at the same position on 3.5 and 4 inch wide displays.
    float hunterPositionX = viewSize.width * 0.5f - 180.0f;
    
    float hunterPositionY = viewSize.height * 0.3f;
    
    _hunter.position = ccp(hunterPositionX, hunterPositionY);
    
    [_batchNode addChild:_hunter];
}

-(void)update:(CCTime)dt
{
    //If game is not playing state, do nothing.
    if (self.gameState != GameStatePlaying)
        return;
    
    //Updating gyro aim (if its enabled)
    [self updateGyroAim];
    
    //Spawning birds
    _timeUntilNextBird -= dt;
    if (_timeUntilNextBird <= 0 && _birdsToSpawn > 0)
    {
        //Spawing bird and decreasing counter.
        [self spawnBird];
        _birdsToSpawn--;
        
        //Calculating random time until next bird.
        int nextBirdTimeMax = 5;
        int nextBirdTimeMin = 2;
        int nextBirdTime = nextBirdTimeMin + arc4random_uniform(nextBirdTimeMax - nextBirdTimeMin);
        _timeUntilNextBird = nextBirdTime;
        
        _gameStats.birdsLeft = _birdsToSpawn;
        [_hud updateStats:_gameStats];
    }
    
    //Detecting collisions.
    
    //1
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CGRect viewBounds = CGRectMake(0,0, viewSize.width, viewSize.height);
    
    //2
    for (int i = _birds.count - 1; i >= 0; i--)
    {
        Bird *bird = _birds[i];
        
        //3
        BOOL birdFlewOffScreen = (bird.position.x + (bird.contentSize.width * 0.5f)) > viewSize.width;
        
        //4
        if (bird.birdState == BirdStateFlyingOut && birdFlewOffScreen)
        {
            _birdsToLose--;
            
            _gameStats.lives = _birdsToLose;
            [_hud updateStats:_gameStats];
            
            [bird removeBird:NO];
            [_birds removeObject:bird];
            continue;
        }
        
        //5
        for (int j = _arrows.count - 1; j >= 0; j--)
        {
            CCSprite* arrow = _arrows[j];
            
            //6
            if (!CGRectContainsPoint(viewBounds, arrow.position))
            {
                [arrow removeFromParentAndCleanup:YES];
                [_arrows removeObject:arrow];
                continue;
            }
            
            //7
            if (CGRectIntersectsRect(arrow.boundingBox, bird.boundingBox))
            {
                [arrow removeFromParentAndCleanup:YES];
                [_arrows removeObject:arrow];
                
                int score = [bird removeBird:YES];
                [_birds removeObject:bird];
                
                _gameStats.score += score;
                [_hud updateStats:_gameStats];
                
                break;
            }
        }
    }
    
    [self checkWonLost];
}

-(void)checkWonLost
{
    if (_birdsToLose <= 0)
    {
        [self lost];
    }
    else if (_birdsToSpawn <= 0 && _birds.count <= 0)
    {
        [self won];
    }
}

-(void)lost
{
    self.gameState = GameStateLost;
    CCLOG(@"YOU LOST!");
}

-(void)won
{
    self.gameState = GameStateWon;
    CCLOG(@"YOU WON!");
}

-(void)spawnBird
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;

    //Randomizing bird height.
    int maxY = viewSize.height * 0.9f;
    int minY = viewSize.height * 0.6f;
    int birdY = minY + arc4random_uniform(maxY - minY);
    int birdX = viewSize.width * 1.3f;
    CGPoint birdStart = ccp(birdX, birdY);
    
    //Random bird type.
    BirdType birdType = (BirdType)(arc4random_uniform(3));
    Bird* bird = [[Bird alloc] initWithBirdType:birdType];
    bird.position = birdStart;
    
    //Adding to batch node and to array (to check for intersection later)
    [_batchNode addChild:bird];
    [_birds addObject:bird];
    
    //Picking up random time for bird to fly through screen (setting bird speed)
    int maxTime = 20;
    int minTime = 10;
    int birdTime =  minTime + (arc4random() % (maxTime - minTime));
    CGPoint screenLeft = ccp(0, birdY);
    
    //Setting up bird movement sequence: fly in, turnaround, fly out, turnaround
    CCActionMoveTo *moveToLeftEdge = [CCActionMoveTo actionWithDuration:birdTime position:screenLeft];
    CCActionCallFunc *turnaround = [CCActionCallFunc actionWithTarget:bird selector:@selector(turnaround)];
    CCActionMoveTo *moveBackOffScreen = [CCActionMoveTo actionWithDuration:birdTime position:birdStart];
    CCActionSequence *moveLeftThenBack = [CCActionSequence actions: moveToLeftEdge, turnaround, moveBackOffScreen, turnaround, nil];
    
    //Repeating this sequence forever. The bird will be removed when its _timesToVisit reaches 0 or hit by an arrow.
    CCActionRepeatForever *flyForever = [CCActionRepeatForever actionWithAction:moveLeftThenBack];
    [bird runAction:flyForever];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //If not in Plauing state. Not handling this touch.
    if (self.gameState != GameStatePlaying)
    {
        [super touchBegan:touch withEvent:event];
        return;
    }
    
    if (_useGyroToAim)
    {
        //If using gyro, then checking if hunter is not reloading. Since it is always aiming.
        if (_hunter.hunterState != HunterStateReloading)
        {
            //If valid state, shooting straight away (not in touchEnded)
            CGPoint targetPoint = [self getGyroTargetPoint];
            CCSprite* arrow =[_hunter shootAtPoint:targetPoint];
            [_arrows addObject:arrow];
        }
        
        //Also not handling touch since using gyro.
        [super touchBegan:touch withEvent:event];
    }
    else
    {
        //In case using touches the only state we can start aiming is Idle.
        if (_hunter.hunterState != HunterStateIdle)
        {
            [super touchBegan:touch withEvent:event];
            return;
        }
        
        CGPoint touchLocation = [touch locationInNode:self];
        [_hunter aimAtPoint:touchLocation];
        
        _aimingIndicator.visible = YES;
        [self checkAimingIndicatorForPoint:touchLocation];
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    //Updating hunter aim and aimind indicator,
    CGPoint touchLocation = [touch locationInNode:self];
    [_hunter aimAtPoint:touchLocation];
    [self checkAimingIndicatorForPoint:touchLocation];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.gameState != GameStatePlaying)
        return;
    
    //This code is only executed when using touch controls (not gyro)
    CGPoint touchLocation = [touch locationInNode:self];
    BOOL canShoot = [self checkAimingIndicatorForPoint:touchLocation];
    
    //If can shoot (touching in aiming radious), shooting, else at least reseting hunter to idle.
    if (canShoot)
    {
        CCSprite* arrow = [_hunter shootAtPoint:touchLocation];
        [_arrows addObject:arrow];
    }
    else
    {
        [_hunter getReadyToShootAgain];
    }
    
    //In both cases hiding aiming indicator.
    _aimingIndicator.visible = NO;
}

-(void)touchCancelled:(NSSet *)touch withEvent:(UIEvent *)event
{
    //Reseting hunter or he will stuck in aiming in case the touch was canceled.
    [_hunter getReadyToShootAgain];
}

-(BOOL)checkAimingIndicatorForPoint:(CGPoint)point
{
    //Placing aiming indicator tail to where the hunter hand is and arrow's tail
    //Don't forget we set the aiming indicator anchor point.
    _aimingIndicator.position = [_hunter torsoCenterInWorldCoordinates];
    _aimingIndicator.rotation = [_hunter torsoRotation];
    
    //Calculating if we're tapping close enough to shoot.
    float distance = ccpDistance(_aimingIndicator.position, point);
    BOOL isInRange = distance < _maxAimingRadius;
    
    //Scaling the aiming indicator so that its tail stayed at hunter's hand,
    //and its tip touching the target point.
    float scale = distance/_aimingIndicator.contentSize.width;
    _aimingIndicator.scale = scale;
    
    //Setting aiming indicator color
    _aimingIndicator.color = isInRange ? [CCColor greenColor] : [CCColor redColor];
    
    //This one will be used to check if the hunter can make a shoot.
    return isInRange;
}

-(CGPoint)getGyroTargetPoint
{
    //Getting gyro data.
    CMDeviceMotion *motion = _motionManager.deviceMotion;
    CMAttitude *attitude = motion.attitude;
    
    //Using pitch to aim,
    float pitch = attitude.pitch;
    
    //Using roll to detect which side of iPhone is up
    //(home button on the left or on the right)
    float roll = attitude.roll;
    if (roll > 0)
        pitch = -1 * pitch;
    
    //Simulating that we touched the point on the screen using gyro angle.
    //This allows to make changes to the Hunter class minimum, since we also pass a point just as we touched the screen.
    CGPoint forward = ccp(1.0, 0);
    CGPoint rot = ccpRotateByAngle(forward, CGPointZero, pitch);
    CGPoint targetPoint = ccpAdd([_hunter torsoCenterInWorldCoordinates], rot);
    return targetPoint;
}

-(void)updateGyroAim
{
    if (!_useGyroToAim)
        return;
    
    CGPoint targetPoint = [self getGyroTargetPoint];
    [_hunter aimAtPoint:targetPoint];
}

@end
