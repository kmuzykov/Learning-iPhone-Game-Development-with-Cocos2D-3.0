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
    //1
    CGPoint torsoCenterLocal = ccp(_torso.contentSize.width / 2.0f, _torso.contentSize.height / 2.0f);
    //2
    CGPoint torsoCenterWorld = [_torso convertToWorldSpace:torsoCenterLocal];
    return torsoCenterWorld;
}

-(float)calculateTorsoRotationToLookAtPoint: (CGPoint)targetPoint
{
    //1
    CGPoint torsoCenterWorld = [self torsoCenterInWorldCoordinates];
    
    //2
    CGPoint pointStraightAhead = ccp(torsoCenterWorld.x + 1.0f, torsoCenterWorld.y);
    
    //3
    CGPoint forwardVector = ccpSub(pointStraightAhead, torsoCenterWorld);
    
    //4
    CGPoint targetVector = ccpSub(targetPoint, torsoCenterWorld);
    
    //5
    float angleRadians = ccpAngleSigned(forwardVector, targetVector);
    
    //6
    float angleDegrees = -1 * CC_RADIANS_TO_DEGREES(angleRadians);
    
    //7
    angleDegrees = clampf(angleDegrees, -60, 25);
    return angleDegrees;
}

-(void)aimAtPoint:(CGPoint)point
{
    _torso.rotation = [self calculateTorsoRotationToLookAtPoint:point];
}

@end 
