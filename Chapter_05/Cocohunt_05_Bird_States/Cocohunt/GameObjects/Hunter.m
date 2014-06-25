//
//  Hunter.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 30/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "Hunter.h"

#import "cocos2d.h"

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
    CGPoint torsoCenterLocal = ccp(_torso.contentSize.width / 2.0f, _torso.contentSize.height / 2.0f);
    
    CGPoint torsoCenterWorld = [_torso convertToWorldSpace:torsoCenterLocal];
    
    return torsoCenterWorld;
}

-(float)calculateTorsoRotationToLookAtPoint: (CGPoint)targetPoint
{
    CGPoint torsoCenterWorld = [self torsoCenterInWorldCoordinates];
    
    CGPoint pointStraightAhead = ccp(torsoCenterWorld.x + 1.0f, torsoCenterWorld.y);
    
    CGPoint forwardVector = ccpSub(pointStraightAhead, torsoCenterWorld);
    
    CGPoint targetVector = ccpSub(targetPoint, torsoCenterWorld);
    
    float angleRadians = ccpAngleSigned(forwardVector, targetVector);
    
    float angleDegrees = -1 * CC_RADIANS_TO_DEGREES(angleRadians);
    
    angleDegrees = clampf(angleDegrees, -60, 25);
    return angleDegrees;
}

-(void)aimAtPoint:(CGPoint)point
{
    _torso.rotation = [self calculateTorsoRotationToLookAtPoint:point];
}

-(CCSprite*)shootAtPoint:(CGPoint)point
{
    //1
    [self aimAtPoint:point];
    
    //2
    CCSprite *arrow =
    [CCSprite spriteWithImageNamed:@"arrow.png"];
    
    //3
    arrow.anchorPoint = ccp(0, 0.5f);
    
    //4
    CGPoint torsoCenterGlobal =
    [self torsoCenterInWorldCoordinates];
    arrow.position = torsoCenterGlobal;
    arrow.rotation = _torso.rotation;
    
    //5
    [self.parent addChild:arrow];
    
    //6
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    CGPoint forwardVector = ccp(1.0f, 0);
    float angleRadians =
    -1 * CC_DEGREES_TO_RADIANS(_torso.rotation);
    CGPoint arrowMovementVector =
    ccpRotateByAngle(forwardVector,
                     
                     CGPointZero,
                     angleRadians);
    arrowMovementVector =
    ccpNormalize(arrowMovementVector);
    arrowMovementVector = ccpMult(arrowMovementVector,
                                  
                                  viewSize.width * 2.0f);
    
    //7
    CCActionMoveBy *moveAction =
    [CCActionMoveBy
     actionWithDuration:2.0f
     
     position:arrowMovementVector];
    [arrow runAction:moveAction];
    
    //8
    return arrow;
}


@end 
