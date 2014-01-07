//
//  NPRAppDelegate.m
//  PubCharts
//
//  Created by Michael Seifollahi on 1/2/14.
//  Copyright (c) 2014 NPR. All rights reserved.
//

#import "NPRAppDelegate.h"

#import "NPRRootViewController.h"

@implementation NPRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NPRRootViewController *rootVC = [[NPRRootViewController alloc] init];
    
    self.navCon =
        [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    
    [self.window setRootViewController:self.navCon];
    self.window.backgroundColor = [UIColor whiteColor];
    
    CGRect frame =
    CGRectMake(0.0f, CGRectGetHeight(self.navCon.navigationBar.frame) - 3.0f,
               CGRectGetWidth(self.navCon.navigationBar.frame) / 3, 3.0f);
    UIView *redStripe = [[UIView alloc] initWithFrame:frame];
    [redStripe setBackgroundColor:HEXCOLOR(COLOR_NPR_RED)];
    
    frame.origin.x += CGRectGetWidth(self.navCon.navigationBar.frame) / 3;
    UIView *blackStripe = [[UIView alloc] initWithFrame:frame];
    [blackStripe setBackgroundColor:[UIColor blackColor]];
    
    frame.origin.x += CGRectGetWidth(self.navCon.navigationBar.frame) / 3;
    UIView *blueStripe = [[UIView alloc] initWithFrame:frame];
    [blueStripe setBackgroundColor:HEXCOLOR(COLOR_NPR_BLUE)];
    
    [self.navCon.navigationBar addSubview:redStripe];
    [self.navCon.navigationBar addSubview:blackStripe];
    [self.navCon.navigationBar addSubview:blueStripe];
    
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
