//
//  LoadingScene.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "LoadingScene.h"

#import "cocos2d.h"
#import "GameScene.h"

@implementation LoadingScene

-(instancetype)init
{
    if (self = [super init])
    {
        CCLabelTTF *loading = [CCLabelTTF labelWithString:@"Loading..."
                                                 fontName:@"Georgia-BoldItalic"
                                                 fontSize:24];
        loading.anchorPoint = ccp(0.5f, 0.5f);
        loading.positionType = CCPositionTypeNormalized;
        loading.position = ccp(0.5f, 0.5f);
        [self addChild:loading];
    }
    
    return self;
}

-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    CCTransition *transition = [CCTransition transitionRevealWithDirection:CCTransitionDirectionDown duration:1.0f];
    GameScene *scene = [[GameScene alloc] init];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:transition];
}

@end
