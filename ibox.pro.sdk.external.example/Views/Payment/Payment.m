//
//  AcceptPayment.m
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 02.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "Payment.h"
#import "Utility.h"
#import "Consts.h"
#import "AppDelegate.h"
#import "PaymentContext.h"
#import "StepItem.h"
#import "BTDevice.h"
#import "UIActionSheet+Blocks.h"
#import "DRToast.h"

@implementation Payment

#pragma mark - Ctor/Dtor
-(Payment *)init
{
    self = [super initWithNibName:@"Payment" bundle:NULL];
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if (mPaymentContext) [mPaymentContext release];
    [lblText release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [Utility updateTextWithViewController:self];
    
    [[PaymentController instance] setDelegate:self];
    [[PaymentController instance] setPaymentContext:mPaymentContext];
    [[PaymentController instance] enable];
    
    if ([mPaymentContext InputType] == TransactionInputType_Cash ||
        [mPaymentContext InputType] == TransactionInputType_Prepaid ||
        [mPaymentContext isKindOfClass:[ReversePaymentContext class]] ||
        [mPaymentContext isKindOfClass:[RecurrentPaymentContext class]])
        [lblText setText:[Utility localizedStringWithKey:@"payment_processing"]];
    else
        [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
    
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disable) name:UIApplicationDidEnterBackgroundNotification object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enable) name:UIApplicationWillEnterForegroundNotification object:NULL];
}

-(void)disable
{
    NSLog(@"Disabled WisePad");
    //[mPaymentController disable];
}

-(void)enable
{
    NSLog(@"Enabled WisePad");
    //[mPaymentController enable];
}

