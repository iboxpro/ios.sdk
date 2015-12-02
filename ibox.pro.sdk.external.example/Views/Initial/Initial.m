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
#import "PaymentContext.h"
#import "DRToast.h"

@implementation Initial

#pragma mark - Ctor/Dtor
-(Initial *)init
{
    self = [super initWithNibName:@"Initial" bundle:NULL];
    return self;
}

-(void)dealloc
{
    [txtEmail release];
    [txtPassword release];
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
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtDescription resignFirstResponder];
    [txtPayType resignFirstResponder];
    [txtAmount resignFirstResponder];
    
    mPaymentMenu = [[UIActionSheet alloc] initWithTitle:[Utility localizedStringWithKey:@"initial_payment"] delegate:self cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"] destructiveButtonTitle:NULL otherButtonTitles:NULL];
    [mPaymentMenu addButtonWithTitle:[Utility localizedStringWithKey:@"initial_payment_type_card"]];
    [mPaymentMenu addButtonWithTitle:[Utility localizedStringWithKey:@"initial_payment_type_recurrent"]];
    [mPaymentMenu showInView:self.view];
    [mPaymentMenu release];
}

-(void)btnPayTypeClick
{
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtDescription resignFirstResponder];
    [txtPayType resignFirstResponder];
    [txtAmount resignFirstResponder];
    
    mReaderMenu = [[UIActionSheet alloc] initWithTitle:[Utility localizedStringWithKey:@"initial_select_reader_type"] delegate:self cancelButtonTitle:[Utility localizedStringWithKey:@"common_cancel"]  destructiveButtonTitle:NULL otherButtonTitles:NULL];
    [mReaderMenu addButtonWithTitle:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"]];
    [mReaderMenu addButtonWithTitle:[Utility localizedStringWithKey:@"initial_reader_type_chippin"]];
    [mReaderMenu showInView:self.view];
    [mReaderMenu release];
}

-(void)btnHistoryClick
{
    [[PaymentController instance] setEmail:txtEmail.text Password:txtPassword.text];
    
    History *history = [[History alloc] init];
    [self.navigationController pushViewController:history animated:TRUE];
    [history release];
}

-(void)btnForgetBTReaderClick
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:CONSTS_KEY_BTREADER_ID];
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
        [ctrFieldsHeight setConstant:sgmProduct.selectedSegmentIndex ? 68.0f : 0.0f];
        [ctrDescriptionHeight setConstant:sgmProduct.selectedSegmentIndex ? 0.0f : 30.0f];
    }
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

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex)
        return;
    
    if (actionSheet == mPaymentMenu)
    {
        [[PaymentController instance] setEmail:txtEmail.text Password:txtPassword.text];
        
        if (buttonIndex == 1)
        {
            PaymentContext *paymentContext = [[PaymentContext alloc] init];
            [self updatePaymentContext:paymentContext];
            
            Payment *payment = [[Payment alloc] init];
            [payment setPaymentContext:paymentContext];
            [payment setDelegate:self];
            [self.navigationController pushViewController:payment animated:FALSE];
            [paymentContext release];
            [payment release];
        }
        else if (buttonIndex == 2)
        {
            RecurrentPaymentContext *recurrentPaymentContext = [[RecurrentPaymentContext alloc] init];
            [self updatePaymentContext:recurrentPaymentContext];
            
            Schedule *schedule = [[Schedule alloc] init];
            [schedule setRecurrentPaymentContext:recurrentPaymentContext];
            [self.navigationController pushViewController:schedule animated:FALSE];
            [recurrentPaymentContext release];
            [schedule release];
        }
    }
    else if (actionSheet == mReaderMenu)
    {
        if (buttonIndex == 1)
            [[PaymentController instance] setReaderType:PaymentControllerReaderType_ChipAndSign];
        else if (buttonIndex == 2)
            [[PaymentController instance] setReaderType:PaymentControllerReaderType_ChipAndPIN];
        
        NSString *strReaderType = [Utility localizedStringWithKey:buttonIndex == 1 ? @"initial_reader_type_chipsign" : @"initial_reader_type_chippin"];
        [txtPayType setText:strReaderType];
    }
}

#pragma mark - Other methods
-(void)updateControls
{
    [Utility updateTextWithViewController:self];
    
    [txtEmail setText:@"agent@integration.demo"];
    [txtPassword setText:@"integration123"];
    [txtAmount setText:@"100"];
    [txtDescription setText:@"Test payment"];
    
    [[PaymentController instance] setReaderType:PaymentControllerReaderType_ChipAndSign];
    [txtPayType setText:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"]];
    
    [[PaymentController instance] setRequestTimeOut:30];
    
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
    
    [paymentContext setAmount:[[txtAmount text] doubleValue]];
    
    if (!sgmProduct.selectedSegmentIndex)
        [paymentContext setDescription:[txtDescription text]];
    else
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
}

@end
