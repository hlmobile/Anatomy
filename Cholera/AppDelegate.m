//
//  AppDelegate.m
//  Cholera
//
//  Created by DianWei on 10/29/13.
//  Copyright (c) 2013 DianWei. All rights reserved.
//

#import "AppDelegate.h"
#import "Utils.h"
#import "JSON.h"

#import "SplashViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isForcedQuit = [[standardUserDefaults objectForKey:@"isForcedQuit"] boolValue];
    if ( isForcedQuit ) {
        NSLog(@"AppDelegate app was crashed last time");
    } else {
        NSLog(@"AppDelegate app was quited");
    }
    [standardUserDefaults setBool:YES forKey:@"isForcedQuit"];
    [standardUserDefaults synchronize];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    SplashViewController *splashCtlr = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:splashCtlr];
    
    // Splash view
    self.navigationController.navigationBarHidden = YES;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
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
    NSLog(@"AppDelegate applicationDidEnterBackground");

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:NO forKey:@"isForcedQuit"];
    [standardUserDefaults synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"AppDelegate applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"AppDelegate applicationDidBecomeActive");

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setBool:YES forKey:@"isForcedQuit"];
    [standardUserDefaults synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"AppDelegate applicationWillTerminate");
}

@end
