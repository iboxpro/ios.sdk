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
#import "DRToast.h"

@implementation Payment

#pragma mark - Ctor/Dtor
-(Payment *)init
{
    self = [super initWithNibName:@"Payment" bundle:NULL];
    if (self)
    {
        mPaymentContext = NULL;
        mTransactionData = NULL;
        mErrorAlert = NULL;
        mFiscalCounter = 0;
    }
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
    
    if ([mPaymentContext InputType] == TransactionInputType_CASH ||
        [mPaymentContext InputType] == TransactionInputType_PREPAID ||
        [mPaymentContext InputType] == TransactionInputType_CREDIT ||
        [mPaymentContext InputType] == TransactionInputType_OUTER_CARD ||
        [mPaymentContext InputType] == TransactionInputType_LINK ||
        [mPaymentContext isKindOfClass:[ReversePaymentContext class]] ||
        [mPaymentContext isKindOfClass:[RecurrentPaymentContext class]])
        [lblText setText:[Utility localizedStringWithKey:@"payment_processing"]];
    else
        [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
    
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:NULL];
}

-(void)enterBackground
{
    NSLog(@"Enter background");
    //[mPaymentController disable];
}

-(void)enterForeground
{
    NSLog(@"Enter foreground");
    //[mPaymentController enable];
}

#pragma mark - Events
-(void)btnCloseClick
{
    [self.navigationController popViewControllerAnimated:FALSE];
    [[PaymentController instance] setDelegate:NULL];
    [[PaymentController instance] disable];
}

#pragma mark - PaymentControllerDelegate
-(void)PaymentControllerStartTransaction:(NSString *)transactionID
{
    NSLog(@"TrID:%@", transactionID);
}

-(void)PaymentControllerReaderEvent:(PaymentControllerReaderEventType)event
{
    if (event == PaymentControllerReaderEventType_INITIALIZED)
    {
        mReaderInfo = [[PaymentController instance] readerInfo];
        if (mReaderInfo) NSLog(@"ReaderInfo:%@", mReaderInfo);
        [lblText setText:[self readerReady4ActionString]];
    }
    else if (event == PaymentControllerReaderEventType_CONNECTED)
        [lblText setText:[Utility localizedStringWithKey:@"payment_reader_init"]];
    else if (event == PaymentControllerReaderEventType_DISCONNECTED)
        [lblText setText:[Utility localizedStringWithKey:@"payment_reader_connect"]];
    else if (event == PaymentControllerReaderEventType_EMV_STARTED ||
             event == PaymentControllerReaderEventType_CARD_SWIPED ||
             event == PaymentControllerReaderEventType_CARD_INSERTED)
        [lblText setText:[Utility localizedStringWithKey:@"payment_processing"]];
}

-(void)PaymentControllerDone:(TransactionData *)transactionData
{
    mTransactionData = transactionData;
    mFiscalCounter = 0;
    [self checkFiscalInfo];
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
            if (error == PaymentControllerErrorType_ZERO_AMOUNT)
                errorMessage = [Utility localizedStringWithKey:@"payment_error_emv_zero_tran"];
            else if (error == PaymentControllerErrorType_EMV_CANCEL)
                errorMessage = [Utility localizedStringWithKey:@"payment_error_emv_cancel"];
            else if (error == PaymentControllerErrorType_READER_DISCONNECTED)
                errorMessage = [Utility localizedStringWithKey:@"payment_error_reader_disconnected"];
            else if (error == PaymentControllerErrorType_REVERSE ||
                     error == PaymentControllerErrorType_REVERSE_CASH ||
                     error == PaymentControllerErrorType_REVERSE_PREPAID ||
                     error == PaymentControllerErrorType_REVERSE_AUTO ||
                     error == PaymentControllerErrorType_REVERSE_CNP)
                errorMessage = [Utility localizedStringWithKey:@"payment_error_reverse"];
            else if (error == PaymentControllerErrorType_READER_TIMEOUT)
                errorMessage = [Utility localizedStringWithKey:@"payment_error_reader_timeout"];
            else
                errorMessage = [Utility localizedStringWithKey:@"common_error"];
        }
        
        NSString *otherButtonTitle = NULL;
        if (error != PaymentControllerErrorType_READER_DISCONNECTED)
            otherButtonTitle = [Utility localizedStringWithKey:@"common_retry"];
        
        if (mErrorAlert)
        {
            [mErrorAlert dismissViewControllerAnimated:TRUE completion:NULL];
            mErrorAlert = NULL;
        }
        
        mErrorAlert = [UIAlertController alertControllerWithTitle:NULL message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        [mErrorAlert addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self btnCloseClick];
            mErrorAlert = NULL;
        }]];
        [mErrorAlert addAction:[UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[PaymentController instance] retry];
            if ([mPaymentContext InputType] == TransactionInputType_CASH ||
                [mPaymentContext InputType] == TransactionInputType_PREPAID ||
                [mPaymentContext InputType] == TransactionInputType_CREDIT ||
                [mPaymentContext InputType] == TransactionInputType_OUTER_CARD ||
                [mPaymentContext InputType] == TransactionInputType_LINK)
                [lblText setText:[Utility localizedStringWithKey:@"payment_processing"]];
            else
                [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
            mErrorAlert = NULL;
        }]];
        [self presentViewController:mErrorAlert animated:TRUE completion:NULL];
    }
}

