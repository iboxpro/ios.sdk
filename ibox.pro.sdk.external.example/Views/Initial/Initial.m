//
//  Login.m
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 02.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "Initial.h"
#import "Utility.h"
#import "Consts.h"
#import "PaymentController.h"
#import "Payment.h"
#import "Schedule.h"
#import "AdditionalData.h"
#import "PaymentResult.h"
#import "History.h"
#import "ReaderScanner.h"
#import "PaymentContext.h"
#import "LinkPayment.h"
#import "DRToast.h"

@implementation Initial

#pragma mark - Ctor/Dtor
-(Initial *)init
{
    self = [super initWithNibName:@"Initial" bundle:NULL];
    if (self)
    {
        mEmail = NULL;
        mPassword = NULL;
    }
    return self;
}

-(void)dealloc
{
    if (mEmail) [mEmail release];
    if (mPassword) [mPassword release];
    [txtAmount release];
    [txtDescription release];
    [txtPayType release];
    [btnPayType release];
    [btnOk release];
    [btnForgetBTReader release];
    [ctrDescriptionHeight release];
    [ctrFieldsHeight release];
    [sgmProduct release];
    [txtFieldOne release];
    [txtFieldTwo release];
    [btnHistory release];
    [btnPing release];
    [viewActivity release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateControls];
    
    mLoginAlert = [[UIAlertView alloc] initWithTitle:[Utility localizedStringWithKey:@"initial_authorization"] message:NULL delegate:self cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"] otherButtonTitles:[Utility localizedStringWithKey:@"common_ok"], NULL];
    [mLoginAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [mLoginAlert show];
    
    [[mLoginAlert textFieldAtIndex:0] setText:@""];
    [[mLoginAlert textFieldAtIndex:1] setText:@""];
}

#pragma mark - Events
-(void)btnOkClick
{
    Account *account = [[Utility appDelegate] account];
    if (account)
    {
        [txtDescription resignFirstResponder];
        [txtPayType resignFirstResponder];
        [txtAmount resignFirstResponder];
        
        mPaymentMenu = [[UIActionSheet alloc] initWithTitle:[Utility localizedStringWithKey:@"initial_payment"] delegate:self cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"] destructiveButtonTitle:NULL otherButtonTitles:NULL];
        
        NSArray *paymentOptions = [account paymentOptions];
        for (PaymentOption *paymentOption in paymentOptions)
        {
            NSMutableString *cellTitle = [[NSMutableString alloc] init];
            if ([paymentOption inputType] == TransactionInputType_SWIPE ||
                [paymentOption inputType] == TransactionInputType_EMV ||
                [paymentOption inputType] == TransactionInputType_NFC)
            {
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_card"]];
            }
            else if ([paymentOption inputType] == TransactionInputType_CASH)
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_cash"]];
            else if ([paymentOption inputType] == TransactionInputType_PREPAID)
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_prepaid"]];
            else if ([paymentOption inputType] == TransactionInputType_CREDIT)
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_credit"]];
            else if ([paymentOption inputType] == TransactionInputType_LINK)
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_link"]];
            
            if ([paymentOption acquirer])
                [cellTitle appendFormat:@" - %@", [[paymentOption acquirer] name]];
            
            [mPaymentMenu addButtonWithTitle:cellTitle];
            [cellTitle release];
        }
        [paymentOptions release];
        
        [mPaymentMenu addButtonWithTitle:[Utility localizedStringWithKey:@"initial_payment_type_recurrent"]];
        [mPaymentMenu showInView:[self view]];
        [mPaymentMenu release];
    }
    else
        [mLoginAlert show];
}

-(void)btnPayTypeClick
{
    [txtDescription resignFirstResponder];
    [txtPayType resignFirstResponder];
    [txtAmount resignFirstResponder];
    
    mReaderMenu = [[UIActionSheet alloc] initWithTitle:[Utility localizedStringWithKey:@"initial_select_reader_type"] delegate:self cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"]  destructiveButtonTitle:NULL otherButtonTitles:NULL];
    [mReaderMenu addButtonWithTitle:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"]];
    [mReaderMenu addButtonWithTitle:[Utility localizedStringWithKey:@"initial_reader_type_chippin"]];
    [mReaderMenu addButtonWithTitle:[Utility localizedStringWithKey:@"initial_reader_type_qposmini"]];
    [mReaderMenu showInView:self.view];
    [mReaderMenu release];
}

-(void)btnHistoryClick
{
    if ((mEmail && ![mEmail isEqualToString:@""]) &&
        (mPassword && ![mPassword isEqualToString:@""]))
    {
        History *history = [[History alloc] init];
        [self.navigationController pushViewController:history animated:TRUE];
        [history release];
    }
    else
        [mLoginAlert show];
}

-(void)btnForgetBTReaderClick
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:CONSTS_KEY_BT_READER];
    [prefs synchronize];
}

-(void)btnPingClick
{
    [[PaymentController instance] pingReaderWithDoneAction:^(NSDictionary *readerData) {
        int charge = [[readerData objectForKey:CONSTS_KEY_READER_CHARGE] intValue];
        BOOL connected = [[readerData objectForKey:CONSTS_KEY_READER_CONNECTED] boolValue];
        [[[DRToast alloc] initWithMessage:connected ? [NSString stringWithFormat:[Utility localizedStringWithKey:@"initial_ping_connected"], charge] : [Utility localizedStringWithKey:@"initial_ping_not_connected"]] show];
        NSLog(@"%@", readerData);
    }];
}

-(void)segmentedControlAction:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl == sgmProduct)
    {
        if (![sgmProduct selectedSegmentIndex])
        {
            [ctrFieldsHeight setConstant:0.0f];
            [ctrDescriptionHeight setConstant:30.0f];
        }
        else if ([sgmProduct selectedSegmentIndex] == 1)
        {
            [ctrFieldsHeight setConstant:68.0f];
            [ctrDescriptionHeight setConstant:0.0f];
        }
        else if ([sgmProduct selectedSegmentIndex] == 2)
        {
            [ctrFieldsHeight setConstant:0.0f];
            [ctrDescriptionHeight setConstant:30.0f];
        }
    }
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int index = (int)buttonIndex;
    if (index)
    {
        if (alertView == mLoginAlert)
        {
            if (![viewActivity isHidden])
                return;
            
            [viewActivity setHidden:FALSE];
            [viewActivity startAnimating];
            
            NSString *email = [[mLoginAlert textFieldAtIndex:0] text];
            NSString *password = [[mLoginAlert textFieldAtIndex:1] text];
            
            [self setEmail:email];
            [self setPassword:password];
            
            [[PaymentController instance] setEmail:email Password:password];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                APIAuthenticationResult *result = [[PaymentController instance] authentication];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [viewActivity setHidden:TRUE];
                    [viewActivity stopAnimating];
                    
                    if (result)
                    {
                        if ([result valid] && ![result errorCode])
                        {
                            Account *account = [result account];
                            [[Utility appDelegate] setAccount:account];
                            [account release];
                        }
                        else
                        {
                            [[[DRToast alloc] initWithMessage:[result errorMessage]] show];
                            
                            [self setEmail:NULL];
                            [self setPassword:NULL];
                        }
                        
                        [result release];
                    }
                });
            });
        }
    }
}

