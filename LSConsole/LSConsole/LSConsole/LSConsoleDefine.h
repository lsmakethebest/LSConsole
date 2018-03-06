//
//  Header.h
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
// 项目地址
// https://github.com/lsmakethebest/LSConsole

#import "LSConsoleLogTool.h"
#ifndef Header_h
#define Header_h


#define LSConsoleLog(fmt, ...)  [LSConsoleLogTool log: [NSString stringWithFormat:@"%@:%d行\n%@", [[NSString stringWithUTF8String:__func__] lastPathComponent], __LINE__, [NSString stringWithFormat:(fmt), ##__VA_ARGS__] ]]
#define LSLog(fmt, ...) LSConsoleLog(fmt,##__VA_ARGS__)


//如果你定义了自己的log比如DLog,需要把DLog改成如下所示
//#define DLog(fmt, ...) LSLog(fmt,##__VA_ARGS__)



//存储的本地日志文件最大数量
#define LSConsoleMaxFileCount    5
//textView上最多显示数量，避免卡顿，如果卡顿请降低改数值
#define LSConsoleMaxTextLength  10000
#define LSConsoleDefaultPrefix  @"LS"


#define LSConsoleScreenWidth [UIScreen mainScreen].bounds.size.width
#define LSConsoleScreenHeight [UIScreen mainScreen].bounds.size.height
#define LSConsoleNavBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height+44)
#define LSConsoleHeight  LSConsoleScreenHeight*0.3
#define LSConsoleWidth 45.0
#define LSConsoleActiveAlpha 1
#define LSConsoleInActiveAlpha 1






#endif /* Header_h */
