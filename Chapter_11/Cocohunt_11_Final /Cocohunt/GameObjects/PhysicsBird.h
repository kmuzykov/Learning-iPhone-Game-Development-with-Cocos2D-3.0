//
//  PhysicsBird.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 23/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "Bird.h"

/** Bird used in PhysicsScene */
@interface PhysicsBird : Bird

@property (nonatomic, weak)   CCSprite *stoneToDrop;

-(void)flyAndDropStoneAt:(CGPoint)point stone:(CCSprite*)stone;

@end
