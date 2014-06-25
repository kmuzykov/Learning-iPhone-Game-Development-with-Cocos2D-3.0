//
//  HUDLayer.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 05/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCNode.h"
#import "GameStats.h"

/** Layer with all information the player should always see (e.g. points, lives,...) */
@interface HUDLayer : CCNode

/** Allowing the game scene to update labels when lives, points,.. change */
-(void)updateStats:(GameStats *)stats;

@end
