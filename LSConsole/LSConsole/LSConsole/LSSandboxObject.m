




//
//  LSSandboxObject.m
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSSandboxObject.h"
#import "LSConsoleDefine.h"

@implementation LSSandboxObject
- (instancetype)initWithKey:(NSString *)key value:(NSObject *)value preNode:(LSSandboxObject *)node
{
    if(self = [super init]){
        self.key = key;
        self.value = value;
        self.preNode = node;
    }
    return self;
}

- (NSDictionary *)dicOfValue
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if([_value isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray *)_value;
        for(NSInteger i = 0; i < array.count; i++){
            dic[@(i)] = array[i];
        }
    }else if ([_value isKindOfClass:[NSDictionary class]]){
        [dic setDictionary:(NSDictionary *)_value];
    }else if(_value){
        dic[_key?:@""] = _value;
    }
    return dic;
}

- (void)setDicOfValue:(NSDictionary *)dicOfValue
{
    if(!dicOfValue || ![dicOfValue isKindOfClass:[NSDictionary class]]){
        return;
    }
    if([_value isKindOfClass:[NSArray class]]){
        //需要保证数组的有序性
        NSInteger count = dicOfValue.allKeys.count;
        NSMutableArray *tmpValue = [NSMutableArray arrayWithCapacity:count];
        for(NSInteger i = 0; i < count; i++){
            NSObject *tmpObj = dicOfValue[@(i)];
            if(tmpObj){
                [tmpValue addObject:tmpObj];
            }
        }
        _value = tmpValue;
    }else if ([_value isKindOfClass:[NSDictionary class]]){
        _value = dicOfValue;
    }else if(_value){
        _value = dicOfValue[_key?:@""];
    }
    
    //更新父节点  父节点要么是数组要么是字典
    LSSandboxObject *obj = self;
    while (obj.preNode && [obj.preNode isKindOfClass:[LSSandboxObject class]]) {
        LSSandboxObject *preObj = obj.preNode;
        if([preObj.value isKindOfClass:[NSArray class]]){
            NSMutableArray *mutArray = [NSMutableArray arrayWithArray:(NSArray *)preObj.value];
            NSInteger index = [obj.key integerValue];
            if(mutArray.count > index){
                mutArray[index] = obj.value;
            }
            preObj.value = mutArray;
        }else if ([preObj.value isKindOfClass:[NSDictionary class]]){
            NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)preObj.value];
            [mutDic setObject:obj.value forKey:obj.key];
            preObj.value = mutDic;
        }
        obj = preObj;
    };
    
    [self saveToSandbox];
}

- (void)saveToSandbox
{
    LSSandboxObject *obj = self;
    while (obj.preNode && [obj.preNode isKindOfClass:[LSSandboxObject class]]) {
        obj = obj.preNode;
    }
    //保存到沙盒
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:obj.value forKey:obj.key];
    [userDefaults synchronize];
}

+ (NSArray *)fetchValues
{
    return [self fetchValuesWithPrefix:LSConsoleDefaultPrefix];
}

+ (NSArray *)fetchValuesWithPrefix:(NSString *)prefix
{
    NSMutableArray *values = [NSMutableArray array];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSArray *keys = dic.allKeys;
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if([evaluatedObject isKindOfClass:[NSString class]]){
            NSString *key = (NSString *)evaluatedObject;
            return [key hasPrefix:prefix?:LSConsoleDefaultPrefix];//注意：这里假设我们自己保存到沙盒的key都是以kYL开头的
        }
        return NO;
    }];
    keys = [keys filteredArrayUsingPredicate:predicate];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = (NSString *)obj;
        id value = dic[key];
        LSSandboxObject *var = [[LSSandboxObject alloc]initWithKey:key value:value preNode:nil];
        [values addObject:var];
    }];
    return values;
}

@end
