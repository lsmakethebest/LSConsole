//
//  AppDelegate.m
//  LSConsole
//
//  Created by liusong on 2018/2/28.
//  Copyright © 2018年 liusong. All rights reserved.
//

#import "AppDelegate.h"
#import "LSConsole.h"
#import "LSTestObject.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [LSConsole startDebugWithIsAlwaysShow:NO];
    //测试沙盒的值
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(YES) forKey:@"LSBOOLKey"];
    [userDefaults setObject:@(238) forKey:@"LSIntegerKey"];
    [userDefaults setObject:@(66.66) forKey:@"LSFloatKey"];
    [userDefaults setObject:@(66.666666) forKey:@"LSDoubleKey"];
    [userDefaults setObject:@"test string" forKey:@"LSStringKey"];
    [userDefaults setObject:@[@"测试",@1,@2,@"https://github.com/lsmakethebest"] forKey:@"LSArrayKey"];
    [userDefaults setObject:@{@"key1":@"value1",@"key2":@200,@"key3":@[@1,@2,@3]} forKey:@"LSDictionaryKey"];
    LSTestObject *obj = [[LSTestObject alloc] initWithKey:@"testKey" value:@"testValue"];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:obj] forKey:@"LSCustomObjectKey"];
    [userDefaults synchronize];

    //反序列化
    //    NSData *data = [userDefaults objectForKey:@"LSCustomObjectKey"];
    //    NSObject *custom = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
