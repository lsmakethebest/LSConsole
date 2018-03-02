//
//  LSConsoleLogTool.h
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSConsoleLogTool : NSObject



//初始化配置
+ (void)startConfig;
//获取当前文件目录
+ (NSString *)logFilePath;
//打印日志
+ (void)log:(NSString *)content;
//获取本地所有日志文件名称
+ (NSMutableArray *)allLogFileNames;
//根据名称获取日志完整目录
+ (NSString *)pathForFile:(NSString *)fileName;
//根据名称删除对应日志文件
+ (void)deleteLogFile:(NSString *)fileName;
//删除所有日志文件
+ (void)deleteAllLogFiles;


@end


