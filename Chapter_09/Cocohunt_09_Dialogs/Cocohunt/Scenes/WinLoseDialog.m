//
//  WinLoseDialog.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "WinLoseDialog.h"

#import "cocos2d.h"
#import "cocos2d-ui.h"

#import "MenuScene.h"
#import "LoadingScene.h"

#define kKeyFont        @"HelveticaNeue"
#define kKeyFontSize    12
#define kKeyX           0.2f

#define kValueFont      @"HelveticaNeue-Bold"
#define kValueFontSize  12
#define kValueX         0.8f

#define kLine1Y                 0.7f
#define kMarginBetweenLines     0.08f

@implementation WinLoseDialog
{
    GameStats *_currenStats;
}

-(instancetype)initWithGameStats:(GameStats *)stats;
{
    if (self = [super init])
    {
        _currenStats = stats;
        
        [self setupModalDialog];
        
        [self createDialogLayout];
    }
    
    return self;
}

-(void)setupModalDialog
{
    self.contentSizeType = CCSizeTypeNormalized;
    self.contentSize = CGSizeMake(1, 1);
    self.userInteractionEnabled = YES;
}

-(void)createDialogLayout
{
    CCSprite *bg = [CCSprite spriteWithImageNamed: @"win_lose_dialog_bg.png"];
    bg.positionType = CCPositionTypeNormalized;
    bg.position = ccp(0.5f, 0.5f);
    [self addChild:bg];
    
    NSDictionary *stats = @{ @"Score" : [NSString stringWithFormat:@"%d", _currenStats.score],
                             @"Lives Left" : [NSString stringWithFormat:@"%d", _currenStats.lives],
                             @"Time Spent" : [NSString stringWithFormat:@"%.1f s", _currenStats.timeSpent] };
    
    float margin = 0;
    CCColor *fontColor = [CCColor orangeColor];
    
    for (NSString *key in stats.allKeys)
    {
        CCLabelTTF *lblKey = [CCLabelTTF labelWithString:key fontName:kKeyFont fontSize:kKeyFontSize];
        lblKey.color = fontColor;
        lblKey.anchorPoint = ccp(0.0f, 0.5f);
        lblKey.positionType = CCPositionTypeNormalized;
        lblKey.position = ccp(kKeyX, kLine1Y - margin);
        [bg addChild:lblKey];
        
        CCLabelTTF *lblValue = [CCLabelTTF labelWithString:[stats objectForKey:key] fontName:kValueFont fontSize:kValueFontSize];
        lblValue.color = fontColor;
        lblValue.anchorPoint = ccp(1.0f, 0.5f);
        lblValue.positionType = CCPositionTypeNormalized;
        lblValue.position = ccp(kValueX, kLine1Y - margin);
        [bg addChild:lblValue];
        
        margin += kMarginBetweenLines;
    }
    
    CCSpriteFrame *restartNormalImage = [CCSpriteFrame frameWithImageNamed:@"btn_restart.png"];
    CCSpriteFrame *restartHighLightedImage = [CCSpriteFrame frameWithImageNamed:@"btn_restart_pressed.png"];
    CCButton *btnRestart = [CCButton buttonWithTitle:nil
                                         spriteFrame:restartNormalImage
                              highlightedSpriteFrame:restartHighLightedImage
                                 disabledSpriteFrame:nil];
    btnRestart.positionType = CCPositionTypeNormalized;
    btnRestart.position = ccp(0.25f, 0.2f);
    [btnRestart setTarget:self selector:@selector(btnRestartTapped:)];
    [bg addChild:btnRestart];
    
    CCSpriteFrame *exitNormalImage = [CCSpriteFrame frameWithImageNamed:@"btn_exit.png"];
    CCSpriteFrame *exitHighLightedImage = [CCSpriteFrame frameWithImageNamed:@"btn_exit_pressed.png"];
    CCButton *btnExit = [CCButton buttonWithTitle:nil
                                      spriteFrame:exitNormalImage
                           highlightedSpriteFrame:exitHighLightedImage
                              disabledSpriteFrame:nil];
    btnExit.positionType = CCPositionTypeNormalized;
    btnExit.position = ccp(0.75f, 0.2f);
    [btnExit setTarget:self selector:@selector(btnExitTapped:)];
    [bg addChild:btnExit];
}

-(void)btnRestartTapped:(id)sender
{
    LoadingScene *loadingScene = [[LoadingScene alloc] init];
    CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:1.0f];    
    [[CCDirector sharedDirector] replaceScene:loadingScene withTransition:transition];
}

-(void)btnExitTapped:(id)sender
{
    MenuScene *menuScene = [[MenuScene alloc] init];
    CCTransition *transition = [CCTransition transitionCrossFadeWithDuration:1.0f];
    [[CCDirector sharedDirector] replaceScene:menuScene withTransition:transition];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //do nothing, swallow touch
}

@end
