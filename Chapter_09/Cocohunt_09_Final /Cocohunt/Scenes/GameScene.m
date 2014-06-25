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
#import "AudioManager.h"
#import "PauseDialog.h"
#import "cocos2d-ui.h"
#import "WinLoseDialog.h"

/** z-orders for scene direct child nodes */
typedef NS_ENUM(NSUInteger, Z_ORDER)
{
    Z_BACKGROUND,
    Z_BATCH_NODE,
    Z_LABELS,
    Z_HUD,
    Z_PAUSE_BUTTON,
    Z_DIALOGS
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
    
    //Reference to HUD layer, to update labels.
    HUDLayer *_hud;
    
    //Current game stats (lives, points,..)
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
        
        //Gameplay configuration (amount if enemies and amount of lives)
        _birdsToSpawn = 1;
        _birdsToLose = 1;
        
        //Time until first bird is spawned.
        _timeUntilNextBird = 0;
        
        //Initializing arrays.
        _birds = [NSMutableArray array];
        _arrows = [NSMutableArray array];
        
        //We want to handle touches.
        self.userInteractionEnabled = YES;
        
        //Creating batch node, importat to do it before adding hunter and birds.
        [self createBatchNode];
        
        //Adding background (its okay to add after batch node, since we've set z-order)
        [self addBackground];
        
        //Adding hunter.
        [self addHunter];
        
        //Setting up aiming indicator sprite.
        [self setupAimingIndicator];
        
        //Creating and initializing HUD
        [self initializeHUD];
        
        //Initializing game stats
        //Note: always call this method AFTER initializeHUD
        [self initializeStats];
        
        //Adding pause button
        [self addPauseButton];
    }
    
    return self;
}

-(void)initializeHUD
{
    //Create hud node and add it to the scene.
    _hud = [[HUDLayer alloc] init];
    [self addChild:_hud z:Z_HUD];
}

-(void)initializeStats
{
    //Setting stats to default values
    _gameStats = [[GameStats alloc] init];
    _gameStats.birdsLeft = _birdsToSpawn;
    _gameStats.lives = _birdsToLose;
    
    //Setting labels in HUD to display default lives and birds left.
    [_hud updateStats:_gameStats];
}

-(void)initializeControls
{
    if (_useGyroToAim)
    {
        //In case of gyro aiming mode initializing the CMMotionManager
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
    
    //Creating and starting campfire particle system.
    [self startFire];
    
    //Creating and starting the sun particle system.
    //Note remove #if and #endif lines if you want to test it on simulator.
#if !TARGET_IPHONE_SIMULATOR
    [self createTheSun];
#endif
    
    //Playing nature sounds.
    //This line is replaced..
    //[[AudioManager sharedAudioManager] playBackgroundSound:@"naturesounds.mp3"];
    
    //..by this line in the Time For Action – Adding Music section (Chapter 8)
    [[AudioManager sharedAudioManager] playMusic];
}

-(void)onExit
{
    //Don't forget this!
    [super onExit];
    
    //Stopping music when exiting the game.
    [[AudioManager sharedAudioManager] stopMusic];
}

-(void)startFire
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    //Adding stone and wood image (campfire) as a base for fire particle system.
    CCSprite *campfire = [CCSprite spriteWithImageNamed:@"campfire.png"];
    campfire.position = ccp(viewSize.width * 0.5, viewSize.height * 0.05f);
    [self addChild:campfire];
    
    //Calculating the point where the fire starts.
    CGPoint campfireTop = ccp(campfire.position.x,
                              campfire.position.y + campfire.boundingBox.size.height * 0.5f);
    
    //Creating predefined particle system and placing it at the top of the campfire sprite.
    CCParticleFire *fire = [CCParticleFire particleWithTotalParticles:300];
    fire.position = campfireTop;
    
    //Re-using feather texture as fire particle, to demonstrate how white feathers become flames.
    fire.texture = [CCTexture textureWithFile:@"feather.png"];
    
    //Scaling it down a bit, since by default it is too big. Using scale property instead of tuning the PS itself.
    fire.scale = 0.3f;
    
    //Adding to the scene.
    [self addChild:fire];
}