-(void)PaymentControllerRequestBTDevice:(NSArray *)devices
{
    [[PaymentController instance] setBTDevice:[devices firstObject]];
}

-(void)PaymentControllerRequestCardApplication:(NSArray *)applications
{
    UIAlertController *cardAppsMenu = [UIAlertController  alertControllerWithTitle:[Utility localizedStringWithKey:@"payment_choose_card_app"] message:NULL preferredStyle:UIAlertControllerStyleActionSheet];
    [cardAppsMenu addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[PaymentController instance] setCardApplication:-1];
    }]];
    for (NSString *application in applications)
    {
        [cardAppsMenu addAction:[UIAlertAction actionWithTitle:application style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            int index = (int)[[cardAppsMenu actions] indexOfObject:action];
            [[PaymentController instance] setCardApplication:(int)index - 1];
        }]];
    }
    [self presentViewController:cardAppsMenu animated:TRUE completion:NULL];
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
    
    UIAlertController *stepsAlert = [UIAlertController  alertControllerWithTitle:[Utility localizedStringWithKey:@"payment_steps"] message:message preferredStyle:UIAlertControllerStyleAlert];
    [stepsAlert addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self btnCloseClick];
    }]];
    [stepsAlert addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_next"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[PaymentController instance] scheduleStepsConfirm];
        [lblText setText:[[PaymentController instance] isReaderConnected] ? [self readerReady4ActionString] : [Utility localizedStringWithKey:@"payment_reader_connect"]];
    }]];
    [self presentViewController:stepsAlert animated:TRUE completion:NULL];
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
    return [Utility localizedStringWithKey:@"payment_swipe_insert_tap"];
}

-(void)checkFiscalInfo
{
    Account *account = [[Utility appDelegate] account];
    if ([mPaymentContext InputType] == TransactionInputType_LINK)
        [self paymentDone];
    else
    {
        if ([account usesServerFiscalization])
            [self processFiscalInfo];
        else
            [self paymentDone];
    }
}

-(void)processFiscalInfo
{
    if (mFiscalCounter > 2)
        [self paymentDone];
    else
    {
        mFiscalCounter++;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            APIFiscalInfoResult *result = [[PaymentController instance] fiscalInfoWithTrId:[[mTransactionData Transaction] ID]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (![result valid] || [result errorCode])
                    [self processFiscalInfo];
                else
                {
                    TransactionItem *transaction = [result transaction];
                    FiscalInfo *fiscalInfo = [transaction fiscalInfo];
                    if (!fiscalInfo)
                        [self processFiscalInfo];
                    else
                    {
                        if ([fiscalInfo status] != FiscalInfoStatus_SUCCESS)
                            [self processFiscalInfo];
                        else
                        {
                            [mTransactionData setTransaction:[result transaction]];
                            [self paymentDone];
                        }
                        [fiscalInfo release];
                    }
                }
            });
        });
    }
}

-(void)paymentDone
{
    Card *card = [[mTransactionData Transaction] card];
    if (![Utility stringIsNullOrEmty:[card panMasked]] &&
        ![[card panMasked] isEqual:[NSNull null]])
        NSLog(@"%@", [card panMasked]);
    [card release];
    
    [self.navigationController popViewControllerAnimated:FALSE];
    
    if (mDelegate && [mDelegate respondsToSelector:@selector(paymentFinished:readerInfo:)])
        [mDelegate paymentFinished:mTransactionData readerInfo:mReaderInfo];
    
    [[PaymentController instance] setDelegate:NULL];
    [[PaymentController instance] disable];
}

@end
