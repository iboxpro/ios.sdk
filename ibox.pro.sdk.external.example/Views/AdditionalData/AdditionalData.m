//
//  AdditionalData.m
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 04.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "AdditionalData.h"
#import "PaymentController.h"
#import "DRToast.h"
#import "PaymentResult.h"

@implementation AdditionalData

#pragma mark - Ctor/Dtor
-(AdditionalData *)init
{
    self = [super initWithNibName:@"AdditionalData" bundle:NULL];
    return self;
}

-(void)dealloc
{
    if (mTransactionData) [mTransactionData release];
    [txtReceiptMail release];
    [txtReceiptPhone release];
    [btnOk release];
    [viewSignature release];
    [viewCover release];
    [ctrReceiptDataTop release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateControls];
}

#pragma mark - Events
-(void)btnOkClick
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator setFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
    [indicator setCenter:self.view.center];
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    [indicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        APIResult *result = NULL;
        if ([mTransactionData Type] == TransactionDataType_Payment)
            result = [[PaymentController instance] adjustWithTrId:mTransactionData.ID Signature:[viewSignature getByteArray] ReceiptEmail:txtReceiptMail.text ReceiptPhone:txtReceiptPhone.text];
        else if ([mTransactionData Type] == TransactionDataType_Schedule)
            result = [[PaymentController instance] adjustWithScheduleId:mTransactionData.ID Signature:[viewSignature getByteArray] ReceiptEmail:txtReceiptMail.text ReceiptPhone:txtReceiptPhone.text];
        else if ([mTransactionData Type] == TransactionDataType_Reverse)
            result = [[PaymentController instance] reverseAdjustWithTrId:mTransactionData.ID Signature:[viewSignature getByteArray] ReceiptEmail:txtReceiptMail.text ReceiptPhone:txtReceiptPhone.text];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            [indicator release];
            
            if (result)
            {
                if ([result valid] && ![result errorCode])
                {
                    PaymentResult *paymentResult = [[PaymentResult alloc] init];
                    [paymentResult setTransactionData:mTransactionData];
                    [self.navigationController pushViewController:paymentResult animated:TRUE];
                    [paymentResult release];
                }
                else
                    [[[DRToast alloc] initWithMessage:[result errorMessage]] show];

                [result release];
            }
        });
    });
}

#pragma mark - UITextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtReceiptMail)
        [txtReceiptPhone becomeFirstResponder];
    else if (textField == txtReceiptPhone)
    {
        [txtReceiptPhone resignFirstResponder];
        
        [ctrReceiptDataTop setConstant:300.0f];
        [UIView animateWithDuration:0.2 animations:^{
            [viewCover setAlpha:0.0f];
            [self.view layoutIfNeeded];
        }];
    }
    return TRUE;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [ctrReceiptDataTop setConstant:100.0f];
    [UIView animateWithDuration:0.2 animations:^{
        [viewCover setAlpha:1.0f];
        [self.view layoutIfNeeded];
    }];
    return TRUE;
}

#pragma mark - Other methods
-(void)updateControls
{
    [txtReceiptMail setDelegate:self];
    [txtReceiptPhone setDelegate:self];
    
    [btnOk addTarget:self action:@selector(btnOkClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Public methods
-(void)setTransactionData:(TransactionData *)data
{
    if (mTransactionData != data)
    {
        if (mTransactionData)
            [mTransactionData release];
        [data retain];
        mTransactionData = data;
    }
}

@end
