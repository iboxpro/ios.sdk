//
//  Utility.h
//  Ferret
//
//  Created by AxonMacMini on 25.12.14.
//  Copyright (c) 2014 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Utility : NSObject

#pragma mark - Localization
+(void)updateTextWithViewController:(UIViewController *)viewController;
+(void)updateTextWithView:(UIView *)view;
+(NSString *)innerText:(NSString *)string;
+(NSString *)localizedStringWithKey:(NSString *)key;
+(NSLocale *)enUSPOSIXLocale;

@end