//
//  ViewController.m
//  LSConsole
//
//  Created by liusong on 2018/2/28.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "ViewController.h"
#import "LSConsole.h"
@interface ViewController ()

@property (nonatomic,strong) UIWindow *window;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    


}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"fsdfsd"); LSLog(@"1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
