//
//  LSConsole.m
//  LSConsole
//
//  Created by liusong on 2018/2/28.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSConsole.h"
#import <UIKit/UIKit.h>


#define  LSConsoleLogFilePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"/log.txt"]

typedef void (^LSConsoleClearBlock)(void);
typedef void (^LSConsoleHideBlock)(void);

@class LSConsoleRootViewController;

@interface LSConsoleWindow :UIWindow

@property (nonatomic,copy)LSConsoleClearBlock clearBlock;
@property (nonatomic, assign)BOOL isFullScreen;
@property (nonatomic,copy)NSString *text;
@property (nonatomic,assign) CGRect currentFrame;
@property (nonatomic,weak) LSConsoleRootViewController *consoleRootViewController;
- (void)maxmize;
- (void)minimize;
-(void)clearAllText;

@end

@interface LSConsoleRootViewController:UIViewController


@property (nonatomic,weak) LSConsoleWindow *consoleWindow;
@property (nonatomic,weak) UITextView *textView;
@property (nonatomic,weak) UIButton *hideButton;
@property (nonatomic,weak) UIButton *clearButton;
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;

@end

@implementation LSConsoleWindow

+(instancetype)consoleWindow
{
    LSConsoleWindow *window = [[self alloc] init];
    window.windowLevel = UIWindowLevelAlert + 100;
    window.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 30, 120, 30, 90);
    LSConsoleRootViewController *vc=[[LSConsoleRootViewController alloc]init];
    vc.consoleWindow=window;
    window.rootViewController=vc;
    window .hidden=NO;
    return window;
}

-(LSConsoleRootViewController *)consoleRootViewController{
    return (LSConsoleRootViewController*)self.rootViewController;
}

- (void)maxmize {
    
    self.isFullScreen=YES;
    self.frame = [UIScreen mainScreen].bounds;
    self.consoleRootViewController.textView.scrollEnabled = YES;
}

- (void)minimize {
    self.isFullScreen=NO;
    if (CGRectEqualToRect(self.currentFrame, CGRectZero)) {
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 30, 120, 30, 90);
    }else{
        self.frame =self.currentFrame;
    }
    self.consoleRootViewController.textView.scrollEnabled = NO;
}
-(void)setText:(NSString *)text{
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.consoleRootViewController.textView.text=text;
    });
    
}
-(NSString *)text{
    return self.consoleRootViewController.textView.text;
}

-(void)clearAllText{
    if (self.clearBlock) {
        self.clearBlock();
    }
}

@end



@implementation LSConsoleRootViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    UITextView *textView=[[UITextView alloc]init];
    textView.textAlignment=NSTextAlignmentLeft;
    textView.backgroundColor=[UIColor blackColor];
    textView.font=[UIFont systemFontOfSize:14];
    textView.editable=NO;
    textView.scrollEnabled=NO;
    textView.textColor=[UIColor whiteColor];
    textView.multipleTouchEnabled=YES;
    self.textView=textView;
    [self.view addSubview:textView];
    
    UIButton *button=[[UIButton alloc]init];
    button.layer.borderColor=[UIColor redColor].CGColor;
    button.layer.borderWidth=1;
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    self.hideButton=button;
    
    
    UIButton *clear=[[UIButton alloc]init];
    clear.layer.borderColor=[UIColor redColor].CGColor;
    clear.layer.borderWidth=1;
    [clear setTitle:@"clear" forState:UIControlStateNormal];
    [clear addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [clear setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:clear];
    self.clearButton=clear;
    
    UITapGestureRecognizer *tappGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapView:)];
    tappGest.numberOfTapsRequired = 2;
    [textView addGestureRecognizer:tappGest];
    [self panGesture];
}

-(void)hide{
    [self doubleTapView:nil];
}
-(void)clear
{
    self.textView.text=nil;
    [self.consoleWindow clearAllText];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.textView.frame=self.view.bounds;
    CGSize size=self.view.bounds.size;
    CGFloat x=size.width-80-10;
    if (self.consoleWindow.isFullScreen) {
        self.hideButton.frame=CGRectMake(x, 5, 80, 30);
        self.clearButton.frame=CGRectMake(x, 50, 80, 30);
    }else{
        self.hideButton.frame=CGRectZero;
        self.clearButton.frame=CGRectZero;
    }
}


