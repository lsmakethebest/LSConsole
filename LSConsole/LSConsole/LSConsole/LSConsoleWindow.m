//
//  LSConsoleWindow.m
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSConsoleWindow.h"
#import "LSConsoleDefine.h"


@implementation LSConsoleWindow

- (instancetype)init
{
    if(self = [super init]){
        self.frame = CGRectMake(0, 0, LSConsoleWidth, LSConsoleWidth);
        self.center = CGPointMake(LSConsoleScreenWidth- LSConsoleWidth * 0.5, LSConsoleScreenHeight * 0.5-100);
        self.layer.cornerRadius = LSConsoleWidth/2.0;
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
        self.rootViewController = [UIViewController new];//必须的
        [self makeKeyAndVisible];
        
        UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
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
    return self;
}

- (void)tapAction
{
    CGRect frame=CGRectMake(0, self.frame.origin.y, LSConsoleScreenWidth-0, LSConsoleHeight);
    if (!self.debugView) {
        self.lastFrame=self.frame;
        
        LSConsoleView *view=[[LSConsoleView alloc]initWithFrame:CGRectMake(0, 0, LSConsoleScreenWidth, LSConsoleHeight)];
        view.backgroundColor=[UIColor redColor];
        [self addSubview:view];
        self.debugView=view;
        
        self.frame=CGRectMake(LSConsoleScreenWidth, self.frame.origin.y, LSConsoleScreenWidth, LSConsoleHeight);
        [UIView animateWithDuration:0.25 animations:^{
            self.frame=frame;
        }completion:^(BOOL finished) {

        }];
        
    }else{
        self.debugView.hidden=NO;
        self.frame=CGRectMake(LSConsoleScreenWidth, self.frame.origin.y, LSConsoleScreenWidth, LSConsoleHeight);
        [UIView animateWithDuration:0.25 animations:^{
            self.frame=frame;
        }];
    }
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
            self.lastFrame=self.frame;
            self.alpha = LSConsoleActiveAlpha;
        }];
    }
    [panGesture setTranslation:CGPointZero inView: [UIApplication sharedApplication].keyWindow ];
}
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
}
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
    self.backgroundColor=[UIColor redColor];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}


@end
