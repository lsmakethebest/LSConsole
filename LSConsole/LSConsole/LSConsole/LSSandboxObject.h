//
//  LSSandboxObject.h
//  LSConsole
//
//  Created by liusong on 2018/3/1.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSSandboxObject : NSObject

@property(nonatomic,copy)NSString *key;
@property(nonatomic,strong)NSObject *value;
@property(nonatomic,weak)LSSandboxObject *preNode;///< 父节点
@property(nonatomic,copy)NSDictionary *dicOfValue;

- (instancetype)initWithKey:(NSString *)key value:(NSObject *)value preNode:(LSSandboxObject *)node;
/*
 获取本地沙盒保存的值 这里只返回自己保存的，不返回系统保存的
 返回包含YLSandboxObject对象的数组
 */
+ (NSArray *)fetchValues;

/*
 获取本地沙盒保存的值，传入你本地key的前缀进行筛选。
 返回包含YLSandboxObject对象的数组
 */
+ (NSArray *)fetchValuesWithPrefix:(NSString *)prefix;
@end
