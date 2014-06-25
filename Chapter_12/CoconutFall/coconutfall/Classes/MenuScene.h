//
//  MenuScene.h
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCScene.h"

#import "GCManager.h"

@interface MenuScene : CCScene<GKLeaderboardViewControllerDelegate,
                               GKGameCenterControllerDelegate,
                               GKAchievementViewControllerDelegate>

@end
