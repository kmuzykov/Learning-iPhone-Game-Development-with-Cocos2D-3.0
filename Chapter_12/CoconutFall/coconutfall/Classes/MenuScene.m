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
    CCSprite *bg = [CCSprite spriteWithImageNamed:@"menu_bg.png"];
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
    
    CCSpriteFrame *btnNormal = [CCSpriteFrame frameWithImageNamed:@"btn_9slice.png"];
    CCSpriteFrame *btnPressed = [CCSpriteFrame frameWithImageNamed:@"btn_9slice_pressed.png"];
    
    for (NSString *btnName in [buttons reverseObjectEnumerator])
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
        [[CCDirector sharedDirector] replaceScene:[GameScene node]];
    }
    else if ([btn.name isEqualToString:kButtonAchievements])
    {
        [self displayGCAchievements];
    }
    else if ([btn.name isEqualToString:kButtonLeaderboards])
    {
        [self displayGCLeaderboard];
    }
    else if ([btn.name isEqualToString:kButtonShop])
    {
        [[CCDirector sharedDirector] replaceScene:[ShopScene node]];
    }
    else
    {
        CCLOG(@"Unknown button:  %@", btn.name);
    }
}

-(void)displayGCAchievements
{
    //1: Displaying GC using different classes for iOS 5.x and iOS 6+
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0)
    {
        //2: Using GKAchievementViewController for iOS 5.x
        GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
        
        //3: Want to get notified when its time to close achievements view controller.
        achievements.achievementDelegate = self;
        
        //4: Displaying achivements (CCDirector is root view controller in cocos2d games)
        [[CCDirector sharedDirector] presentModalViewController:achievements animated:YES];
    }
    else
    {
        //5: The GKGameCenterViewController can be used to display both achievements and leaderborards,
        //   we'll use it right now to display achievements (see viewState below)
        GKGameCenterViewController *achievements = [[GKGameCenterViewController alloc] init];
        
        //6: Want to get notified when its time to close achievements view controller.
        achievements.gameCenterDelegate = self;
        
        //7: Since one class (GKGameCenterViewController) can display multiple GC dialogs,
        //   we need to set which one we want. We want to display achivements.
        achievements.viewState = GKGameCenterViewControllerStateAchievements;
        
        //8: Displaying achivements.
        [[CCDirector sharedDirector] presentModalViewController:achievements animated:YES];
    }
}

-(void)displayGCLeaderboard
{
    //Code of this method is VERY similiar to the displayGCAchievements method.
    
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0)
    {
        GKLeaderboardViewController *leaderboard = [[GKLeaderboardViewController alloc] init];
        leaderboard.leaderboardDelegate = self;
        [[CCDirector sharedDirector] presentModalViewController:leaderboard animated:YES];
    }
    else
    {
        GKGameCenterViewController *leaderboard = [[GKGameCenterViewController alloc] init];
        leaderboard.gameCenterDelegate = self;
        leaderboard.viewState = GKGameCenterViewControllerStateLeaderboards;
        [[CCDirector sharedDirector] presentModalViewController:leaderboard animated:YES];
    }
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [viewController.presentingViewController dismissModalViewControllerAnimated:YES];
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [viewController.presentingViewController dismissModalViewControllerAnimated:YES];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController.presentingViewController dismissModalViewControllerAnimated:YES];
}


@end
