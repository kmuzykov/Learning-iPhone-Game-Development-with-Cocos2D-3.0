//
//  GCManager.m
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "GCManager.h"

@implementation GCManager
{
    BOOL _isUserLoggedIn;
}

-(id)init
{
    if (self =[super init])
    {
        _isUserLoggedIn = NO;
        [self subscribeToAuthStatusChange];
    }
    
    return self;
}

-(void)loginToGameCenter
{
    if ([GKLocalPlayer localPlayer].authenticated == NO)
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    else
        NSLog(@"loginToGameCenter: User Already Logged In");
}

-(void)subscribeToAuthStatusChange
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticationChanged)
                                                 name:GKPlayerAuthenticationDidChangeNotificationName
                                               object:nil];
}

-(void)authenticationChanged {
    if ([GKLocalPlayer localPlayer].isAuthenticated && !_isUserLoggedIn)
    {
        _isUserLoggedIn = YES;
        NSLog(@"User logged in to Game Center");
    }
    else if (![GKLocalPlayer localPlayer].isAuthenticated && _isUserLoggedIn)
    {
        _isUserLoggedIn = NO;
        NSLog(@"User logged out from Game Center");
    }
}

-(void)reportScore:(int)score
{
    //1: If user not logged in we can't report score
    if (!_isUserLoggedIn)
        return;
    
    //2: Creating score object
    GKScore *gkScore = [[GKScore alloc] initWithCategory:kLeaderboardID];
    
    //3: Setting score value
    gkScore.value = score;
    
    //4: Creating completion handler used in both cases (iOS 5.x and iOS 6+)
    id completionHandler = ^(NSError * error) {
        if (error)
            NSLog(@"Error reporting score: %@", error);
    };
    
    //5: Reporting score using different methods depending on iOS version
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0)
    {
        [gkScore reportScoreWithCompletionHandler:completionHandler];
    }
    else
    {
        [GKScore reportScores:@[gkScore] withCompletionHandler:completionHandler];
    }
}

-(void)reportAchievement:(NSString *)achievementId
                progress:(double)progress
{
    //1: Creating achievement object
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
    
    //2: Setting percent complete
    achievement.percentComplete = progress;
    
    //3: We want to show default completion banner.
    achievement.showsCompletionBanner = YES;
    
    //4: Once again using same completion handler for any iOS version.
    id completionHandler = ^(NSError * error) {
        if (error)
            NSLog(@"Error reporting achievements: %@", error);
    };
    
    //5: Using different method to report achievement(s) depending on iOS version
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0)
    {
        [achievement reportAchievementWithCompletionHandler: completionHandler];
    }
    else
    {
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:completionHandler];
    }
}

+(GCManager *)sharedInstance
{
    static dispatch_once_t pred;
    static GCManager * _sharedInstance;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

@end
