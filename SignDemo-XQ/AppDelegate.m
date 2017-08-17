//
//  AppDelegate.m
//  SignDemo-XQ
//
//  Created by 萧奇 on 2017/8/14.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "AppViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 配置高德地图
    [AMapServices sharedServices].apiKey = @"4155a176a611711cae5f98d3b1a993a3";
    
    // 监听网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case -1:
                Log(@"未知网络");
                break;
            case 0:
                Log(@"网络不可用");
                break;
            case 1:
                Log(@"GPRS网络");
                break;
            case 2:
                Log(@"wifi网络");
                break;
            default:
                break;
        }
        User *user = [User shareUser];
        if(status ==AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi){
            Log(@"有网");
            user.netState = YES;
        }else {
            Log(@"没有网");
            user.netState = NO;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"失去网络连接" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[AppViewController new]];
    self.window.rootViewController = navigationController;
    
    
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
