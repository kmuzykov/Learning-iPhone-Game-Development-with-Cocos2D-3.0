//
//  Coconut.h
//  coconutfall
//
//  Created by Kirill Muzykov on 28/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCSprite.h"

@protocol CoconutDelegate <NSObject>

-(void)coconutRemovedAt:(CGPoint)position;

-(void)fallenOffScreenAt:(CGPoint)position;

@end

@interface Coconut : CCSprite

@property (nonatomic, weak) id<CoconutDelegate> delegate;

@end
