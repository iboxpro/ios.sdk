//
//  AdditionalData.m
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 04.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "AdditionalData.h"
#import "Utility.h"
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
    [viewActivity release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateControls];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view addGestureRecognizer:mTapGestureRecognizer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.view removeGestureRecognizer:mTapGestureRecognizer];
    [super viewWillDisappear:animated];
}

#pragma mark - Events
-(void)btnOkClick
{
    [viewActivity setHidden:FALSE];
    [viewActivity startAnimating];
    
    NSData *signatureData = NULL;
    if (![viewSignature isEmpty])
        signatureData = [viewSignature getByteArray];
    
    __block NSString *email = [txtReceiptMail text];
    __block NSString *phone = [txtReceiptPhone text];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        APIResult *result = NULL;
        if ([mTransactionData Type] == TransactionDataType_PAYMENT)
            result = [[PaymentController instance] adjustWithTrId:[mTransactionData ID] Signature:signatureData ReceiptEmail:email ReceiptPhone:phone];
        else if ([mTransactionData Type] == TransactionDataType_SCHEDULE)
            result = [[PaymentController instance] adjustWithScheduleId:[mTransactionData ID] Signature:signatureData ReceiptEmail:email ReceiptPhone:phone];
        else if ([mTransactionData Type] == TransactionDataType_REVERSE)
            result = [[PaymentController instance] reverseAdjustWithTrId:[mTransactionData ID] Signature:signatureData ReceiptEmail:email ReceiptPhone:phone];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [viewActivity setHidden:TRUE];
            [viewActivity stopAnimating];
            
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

-(void)tap
{
    [txtReceiptMail resignFirstResponder];
    [txtReceiptPhone resignFirstResponder];
    
    [ctrReceiptDataTop setConstant:300.0f];
    [UIView animateWithDuration:0.2 animations:^{
        [viewCover setAlpha:0.0f];
        [self.view layoutIfNeeded];
    }];
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

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return TRUE;
}

#pragma mark - Other methods
-(void)updateControls
{
    [Utility updateTextWithViewController:self];
    [viewActivity setHidden:TRUE];
    
    [txtReceiptMail setDelegate:self];
    [txtReceiptPhone setDelegate:self];
    
    [btnOk addTarget:self action:@selector(btnOkClick) forControlEvents:UIControlEventTouchUpInside];
    
    mTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [mTapGestureRecognizer setNumberOfTapsRequired:1];
    [mTapGestureRecognizer setNumberOfTouchesRequired:1];
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
