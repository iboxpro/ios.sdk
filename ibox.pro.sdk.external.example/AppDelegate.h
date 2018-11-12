//
//  AppDelegate.h
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 02.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
@private UIWindow *mWindow;
@private UINavigationController *mNavigationController;
@private Account *mAccount;
}

-(void)setAccount:(Account *)account;
-(UIWindow *)window;
-(Account *)account;

@end