#pragma mark - ReaderScannerDelegate
-(void)ReaderScannerDelegateSelectedReader:(BTDevice *)reader ReaderType:(PaymentControllerReaderType)readerType ReaderTypeLocalized:(NSString *)readerTypeLocalized
{
    if (reader)
    {
        [[PaymentController instance] setReaderType:readerType];
        [txtPayType setText:readerTypeLocalized];
    }
}

#pragma mark - PaymentDelegate
-(void)paymentFinished:(TransactionData *)transactionData
{
    if (!transactionData)
        return;
    
    if ([[transactionData Transaction] inputType] == TransactionInputType_LINK)
    {
        LinkPayment *linkPayment = [[LinkPayment alloc] init];
        [linkPayment setTransactionData:transactionData];
        [self.navigationController pushViewController:linkPayment animated:TRUE];
        [linkPayment release];
    }
    else
    {
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
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex)
        return;
    
    if (actionSheet == mPaymentMenu)
    {
        mPaymentMenu = NULL;
        if ((mEmail && ![mEmail isEqualToString:@""]) &&
            (mPassword && ![mPassword isEqualToString:@""]))
        {
            NSArray *paymentOptions = [[[Utility appDelegate] account] paymentOptions];
            int index = (int)buttonIndex - 1;
            if (index < [paymentOptions count])
            {
                PaymentOption *paymentOption = [paymentOptions objectAtIndex:index];
             
                PaymentContext *paymentContext = [[PaymentContext alloc] init];
                [self updatePaymentContext:paymentContext];
                
                if ([paymentOption inputType] == TransactionInputType_SWIPE ||
                    [paymentOption inputType] == TransactionInputType_EMV ||
                    [paymentOption inputType] == TransactionInputType_NFC)
                {
                    [paymentContext setInputType:TransactionInputType_SWIPE];
                }
                else if ([paymentOption inputType] == TransactionInputType_CASH)
                {
                    double amountCashGot = (int)([paymentContext Amount] * 2.0);
                    [paymentContext setAmountCash:amountCashGot];
                    [paymentContext setInputType:TransactionInputType_CASH];
                }
                else
                {
                    [paymentContext setInputType:[paymentOption inputType]];
                }
                
                if ([paymentOption acquirer])
                    [paymentContext setAcquirer:[[paymentOption acquirer] code]];
                
                Payment *payment = [[Payment alloc] init];
                [payment setPaymentContext:paymentContext];
                [payment setDelegate:self];
                [self.navigationController pushViewController:payment animated:FALSE];
                [paymentContext release];
                [payment release];
            }
            else
            {
                RecurrentPaymentContext *recurrentPaymentContext = [[RecurrentPaymentContext alloc] init];
                [self updatePaymentContext:recurrentPaymentContext];
                
                Schedule *schedule = [[Schedule alloc] init];
                [schedule setRecurrentPaymentContext:recurrentPaymentContext];
                [self.navigationController pushViewController:schedule animated:FALSE];
                [recurrentPaymentContext release];
                [schedule release];
            }
            [paymentOptions release];
        }
        else
            [mLoginAlert show];
    }
    else if (actionSheet == mReaderMenu)
    {
        mReaderMenu = NULL;
        if (buttonIndex == 1)
        {
            [[PaymentController instance] setReaderType:PaymentControllerReaderType_C15];
            [txtPayType setText:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"]];
        }
        else if (buttonIndex == 2)
        {
            ReaderScanner *readerScanner = [[ReaderScanner alloc] init];
            [readerScanner setReaderType:PaymentControllerReaderType_P15];
            [readerScanner setReaderTypeLocalized:[Utility localizedStringWithKey:@"initial_reader_type_chippin"]];
            [readerScanner setDelegate:self];
            [self.navigationController pushViewController:readerScanner animated:TRUE];
            [readerScanner release];
        }
        else if (buttonIndex == 3)
        {
            ReaderScanner *readerScanner = [[ReaderScanner alloc] init];
            [readerScanner setReaderType:PaymentControllerReaderType_P17];
            [readerScanner setReaderTypeLocalized:[Utility localizedStringWithKey:@"initial_reader_type_qposmini"]];
            [readerScanner setDelegate:self];
            [self.navigationController pushViewController:readerScanner animated:TRUE];
            [readerScanner release];
        }
    }
}

#pragma mark - Other methods
-(void)updateControls
{
    [Utility updateTextWithViewController:self];
    [viewActivity setHidden:TRUE];
    [txtAmount setText:@"100"];
    [txtDescription setText:@"Test payment"];
    
    [[PaymentController instance] setReaderType:PaymentControllerReaderType_C15];
    [[PaymentController instance] setSingleStepAuthentication:FALSE];
    
    [txtPayType setText:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"]];
    
    [[PaymentController instance] setRequestTimeOut:30];
    [[PaymentController instance] setClientProductCode:@""];
    
    [sgmProduct addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    [btnOk addTarget:self action:@selector(btnOkClick) forControlEvents:UIControlEventTouchUpInside];
    [btnPayType addTarget:self action:@selector(btnPayTypeClick) forControlEvents:UIControlEventTouchUpInside];
    [btnForgetBTReader addTarget:self action:@selector(btnForgetBTReaderClick) forControlEvents:UIControlEventTouchUpInside];
    [btnHistory addTarget:self action:@selector(btnHistoryClick) forControlEvents:UIControlEventTouchUpInside];
    [btnPing addTarget:self action:@selector(btnPingClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)updatePaymentContext:(PaymentContext *)paymentContext
{
    if (!paymentContext)
        return;
    
    [paymentContext setCurrency:CurrencyType_RUB];
    [paymentContext setAmount:[[txtAmount text] doubleValue]];
    
    if (![sgmProduct selectedSegmentIndex])
        [paymentContext setDescription:[txtDescription text]];
    else if ([sgmProduct selectedSegmentIndex] == 1)
    {
        [paymentContext setProductCode:@"PRODUCT_TEST"];
        
        NSMutableArray *productData = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *fildOneData = [[NSMutableDictionary alloc] init];
        [fildOneData setObject:[txtFieldOne text] forKey:@"FIELD_1"];   // You can also add UIImage object
        [productData addObject:fildOneData];
        [fildOneData release];
        
        NSMutableDictionary *fildTwoData = [[NSMutableDictionary alloc] init];
        [fildTwoData setObject:[txtFieldTwo text] forKey:@"FIELD_2"];   // You can also add UIImage object
        [productData addObject:fildTwoData];
        [fildTwoData release];
        
        [paymentContext setProductData:productData];
        [productData release];
    }
    else if ([sgmProduct selectedSegmentIndex] == 2)
    {
        [paymentContext setDescription:[txtDescription text]];
        
        NSMutableArray *purchases = [[NSMutableArray alloc] init];
        
        Purchase *purchase1 = [[Purchase alloc] init];
        [purchase1 setTitle:@"Позиция 1"];
        [purchase1 setTaxes:@[@"VAT1800"]];
        [purchase1 setPrice:120.0];
        [purchase1 setQuantity:2];
        
        Purchase *purchase2 = [[Purchase alloc] init];
        [purchase2 setTitle:@"Позиция 2"];
        [purchase2 setTaxes:@[]];
        [purchase2 setPrice:100.0];
        [purchase2 setQuantity:1];
        
        [purchases addObject:purchase1];
        [purchase1 release];
        
        [purchases addObject:purchase2];
        [purchase2 release];
        
        [paymentContext setPurchases:purchases];
        [purchases release];
    }
}

-(void)setEmail:(NSString *)email
{
    if (mEmail != email)
    {
        if (mEmail)
            [mEmail release];
        [email retain];
        mEmail = email;
    }
}

-(void)setPassword:(NSString *)password
{
    if (mPassword != password)
    {
        if (mPassword)
            [mPassword release];
        [password retain];
        mPassword = password;
    }
}

@end
