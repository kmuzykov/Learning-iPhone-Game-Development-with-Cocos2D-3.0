//
//  PhysicsBird.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 23/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "PhysicsBird.h"

#import "PhysicsBird.h"
#import "cocos2d.h"

/** The bird lifecycle. */
typedef NS_ENUM(NSUInteger, PhysicsBirdState)
{
    PhysicsBirdStateIdle,
    PhysicsBirdStateFlyingIn,
    PhysicsBirdStateFlyingOut
};

@implementation PhysicsBird
{
    //Current state of the bird
    PhysicsBirdState _state;
    
    //The point where the bird should drop the stone at
    CGPoint _targetPoint;
    
    //Joint holding the stone
    CCPhysicsJoint *_stoneJoint;
}

-(instancetype)initWithBirdType:(BirdType)typeOfBird
{
    //1: Reusing the Bird's init method to create a bird.
    if (self = [super initWithBirdType:typeOfBird])
    {
        //2: Starting Idle
        _state = PhysicsBirdStateIdle;
        
        //3: Creating physics body for the bird itself (to apply force to it and attach a stone using joint)
        CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:self.contentSize.height*0.3f andCenter:self.anchorPointInPoints];
        body.collisionType = @"bird";
        body.type = CCPhysicsBodyTypeDynamic;
        body.mass = 30.0f;
        self.physicsBody = body;
    }
    
    return self;
}

-(void)flyAndDropStoneAt:(CGPoint)point stone:(CCSprite*)stone
{
    //1: Starting to fly in
    _state = PhysicsBirdStateFlyingIn;
    _targetPoint = point;
    self.stoneToDrop = stone;
    
    //2: At the start stone is not colliding with anything, so that it didn't hit the bird if swings too high.
    self.stoneToDrop.physicsBody.collisionMask = @[];
    self.physicsBody.collisionMask = @[];
    
    //3: Calculating the distance
    float distanceToHoldTheStone = self.contentSize.height * 0.5f;
    self.stoneToDrop.position = ccpSub(self.position, ccp(0, distanceToHoldTheStone));
    
    //4
    _stoneJoint = [CCPhysicsJoint connectedDistanceJointWithBodyA: self.physicsBody
                                                            bodyB: stone.physicsBody
                                                          anchorA: self.anchorPointInPoints
                                                          anchorB: stone.anchorPointInPoints];
}

-(void)fixedUpdate:(CCTime)dt
{
    //1: Calculating vertical force to hold the bird in the air.
    float forceToHoldBird = -1 * self.physicsBody.mass * self.physicsNode.gravity.y;
    
    //2: Checking the bird state
    if (_state == PhysicsBirdStateFlyingIn)
    {
        //3: If bird is flying in than it carries a stone. Adding vertical force to hold the stone.
        float forceToHoldStone = -1 * self.stoneToDrop.physicsBody.mass * self.physicsNode.gravity.y;
        
        //4: Total force to hold the bird and the stone (joint weights nothing)
        float forceUp = forceToHoldBird + forceToHoldStone;
        
        //5: Applying force to the bird to keep it in the air
        [self.physicsBody applyForce:ccp(-1500, forceUp)];
        
        //6: If reached target point dropping the stone and switching to next state.
        if (self.position.x <= _targetPoint.x)
        {
            _state = PhysicsBirdStateFlyingOut;
            [self dropStone];
        }
    }
    else if (_state == PhysicsBirdStateFlyingOut)
    {
        //7: Making bird to fly up
        float forceUp = forceToHoldBird * 1.5f;
        
        //8: Appluing force to fly up
        [self.physicsBody applyForce:ccp(0, forceUp)];
        
        //9: Checkinf if the bird left the screen.
        CGSize viewSize = [CCDirector sharedDirector].viewSize;
        if (self.position.y > viewSize.height)
        {
            [self removeFromParentAndCleanup:YES];
        }
    }
}

-(void)dropStone
{
    self.stoneToDrop.physicsBody.collisionMask = nil;
    [_stoneJoint invalidate];
}

@end
