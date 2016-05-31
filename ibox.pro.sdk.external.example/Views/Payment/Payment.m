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
    
    if ([mPaymentContext isKindOfClass:[ReversePaymentContext class]] ||
        [mPaymentContext isKindOfClass:[RecurrentPaymentContext class]])
        [lblText setText:[Utility localizedStringWithKey:@"payment_processung"]];
    else
        [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
    
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disable) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enable) name:UIApplicationWillEnterForegroundNotification object:nil];
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
    if (!buttonIndex)
        [self btnCloseClick];
    else
    {
        [[PaymentController instance] scheduleStepsConfirm];
        [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
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
             event == PaymentControllerReaderEventType_CardInsertedCorrect)
        [lblText setText:[Utility localizedStringWithKey:@"payment_processung"]];
    else if (event == PaymentControllerReaderEventType_CardInsertedWrong)
        [[[DRToast alloc] initWithMessage:[Utility localizedStringWithKey:@"payment_card_error"]] show];
    else if (event == PaymentControllerReaderEventType_EjectCardTimeout)
        [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
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
    if (message && ![message isEqualToString:@""])
        [[[DRToast alloc] initWithMessage:message] show];
    
    if (error == PaymentControllerErrorType_Swipe)
        [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
    else if (error == PaymentControllerErrorType_EMV_ZERO_TRAN)
    {
        [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
        [[[DRToast alloc] initWithMessage:[Utility localizedStringWithKey:@"payment_error_zero_transaction"]] show];
    }
    else if (error == PaymentControllerErrorType_Reverse)
    {
        [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
        [[[DRToast alloc] initWithMessage:[Utility localizedStringWithKey:@"payment_error_reverse"]] show];
    }
    else if (error == PaymentControllerErrorType_OnlineProcess ||
             error == PaymentControllerErrorType_EMV_ERROR ||
             error == PaymentControllerErrorType_EMV_TERMINATED ||
             error == PaymentControllerErrorType_EMV_DECLINED ||
             error == PaymentControllerErrorType_EMV_CANCEL ||
             error == PaymentControllerErrorType_EMV_CARD_ERROR ||
             error == PaymentControllerErrorType_EMV_CARD_BLOCKED ||
             error == PaymentControllerErrorType_EMV_DEVICE_ERROR ||
             error == PaymentControllerErrorType_EMV_CARD_NOT_SUPPORTED)
    {
        [lblText setText:[Utility localizedStringWithKey:@"payment_card_eject"]];
    }
}

-(void)PaymentControllerRequestBTDevice:(NSArray *)devices
{
    if (mBTDevicesMenu)
        [mBTDevicesMenu dismissWithClickedButtonIndex:mBTDevicesMenu.cancelButtonIndex animated:FALSE];
    
    if (devices)
    {
        NSString *readerID = [[NSUserDefaults standardUserDefaults] stringForKey:CONSTS_KEY_BTREADER_ID];
        if (readerID && ![readerID isEqualToString:@""])
        {
            for (int i = 0; i < [devices count]; i++)
            {
                CBPeripheral *device = [devices objectAtIndex:i];
                if ([readerID isEqualToString:[[device identifier] UUIDString]])
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
                [[PaymentController instance] setBTDevice:0];
                
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                CBPeripheral *device = [devices objectAtIndex:0];
                [prefs setObject:[[device identifier] UUIDString] forKey:CONSTS_KEY_BTREADER_ID];
                [prefs synchronize];
            }
            else
            {
                mBTDevicesMenu = [[UIActionSheet alloc] initWithTitle:[Utility localizedStringWithKey:@"initial_select_reader_type"] delegate:NULL cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"] destructiveButtonTitle:NULL otherButtonTitles:NULL];
                for (CBPeripheral *device in devices)
                    [mBTDevicesMenu addButtonWithTitle:[device name]];
                [mBTDevicesMenu setTapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                    if (buttonIndex == actionSheet.cancelButtonIndex)
                        [[PaymentController instance] setBTDevice:-1];
                    else
                    {
                        int deviceIndex = (int)buttonIndex - 1;
                        [[PaymentController instance] setBTDevice:deviceIndex];
                        
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        CBPeripheral *device = [devices objectAtIndex:deviceIndex];
                        [prefs setObject:[[device identifier] UUIDString] forKey:CONSTS_KEY_BTREADER_ID];
                        [prefs synchronize];
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
    [lblText setText:[Utility localizedStringWithKey:@"payment_processung"]];
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
