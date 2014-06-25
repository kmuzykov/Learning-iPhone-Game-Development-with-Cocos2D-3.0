//
//  GameStats.m
//  Cocohunt
//
//  Created by Kirill Muzykov on 05/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "GameStats.h"

@implementation GameStats

-(instancetype)init
{
    if (self = [super init])
    {
        //To be safe initializing values with zeros.
        self.score = 0;
        self.birdsLeft = 0;
        self.lives = 0;
        self.timeSpent = 0;
    }    
    
    return self;
}

@end
