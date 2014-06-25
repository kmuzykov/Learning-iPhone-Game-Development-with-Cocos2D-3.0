//
//  PhysicsHunter.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 22/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "PhysicsHunter.h"
#import "CCAnimation.h"

#define kHunterMovementSpeed    90.0f

@implementation PhysicsHunter
{
    CCAnimation *_runAnimation;
    CCAnimation *_idleAnimation;
    
    PhysicsHunterState _state;
    PhysicsHunterRunDirection _runningDirection;
}

-(instancetype)init
{
    if (self = [super initWithImageNamed:@"physics_hunter_idle_00.png"])
    {
        _state = PhysicsHunterStateIdle;
        
        [self createAnimations];
        [self createPhysicsBody];
    }
    
    return self;
}

-(void)onEnter
{
    [super onEnter];
    [self playIdleAnimation];
}

-(void)createAnimations
{
    NSMutableArray *runFrames = [NSMutableArray array];
    for (int i = 0; i < 10; i++)
    {
        CCSpriteFrame *frame =
        [CCSpriteFrame frameWithImageNamed:
         [NSString
          stringWithFormat:@"physics_hunter_run_%.2d.png",i
          ]];
        [runFrames addObject:frame];
    }
    _runAnimation = [CCAnimation
                     animationWithSpriteFrames:runFrames
                     delay:0.075f];
    
    NSMutableArray *idleFrames = [NSMutableArray array];
    for (int i = 0; i < 3; i++)
    {
        CCSpriteFrame *frame =
        [CCSpriteFrame frameWithImageNamed:
         [NSString
          stringWithFormat:@"physics_hunter_idle_%.2d.png",i
          ]];
        [idleFrames addObject:frame];
    }
    
    _idleAnimation = [CCAnimation animationWithSpriteFrames:idleFrames delay:0.2f];
}

-(void)createPhysicsBody
{
    //Pill shape bottom point
    CGPoint from = ccp(self.contentSizeInPoints.width * 0.5f, self.contentSizeInPoints.height * 0.15f);
    
    //Pill shape top point
    CGPoint to = ccp(self.contentSizeInPoints.width * 0.5f,self.contentSizeInPoints.height * 0.85f);
    
    //Creating hunter body using ill shape
    CCPhysicsBody *body = [CCPhysicsBody bodyWithPillFrom:from to:to cornerRadius:8.0f];
    
    //Not allowing hunter to rotate, or he'll fall on the side.
    body.allowsRotation = NO;
    
    //Fixing hunter sliding too much
    body.friction = 3.0f;
    
    //Setting collision detection related properties
    body.collisionType = @"hunter";

    //Linking hunter with its physics body
    self.physicsBody = body;
}

-(void)runAtDirection:(PhysicsHunterRunDirection)direction;
{
    if (_state != PhysicsHunterStateIdle)
        return;
    
    _runningDirection = direction;
    _state = PhysicsHunterStateRunning;
    
    [self playRunAnimation];
}

-(void)stop
{
    if (_state != PhysicsHunterStateRunning)
        return;
    
    _state = PhysicsHunterStateIdle;
    [self playIdleAnimation];
}

-(void)playRunAnimation
{
    [self stopAllActions];
    
    if (_runningDirection == PhysicsHunterRunDirectionRight)
        self.flipX = NO;
    else
        self.flipX = YES;
    
    CCActionAnimate *animateRun = [CCActionAnimate actionWithAnimation:_runAnimation];
    CCActionRepeatForever *runForever = [CCActionRepeatForever actionWithAction:animateRun];
    [self runAction:runForever];
}

-(void)playIdleAnimation
{
    [self stopAllActions];
    
    CCActionAnimate *animateIdle = [CCActionAnimate actionWithAnimation:_idleAnimation];
    CCActionRepeatForever *idleForever = [CCActionRepeatForever actionWithAction:animateIdle];
    [self runAction:idleForever];
}

-(void)fixedUpdate:(CCTime)dt
{
    if (_state == PhysicsHunterStateRunning)
    {
        CGPoint newVelocity = self.physicsBody.velocity;
        
        if (_runningDirection == PhysicsHunterRunDirectionRight)
            newVelocity.x = kHunterMovementSpeed;
        else
            newVelocity.x = -1 * kHunterMovementSpeed;
        
        self.physicsBody.velocity = newVelocity;
    }
}

-(void)die
{
    if (_state != PhysicsHunterStateDead)
    {
        CCParticleExplosion *explode = [CCParticleExplosion node];
        explode.texture = [CCTexture textureWithFile:@"feather.png"];
        explode.positionType = self.positionType;
        explode.position = self.position;
        
        [[CCDirector sharedDirector].runningScene addChild:explode];
        
        [self removeFromParentAndCleanup:YES];
    }
    
    _state = PhysicsHunterStateDead;
}

@end
