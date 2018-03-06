



//
//  LSConsoleListViewController.m
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSConsoleListViewController.h"
#import "LSConsole.h"
#import "LSConsoleWebViewController.h"
#import "LSConsoleSandboxViewController.h"
#import "LSSandboxObject.h"
@interface LSConsoleListViewController ()

@property (nonatomic,strong) NSMutableArray *logList;
@property (nonatomic,strong) NSMutableArray *sandboxValues;
@property(nonatomic,strong)UIButton *footer;

@end

@implementation LSConsoleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.title = @"LSConsole";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"删除全部" style:UIBarButtonItemStylePlain target:self action:@selector(clean)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = self.footer;
    self.logList=[LSConsoleLogTool allLogFileNames];
    
    
    self.sandboxValues=[NSMutableArray arrayWithArray:[LSSandboxObject fetchValues]];
}

- (UIButton *)footer
{
    if(!_footer){
        _footer = [UIButton buttonWithType:UIButtonTypeCustom];
        _footer.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _footer.frame = CGRectMake(0, 0, 0, 45);
        _footer.titleLabel.font = [UIFont systemFontOfSize:20];
        [_footer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_footer setTitle:@"添加键值对" forState:UIControlStateNormal];
        [_footer addTarget:self action:@selector(addKeyValue) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footer;
}

#pragma mark---other methods
- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [LSConsole shareInstance].debugWindow .hidden = NO;
}

- (void)clean
{
    [LSConsoleLogTool deleteAllLogFiles];
    [self.logList removeAllObjects];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? @"日志文件" : @"沙盒值";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) return self.logList.count;
    return self.sandboxValues.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"cell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section==0) {
        cell.textLabel.text=self.logList[indexPath.row];
    }else{
        LSSandboxObject *object=self.sandboxValues[indexPath.row];
        cell.textLabel.text=object.key;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        LSConsoleWebViewController *web=[[LSConsoleWebViewController alloc]initWithFile:self.logList[indexPath.row]];
        [self.navigationController pushViewController:web animated:YES];
    }else if (indexPath.section==1){
        LSConsoleSandboxViewController *preController = [[LSConsoleSandboxViewController alloc]initWithSandboxObject:self.sandboxValues[indexPath.row]];
        [self.navigationController pushViewController:preController animated:YES];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(indexPath.section == 0){
            [LSConsoleLogTool deleteLogFile:self.logList[indexPath.row]];
            [self.logList removeObjectAtIndex:indexPath.row];
        }else{
            LSSandboxObject *obj = self.sandboxValues[indexPath.row];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:obj.key];
            [userDefaults synchronize];
            [self.sandboxValues removeObjectAtIndex:indexPath.row];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)addKeyValue
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请填写键值对信息" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [[alert textFieldAtIndex:0] setPlaceholder:@"key"];
    [[alert textFieldAtIndex:1] setPlaceholder:@"value"];
    [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
    [alert show];
}

#pragma mark---UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex){
        NSString *key = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *value = [[[alertView textFieldAtIndex:1] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(key.length > 0 && value.length > 0){
            NSObject *obj;
            NSString *tmpStr = [value stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            if(tmpStr.length == 0) {
                //都是数字
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
                obj = [formatter numberFromString:value];
            } else {
                //不是数字
                obj = value;
            }
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:obj forKey:key];
            [userDefaults synchronize];
            
            self.sandboxValues = [NSMutableArray arrayWithArray:[LSSandboxObject fetchValues]];
            [self.tableView reloadData];
        }
    }
}


@end