#pragma mark - Events
-(void)btnCloseClick
{
    [self.navigationController popViewControllerAnimated:FALSE];
    [[PaymentController instance] setDelegate:NULL];
    [[PaymentController instance] disable];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == mCardAppsMenu)
    {
        if (buttonIndex == actionSheet.cancelButtonIndex)
            [[PaymentController instance] setCardApplication:-1];
        else
            [[PaymentController instance] setCardApplication:(int)buttonIndex - 1];
        mCardAppsMenu = NULL;
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == mErrorAlert)
    {
        if (!buttonIndex)
            [self btnCloseClick];
        else
        {
            [[PaymentController instance] retry];
            if ([mPaymentContext InputType] == TransactionInputType_Cash ||
                [mPaymentContext InputType] == TransactionInputType_Prepaid)
                [lblText setText:[Utility localizedStringWithKey:@"payment_processing"]];
            else
                [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
        }
        [mErrorAlert release];
        mErrorAlert = NULL;
    }
    else
    {
        if (!buttonIndex)
            [self btnCloseClick];
        else
        {
            [[PaymentController instance] scheduleStepsConfirm];
            [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
        }
    }
}

#pragma mark - PaymentControllerDelegate
-(void)PaymentControllerStartTransaction:(NSString *)transactionID
{
    NSLog(@"TrID:%@", transactionID);
}

-(void)PaymentControllerReaderEvent:(PaymentControllerReaderEventType)event
{
    if (event == PaymentControllerReaderEventType_Initialize)
        [lblText setText:[self readerReady4ActionString]];
    else if (event == PaymentControllerReaderEventType_Connect)
        [lblText setText:[Utility localizedStringWithKey:@"payment_reader_init"]];
    else if (event == PaymentControllerReaderEventType_Disconnect)
        [lblText setText:[Utility localizedStringWithKey:@"payment_reader_connect"]];
    else if (event == PaymentControllerReaderEventType_StartEMV ||
             event == PaymentControllerReaderEventType_SwipeCard ||
             event == PaymentControllerReaderEventType_CardInserted)
        [lblText setText:[Utility localizedStringWithKey:@"payment_processing"]];
}

-(void)PaymentControllerDone:(TransactionData *)transactionData
{
    NSLog(@"%@", [[transactionData Transaction] cardNumber]);
    
    [self.navigationController popViewControllerAnimated:FALSE];
    
    if (mDelegate && [mDelegate respondsToSelector:@selector(paymentFinished:)])
        [mDelegate paymentFinished:transactionData];
    
    [[PaymentController instance] setDelegate:NULL];
    [[PaymentController instance] disable];
}

-(void)PaymentControllerError:(PaymentControllerErrorType)error Message:(NSString *)message
{
    if (error == PaymentControllerErrorType_ONLINE_PROCESS)
    {
        // wait for transaction result
        NSLog(@"%@", message);
    }
    else
    {
        NSString *errorMessage = NULL;
        if (message && ![message isEqualToString:@""])
            errorMessage = message;
        else
        {
            if (error == PaymentControllerErrorType_EMV_ZERO_TRAN)
                errorMessage = [Utility localizedStringWithKey:@"payment_error_zero_transaction"];
            else if (error == PaymentControllerErrorType_REVERSE ||
                     error == PaymentControllerErrorType_REVERSE_CASH ||
                     error == PaymentControllerErrorType_REVERSE_PREPAID)
                errorMessage = [Utility localizedStringWithKey:@"payment_error_reverse"];
            else
                errorMessage = [Utility localizedStringWithKey:@"common_error"];
        }
        
        if (mErrorAlert)
        {
            [mErrorAlert dismissWithClickedButtonIndex:0 animated:FALSE];
            [mErrorAlert release];
            mErrorAlert = NULL;
        }
        
        mErrorAlert = [[UIAlertView alloc] initWithTitle:NULL message:errorMessage delegate:self cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"] otherButtonTitles:[Utility localizedStringWithKey:@"common_retry"], NULL];
        [mErrorAlert show];
    }
}

-(void)PaymentControllerRequestBTDevice:(NSArray *)devices
{
    if (mBTDevicesMenu)
        [mBTDevicesMenu dismissWithClickedButtonIndex:[mBTDevicesMenu cancelButtonIndex] animated:FALSE];
    
    if (devices)
    {
        NSString *readerID = [[NSUserDefaults standardUserDefaults] stringForKey:CONSTS_KEY_BTREADER_ID];
        if (readerID && ![readerID isEqualToString:@""])
        {
            for (int i = 0; i < [devices count]; i++)
            {
                BTDevice *device = [devices objectAtIndex:i];
                if ([readerID isEqualToString:[device ID]])
                {
                    [[PaymentController instance] setBTDevice:i];
                    break;
                }
            }
        }
        else
        {
            if ([devices count] == 1)
            {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                BTDevice *device = [devices firstObject];
                [prefs setObject:[device ID] forKey:CONSTS_KEY_BTREADER_ID];
                [prefs synchronize];
                
                [[PaymentController instance] setBTDevice:0];
            }
            else
            {
                mBTDevicesMenu = [[UIActionSheet alloc] initWithTitle:[Utility localizedStringWithKey:@"initial_select_reader_type"] delegate:NULL cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"] destructiveButtonTitle:NULL otherButtonTitles:NULL];
                for (BTDevice *device in devices)
                    [mBTDevicesMenu addButtonWithTitle:[device name]];
                [mBTDevicesMenu setTapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                    if (buttonIndex == actionSheet.cancelButtonIndex)
                        [[PaymentController instance] setBTDevice:-1];
                    else
                    {
                        int deviceIndex = (int)buttonIndex - 1;
                        
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        BTDevice *device = [devices objectAtIndex:deviceIndex];
                        [prefs setObject:[device ID] forKey:CONSTS_KEY_BTREADER_ID];
                        [prefs synchronize];
                        
                        [[PaymentController instance] setBTDevice:deviceIndex];
                    }
                    mBTDevicesMenu = NULL;
                }];
                [mBTDevicesMenu showInView:self.view];
                [mBTDevicesMenu release];
            }
        }
    }
}

-(void)PaymentControllerRequestCardApplication:(NSArray *)applications
{
    mCardAppsMenu = [[UIActionSheet alloc] initWithTitle:[Utility localizedStringWithKey:@"payment_choose_card_app"] delegate:self cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"] destructiveButtonTitle:NULL otherButtonTitles:NULL];
    for (NSString *application in applications)
        [mCardAppsMenu addButtonWithTitle:application];
    [mCardAppsMenu showInView:self.view];
    [mCardAppsMenu release];
}

-(void)PaymentControllerScheduleStepsStart
{
    [lblText setText:[Utility localizedStringWithKey:@"payment_processing"]];
}

-(void)PaymentControllerScheduleStepsCreated:(NSArray *)scheduleSteps
{
    NSMutableString *message = NULL;
    if (scheduleSteps && [scheduleSteps count])
    {
        message = [[NSMutableString alloc] init];
        for (StepItem *step in scheduleSteps)
        {
            [message appendFormat:@"%@ - %.2lf", [step date], [step amount]];
            if (step != [scheduleSteps lastObject]) [message appendString:@"\n"];
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Utility localizedStringWithKey:@"payment_steps"] message:message delegate:self cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"] otherButtonTitles:[Utility localizedStringWithKey:@"common_next"], NULL];
    [alert show];
}

#pragma mark - Public methods
-(void)setPaymentContext:(PaymentContext *)paymentContext
{
    if (mPaymentContext != paymentContext)
    {
        if (mPaymentContext)
            [mPaymentContext release];
        [paymentContext retain];
        mPaymentContext = paymentContext;
    }
}

-(void)setDelegate:(id<PaymentDelegate>)delegate
{
    mDelegate = delegate;
}

#pragma mark - Other methods
-(NSString *)readerReady4ActionString
{
    if ([mPaymentContext isKindOfClass:[RecurrentPaymentContext class]] ||
        [mPaymentContext isKindOfClass:[ReversePaymentContext class]])
        return [Utility localizedStringWithKey:@"payment_swipe"];
    else
        return [Utility localizedStringWithKey:@"payment_swipe_insert"];
}

@end
