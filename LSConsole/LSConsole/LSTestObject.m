


//
//  LSTestObject.m
//  LSConsole
//
//  Created by liusong on 2018/3/2.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "LSTestObject.h"

@implementation LSTestObject

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value
{
    if(self = [super init]){
        self.key = key;
        self.value = value;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.key = [aDecoder decodeObjectForKey:@"key"];
    self.value = [aDecoder decodeObjectForKey:@"value"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeObject:_value forKey:@"value"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"key:%@, value:%@",_key,_value];
}

@end
