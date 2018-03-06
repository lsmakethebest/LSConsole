//
//  LSConsoleView.h
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSConsoleView : UIView
@property (nonatomic,copy)NSString *text;
@property (nonatomic,copy)NSString *lastText;
@property (nonatomic,weak) UITextView *textView;
@end
