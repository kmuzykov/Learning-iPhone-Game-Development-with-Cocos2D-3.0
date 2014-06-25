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
#import "HighscoreManager.h"

#define kHighscoreRowHeight 32
#define kHighscoreFontName @"Helvetica"
#define kHighscoreFontSize 12

@implementation HighscoresScene

-(instancetype)init
{
    if (self = [super init])
    {
        [self addBackground];
        [self addBackButton];
        [self addHighscoresTable];
    }
    
    return self;
}

-(void)addBackground
{
    CCSprite *bg = [CCSprite spriteWithImageNamed:@"highscores_bg.png"];
    bg.positionType = CCPositionTypeNormalized;
    bg.position = ccp(0.5f,0.5f);
    [self addChild:bg];
}

-(void)addBackButton
{
    CCSpriteFrame *backNormalImage = [CCSpriteFrame frameWithImageNamed:@"btn_back.png"];
    CCSpriteFrame *backHighlightedImage = [CCSpriteFrame frameWithImageNamed:@"btn_back_pressed.png"];
    CCButton *btnBack = [CCButton buttonWithTitle:nil
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
    CCTransition *transition = [CCTransition transitionPushWithDirection:CCTransitionDirectionUp duration:1.0f];
    MenuScene *scene = [[MenuScene alloc] init];
    [[CCDirector sharedDirector] replaceScene:scene withTransition:transition];
}

-(void)addHighscoresTable
{
    //1
    CCTableView *highscoresTable = [[CCTableView alloc] init];
    
    //2
    highscoresTable.rowHeight = kHighscoreRowHeight;
    
    //3
    highscoresTable.anchorPoint = ccp(0.5, 1.0f);
    
    //4
    highscoresTable.positionType = CCPositionTypeNormalized;
    highscoresTable.position = ccp(0.5f, 0.65f);
    highscoresTable.contentSizeType = CCSizeTypeNormalized;
    highscoresTable.contentSize = CGSizeMake(1, 0.4f);
    
    //5
    highscoresTable.userInteractionEnabled = NO;
    
    //6
    [self addChild:highscoresTable];
    
    //7
    highscoresTable.dataSource = self;
}

- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index
{
    //1
    GameStats *highscore = [[[HighscoreManager sharedHighscoreManager] getHighScores] objectAtIndex:index];
    NSString *playerName = highscore.playerName;
    int score = highscore.score;
    
    //2
    CCTableViewCell * cell = [[CCTableViewCell alloc] init];
    cell.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
    cell.contentSize = CGSizeMake(1, kHighscoreRowHeight);
    
    //3
    CCSprite *bg = [CCSprite spriteWithImageNamed:@"table_cell_bg.png"];
    bg.positionType = CCPositionTypeNormalized;
    bg.position = ccp(0.5f, 0.5f);
    [cell addChild:bg];
    
    //4
    CCLabelTTF *lblPlayerName = [CCLabelTTF labelWithString:playerName
                                                   fontName:kHighscoreFontName
                                                   fontSize:kHighscoreFontSize];
    lblPlayerName.positionType = CCPositionTypeNormalized;
    lblPlayerName.position = ccp(0.05, 0.5f);
    lblPlayerName.anchorPoint = ccp(0, 0.5f);
    [bg addChild:lblPlayerName];
    
    //5
    NSString *scoreString = [NSString stringWithFormat:@"%d pts.", score];
    CCLabelTTF *lblScore = [CCLabelTTF labelWithString:scoreString
                                              fontName:kHighscoreFontName
                                              fontSize:kHighscoreFontSize];
    lblScore.positionType = CCPositionTypeNormalized;
    lblScore.position = ccp(0.95f, 0.5f);
    lblScore.anchorPoint = ccp(1, 0.5f);
    [bg addChild:lblScore];
    
    //6
    return cell;
}

- (NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView
{
    return [[HighscoreManager sharedHighscoreManager] getHighScores].count;
}


@end