-(void)createTheSun
{
    //Loading Red Sun particle system exported from Particle Designer 2.
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CCParticleSystem *sun = [CCParticleSystem particleWithFile:@"sun.plist"];
    sun.position = ccp(viewSize.width  * 0.05f, viewSize.height * 0.9f);
    [self addChild:sun];
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
    
    //Note z parameter.
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
    
    //Counting time player spent before wining or losing.
    _gameStats.timeSpent += dt;
    
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
        int nextBirdTimeMax = 3;
        int nextBirdTimeMin = 1;
        int nextBirdTime = nextBirdTimeMin + arc4random_uniform(nextBirdTimeMax - nextBirdTimeMin);
        _timeUntilNextBird = nextBirdTime;
        
        _gameStats.birdsLeft = _birdsToSpawn;
        [_hud updateStats:_gameStats];
    }
    
    //Detecting collisions.
    
    //Screen bounds (if anything is outside this rect, its not on screen)
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CGRect viewBounds = CGRectMake(0,0, viewSize.width, viewSize.height);
    
    //Enumerating birds
    for (int i = _birds.count - 1; i >= 0; i--)
    {
        Bird *bird = _birds[i];
        
        //Checking if the bird is on screen.
        BOOL birdFlewOffScreen = (bird.position.x + (bird.contentSize.width * 0.5f)) > viewSize.width;
        
        //If bird doesn't come back removing it and updating stats, lives.
        if (bird.birdState == BirdStateFlyingOut && birdFlewOffScreen)
        {
            _birdsToLose--;
            
            _gameStats.lives = _birdsToLose;
            [_hud updateStats:_gameStats];
            
            [bird removeBird:NO];
            [_birds removeObject:bird];
            continue;
        }
        
        //For each bird checking if there is an arrow that is hitting it (at current frame)
        for (int j = _arrows.count - 1; j >= 0; j--)
        {
            CCSprite* arrow = _arrows[j];
            
            //If the arrow out of screen, removing it to free some resources.
            if (!CGRectContainsPoint(viewBounds, arrow.position))
            {
                [arrow removeFromParentAndCleanup:YES];
                [_arrows removeObject:arrow];
                continue;
            }
            
            //If the arrow hits this bird, removing bird & arrow, updating points and so on.
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
    //Stopping music when lost
    [[AudioManager sharedAudioManager] stopMusic];
    
    //Playng losing sound effect
    [[AudioManager sharedAudioManager] playSoundEffect:kSoundLose];
    
    //Changing state and displaying the label
    self.gameState = GameStateLost;
    [self displayWinLoseLabelWithText:@"You lose!" andFont:@"lost.fnt"];
    
    //Showing dialog.
    WinLoseDialog *wlDialog = [[WinLoseDialog alloc] initWithGameStats:_gameStats];
    [self addChild:wlDialog];
}

-(void)won
{
    //Stopping music when won
    [[AudioManager sharedAudioManager] stopMusic];
    
    //Playing winning sound effect.
    [[AudioManager sharedAudioManager] playSoundEffect:kSoundWin];
    
    self.gameState = GameStateWon;
    [self displayWinLoseLabelWithText:@"You win!" andFont:@"win.fnt"];
    
    WinLoseDialog *wlDialog = [[WinLoseDialog alloc] initWithGameStats:_gameStats];
    [self addChild:wlDialog];
}

-(void)displayWinLoseLabelWithText:(NSString *)text
                           andFont:(NSString *)fontFileName
{
    //Creating label in its final position.
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CCLabelBMFont *label = [CCLabelBMFont labelWithString:text fntFile:fontFileName];
    label.position = ccp(viewSize.width * 0.5f, viewSize.height * 0.85f);
    [self addChild:label z:Z_LABELS];
    
    //Setting initial scale to almost invisible (the label will pop out)
    label.scale = 0.01f;
    
    //Creating eased action to scale label out at 1.5x scale...
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:1.5f scale:1.2f];
    CCActionEaseIn  *easedScaleUp = [CCActionEaseIn actionWithAction:scaleUp rate:5.0f];

    //..and then to final 1.0x scale (this will create a requried effect)
    CCActionScaleTo *scaleNormal = [CCActionScaleTo actionWithDuration:0.5f scale:1.0f];
    
    //Creating sequence for the label and running it.
    CCActionSequence *scaleUpThenNormal = [CCActionSequence actions:easedScaleUp, scaleNormal,  nil];
    [label runAction:scaleUpThenNormal];
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
    int maxTime = 6;
    int minTime = 4;
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

-(void)addPauseButton
{
    CCSpriteFrame *pauseNormalImage = [CCSpriteFrame frameWithImageNamed:@"btn_pause.png"];
    CCSpriteFrame *pauseHighlightedImage  = [CCSpriteFrame frameWithImageNamed:@"btn_pause_pressed.png"];
    CCButton *btnPause = [CCButton buttonWithTitle:nil
                                       spriteFrame:pauseNormalImage
                            highlightedSpriteFrame:pauseHighlightedImage
                               disabledSpriteFrame:nil];
    
    btnPause.positionType = CCPositionTypeNormalized;
    btnPause.position = ccp(0.95f, 0.05f);
    [btnPause setTarget:self
               selector:@selector(btnPauseTapped:)];
    
    [self addChild:btnPause z:Z_PAUSE_BUTTON];
}

-(void)btnPauseTapped:(id)sender
{
    if (_gameState != GameStatePlaying)
        return;
    
    _gameState = GameStatePaused;
    
    for (Bird *bird in _birds)
        bird.paused = YES;
    
    for (CCSprite *arrow in _arrows)
        arrow.paused = YES;
    
    PauseDialog *dlg = [[PauseDialog alloc] init];
    dlg.onCloseBlock = ^{
        
        _gameState = GameStatePlaying;
        
        for (Bird *bird in _birds)
            bird.paused = NO;
        
        for (CCSprite *arrow in _arrows)
            arrow.paused = NO;
        
    };
    [self addChild:dlg z:Z_DIALOGS];
}

@end
