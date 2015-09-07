//
//  DRToast.h
//  TestLib
//
//  Created by Oleg on 24.04.13.
//  Copyright (c) 2013 Devreactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum
{
    Long = 3,
    Short = 1
} ToastDuration;

@interface DRToast : NSObject
{
@private UIWindow *mWindow;
@private UIView *mMainWrapper;
@private UILabel *mTitleView;
@private UIButton *mMessageView;
@private UIView *mTouchInterceptor;
@private UIImageView *mExclamationMarkView;
@private UIInterfaceOrientation mCurrentOrientation;
    
@private NSMutableString *mMessage;
@private NSString *mTitle;

@private float mDuration;
@private float mOvertime;
@private CGRect mScreenRect;
@private BOOL mIsDead;
@private BOOL mIsHidden;
@private BOOL mIsImportant;
}

-(DRToast *)initWithMessage:(NSString *)message;
-(DRToast *)initWithMessage:(NSString *)message Duration:(ToastDuration) duration;
-(DRToast *)initWithMessage:(NSString *)message Title:(NSString *)title Duration:(ToastDuration) duration;

-(void)addMessage:(NSString *)message;
-(void)makeImportant;
-(void)show;

-(NSString *)message;

@end