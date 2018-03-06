//
//  LSConsole.h
//  LSConsole
//
//  Created by liusong on 2018/2/28.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSConsoleWindow.h"
#import "LSConsoleDefine.h"
@interface LSConsole : NSObject

@property (nonatomic,strong) LSConsoleWindow *debugWindow;

+ (instancetype)shareInstance;
//开启设置
+ (void)startDebugWithIsAlwaysShow:(BOOL)isAlwaysShow;

@end
