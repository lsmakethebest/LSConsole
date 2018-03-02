//
//  LSConsoleSandboxViewController.m
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSConsoleSandboxViewController.h"
#import "LSSandboxObject.h"
#import "LSConsoleLogTool.h"
#import "LSConsoleCell.h"
static NSString * const LSObjectChangedNotification = @"LSObjectChangedNotification";
static NSString *cellIdentifier = @"LSConsoleCell";

@interface LSConsoleSandboxViewController ()
{
    NSArray *keys;
    NSMutableDictionary *dataDic;
}
@property(nonatomic,strong)LSSandboxObject *obj;
@property(nonatomic,strong)UITableView *table;
@property(nonatomic,weak)UITextField *activeField;
@end

@implementation LSConsoleSandboxViewController

- (instancetype)initWithSandboxObject:(LSSandboxObject *)obj
{
    if(self = [super init]){
        self.obj = obj;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.title = _obj.key;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    [self.view addSubview:self.table];
    [self reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification:) name:LSObjectChangedNotification object:nil];
}

- (void)reloadData
{
    NSDictionary *dicValue = [_obj dicOfValue];
    dataDic = [NSMutableDictionary dictionaryWithDictionary:dicValue];
    keys = [dataDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if(obj1 < obj2) return NSOrderedAscending;
        if(obj1 > obj2) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    [_table reloadData];
}

- (void)reloadNotification:(NSNotification *)notification
{
    if([notification.object isKindOfClass:[LSSandboxObject class]]){
        LSSandboxObject *otherObj = (LSSandboxObject *)notification.object;
        if(self.obj == otherObj){
            [self reloadData];
        }
    }
}

- (UITableView *)table
{
    if(!_table){
        _table = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_table registerClass:[LSConsoleCell class] forCellReuseIdentifier:cellIdentifier];
        _table.dataSource = self;
        _table.delegate = self;
        _table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;//拖动时释放键盘
        _table.tableFooterView = [UIView new];
    }
    return _table;
}


#pragma mark---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return keys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    LSConsoleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = indexPath.row;
    NSObject *key = keys[row];
    NSObject *value = dataDic[key];
    [cell refreshWithTitle:key value:value];
    cell.valueField.tag = row;
    cell.valueField.delegate = self;
    return cell;
}

#pragma mark---UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [LSConsoleCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSString *key = keys[row];
    NSObject *value = dataDic[key];
    if([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]])
    {
        LSSandboxObject *obj = [[LSSandboxObject alloc]initWithKey:key value:value preNode:_obj];
        LSConsoleSandboxViewController *preController = [[LSConsoleSandboxViewController alloc]initWithSandboxObject:obj];
        [self.navigationController pushViewController:preController animated:YES];
    }
}

#pragma mark---UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger row = textField.tag;
    if(keys.count > row){
        NSObject *key = keys[row];
        NSString *content = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *tmpStr = [content stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        if(tmpStr.length == 0) {
            //都是数字
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
            NSNumber *number = [formatter numberFromString:content];
            dataDic[key] = number;
        } else {
            //不是数字
            dataDic[key] = content;
        }
    }
}

#pragma mark---other methods
- (void)save
{
    [self.view endEditing:YES];
    [self.obj setDicOfValue:dataDic];
    [[NSNotificationCenter defaultCenter] postNotificationName:LSObjectChangedNotification object:self.obj.preNode];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
