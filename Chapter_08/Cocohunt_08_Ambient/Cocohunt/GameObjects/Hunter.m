//
//  Hunter.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 30/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "Hunter.h"
#import "cocos2d.h"
#import "CCAnimation.h"

#import "AudioManager.h"

@implementation Hunter
{
    //Child torso sprite that will be rotated.
    //Like a turret on the tank.
    CCSprite *_torso;
}

-(instancetype)init
{
    //Using super's init method, since we're subclass of CCSprite
    //and want to reuse all of its functions, but add everything related to the hunter
    //(e.g. rotating torso, spawing arrows,..)
    if (self = [super initWithImageNamed:@"hunter_bottom.png"])
    {
        //Initialising hunter state to Idle
        self.hunterState = HunterStateIdle;
        
        //Creating torso sprite using first frame of animation.
        _torso = [CCSprite spriteWithImageNamed:@"hunter_top_0.png"];
        
        //Setting anchor point at the point where the waist is.
        _torso.anchorPoint = ccp(0.5f, 10.0f/44.0f);
        
        //Setting position of the torso using anchor point to "grow" from legs.
        _torso.position = ccp(self.boundingBox.size.width/2.0f,
                              self.boundingBox.size.height);
        
        //Using z:-1 to put it below the legs sprite, which is parent.
        //This doesn't put it below the background since z-order only affects order within parent node.
        [self addChild:_torso z:-1];
    }
    
    return self;
}

-(CGPoint)torsoCenterInWorldCoordinates
{
    //Returnin the position of child sprite (torso) center in world coordinates.
    //This point is where the hunter's hand and arrow tail is (image is designed this way)
    CGPoint torsoCenterLocal = ccp(_torso.contentSize.width / 2.0f, _torso.contentSize.height / 2.0f);
    CGPoint torsoCenterWorld = [_torso convertToWorldSpace:torsoCenterLocal];
    return torsoCenterWorld;
}

-(float)torsoRotation
{
    return _torso.rotation;
}

-(float)calculateTorsoRotationToLookAtPoint: (CGPoint)targetPoint
{
    //Tail of the arrow
    CGPoint torsoCenterWorld = [self torsoCenterInWorldCoordinates];
    
    //Point straight ahead (used to create forward looking vector)
    CGPoint pointStraightAhead = ccp(torsoCenterWorld.x + 1.0f, torsoCenterWorld.y);
    
    //Vector pointing straight ahead (vector of arrow without any rotation)
    CGPoint forwardVector = ccpSub(pointStraightAhead, torsoCenterWorld);
    
    //Vector from arrow tail to the point where we touch the screen.
    CGPoint targetVector = ccpSub(targetPoint, torsoCenterWorld);
    
    //Calulating angle to rotate the torso, so that the arrow pointed to the target point.
    float angleRadians = ccpAngleSigned(forwardVector, targetVector);
    float angleDegrees = -1 * CC_RADIANS_TO_DEGREES(angleRadians);
    
    //Limiting torso rotation, since the hunter is still a human.
    angleDegrees = clampf(angleDegrees, -60, 25);
    return angleDegrees;
}

-(void)aimAtPoint:(CGPoint)point
{
    if (self.hunterState != HunterStateReloading)
        self.hunterState = HunterStateAiming;
    
    _torso.rotation = [self calculateTorsoRotationToLookAtPoint:point];
}

-(CCSprite*)shootAtPoint:(CGPoint)point
{
    [[AudioManager sharedAudioManager] playSoundEffect:@"arrow_shot.wav"];
    
    //Updating target to the latest point.
    [self aimAtPoint:point];
    
    //Creating arrow image (from batch node)
    CCSprite *arrow = [CCSprite spriteWithImageNamed:@"arrow.png"];
    
    //Setting anchor point to the tail of arrow
    arrow.anchorPoint = ccp(0, 0.5f);
    
    //Placing arrow in hand of the hunter,
    CGPoint torsoCenterGlobal = [self torsoCenterInWorldCoordinates];
    arrow.position = torsoCenterGlobal;
    arrow.rotation = _torso.rotation;
    
    //Adding arrow to the self.parten, which is batch node.
    [self.parent addChild:arrow];
    
    //Finding direction of the arrow
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CGPoint forwardVector = ccp(1.0f, 0);
    float angleRadians =  -1 * CC_DEGREES_TO_RADIANS(_torso.rotation);
    
    //Creating movement trajectory that ends off screen.
    CGPoint arrowMovementVector = ccpRotateByAngle(forwardVector, CGPointZero, angleRadians);
    arrowMovementVector = ccpNormalize(arrowMovementVector);
    arrowMovementVector = ccpMult(arrowMovementVector, viewSize.width * 2.0f);
    
    //Running move action
    CCActionMoveBy *moveAction = [CCActionMoveBy actionWithDuration:2.0f position:arrowMovementVector];
    [arrow runAction:moveAction];
    
    //Starting reload animation
    [self reloadArrow];
    
    //Returning arrow to store in array in use in game scene
    return arrow;
}

-(void)getReadyToShootAgain
{
    self.hunterState = HunterStateIdle;
}

-(void)reloadArrow
{
    //Setting state to Reloading, this won't allow to shoot while reloading is not ended.
    self.hunterState = HunterStateReloading;
    
    //Loading animation frames
    NSString *frameNameFormat = @"hunter_top_%d.png";
    NSMutableArray* frames = [NSMutableArray array];
    for (int i = 0; i < 6; i++)
    {
        NSString *frameName = [NSString stringWithFormat:frameNameFormat, i];
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:frameName];
        [frames addObject:frame];
    }
    
    //Creating animation and animate action
    CCAnimation *reloadAnimation = [CCAnimation animationWithSpriteFrames:frames delay:0.05f];
    reloadAnimation.restoreOriginalFrame = YES;
    CCActionAnimate *reloadAnimAction = [CCActionAnimate actionWithAnimation:reloadAnimation];
    
    //Creating action to reset hunter state
    CCActionCallFunc *readyToShootAgain = [CCActionCallFunc actionWithTarget:self selector:@selector(getReadyToShootAgain)];
    
    //Creating delay to lower the rate of fire.
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.25f];
    
    //Putting all actions into sequence
    CCActionSequence *reloadAndGetReady = [CCActionSequence actions:reloadAnimAction, delay, readyToShootAgain, nil];
    
    //Runnign sequence
    [_torso runAction:reloadAndGetReady];
}

@end
