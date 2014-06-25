//
//  HUDLayer.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 05/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCNode.h"
#import "GameStats.h"

@interface HUDLayer : CCNode

-(void)updateStats:(GameStats *)stats;

@end
