//
//  HighscoresScene.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "HighscoresScene.h"

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "MenuScene.h"

@implementation HighscoresScene

-(instancetype)init
{
    if (self = [super init])
    {
        [self addBackground];
        [self addBackButton];
    }
    
    return self;
}

-(void)addBackground
{
    CCSprite *bg =
    [CCSprite spriteWithImageNamed:@"highscores_bg.png"];
    bg.positionType = CCPositionTypeNormalized;
    bg.position = ccp(0.5f,0.5f);
    [self addChild:bg];
}

-(void)addBackButton
{
    CCSpriteFrame *backNormalImage =
    [CCSpriteFrame frameWithImageNamed:@"btn_back.png"];
    CCSpriteFrame *backHighlightedImage =
    [CCSpriteFrame
     frameWithImageNamed:@"btn_back_pressed.png"];
    CCButton *btnBack =
    [CCButton buttonWithTitle:nil
                  spriteFrame:backNormalImage
       highlightedSpriteFrame:backHighlightedImage
          disabledSpriteFrame:nil];
    
    btnBack.positionType = CCPositionTypeNormalized;
    btnBack.position = ccp(0.1f, 0.9f);
    
    [btnBack setTarget:self selector:@selector(backTapped:)];
    [self addChild:btnBack];
}

-(void)backTapped:(id)sender
{
    CCTransition *transition =
    [CCTransition
     transitionPushWithDirection:CCTransitionDirectionUp
     duration:1.0f];
    MenuScene *scene = [[MenuScene alloc] init];
    [[CCDirector sharedDirector] replaceScene:scene
                               withTransition:transition];
}

@end
