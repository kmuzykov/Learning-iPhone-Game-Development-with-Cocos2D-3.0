//
//  HighscoreManager.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "HighscoreManager.h"

@implementation HighscoreManager
{
    NSMutableArray *_highScores;
}

-(instancetype)init
{
    if (self = [super init])
    {
        _highScores = [NSMutableArray arrayWithCapacity:kMaxHighscores];
    }
    
    return self;
}

-(BOOL)isHighscore:(int)score
{
    //score is a highscore if it is higher than the lowest highscore or highscores table is not full.
    return (score > 0) && ((_highScores.count < kMaxHighscores) || (score > [_highScores.lastObject score]));
}

-(void)addHighScore:(GameStats *)newHighscore
{
    NSAssert([newHighscore.playerName length] > 0, @"You must specify player name for the highscore!");
    
    //Searching for a place to insert highscore.
    for (int i=0; i < _highScores.count; i++)
    {
        GameStats *gs = [_highScores objectAtIndex:i];
        if (newHighscore.score > gs.score)
        {
            [_highScores insertObject:newHighscore atIndex:i];
            
            if (_highScores.count > kMaxHighscores)
                [_highScores removeLastObject];
            
            return;
        }
    }
    
    //We can get here if only if newHighscore is not higher than any score in higscores table
    //Then there is only 1 chance we add it to the table, if it is still not full ( < 5 higscores on record)
    if (_highScores.count < kMaxHighscores)
    {
        [_highScores addObject:newHighscore];
        return;
    }
}

-(NSArray *)getHighScores
{
    return _highScores;
}

+(HighscoreManager *)sharedHighscoreManager
{
    static dispatch_once_t pred;
    static HighscoreManager * _sharedInstance;
    dispatch_once(&pred, ^{ _sharedInstance = [[self alloc] init]; });
    return _sharedInstance;
}

@end
