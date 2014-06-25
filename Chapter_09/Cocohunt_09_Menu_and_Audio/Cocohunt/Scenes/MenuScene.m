//
//  MenuScene.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 20/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "MenuScene.h"

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "GameScene.h"

#import "AudioManager.h"

@implementation MenuScene
{
    //Layout containing menu buttons
    CCLayoutBox *_menu;
    
    //Sound effects & music toggle buttons
    CCButton *_btnSoundToggle;
    CCButton *_btnMusicToggle;
}

-(instancetype)init
{
    if (self = [super init])
    {
        [self addBackground];
        [self addMenuButtons];
        [self addAudioButtons];
    }
    
    return self;
}

-(void)addBackground
{
    CCSprite *bg = [CCSprite
                    spriteWithImageNamed:@"menu_bg.png"];
    bg.positionType =
    CCPositionTypeMake(CCPositionUnitNormalized,
                       CCPositionUnitNormalized,
                       CCPositionReferenceCornerBottomLeft);
    bg.position = ccp(0.5f, 0.5f);
    [self addChild:bg];
}

-(void)addMenuButtons
{
    //1
    CCSpriteFrame *startNormalImage = [CCSpriteFrame frameWithImageNamed:@"btn_start.png"];
    
    //2
    CCSpriteFrame *startHighlightedImage = [CCSpriteFrame frameWithImageNamed:@"btn_start_pressed.png"];
    
    //3
    CCButton *btnStart = [CCButton buttonWithTitle:nil
                                       spriteFrame:startNormalImage
                            highlightedSpriteFrame:startHighlightedImage
                               disabledSpriteFrame:nil];
    
    //4
    [btnStart setTarget:self selector:@selector(btnStartTapped:)];
    
    CCSpriteFrame *aboutNormalImage = [CCSpriteFrame frameWithImageNamed:@"btn_about.png"];
    CCSpriteFrame *aboutHighlightedImage = [CCSpriteFrame frameWithImageNamed:@"btn_about_pressed.png"];
    CCButton *btnAbout = [CCButton buttonWithTitle:nil
                                       spriteFrame:aboutNormalImage
                            highlightedSpriteFrame:aboutHighlightedImage
                               disabledSpriteFrame:nil];
    [btnAbout setTarget:self selector:@selector(btnAboutTapped:)];
    
    CCSpriteFrame *highscoresNormalImage = [CCSpriteFrame frameWithImageNamed:@"btn_highscores.png"];
    CCSpriteFrame *highscoresHighlightedImage = [CCSpriteFrame frameWithImageNamed:@"btn_highscores_pressed.png"];
    CCButton *btnHighscores = [CCButton buttonWithTitle:nil
                                            spriteFrame:highscoresNormalImage
                                 highlightedSpriteFrame:highscoresHighlightedImage
                                    disabledSpriteFrame:nil];
    [btnHighscores setTarget:self selector:@selector(btnHighscoresTapped:)];
    
    //5
    _menu = [[CCLayoutBox alloc] init];
    _menu.direction = CCLayoutBoxDirectionVertical;
    _menu.spacing = 40.0f;
    
    //6
    [_menu addChild:btnHighscores];
    [_menu addChild:btnAbout];
    [_menu addChild:btnStart];
    
    //7
    [_menu layout];
    
    //8
    _menu.anchorPoint = ccp(0.5f, 0.5f);
    _menu.positionType = CCPositionTypeMake(CCPositionUnitNormalized,
                                            CCPositionUnitNormalized,
                                            CCPositionReferenceCornerBottomLeft);
    _menu.position = ccp(0.5f, 0.5f);
    
    [self addChild:_menu];
}

-(void)addAudioButtons
{
    //1
    CCSpriteFrame *soundOnImage = [CCSpriteFrame frameWithImageNamed:@"btn_sound.png"];
    CCSpriteFrame *soundOffImage = [CCSpriteFrame frameWithImageNamed:@"btn_sound_pressed.png"];
    _btnSoundToggle = [CCButton buttonWithTitle:nil
                                    spriteFrame:soundOnImage
                         highlightedSpriteFrame:soundOffImage
                            disabledSpriteFrame:nil];
    //2
    _btnSoundToggle.togglesSelectedState = YES;
    
    //3
    _btnSoundToggle.selected =
    [AudioManager sharedAudioManager].isSoundEnabled;
    
    //4
    _btnSoundToggle.block = ^(id sender){
        [[AudioManager sharedAudioManager] toggleSound];
    };
    
    //5
    _btnSoundToggle.positionType = CCPositionTypeNormalized;
    _btnSoundToggle.position = ccp(0.95f, 0.1f);
    [self addChild:_btnSoundToggle];
    
    //6
    CCSpriteFrame *musicOnImage  = [CCSpriteFrame frameWithImageNamed:@"btn_music.png"];
    CCSpriteFrame *musicOffImage = [CCSpriteFrame frameWithImageNamed:@"btn_music_pressed.png"];
    _btnMusicToggle = [CCButton buttonWithTitle:nil
                                    spriteFrame:musicOnImage
                         highlightedSpriteFrame:musicOffImage
                            disabledSpriteFrame:nil];
    
    _btnMusicToggle.togglesSelectedState = YES;
    _btnMusicToggle.selected =
    
    [AudioManager sharedAudioManager].isMusicEnabled;
    _btnMusicToggle.block = ^(id sender){
        [[AudioManager sharedAudioManager] toggleMusic];
    };
    
    //7
    float musicButtonOffset = _btnSoundToggle.boundingBox.size.width + 10;
    CGPoint soundButtonPosInPoints = _btnSoundToggle.positionInPoints;
    _btnMusicToggle.positionType = CCPositionTypeMake(CCPositionUnitPoints,
                                                      CCPositionUnitNormalized,
                                                      CCPositionReferenceCornerBottomLeft);
    _btnMusicToggle.position = ccp(soundButtonPosInPoints.x - musicButtonOffset, 0.1f);
    
    [self addChild:_btnMusicToggle];
}

-(void)btnStartTapped:(id)sender
{
    CCLOG(@"Start Tapped");
    [[CCDirector sharedDirector]
        replaceScene:[[GameScene alloc] init]];
}

-(void)btnAboutTapped:(id)sender
{
    CCLOG(@"About Tapped");
}

-(void)btnHighscoresTapped:(id)sender
{
    CCLOG(@"Highscores Tapped");
}


@end
