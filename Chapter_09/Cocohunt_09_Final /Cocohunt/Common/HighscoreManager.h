//
//  HighscoreManager.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "GameStats.h"

/** Amount of stored highscores. Only TOP 5 highscores are stored. */
#define kMaxHighscores 5

/** Singleton to manage highscores (add, get, check if score is highscore) */
@interface HighscoreManager : NSObject

/** Get sorted array of highscores */
-(NSArray *)getHighScores;

/** Check if given score is a highscore */
-(BOOL)isHighscore:(int)score;

/** Add highscore. Will automaticaly place highscore at correct position */
-(void)addHighScore:(GameStats *)newHighscore;

+(HighscoreManager *)sharedHighscoreManager;

@end
