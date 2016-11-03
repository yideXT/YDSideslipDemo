//
//  AppDelegate.m
//  YDSideslipDemo
//
//  Created by 罗义德 on 15/6/19.
//  Copyright (c) 2015年 lyd. All rights reserved.
//

#import "AppDelegate.h"
#import "FOSideslipViewController.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ViewController *mainVC = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    
    FOSideslipViewController *sideslipVC = [[FOSideslipViewController alloc] initWithCenterViewController:nav];
    //是否显示抽屉阴影
    sideslipVC.isShowShadow = YES;
    //动画的时间
    sideslipVC.animationDuration = 0.35;
    //关掉缩放
    sideslipVC.isCenterScaleGradient = NO;
    //取消阴影
    sideslipVC.isShowShadow = NO;
    //左边控制器offset
    sideslipVC.leftOffset = [UIScreen mainScreen].bounds.size.width - 80;
    
    
    UIViewController *left = [[UIViewController alloc] init];
    left.view.backgroundColor = [UIColor greenColor];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:left];
    left.title = @"左边控制器";
    sideslipVC.leftViewController = nav1;
    
    UITableViewController *right = [[UITableViewController alloc] init];
    right.view.backgroundColor = [UIColor colorWithRed:0.19f green:0.60f blue:1.00f alpha:1.00f];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:right];
    right.title = @"右边控制器";
    sideslipVC.rightViewController = nav2;
    
    self.window.rootViewController = sideslipVC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
