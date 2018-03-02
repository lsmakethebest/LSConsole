//
//  UIWebView+LSConsole.h
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (LSConsole)

- (NSInteger)yl_highlightAllOccurencesOfString:(NSString*)str;
- (void)yl_removeAllHighlights;

@end
