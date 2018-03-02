//
//  LSConsole.m
//  LSConsole
//
//  Created by liusong on 2018/2/28.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSConsole.h"
#import <UIKit/UIKit.h>
#import "LSConsoleLogTool.h"
#import "LSConsoleWindow.h"

@implementation LSConsole

+ (instancetype)shareInstance
{
    static LSConsole *console = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        console = [[LSConsole alloc]init];
    });
    return console;
}
- (instancetype)init
{
    if(self = [super init]){
        self.debugWindow=[[LSConsoleWindow alloc]init];
    }

    return self;
}

+(void)startDebugWithIsAlwaysShow:(BOOL)isAlwaysShow
{
    [LSConsole shareInstance];
    [LSConsoleLogTool startConfig];
    NSMutableArray *logList =[LSConsoleLogTool allLogFileNames];
    
    int maxCount=LSConsoleMaxFileCount;
    if (logList.count>maxCount) {
        for (int i=maxCount; i<logList.count; i++) {
            [LSConsoleLogTool deleteLogFile: logList[i]];
        }
        [logList removeObjectsInRange:NSMakeRange(maxCount, logList.count-maxCount)];
    }
    [[LSConsole shareInstance].debugWindow setAlwasysShow:isAlwaysShow];
}


@end
