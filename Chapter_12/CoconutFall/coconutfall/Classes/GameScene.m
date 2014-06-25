//
//  GameScene.m
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "GameScene.h"

#import "MenuScene.h"
#import "cocos2d.h"

#import "GCManager.h"
#import "IAPManager.h"

typedef NS_ENUM(NSUInteger, GameState)
{
    GameStateInit,
    GameStatePlaying,
    GameStateLost
};

@implementation GameScene
{
    int _lives;
    int _points;
    int _pointsPerCoconut;
    
    GameState _gameState;
    float _timeUntilNextCoconut;
    
    CCLabelTTF *_lblPoints;
    CCLabelTTF *_lblLives;
}

-(instancetype)init
{
    if (self = [super init])
    {
        [self setupGameDefaults];
        [self addBackground];
        [self addLabels];
        
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    _gameState = GameStatePlaying;
}

-(void)setupGameDefaults
{
    _gameState = GameStateInit;
    _timeUntilNextCoconut = 0;
    
    _lives = 3;
    _points = 0;
    _pointsPerCoconut = 5;
    
    //Checking if player purchased double points
    if ([[IAPManager sharedInstance] isProductPurchased:kInAppPoints])
        _pointsPerCoconut *= 2;
    
    //Checking if player purchased double lives
    if ([[IAPManager sharedInstance] isProductPurchased:kInAppLives])
        _lives *= 2;
}

-(void)addBackground
{
    CCSprite *bg = [CCSprite spriteWithImageNamed:@"game_bg.png"];
    bg.positionType = CCPositionTypeNormalized;
    bg.position = ccp(0.5f, 0.5f);
    [self addChild:bg];
}

-(void)addLabels
{
    _lblPoints = [CCLabelTTF labelWithString:@"Points: 0"
                                    fontName:@"Helvetica"
                                    fontSize:14];
    
    _lblPoints.anchorPoint = ccp(0, 0.5f);
    _lblPoints.color = [CCColor redColor];
    _lblPoints.positionType = CCPositionTypeNormalized;
    _lblPoints.position = ccp(0.05f, 0.95f);
    [self addChild:_lblPoints];
    
    NSString *lives = [NSString stringWithFormat:@"Lives: %d", _lives];
    
    _lblLives = [CCLabelTTF labelWithString:lives
                                   fontName:@"Helvetica"
                                   fontSize:14];
    
    _lblLives.anchorPoint = ccp(1, 0.5f);
    _lblLives.color = [CCColor redColor];
    _lblLives.positionType = CCPositionTypeNormalized;
    _lblLives.position = ccp(0.95f, 0.95f);
    [self addChild:_lblLives];
}

-(void)update:(CCTime)dt
{
    if (_gameState == GameStatePlaying)
    {
        _timeUntilNextCoconut -= dt;
        
        if (_timeUntilNextCoconut <= 0)
        {
            Coconut *coconut = [Coconut node];
            coconut.name = @"coconut";
            coconut.delegate = self;
            [self addChild:coconut];
            
            _timeUntilNextCoconut = 0.5f + arc4random_uniform(2.0f);
        }
    }
}

-(void)coconutRemovedAt:(CGPoint)position
{
    if (_gameState == GameStatePlaying)
    {
        [[GCManager sharedInstance] reportAchievement:kAchievementFirstBlood progress:100];
        
        _points += _pointsPerCoconut;
        _lblPoints.string = [NSString stringWithFormat:@"Points: %d", _points];
    }
}

-(void)fallenOffScreenAt:(CGPoint)position
{
    [self displayMissedCoconutAt:position.x];
    
    _lives--;
    if (_lives < 0)
        _lives = 0;
    
    _lblLives.string =
    [NSString stringWithFormat:@"Lives: %d", _lives];
    
    if (_lives <= 0 && _gameState == GameStatePlaying)
    {
        //Reporting Wake Up achievement.
        if (_points == 0)
            [[GCManager sharedInstance] reportAchievement:kAchievementWakeUp progress:100];
        
        //Reporting Hundred achievement.
        if (_points > 100)
            [[GCManager sharedInstance] reportAchievement:kAchievementHundred progress:100];
        else
            [[GCManager sharedInstance] reportAchievement:kAchievementHundred progress:_points];
        
        //Reporting Score.
        [[GCManager sharedInstance] reportScore:_points];
        
        _gameState = GameStateLost;
        
        CCLabelTTF *youLoseLabel = [CCLabelTTF labelWithString:@"You lose!"
                                                      fontName:@"Helvetica-Bold"
                                                      fontSize:48];
        
        youLoseLabel.positionType = CCPositionTypeNormalized;
        youLoseLabel.position = ccp(0.5f, 0.5f);
        youLoseLabel.color = [CCColor whiteColor];
        [self addChild:youLoseLabel];
    }
}

-(void)displayMissedCoconutAt:(float)coconutX
{
    CCSprite *cross = [CCSprite spriteWithImageNamed:@"cross.png"];
    cross.positionType = CCPositionTypeNormalized;
    cross.position = ccp(coconutX, 0.05f);
    [self addChild:cross];
    
    CCActionDelay *delay = [CCActionDelay actionWithDuration:1.0f];
    CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:0.5f];
    CCActionRemove *remove = [CCActionRemove action];
    
    CCActionSequence *displayFadeThenRemove = [CCActionSequence actions:delay,fadeOut,remove, nil];
    [cross runAction:displayFadeThenRemove];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_gameState == GameStateLost)
        [[CCDirector sharedDirector] replaceScene:[MenuScene node]];
}

@end
