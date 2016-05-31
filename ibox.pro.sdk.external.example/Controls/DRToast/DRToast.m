//
//  DRToastNew.m
//  iboxPro
//
//  Created by Axon on 21.08.13.
//  Copyright (c) 2013 Maxim Rudenko. All rights reserved.
//

#import "DRToast.h"
#import "DRToastManager.h"

@implementation DRToast

#pragma mark - Consts
static const float DEFAULT_HEIGHT = 85.0f;
static const float WIDTH = 270.0f;

#pragma mark - Ctors/Dtor
-(DRToast *)initWithMessage:(NSString *)message Title:(NSString *)title Duration:(ToastDuration)duration
{
    self = [super init];
    if (self)
    {
        DRToast *toast = [[DRToastManager instance] toast];
        if (!toast)
        {
            float width = [[UIScreen mainScreen] bounds].size.width;
            float height = [[UIScreen mainScreen] bounds].size.height;
            if (width < height)
                mScreenRect = CGRectMake(0.0f, 0.0f, width, height);
            else
                mScreenRect = CGRectMake(0.0f, 0.0f, height, width);
            
            mMessage = [[NSMutableString alloc] init];
            if (message) [mMessage appendString:message];
            mTitle = title;
            mDuration = (float)duration;
            mIsHidden = TRUE;
            mIsDead = FALSE;
            
            mWindow = [[UIWindow alloc] initWithFrame:mScreenRect];
            [mWindow setTag:66];
            
            [self createBackground];
            [self createMainView];
            if (mTitle) [self createTitleView];
            [self createMessageView];
            [self createTouchInterceptor];

            [[DRToastManager instance] setToast:self];
        }
        else
        {
            mIsDead = TRUE;
            [toast addMessage:message];
        }
    }
    return self;
}

-(DRToast *)initWithMessage:(NSString *)message Duration:(ToastDuration)duration
{
    return [self initWithMessage:message Title:NULL Duration:duration];
}

-(DRToast *)initWithMessage:(NSString *)message
{
    return [self initWithMessage:message Title:NULL Duration:Long];
}

-(void)dealloc
{
    if (mMessage) [mMessage release];
    [super dealloc];
}

#pragma mark - Public methods
-(void)addMessage:(NSString *)message
{
    if (!message)
        return;
    
    mOvertime += mDuration;
    [mMessage appendFormat:@"\n%@", message];
    [mMessageView setTitle:NULL forState:UIControlStateNormal];
    [mMessageView setTitle:mMessage forState:UIControlStateNormal];
    [self updateMessageView];
}

-(void)show
{
    if (mIsDead)
        [[DRToastManager instance] destroyToast:self];
    else
    {
        mWindow.windowLevel = UIWindowLevelAlert;
        [mWindow makeKeyAndVisible];
        
        CGAffineTransform transform = mMainWrapper.transform;
        [mMainWrapper setAlpha:0.0f];
        [mMainWrapper setTransform:CGAffineTransformScale(transform, 0.5f, 0.5f)];
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [mMainWrapper setAlpha:1.0f];
            [mMainWrapper setTransform:CGAffineTransformScale(transform, 1.1f, 1.1f)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.08f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [mMainWrapper setTransform:CGAffineTransformScale(transform, 1.0f, 1.0f)];
            } completion:^(BOOL finished) {
                mIsHidden = FALSE;
                [self hideAfter:mDuration];
            }];
        }];
    }
}

-(void)hideAfter:(float)time
{
    dispatch_time_t sleepTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
    dispatch_after(sleepTime, dispatch_get_main_queue(), ^(void) {
        if (mOvertime > 0)
        {
            [self hideAfter:mOvertime];
            mOvertime -= mDuration;
        }
        else
        {
            [self hide];
            [self release];
        }
    });
}

-(void)hide
{
    if (!mIsHidden)
    {
        mIsHidden = TRUE;
        [[DRToastManager instance] setToast:NULL];
        
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [mWindow setAlpha:0.0f];
        } completion:^(BOOL finished) {
            //[mWindow resignKeyWindow];
            [mWindow release];
            [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
        }];
    }
}

-(void)makeImportant
{
    mIsImportant = TRUE;
    
    if (mTitleView)
        [mTitleView removeFromSuperview];
 
    CGSize exclamationMarkSize = CGSizeMake(12.0f, 54.0f);
    mExclamationMarkView = [[UIImageView alloc]init];
    [mExclamationMarkView setFrame:CGRectMake((int)(mMainWrapper.frame.size.width / 2 - exclamationMarkSize.width / 2), 10.0f, exclamationMarkSize.width, exclamationMarkSize.height)];
    [mExclamationMarkView setContentMode:UIViewContentModeScaleAspectFit];
    [mExclamationMarkView setImage:[UIImage imageNamed:@"exclamation_mark"]];
    [mMainWrapper addSubview:mExclamationMarkView];
    [mExclamationMarkView release];
    
    [mMessageView setFrame:CGRectMake(mMessageView.frame.origin.x, exclamationMarkSize.height + 20.0f, mMessageView.frame.size.width, mMessageView.frame.size.height)];
    
    float totalContentHeight = mMessageView.frame.origin.y + mMessageView.frame.size.height;
    [mMainWrapper setFrame:CGRectMake(mMainWrapper.frame.origin.x, (int)(mScreenRect.size.height / 2 - totalContentHeight / 2), mMainWrapper.frame.size.width, totalContentHeight)];
    [mTouchInterceptor setFrame:mMainWrapper.frame];
}

