


//
//  LSConsoleView.m
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSConsoleView.h"
#import "LSConsoleLogTool.h"
#import "LSConsole.h"
#import "LSConsoleListViewController.h"
@interface LSConsoleView()

@property (nonatomic, strong)  dispatch_source_t source;
@property (nonatomic,copy)NSString *fileName;
@property (nonatomic,weak) UIButton *hideButton;
@property (nonatomic,weak) UIButton *openButton;
@property (nonatomic,weak) UIButton *clearButton;

@end

@implementation LSConsoleView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lastText=@"";
        self.fileName=[LSConsoleLogTool logFilePath];
        UITextView *textView=[[UITextView alloc]init];
        textView.showsVerticalScrollIndicator=YES;
        textView.textAlignment=NSTextAlignmentLeft;
        textView.backgroundColor=[UIColor blackColor];
        textView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
        textView.font=[UIFont systemFontOfSize:12];
        textView.editable=NO;
        textView.textColor=[UIColor whiteColor];
        textView.multipleTouchEnabled=YES;
        textView.layoutManager.allowsNonContiguousLayout = NO;
        [self addSubview:textView];
        self.textView=textView;

        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.text=[self getLogText];
        });
        
        
        UIButton *button=[[UIButton alloc]init];
        button.layer.borderColor=[UIColor redColor].CGColor;
        button.layer.borderWidth=1;
        [button setTitle:@"隐藏" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self addSubview:button];
        self.hideButton=button;
        
        UIButton *openButton=[[UIButton alloc]init];
        openButton.layer.borderColor=[UIColor greenColor].CGColor;
        openButton.layer.borderWidth=1;
        [openButton setTitle:@"打开列表" forState:UIControlStateNormal];
        [openButton addTarget:self action:@selector(open) forControlEvents:UIControlEventTouchUpInside];
        [openButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self addSubview:openButton];
        self.openButton=openButton;
        
        UIButton *clearButton=[[UIButton alloc]init];
        clearButton.layer.borderColor=[UIColor yellowColor].CGColor;
        clearButton.layer.borderWidth=1;
        [clearButton setTitle:@"清空" forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [self addSubview:clearButton];
        self.clearButton=clearButton;
     
        
        self.textView.frame=self.bounds;
        self.hideButton.frame=CGRectMake(self.frame.size.width-10-80, 5, 80, 30);
        self.openButton.frame=CGRectMake(self.frame.size.width-10-80, 45, 80, 30);
        self.clearButton.frame=CGRectMake(self.frame.size.width-10-80, 85, 80, 30);
    }
    return self;
}
-(void)clear{
    self.lastText=@"";
    self.textView.text=@"";
}
-(void)open
{
    [LSConsole shareInstance].debugWindow.hidden=YES;
    LSConsoleListViewController *logListController = [[LSConsoleListViewController alloc]initWithStyle:UITableViewStylePlain];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logListController];
    UIViewController *rootVc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootVc presentViewController:nav animated:YES completion:nil];
}

-(void)hide{
    LSConsoleWindow *window= [LSConsole shareInstance].debugWindow;
    [UIView animateWithDuration:0.25 animations:^{
        window.frame=CGRectMake(LSConsoleScreenWidth, window.frame.origin.y, window.frame.size.width, window.frame.size.height);
    }completion:^(BOOL finished) {
        window.frame= window.smallFrame;
        self.hidden=YES;
        window.hidden=NO;
        [LSConsole shareInstance].debugWindow.isFullScreen=NO;
    }];
}

- (void)stopManager {
    dispatch_cancel(self.source);
}

-(void)setText:(NSString *)text
{
    if (text==nil) {
        return;
    }
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue=dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL);
    });
    
    dispatch_async(queue, ^{
        NSString *newText=[self.lastText stringByAppendingString:text];
        if (newText.length>LSConsoleMaxTextLength) {
            newText=[newText substringFromIndex:newText.length-LSConsoleMaxTextLength];
        }
        self.lastText=newText;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.hidden) {
                return;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LSConsoleDelayShowTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([self.lastText isEqualToString: self.textView.text]) {
                    return ;
                }
                CGFloat offset1=self.textView.contentOffset.y;
                CGFloat height1=self.textView.contentSize.height;
                //加1是因为有时候获取的总是差1 原因未知
                BOOL needScroll=!(self.textView.contentOffset.y+1 < (self.textView.contentSize.height-self.textView.frame.size.height));
                self.textView.text=self.lastText;
                if(needScroll){
                    [self.textView scrollRangeToVisible:NSMakeRange(0,self.textView.text.length) ];
                }else{
                    //                    [self.textView setContentOffset:CGPointMake(0, y) ];
                }
                CGFloat offset2=self.textView.contentOffset.y;
                CGFloat height2=self.textView.contentSize.height;
                NSLog(@"%lf %lf %lf %lf",offset1,height1,offset2,height2);
            });
        });
    });
    
}
-(NSString*)getLogText
{
    NSString *text= [[NSString alloc]initWithData:[NSData dataWithContentsOfFile:self.fileName] encoding:NSUTF8StringEncoding];
    return text;
}

//此方法没有用到 此方法是监听文件变化
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

@end
