//
//  LSTestObject.h
//  LSConsole
//
//  Created by liusong on 2018/3/2.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSTestObject : NSObject<NSCopying>

@property(nonatomic,copy)NSString *key;
@property(nonatomic,copy)NSString *value;
- (instancetype)initWithKey:(NSString *)key value:(NSString *)value;

@end
