//
//  HUDLayer.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 05/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "HUDLayer.h"

#import "cocos2d.h"

#define kFontName @"Noteworthy-Bold"
#define kFontSize 14

@implementation HUDLayer
{
    CCLabelTTF *_score;
    CCLabelTTF *_birdsLeft;
    CCLabelTTF *_lives;
}

-(instancetype)init
{
    if (self = [super init])
    {
        //1
        _score = [CCLabelTTF
                  labelWithString:@"Score: 99999"
                  fontName:kFontName
                  fontSize:kFontSize];
        _birdsLeft = [CCLabelTTF
                      labelWithString:@"Birds Left: 99"
                      fontName:kFontName
                      fontSize:kFontSize];
        _lives = [CCLabelTTF
                  labelWithString:@"Lives: 99"
                  fontName:kFontName
                  fontSize:kFontSize];
        
        //2
        _score.color =  [CCColor colorWithRed:0 green:0.42f blue:0.03f];
        _birdsLeft.color = [CCColor colorWithRed:0.84f green:0.49f blue:0.08f];
        _lives.color = [CCColor colorWithRed:0.64f green:0.06f blue:0.06f];
        
        //3
        CGSize viewSize = [CCDirector sharedDirector].viewSize;
        float labelsY = viewSize.height * 0.95f;
        float labelsPaddingX = viewSize.width * 0.01f;
        
        //4
        _score.anchorPoint = ccp(0, 0.5f);
        _score.position = ccp(labelsPaddingX, labelsY);
        
        //5
        _birdsLeft.anchorPoint = ccp(0.5f, 0.5f);
        _birdsLeft.position = ccp(viewSize.width * 0.5f, labelsY);
        
        //6
        _lives.anchorPoint = ccp(1, 0.5f);
        _lives.position = ccp(viewSize.width - labelsPaddingX, labelsY);
        
        //7
        [self addChild:_score];
        [self addChild:_birdsLeft];
        [self addChild:_lives];
    }
    
    return self;
}

-(void)updateStats:(GameStats *)stats
{
    _score.string =[NSString stringWithFormat:@"Score: %d", stats.score];
    
    _birdsLeft.string = [NSString stringWithFormat:@"Birds Left: %d", stats.birdsLeft];
    
    _lives.string = [NSString stringWithFormat:@"Lives: %d", stats.lives];
}

@end
