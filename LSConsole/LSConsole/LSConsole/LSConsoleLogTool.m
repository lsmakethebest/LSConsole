


//
//  LSConsoleLogTool.m
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSConsoleLogTool.h"
#import <UIKit/UIKit.h>
#import "LSConsoleWindow.h"
#import "LSConsole.h"
#import "LSConsoleDefine.h"

static NSString *currentLogFileName;///< 当前日志文件名
static dispatch_queue_t writeLogQueue;//用于写入文件时的子线程

@implementation LSConsoleLogTool


//是否连接xcode
+ (BOOL)isConnectXcode
{
    //该函数用于检测输出 (STDOUT_FILENO) 是否重定向 是个 Linux 程序方法
    if(isatty(STDOUT_FILENO)) {
        return YES;
    }
    return NO;
}

-(BOOL)isSimulator
{
    // 判断 当前是否在 模拟器环境 下 在模拟器不保存到文件中
    UIDevice *device = [UIDevice currentDevice];
    if([[device model] hasSuffix:@"Simulator"]){
        return YES;
    }
    return NO;
}
+ (void)startConfig
{
    if(!writeLogQueue){
        writeLogQueue = dispatch_queue_create("http://ydo.me", DISPATCH_QUEUE_SERIAL);//串行队列
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self logFilePath];
    if(![fileManager fileExistsAtPath:path]){
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    [self redirectNSLog];
}

+ (void)redirectNSLog
{
    //如果想对模拟器特殊处理，在此处判断就好
    if([self isConnectXcode]) return;
    // 将log输入到文件
    //iOS学习笔记40-日志重定向              http://www.jianshu.com/p/aaf49d0d0d98
    NSString *path = [self logFilePath];
    freopen([path cStringUsingEncoding:NSUTF8StringEncoding], "a+", stdout);
    freopen([path cStringUsingEncoding:NSUTF8StringEncoding], "a+", stderr);
    
    //未捕获的Objective-C异常日志
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

+ (NSString *)logDirectory{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *logDir = [docPath stringByAppendingPathComponent:@"Logs"];
    return logDir;
}

+ (NSString *)logFilePath
{
    if(!currentLogFileName){
        NSString *logDir = [self logDirectory];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:logDir]){
            NSError *error;
            [fileManager createDirectoryAtPath:logDir withIntermediateDirectories:YES attributes:nil error:&error];
            if(error){
                NSLog(@"%@",error);
            }
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [dateStr stringByAppendingString:@".txt"];
        currentLogFileName = [logDir stringByAppendingPathComponent:fileName];
    }
    return currentLogFileName;
}
void UncaughtExceptionHandler(NSException* exception)
{
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    NSArray *symbols = [exception callStackSymbols]; // 异常发生时的调用栈
    NSMutableString *strSymbols = [[NSMutableString alloc] init]; //将调用栈拼成输出日志的字符串
    for(NSString *item in symbols)
    {
        [strSymbols appendString: item];
        [strSymbols appendString: @"\r\n"];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    
    [LSConsoleLogTool log:crashString];
}


+ (void)log:(NSString *)content
{
    if(!content){
        return;
    }
    if([self isConnectXcode]){
        //同时输出到控制台
        NSLog(@"%@",content);
    }
    if (writeLogQueue==NULL) {
        //有种情况没开启悬浮窗功能，但是还LSLog打印，还是会走此方法，因为不是Release,所以需要判断
        return;
    }
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    content=[NSString stringWithFormat:@"%@  %@\n",[formatter stringFromDate: [NSDate date]],content];
    LSConsoleView *debugView=[LSConsole shareInstance].debugWindow.debugView;
    if (debugView) {
        debugView.text=content;
    }
    
    //这里以追加的形式写入文件
    dispatch_async(writeLogQueue, ^{
        //打开一个文件准备更新（读取或写入）
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[self logFilePath]];
        //将文件指针的当前位置（偏移量）放在文件末尾处
        [fileHandle seekToEndOfFile];
        //在文件指针的当前位置写入，写入完成后文件指针的当前位置自动更新
        //采用UTF8编码会导致在浏览器中正常，在真机上显示乱码
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];//关闭文件
    });
}

+ (NSMutableArray *)allLogFileNames
{
    NSMutableArray *fileNames = [NSMutableArray array];
    NSString *logDir = [self logDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:logDir error:&error];
//    NSLog(@"%@",error);
    if(contents){
        contents = [contents sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            NSComparisonResult result = [obj1 compare:obj2];
            if(result == NSOrderedAscending) return NSOrderedDescending;
            if(result == NSOrderedDescending) return NSOrderedAscending;
            return NSOrderedSame;
        }];
        [fileNames addObjectsFromArray:contents];
    }
    return fileNames;
}

+ (NSString *)pathForFile:(NSString *)fileName
{
    NSString *logDir = [self logDirectory];
    NSString *filePath = [logDir stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (void)deleteLogFile:(NSString *)fileName
{
    NSString *filePath = [self pathForFile:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath]){
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
//        NSLog(@"%@",error);
    }
    
}

+ (void)deleteAllLogFiles
{
    NSString *logDir = [self logDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:logDir error:&error];
//    NSLog(@"%@",error);
}

@end
