//
//  FirstScene.m
//  HelloWorld
//
//  Created by Kirill Muzykov on 25/04/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "FirstScene.h"
#import "cocos2d.h"

@implementation FirstScene

-(instancetype)init
{
    if (self = [super init])
    {
        //1
        CCSprite* earth =
        [CCSprite spriteWithImageNamed:@"earth.png"];
        
        //2
        CGSize winSize = [CCDirector sharedDirector].viewSize;
        
        //3
        earth.position = ccp(winSize.width / 2.0f,
                             winSize.height / 2.0f);
        
        //4
        [self addChild:earth];
        
        //1
        CCLabelTTF* welcome =
        [CCLabelTTF labelWithString:@"Hello!"
                           fontName:@"Helvetica"
                           fontSize:32];
        
        //2
        welcome.position = ccp(winSize.width/2.0f,
                               winSize.height * 0.9f);
        
        //3
        [self addChild:welcome];

    }
    
    return self;
}

@end
