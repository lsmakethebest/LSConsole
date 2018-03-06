


//
//  UIWindow+LSConsole.m
//  LSConsole
//
//  Created by liusong on 2018/3/2.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "UIWindow+LSConsole.h"

@implementation UIWindow (LSConsole)

-(BOOL)becomeFirstResponder
{
    return YES;
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion==UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter]postNotificationName:LSConsoleShakePhoneNotification object:nil];
    }
}


@end
