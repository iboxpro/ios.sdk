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
    [ctrScrollBottom release];
    [txtAuxData release];
    [viewAuxDataContainer release];
    [ctrDividerTop release];
    [txtEmail release];
    [txtPhone release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [Utility updateTextWithViewController:self];
    [self updateControls];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self enableKeyboardObservers];
    [self.view addGestureRecognizer:mTapGestureRecognizer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.view removeGestureRecognizer:mTapGestureRecognizer];
    [self disableKeyboardObservers];
    [super viewWillDisappear:animated];
}

#pragma mark - Events
-(void)btnCloseClick
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void)btnOkClick
{
    [self tap];
    
    ReversePaymentContext *reverseContext = [[ReversePaymentContext alloc] init];
    [reverseContext setTransaction:mTransaction];
    if ([[mTransaction currencyID] isEqualToString:CONSTS_CURRENCY_ID_VND])
        [reverseContext setCurrency:CurrencyType_VND];
    else
        [reverseContext setCurrency:CurrencyType_RUB];
    [reverseContext setAmount:[mTransaction amount]];
    
    if ([[txtReverse text] doubleValue] != [mTransaction amount])
        [reverseContext setAmountReverse:[[txtReverse text] doubleValue]];
    if (![Utility stringIsNullOrEmty:[txtEmail text]])
        [reverseContext setReceiptMail:[txtEmail text]];
    if (![Utility stringIsNullOrEmty:[txtPhone text]])
        [reverseContext setReceiptPhone:[txtPhone text]];
    
    NSMutableString *errorMessage = [[NSMutableString alloc] init];
    
    if ([mTransaction withAuxData])
    {
        NSString *auxData = [txtAuxData text];
        if ([Utility stringIsNullOrEmty:auxData])
            [errorMessage appendString:[Utility localizedStringWithKey:@"reverse_purchases_error"]];
        else
            [reverseContext setAuxData:auxData];
    }
    
    if (![errorMessage isEqualToString:@""])
        [[[DRToast alloc] initWithMessage:errorMessage] show];
    else
    {
        Payment *payment = [[Payment alloc] init];
        [payment setPaymentContext:reverseContext];
        [payment setDelegate:self];
        [self.navigationController pushViewController:payment animated:FALSE];
        [payment release];
    }
    
    [reverseContext release];
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    float bottomMargin = [Utility keyboardHeightWithNotification:notification];
    [ctrScrollBottom setConstant:bottomMargin];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:NULL];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [ctrScrollBottom setConstant:0.0f];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:NULL];
}

-(void)tap
{
    [txtAmount resignFirstResponder];
    [txtReverse resignFirstResponder];
    [txtAuxData resignFirstResponder];
    [txtEmail resignFirstResponder];
    [txtPhone resignFirstResponder];
}

#pragma mark - PaymentDelegate
-(void)paymentFinished:(TransactionData *)transactionData readerInfo:(NSDictionary *)info
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
-(void)updateControls
{
    [txtAmount setText:[NSString stringWithFormat:@"Amount:%.2lf p.", [mTransaction amountEff]]];
    [viewAuxDataContainer setHidden:TRUE];
    [ctrDividerTop setConstant:-119.0f];
    
    if ([mTransaction withAuxData])
    {
        [viewAuxDataContainer setHidden:FALSE];
        [ctrDividerTop setConstant:0.0f];
        
        NSError *error = NULL;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[mTransaction auxData] options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error && ![Utility stringIsNullOrEmty:jsonString])
            [txtAuxData setText:jsonString];
    }
    
    if ([mTransaction reverseMode] == TransactionReverseMode_CANCEL_PARTIAL ||
        [mTransaction reverseMode] == TransactionReverseMode_RETURN_PARTIAL ||
        [mTransaction reverseMode] == TransactionReverseMode_CANCEL_CNP_PARTIAL)
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
    
    mTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [mTapGestureRecognizer setNumberOfTapsRequired:1];
    [mTapGestureRecognizer setNumberOfTouchesRequired:1];
}

-(void)enableKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:NULL];
}

-(void)disableKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
