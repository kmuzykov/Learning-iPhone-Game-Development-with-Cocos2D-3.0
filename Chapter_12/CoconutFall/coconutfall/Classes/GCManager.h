//
//  GCManager.h
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;

//Leaderboard
#define kLeaderboardID  @"com.packtpub.coconutfall.leaderboard.highestscore"

//Achivements
#define kAchievementHundred     @"com.packtpub.coconutfall.achievement.hundred"
#define kAchievementWakeUp      @"com.packtpub.coconutfall.achievement.wakeup"
#define kAchievementFirstBlood  @"com.packtpub.coconutfall.achievement.firstblood"

@interface GCManager : NSObject

-(void)loginToGameCenter;

-(void)reportScore:(int)score;

-(void)reportAchievement:(NSString *)achievementId progress:(double)progress;

+(GCManager *)sharedInstance;

@end
