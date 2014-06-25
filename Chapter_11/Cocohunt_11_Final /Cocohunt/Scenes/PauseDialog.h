//
//  PauseDialog.h
//  Cocohunt
//
//  Created by Kirill Muzykov on 21/05/14.
//  Copyright (c) 2014 Kirill Muzykov. All rights reserved.
//

#import "CCNode.h"

@interface PauseDialog : CCNode<UIAlertViewDelegate>

@property (nonatomic, copy) void(^onCloseBlock)(void);

@end
