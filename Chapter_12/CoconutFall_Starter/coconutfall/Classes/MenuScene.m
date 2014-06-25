//
//  MenuScene.m
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "MenuScene.h"

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "GameScene.h"
#import "ShopScene.h"

#define kButtonStart        @"Start"
#define kButtonAchievements @"Achievements"
#define kButtonLeaderboards @"Leaderboards"
#define kButtonShop         @"Shop"

@implementation MenuScene

-(instancetype)init
{
    if (self = [super init])
    {
        [self addBackground];
        [self addButtons];
    }
    
    return self;
}

-(void)addBackground
{
    CCSprite *bg =
    [CCSprite spriteWithImageNamed:@"menu_bg.png"];
    bg.positionType = CCPositionTypeNormalized;
    bg.position = ccp(0.5f, 0.5f);
    [self addChild:bg];
}

-(void)addButtons
{
    CCLayoutBox *buttonsLayout = [CCLayoutBox node];
    buttonsLayout.spacing = 20.0f;
    buttonsLayout.direction = CCLayoutBoxDirectionVertical;
    
    NSArray *buttons = @[kButtonStart,
                         kButtonAchievements,
                         kButtonLeaderboards,
                         kButtonShop];
    
    CCSpriteFrame *btnNormal =
    [CCSpriteFrame frameWithImageNamed:@"btn_9slice.png"];
    CCSpriteFrame *btnPressed =
    [CCSpriteFrame
     frameWithImageNamed:@"btn_9slice_pressed.png"];
    
    for (NSString *btnName in
         [buttons reverseObjectEnumerator])
    {
        CCButton *button = [CCButton buttonWithTitle:btnName
                                         spriteFrame:btnNormal
                              highlightedSpriteFrame:btnPressed
                                 disabledSpriteFrame:nil];
        button.name = btnName;
        button.horizontalPadding = 12.0f;
        button.verticalPadding = 4.0f;
        
        [button setTarget:self selector:@selector(onBtnTap:)];
        
        [buttonsLayout addChild:button];
    }
    
    [buttonsLayout layout];
    
    buttonsLayout.anchorPoint = ccp(0.5f, 0.5f);
    buttonsLayout.positionType = CCPositionTypeNormalized;
    buttonsLayout.position = ccp(0.5f, 0.5f);
    [self addChild:buttonsLayout];
}

-(void)onBtnTap:(CCButton *)btn
{
    if ([btn.name isEqualToString:kButtonStart])
    {
        [[CCDirector sharedDirector]
         replaceScene:[GameScene node]];
    }
    else if ([btn.name isEqualToString:kButtonAchievements])
    {
        //Nothing to do yet
    }
    else if ([btn.name isEqualToString:kButtonLeaderboards])
    {
        //Nothing to do yet
    }
    else if ([btn.name isEqualToString:kButtonShop])
    {
        [[CCDirector sharedDirector]
         replaceScene:[ShopScene node]];
    }
    else
    {
        CCLOG(@"Unknown button:  %@", btn.name);
    }
}

@end
