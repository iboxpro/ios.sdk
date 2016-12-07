//
//  Reverse.m
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 01.08.16.
//  Copyright © 2016 DevReactor. All rights reserved.
//

#import "Reverse.h"
#import "Payment.h"
#import "AdditionalData.h"
#import "PaymentController.h"
#import "PaymentResult.h"
#import "Utility.h"
#import "Consts.h"
#import "AppDelegate.h"
#import "DRToast.h"

@implementation Reverse

#pragma mark - Ctor/Dtor
-(Reverse *)init
{
    self = [super initWithNibName:@"Reverse" bundle:NULL];
    return self;
}

-(void)dealloc
{
    if (mTransaction) [mTransaction release];
    [btnClose release];
    [txtAmount release];
    [txtReverse release];
    [btnOk release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [Utility updateTextWithViewController:self];
    
    [txtAmount setText:[NSString stringWithFormat:@"Amount:%.2lf p.", [mTransaction amountEff]]];
    
    if ([mTransaction reverseMode] == TransactionItemReverseMode_CancelPartial ||
        [mTransaction reverseMode] == TransactionItemReverseMode_ReturnPartial)
    {
        [txtReverse setText:[NSString stringWithFormat:@"%.2lf", [mTransaction amountEff]]];
        [txtReverse setUserInteractionEnabled:TRUE];
    }
    else
    {
        [txtReverse setText:[NSString stringWithFormat:@"%.2lf", [mTransaction amount]]];
        [txtReverse setUserInteractionEnabled:FALSE];
    }
    
    [btnOk addTarget:self action:@selector(btnOkClick) forControlEvents:UIControlEventTouchUpInside];
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Events
-(void)btnCloseClick
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void)btnOkClick
{
    ReversePaymentContext *reverseContext = [[ReversePaymentContext alloc] init];
    [reverseContext setTransactionID:[mTransaction ID]];
    if ([[mTransaction currencyID] isEqualToString:CONSTS_CURRENCY_ID_VND])
        [reverseContext setCurrency:CurrencyType_VND];
    else
        [reverseContext setCurrency:CurrencyType_RUB];
    [reverseContext setAmount:[mTransaction amount]];
    if ([[txtReverse text] doubleValue] != [mTransaction amount])
        [reverseContext setAmountReverse:[[txtReverse text] doubleValue]];
    
    Payment *payment = [[Payment alloc] init];
    [payment setPaymentContext:reverseContext];
    [payment setDelegate:self];
    [self.navigationController pushViewController:payment animated:FALSE];
    [reverseContext release];
    [payment release];
}

#pragma mark - PaymentDelegate
-(void)paymentFinished:(TransactionData *)transactionData
{
    if (!transactionData)
        return;
    
    if ([transactionData RequiredSignature])
    {
        AdditionalData *additionalData = [[AdditionalData alloc] init];
        [additionalData setTransactionData:transactionData];
        [self.navigationController pushViewController:additionalData animated:TRUE];
        [additionalData release];
    }
    else
    {
        PaymentResult *paymentResult = [[PaymentResult alloc] init];
        [paymentResult setTransactionData:transactionData];
        [self.navigationController pushViewController:paymentResult animated:TRUE];
        [paymentResult release];
    }
}

#pragma mark - Public methods
-(void)setTransaction:(TransactionItem *)transaction
{
    if (mTransaction != transaction)
    {
        if (mTransaction)
            [mTransaction release];
        [transaction retain];
        mTransaction = transaction;
    }
}

#pragma mark - Other methods

@end
