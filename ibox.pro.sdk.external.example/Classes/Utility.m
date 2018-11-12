//
//  Utility.m
//  Ferret
//
//  Created by AxonMacMini on 25.12.14.
//  Copyright (c) 2014 DevReactor. All rights reserved.
//

#import "Utility.h"

@implementation Utility

#pragma mark - Localization
+(void)updateTextWithViewController:(UIViewController *)viewController
{
    if (viewController.view) [Utility updateTextWithView:viewController.view];
}

+(void)updateTextWithView:(UIView *)view
{
    for (UIView *subView in view.subviews)
    {
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel *lbl = (UILabel *)subView;
            NSString *keyString = [Utility innerText:lbl.text];
            if (keyString && ![keyString isEqualToString:@""])
            {
                [lbl setText:[Utility localizedStringWithKey:keyString]];
            }
        }
        else if ([subView isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)subView;
            NSString *keyString = [Utility innerText:btn.titleLabel.text];
            if (keyString && ![keyString isEqualToString:@""])
            {
                [btn setTitle:[Utility localizedStringWithKey:keyString] forState:UIControlStateNormal];
                [btn setTitle:[Utility localizedStringWithKey:keyString] forState:UIControlStateHighlighted];
                [btn setTitle:[Utility localizedStringWithKey:keyString] forState:UIControlStateSelected];
                [btn setTitle:[Utility localizedStringWithKey:keyString] forState:UIControlStateDisabled];
            }
        }
        else if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *txt = (UITextField *)subView;
            NSString *keyString = [Utility innerText:txt.text];
            if (keyString && ![keyString isEqualToString:@""])
            {
                [txt setText:[Utility localizedStringWithKey:keyString]];
            }
            keyString = [Utility innerText:txt.placeholder];
            if (keyString && ![keyString isEqualToString:@""])
            {
                [txt setPlaceholder:[Utility localizedStringWithKey:keyString]];
            }
        }
        else if ([subView isKindOfClass:[UITextView class]])
        {
            UITextView *txt = (UITextView *)subView;
            NSString *keyString = [Utility innerText:txt.text];
            if (keyString && ![keyString isEqualToString:@""])
            {
                [txt setText:[Utility localizedStringWithKey:keyString]];
            }
        }
        else
        {
            [Utility updateTextWithView:subView];
        }
    }
}

+(NSString *)innerText:(NSString *)string
{
    NSString *result = NULL;
    
    if (string && ![string isEqualToString:@""])
        if ([string hasPrefix:@"["] && [string hasSuffix:@"]"])
            result = [string substringWithRange:NSMakeRange(1, string.length - 2)];
    
    return result;
}

+(NSString *)localizedStringWithKey:(NSString *)key
{
    NSString *returnValue = NSLocalizedString(key, NULL);
    if ([returnValue isEqualToString:key])
    {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"]];
        returnValue = NSLocalizedStringFromTableInBundle(key, @"Localizable", bundle, NULL);
    }
    return returnValue;
}

+(NSLocale *)enUSPOSIXLocale
{
    return [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
}

#pragma mark - Image
+(UIImage *)createQRWithString:(NSString *)qrString
{
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = [qrFilter outputImage];
    float scaleX = 200.0f / qrImage.extent.size.width;
    float scaleY = 200.0f / qrImage.extent.size.height;
    
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:qrImage fromRect:[qrImage extent]];
    UIImage *image = [[UIImage alloc] initWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;
}

#pragma mark - Other methods
+(AppDelegate *)appDelegate
{
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
}

@end
