//
//  LSConsoleCell.h
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSConsoleCell : UITableViewCell
@property(nonatomic,strong)UILabel *keyLabel;
@property(nonatomic,strong)UITextField *valueField;

- (void)refreshWithTitle:(NSObject *)title value:(NSObject *)obj;

+ (CGFloat)height;

@end
