//
//  Coconut.m
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "Coconut.h"
#import "cocos2d.h"

@implementation Coconut

-(instancetype)init
{
    if (self = [super initWithImageNamed:@"coconut.png"])
    {
        self.userInteractionEnabled = YES;
        
        float coconutX = clampf(CCRANDOM_0_1(), 0.05f, 0.95f);
        self.positionType = CCPositionTypeNormalized;
        self.position = ccp(coconutX, 1.1f);
    }
    
    return self;
}

-(void)onEnter
{
    [super onEnter];
    
    float coconutSpeed = 3.0f + CCRANDOM_0_1() * 2.0f;
    CCActionMoveTo *moveDown = [CCActionMoveTo  actionWithDuration:coconutSpeed position:ccp(self.position.x, -0.1f)];
    CCActionEaseIn *moveDownEased = [CCActionEaseIn actionWithAction:moveDown rate:2.0f];
    CCActionCallFunc *notify = [CCActionCallFunc actionWithTarget:self selector:@selector(fallenOffScreen)];
    CCActionSequence *fallDownAndNotify = [CCActionSequence actions:moveDownEased, notify, nil];
    [self runAction:fallDownAndNotify];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.delegate coconutRemovedAt:self.position];
    [self removeFromParentAndCleanup:YES];
}

-(void)fallenOffScreen;
{
    [self.delegate fallenOffScreenAt:self.position];
    [self removeFromParentAndCleanup:YES];
}
@end
