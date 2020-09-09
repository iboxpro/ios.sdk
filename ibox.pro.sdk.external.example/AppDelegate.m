//
//  AppDelegate.m
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 02.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "AppDelegate.h"
#import "Initial.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    mWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [mWindow setBackgroundColor:[UIColor whiteColor]];
    
    mNavigationController = [[UINavigationController alloc] init];
    [mNavigationController.view setBackgroundColor:[UIColor whiteColor]];
    [mNavigationController setNavigationBarHidden:TRUE];
    
    [mWindow setRootViewController:mNavigationController];
    [mWindow makeKeyAndVisible];
    
    Initial *login = [[Initial alloc] init];
    [mNavigationController pushViewController:login animated:FALSE];
    [login release];
    
    [self setAccount:NULL];
    
    return TRUE;
}

-(void)applicationWillResignActive:(UIApplication *)application
{
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
}

-(void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark - Public methods
-(void)setAccount:(Account *)account
{
    if (mAccount != account)
    {
        if (mAccount)
            [mAccount release];
        [account retain];
        mAccount = account;
    }
}

-(UIViewController *)currentViewController
{
    return [[mNavigationController viewControllers] lastObject];
}

-(UIWindow *)window
{
    return mWindow;
}

-(Account *)account
{
    return mAccount;
}

/*
 removed from info.plist 29.05.2019
 <key>UIBackgroundModes</key>
 <array>
 <string>external-accessory</string>
 <string>bluetooth-central</string>
 </array>
 */

@end
