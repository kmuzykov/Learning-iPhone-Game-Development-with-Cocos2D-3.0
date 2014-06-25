//
//  WinLoseDialog.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCNode.h"

#import "GameStats.h"

@interface WinLoseDialog : CCNode

-(instancetype)initWithGameStats:(GameStats *)stats;

@end
