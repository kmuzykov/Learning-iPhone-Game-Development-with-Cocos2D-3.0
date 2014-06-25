//
//  GameStats.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 05/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameStats : NSObject

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int birdsLeft;
@property (nonatomic, assign) int lives;

@end
