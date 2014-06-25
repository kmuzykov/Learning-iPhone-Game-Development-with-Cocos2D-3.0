//
//  HighscoreDialog.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "HighscoreDialog.h"

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "HighscoreManager.h"

@implementation HighscoreDialog
{
    GameStats *_currentStats;
    
    CCTextField *_playerNameInput;
    CCLabelTTF  *_validateResult;
}

-(instancetype)initWithGameStats:(GameStats *)stats
{
    if (self = [super init])
    {
        _currentStats = stats;
        [self createDialogLayout];
    }
    
    return self;
}

-(void)createDialogLayout
{
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    CCSprite *background = [CCSprite spriteWithImageNamed:@"highscore_dialog_bg.png"];
    background.position = ccp(viewSize.width * 0.5f, viewSize.height * 0.5f);
    [self addChild:background];
    
    CCSpriteFrame *textFieldFrame = [CCSpriteFrame frameWithImageNamed:@"highscore_dialog_textfield.png"];
    _playerNameInput = [CCTextField textFieldWithSpriteFrame:textFieldFrame];
    _playerNameInput.string = @"Player1";
    
    _playerNameInput.preferredSize = textFieldFrame.rect.size;
    _playerNameInput.padding = 4.0f;
    _playerNameInput.fontSize = 10.0f;
    
    _playerNameInput.positionType = CCPositionTypeNormalized;
    _playerNameInput.anchorPoint = ccp(0.5f, 0.5f);
    _playerNameInput.position = ccp(0.5f, 0.7f);
    [background addChild:_playerNameInput];
    
    _validateResult = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:8];
    _validateResult.color = [CCColor redColor];
    _validateResult.positionType = CCPositionTypeNormalized;
    _validateResult.position = ccp(0.5f, 0.6f);
    [background addChild:_validateResult];
    
    CCSpriteFrame *okNormalImage = [CCSpriteFrame frameWithImageNamed:@"btn_ok.png"];
    CCSpriteFrame *okHighlightedImage = [CCSpriteFrame frameWithImageNamed:@"btn_ok_pressed.png"];
    
    CCButton *btnOk = [CCButton buttonWithTitle:nil spriteFrame:okNormalImage highlightedSpriteFrame:okHighlightedImage disabledSpriteFrame:nil];
    btnOk.positionType = CCPositionTypeNormalized;
    btnOk.position = ccp(0.5f, 0.2f);
    [btnOk setTarget:self selector:@selector(btnOkPressed:)];
    [background addChild:btnOk];
}

-(void)btnOkPressed:(id)sender
{
    NSString *playerName = _playerNameInput.string;
    if ([self validatePlayerName:playerName])
    {
        _currentStats.playerName = playerName;
        [[HighscoreManager sharedHighscoreManager] addHighScore:_currentStats];
        
        if (self.onCloseBlock)
            self.onCloseBlock();
        
        [self removeFromParentAndCleanup:YES];
    }
}

-(BOOL)validatePlayerName:(NSString *)playerName
{
    BOOL isEmpty = ([playerName length] != 0);
    
    if (!isEmpty)
    {
        _validateResult.visible = YES;
        _validateResult.string = @"Player name cannot be empty!";
    }
    else
    {
        _validateResult.visible = NO;
    }
    
    return isEmpty;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //swallow touch
}

@end
