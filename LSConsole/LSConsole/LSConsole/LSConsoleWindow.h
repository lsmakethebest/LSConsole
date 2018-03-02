//
//  LSConsoleWindow.h
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSConsoleView.h"

@interface LSConsoleWindow : UIWindow

@property (nonatomic,weak) LSConsoleView *debugView;
@property (nonatomic,assign) CGRect fullScreenFrame;
@property (nonatomic,assign) CGRect smallFrame;
@property (nonatomic,assign) BOOL isFullScreen;
-(void)setAlwasysShow:(BOOL)show;

@end
