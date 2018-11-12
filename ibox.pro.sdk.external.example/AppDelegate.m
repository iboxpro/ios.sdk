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
    
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
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

-(UIWindow *)window
{
    return mWindow;
}

-(Account *)account
{
    return mAccount;
}

@end
