//
//  PhysicsHunter.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 22/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "cocos2d.h"

typedef NS_ENUM(NSUInteger, PhysicsHunterState)
{
    PhysicsHunterStateIdle,
    PhysicsHunterStateRunning,
    PhysicsHunterStateDead
};

typedef NS_ENUM(NSInteger, PhysicsHunterRunDirection)
{
    PhysicsHunterRunDirectionLeft,
    PhysicsHunterRunDirectionRight
};

@interface PhysicsHunter : CCSprite

@property (nonatomic, readonly) PhysicsHunterState state;

-(void)runAtDirection:(PhysicsHunterRunDirection)direction;

-(void)stop;

-(void)die;

@end
