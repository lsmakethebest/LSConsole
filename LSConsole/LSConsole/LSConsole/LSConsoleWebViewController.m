//
//  LSConsoleWebViewController.m
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSConsoleWebViewController.h"
#import "LSConsoleLogTool.h"
#import "UIWebView+LSConsole.h"
#import "LSConsoleDefine.h"
@interface LSConsoleWebViewController ()<UIWebViewDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)UIWebView *myWebView;
@property(nonatomic,strong)UIActivityIndicatorView *indicator;
@property(nonatomic,copy)NSString *content;
@end

@implementation LSConsoleWebViewController

- (instancetype)initWithFile:(NSString *)name
{
    if(self = [super init]){
        self.title = name;
        NSString *path = [LSConsoleLogTool pathForFile:name];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        str=[str stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
        NSString *htmlStr = [NSString stringWithFormat:
                             @"<HTML>"
                             "<head>"
                             "<title>%@</title>"
                             "</head>"
                             "<BODY"
                             "<div style=\"font-size:10px;padding:200px;color:red>\""
                             "%@"
                             "</div>"
                             "</BODY>"
                             "</HTML>",
                             name,str];
        self.content = htmlStr;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search)];
    self.navigationItem.rightBarButtonItem = searchItem;
    
    [self.view addSubview:self.myWebView];
    //    self.myWebView.scalesPageToFit=YES;
    [self.myWebView loadHTMLString:_content baseURL:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (UIWebView *)myWebView
{
    if(!_myWebView){
        _myWebView = [[UIWebView alloc]initWithFrame:self.view.bounds];
        _myWebView.delegate = self;
        _myWebView.scalesPageToFit=NO;
        _myWebView.frame=CGRectMake(0, 0,LSConsoleScreenWidth, LSConsoleScreenHeight-LSConsoleNavBarHeight);
        
        _myWebView.scalesPageToFit = YES;
        //        _myWebView.multipleTouchEnabled = YES;
        //        _myWebView.scrollView.scrollEnabled = YES;
        _myWebView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _myWebView;
}



- (UIActivityIndicatorView *)indicator
{
    if(!_indicator){
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.center = self.view.center;
    }
    return _indicator;
}

#pragma mark---UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view addSubview:self.indicator];
    [self.indicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
    
    
    NSString *jsMeta = [NSString stringWithFormat:@"var meta = document.createElement('meta');meta.content='width=device-width,initial-scale=1,minimum-scale=.1,maximum-scale=3,user-scalable =yes';meta.name='viewport';document.getElementsByTagName('head')[0].appendChild(meta);"];
    [webView stringByEvaluatingJavaScriptFromString:jsMeta];
    CGFloat height = webView.scrollView.contentSize.height;
    if(height > CGRectGetHeight(self.view.frame)){
        height -= CGRectGetHeight(self.view.frame);
        [webView.scrollView setContentOffset:CGPointMake(0, height)];
    }
}

#pragma mark---UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex){
        NSString *keywords = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(keywords.length > 0){
            [self.myWebView yl_highlightAllOccurencesOfString:keywords];
        }
    }
}

#pragma mark---other methods
- (void)search
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请输入关键字"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"搜索", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)orientationChanged
{
    self.myWebView.frame = self.view.frame;
    self.indicator.center = self.view.center;
}


@end