-(NSString *)message
{
    return mMessage;
}

#pragma mark - Private methods
-(void)createBackground
{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, mWindow.frame.size.width, mWindow.frame.size.height)];
    [bgView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];
    [mWindow addSubview:bgView];
    [bgView release];
}

-(void)createMainView
{
    mMainWrapper = [[UIView alloc] initWithFrame:CGRectMake((int)(mScreenRect.size.width / 2 - WIDTH / 2), (int)(mScreenRect.size.height / 2 - DEFAULT_HEIGHT / 2), WIDTH, DEFAULT_HEIGHT)];
    [mMainWrapper setBackgroundColor:[UIColor colorWithWhite:237.0f / 255.0f alpha:1.0f]];
    [mMainWrapper.layer setCornerRadius:6.0f];
    [mMainWrapper.layer setMasksToBounds:TRUE];
    [mWindow addSubview:mMainWrapper];
    [mMainWrapper release];
}

-(void)createTitleView
{
    mTitleView = [[UILabel alloc]initWithFrame:CGRectMake(10.0f, 10.0f, mMainWrapper.frame.size.width - 20.0f, 34.0f)];
    [mTitleView setBackgroundColor:[UIColor clearColor]];
    [mTitleView setTextAlignment:NSTextAlignmentCenter];
    [mTitleView setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]];
    [mTitleView setText:mTitle];
    [mMainWrapper addSubview:mTitleView];
    [mTitleView release];
}

-(void)createMessageView
{
    mMessageView = [[UIButton alloc] init];
    [mMessageView sizeToFit];
    [mMessageView setFrame:CGRectMake(0.0f, 0.0f, mMainWrapper.frame.size.width, mScreenRect.size.height)];
    [mMessageView setBackgroundColor:[UIColor clearColor]];
    [mMessageView.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [mMessageView.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [mMessageView.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    [mMessageView.titleLabel setAdjustsFontSizeToFitWidth:TRUE];
    [mMessageView.titleLabel setMinimumScaleFactor:40.0f];
    [mMessageView setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    [mMessageView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [mMessageView setTitle:mMessage forState:UIControlStateNormal];
    [self updateMessageView];
    [mMainWrapper addSubview:mMessageView];
    [mMessageView release];
}

-(void)updateMessageView
{
    float titleHeight = mTitleView ? mTitleView.frame.origin.y + mTitleView.frame.size.height : 0.0f;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:mMessageView.titleLabel.font, NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName, NULL];
    CGSize textSize = [mMessage boundingRectWithSize:CGSizeMake(mMainWrapper.frame.size.width - 10.0f, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL].size;
    CGSize adjustedTextSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    float messageHeight = adjustedTextSize.height + 18.0f;
    [paragraphStyle release];
    
    float totalContentHeight = titleHeight + messageHeight + 10.0f;
    if (totalContentHeight < DEFAULT_HEIGHT)
    {
        [mMessageView setFrame:CGRectMake(0.0f, titleHeight, mMainWrapper.frame.size.width, mMainWrapper.frame.size.height - titleHeight)];
    }
    else
    {
        [mMainWrapper setFrame:CGRectMake(mMainWrapper.frame.origin.x, (int)(mScreenRect.size.height / 2 - totalContentHeight / 2), mMainWrapper.frame.size.width, totalContentHeight)];
        [mMessageView setFrame:CGRectMake(0.0f, titleHeight, mMainWrapper.frame.size.width, messageHeight + 10.0f)];
    }
}

-(void)createTouchInterceptor
{
    mTouchInterceptor = [[UIView alloc] init];
    [mTouchInterceptor setFrame:CGRectMake(0.0f, 0.0f, mWindow.frame.size.width, mWindow.frame.size.height)];
    [mTouchInterceptor setBackgroundColor:[UIColor clearColor]];
    [mTouchInterceptor setUserInteractionEnabled:TRUE];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [mTouchInterceptor addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    
    [mWindow addSubview:mTouchInterceptor];
    [mTouchInterceptor release];
}

-(void)tap
{
    [self hide];
}

#pragma mark - Orientation
-(void)deviceRotated:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown ||
        orientation == mCurrentOrientation)
        return;
    
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self rotateToOrientation:orientation];
    } completion:NULL];
}

-(void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationPortrait)
    {
        [mMainWrapper setTransform:CGAffineTransformIdentity];
        mCurrentOrientation = orientation;
    }
    else if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
        [mMainWrapper setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        mCurrentOrientation = orientation;
    }
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
        [mMainWrapper setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        mCurrentOrientation = orientation;
    }
    
    [mMainWrapper setFrame:CGRectMake((int)mMainWrapper.frame.origin.x, (int)mMainWrapper.frame.origin.y, (int)mMainWrapper.frame.size.width, (int)mMainWrapper.frame.size.height)];
}

@end