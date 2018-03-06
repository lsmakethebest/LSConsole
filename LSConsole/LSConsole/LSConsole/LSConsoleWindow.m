//
//  LSConsoleWindow.m
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSConsoleWindow.h"
#import "LSConsoleDefine.h"
#import "UIWindow+LSConsole.h"
@interface LSConsoleWindow()
@property (nonatomic,assign) BOOL isShow;
@property (nonatomic,assign) BOOL isAlwaysShow;

@end

@implementation LSConsoleWindow


-(void)setAlwasysShow:(BOOL)show
{
    [self initSetting];
    self.isAlwaysShow=show;
    if (!show) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(motionEnded) name:LSConsoleShakePhoneNotification object:nil];
        self.frame = CGRectMake(LSConsoleScreenWidth , LSConsoleScreenHeight * 0.5-100, LSConsoleWidth, LSConsoleWidth);
    }
    
}

-(void)initSetting
{
    self.frame = CGRectMake(LSConsoleScreenWidth-LSConsoleWidth , LSConsoleScreenHeight * 0.5-100, LSConsoleWidth, LSConsoleWidth);
    self.smallFrame=self.frame;
    self.layer.cornerRadius = LSConsoleWidth/2.0;
    self.windowLevel = UIWindowLevelAlert + 1;
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
    self.rootViewController = [UIViewController new];//必须的
    self.hidden=NO;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LSConsoleWidth, LSConsoleWidth)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:20];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Log";
    [self addSubview:label];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:panGesture];
    
}

- (void)tapAction
{
    
    CGRect frame=CGRectMake(0, self.frame.origin.y, LSConsoleScreenWidth-0, LSConsoleHeight);
    if (!self.debugView) {
        self.smallFrame=self.frame;
        
        LSConsoleView *view=[[LSConsoleView alloc]initWithFrame:CGRectMake(0, 0, LSConsoleScreenWidth, LSConsoleHeight)];
        view.backgroundColor=[UIColor redColor];
        [self addSubview:view];
        self.debugView=view;
        
        self.frame=CGRectMake(LSConsoleScreenWidth, self.frame.origin.y, LSConsoleScreenWidth, LSConsoleHeight);
        [UIView animateWithDuration:0.25 animations:^{
            self.frame=frame;
        }completion:^(BOOL finished) {
            self.fullScreenFrame=frame;
        }];
        
    }else{
        if (!self.debugView.hidden) {
            return;
        }
        self.debugView.hidden=NO;
        self.frame=CGRectMake(LSConsoleScreenWidth, self.frame.origin.y, LSConsoleScreenWidth, LSConsoleHeight);
        self.debugView.textView.text=self.debugView.lastText;
        [UIView animateWithDuration:0.25 animations:^{
            self.frame=frame;
        }completion:^(BOOL finished) {
            self.fullScreenFrame=frame;
        }];
    }
    self.isFullScreen=YES;
}

- (void)panAction:(UIPanGestureRecognizer *)panGesture
{
    CGPoint point = [panGesture translationInView:[[UIApplication sharedApplication] keyWindow]];
    if(panGesture.state == UIGestureRecognizerStateBegan){
        self.alpha = LSConsoleActiveAlpha;
    }
    if(panGesture.state == UIGestureRecognizerStateChanged){
        CGRect frame=self.frame;
        frame.origin. x+=point.x;
        frame.origin.y+=point.y;
        self.frame=frame;
    }else if(panGesture.state == UIGestureRecognizerStateEnded||panGesture.state ==UIGestureRecognizerStateCancelled){
        
        CGFloat x=self.frame.origin.x;
        if (x<=0) {
            x=0;
        }else if (x>LSConsoleScreenWidth-self.frame.size.width){
            x=LSConsoleScreenWidth-self.frame.size.width;
        }
        
        CGFloat y=self.frame.origin.y;
        if (y<=40) {
            y=40;
        }else if (y>LSConsoleScreenHeight-self.frame.size.height){
            y=LSConsoleScreenHeight-self.frame.size.height;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.frame=CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
        }completion:^(BOOL finished) {
            if (self.isFullScreen) {
                self.fullScreenFrame=self.frame;
            }else{
                self.smallFrame=self.frame;
            }
            self.alpha = LSConsoleActiveAlpha;
        }];
    }
    [panGesture setTranslation:CGPointZero inView: [UIApplication sharedApplication].keyWindow ];
}

-(void)motionEnded
{

        CGPointMake(LSConsoleScreenWidth- LSConsoleWidth * 0.5, LSConsoleScreenHeight * 0.5-100);
        if (self.isShow) {
            CGRect frame=self.frame;
            frame.origin.x=LSConsoleScreenWidth;
            [UIView animateWithDuration:0.25 animations:^{
                self.frame=frame;
            } completion:^(BOOL finished) {
                self.isShow=NO;
            }];
        }else
        {
            CGRect lastFrame;
            if (self.isFullScreen) {
                lastFrame=self.fullScreenFrame;
            }else{
                lastFrame=self.smallFrame;
            }
            CGRect newFrame=lastFrame;
            [UIView animateWithDuration:0.25 animations:^{
                self.frame=newFrame;
            }completion:^(BOOL finished) {
                self.isShow=YES;
            }];
        }

}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