- (UIPanGestureRecognizer *)panGesture{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panWindow:)];
        [self.textView addGestureRecognizer:_panGesture];
    }
    return _panGesture;
}
- (void)panWindow:(UIPanGestureRecognizer *)panGesture{
    
    if (self.consoleWindow.isFullScreen == YES) {
        return;
    }else{
        if(panGesture.state == UIGestureRecognizerStateChanged){
            CGPoint transalte = [panGesture translationInView:[UIApplication sharedApplication].keyWindow];
            CGRect rect = self.consoleWindow.frame;
            rect.origin.y += transalte.y;
            if(rect.origin.y < 0){
                rect.origin.y = 0;
            }
            CGFloat maxY = [UIScreen mainScreen].bounds.size.height - rect.size.height;
            if(rect.origin.y > maxY){
                rect.origin.y = maxY;
            }
            self.consoleWindow.frame = rect;
            self.consoleWindow.currentFrame=rect;
            [panGesture setTranslation:CGPointZero inView:[UIApplication sharedApplication].keyWindow];
        }
    }
}


- (void)doubleTapView:(UITapGestureRecognizer *)tapGesture{
    
    if (!self.consoleWindow.isFullScreen) {//变成全屏
        [UIView animateWithDuration:0.2 animations:^{
            [self.consoleWindow maxmize];
        } completion:^(BOOL finished) {
            self.consoleWindow.isFullScreen = YES;
            [self.consoleWindow.rootViewController.view removeGestureRecognizer:self.panGesture];
        }];
    }else{//退出全屏
        [UIView animateWithDuration:0.2 animations:^{
            [self.consoleWindow minimize];
        } completion:^(BOOL finished) {
            self.consoleWindow.isFullScreen = NO;
            [self.view addGestureRecognizer:self.panGesture];
        }];
    }
}
@end





@interface LSConsole()

@property (nonatomic, strong)  dispatch_source_t source;
@property (nonatomic,strong) LSConsoleWindow *consoleWindow;

@end

@implementation LSConsole


-(LSConsoleWindow *)createConsoleWindow
{
    if(!_consoleWindow){
        _consoleWindow = [LSConsoleWindow consoleWindow];
    }
    return _consoleWindow;
}

-(void)clearAllText
{
    
    NSString *filePath=LSConsoleLogFilePath;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager createFileAtPath:filePath contents:nil attributes:nil];
    return;
    NSError *error;
//  BOOL v=  [@"" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSFileHandle *writeHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [writeHandle writeData:[NSData data]];
    [writeHandle closeFile];
}

// 将NSlog打印信息保存到Document目录下的文件中
- (void)redirectNSlogToDocumentFolder
{
    NSString *logFilePath =LSConsoleLogFilePath;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager createFileAtPath:logFilePath contents:nil attributes:nil];

    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}


- (void)startLog;
{
    // 当真机连接Mac调试的时候把这些注释掉，否则log只会输入到文件中，而不能从xcode的监视器中看到。
    // 如果是真机就保存到Document目录下的log.txt文件中
    UIDevice *device = [UIDevice currentDevice];
//    if (![[device model] containsString:@"Simulator"]) {
        __weak typeof(self) weakSelf = self;
        [self createConsoleWindow];
        self.consoleWindow.clearBlock = ^{
            [weakSelf clearAllText];
        };
        // 开始保存日志文件
        [self redirectNSlogToDocumentFolder];
//        NSString *str=[self getLogText];
        NSString *logFilePath = LSConsoleLogFilePath;
        [self startMonitorFile:logFilePath];
//    }
}


- (void)startMonitorFile:(NSString *)filePath
{
    //监听文件的变化
    int const fd = open(filePath.fileSystemRepresentation, O_EVTONLY);
    if (fd < 0) {
        //目录为空
        return;
    }
    dispatch_source_t source =
    dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd,
                           DISPATCH_VNODE_WRITE,
                           DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_event_handler(source, ^() {
        unsigned long const type = dispatch_source_get_data(source);
        switch (type) {
            case DISPATCH_VNODE_WRITE: {
                NSString *text=[self getLogText];
                self.consoleWindow.text=text;
                break;
            }
            default:
                break;
        }
    });
    dispatch_source_set_cancel_handler(source, ^{
        close(fd);
    });
    self.source = source;
    dispatch_resume(self.source);
}
- (void)stopManager {
    dispatch_cancel(self.source);
}

-(NSString*)getLogText
{
    NSString *logFilePath =LSConsoleLogFilePath;
    NSFileHandle * fileHandle=[NSFileHandle fileHandleForReadingAtPath:logFilePath];
    NSData * data= [fileHandle readDataToEndOfFile];
    [fileHandle seekToEndOfFile];
    //定位光标的位置
    NSInteger line=   fileHandle.offsetInFile;
    NSString *text= [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [fileHandle closeFile];
    return text;
}




@end
