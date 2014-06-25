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
    CCSprite *_torso;
}

-(instancetype)init
{
    if (self = [super initWithImageNamed:@"hunter_bottom.png"])
    {
        _torso =
        [CCSprite spriteWithImageNamed:@"hunter_top.png"];
        
        _torso.anchorPoint = ccp(0.5f, 10.0f/44.0f);
        _torso.position = ccp(self.boundingBox.size.width/2.0f,
                              self.boundingBox.size.height);
        
        [self addChild:_torso z:-1];
    }
    
    return self;
}

@end 
