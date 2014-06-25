//
//  LevelSelectScene.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "LevelSelectScene.h"

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "MenuScene.h"

#import "GameScene.h"

#define kLevelHunting   @"hunting"
#define kLevelDodging   @"dodging"

@implementation LevelSelectScene

-(instancetype)init
{
    if (self = [super init])
    {
        [self addBackground];
        [self addBackButton];
        [self addScroll];
    }
    
    return self;
}

-(void)addBackground
{
    CCSprite *bg =
    [CCSprite spriteWithImageNamed:@"level_select_bg.png"];
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
     transitionPushWithDirection:CCTransitionDirectionDown
     duration:1.0f];
    
    MenuScene *scene = [[MenuScene alloc] init];
    [[CCDirector sharedDirector] replaceScene:scene
                               withTransition:transition];
}

-(void)addScroll
{
    //1
    int levels = 10;
    
    //2
    CCNode *scrollViewContents = [CCNode node];
    scrollViewContents.contentSizeType = CCSizeTypeNormalized;
    scrollViewContents.contentSize = CGSizeMake(levels, 1);
    
    for (int i =0; i < levels; i++)
    {
        //3
        CCButton *level = nil;
        if (i % 2 == 0)
        {
            CCSpriteFrame *levelImage =
            [CCSpriteFrame
             frameWithImageNamed:@"hunting_level.png"];
            level = [CCButton buttonWithTitle:nil
                                  spriteFrame:levelImage];
            level.name = kLevelHunting;
        }
        else
        {
            CCSpriteFrame *levelImage =
            [CCSpriteFrame
             frameWithImageNamed:@"dodging_level.png"];
            level = [CCButton buttonWithTitle:nil
                                  spriteFrame:levelImage];
            level.name = kLevelDodging;
        }
        
        level.positionType = CCPositionTypeNormalized;
        level.position = ccp((i + 0.5f)/levels, 0.5f);
        
        //4
        [level setTarget:self
                selector:@selector(levelTapped:)];
        
        //5
        [scrollViewContents addChild:level];
    }
    
    //6
    CCScrollView *scrollView =
    [[CCScrollView alloc]
     initWithContentNode:scrollViewContents];
    
    //7
    scrollView.pagingEnabled = YES;
    
    //8
    scrollView.horizontalScrollEnabled = YES;
    scrollView.verticalScrollEnabled = NO;
    
    [self addChild:scrollView];
}

-(void)levelTapped:(id)sender
{
    NSString *levelName = ((CCButton*)sender).name;
    if ([levelName isEqualToString:kLevelHunting])
    {
        GameScene *scene = [[GameScene alloc] init];
        CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:1.0f];
        
        [[CCDirector sharedDirector] replaceScene:scene withTransition:transition];
    }
    else
    {
        CCLOG(@"Level not implemented: %@", levelName);
    }
}

@end
