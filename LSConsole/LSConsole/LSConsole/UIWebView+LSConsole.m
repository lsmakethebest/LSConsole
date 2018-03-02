


//
//  UIWebView+LSConsole.m
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "UIWebView+LSConsole.h"

@implementation UIWebView (LSConsole)

- (NSInteger)yl_highlightAllOccurencesOfString:(NSString*)str
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LSConsole" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@')",str];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    
    NSString *result = [self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount"];
    return [result integerValue];
}

- (void)yl_removeAllHighlights
{
    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}


@end
