//
//  PaymentResult.m
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 04.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "PaymentResult.h"
#import "Utility.h"
#import "TransactionData.h"

@implementation PaymentResult

#pragma mark - Ctor/Dtor
-(PaymentResult *)init
{
    self = [super initWithNibName:@"PaymentResult" bundle:NULL];
    return self;
}

-(void)dealloc
{
    if (mTransactionData) [mTransactionData release];
    [txtData release];
    [btnOk release];
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
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

#pragma mark - Other methods
-(void)updateControls
{
    [Utility updateTextWithViewController:self];
    
    if (mTransactionData)
    {
        NSMutableString *slipString = [[NSMutableString alloc] init];
        
        Account *account = [[Utility appDelegate] account];
        if (account)
        {
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_bank_name"]];
            [slipString appendString:@": "];
            [self safeAppendString:[account bankName] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_client_name"]];
            [slipString appendString:@": "];
            [self safeAppendString:[account clientName] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_client_legal_name"]];
            [slipString appendString:@": "];
            [self safeAppendString:[account clientLegalName] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_client_phone"]];
            [slipString appendString:@": "];
            [self safeAppendString:[account clientPhone] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_client_web"]];
            [slipString appendString:@": "];
            [self safeAppendString:[account clientWeb] MotherString:slipString];
            [slipString appendString:@"\n"];
        }
        
        TransactionItem *transaction = [mTransactionData Transaction];
        if (transaction)
        {
            Card *card = [transaction card];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_date"]];
            [slipString appendString:@": "];
            [self safeAppendString:[transaction date] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_terminal_name"]];
            [slipString appendString:@": "];
            [self safeAppendString:[transaction terminalName] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_invoice"]];
            [slipString appendString:@": "];
            [self safeAppendString:[transaction invoice] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_approval_code"]];
            [slipString appendString:@": "];
            [self safeAppendString:[transaction approvalCode] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_iin_and_pan"]];
            [slipString appendString:@": "];
            [self safeAppendString:[card iin] MotherString:slipString];
            [slipString appendString:@" "];
            [self safeAppendString:[card panMasked] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            NSDictionary *emvData = [transaction emvData];
            if (emvData && [emvData count])
            {
                [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_emv_data"]];
                [slipString appendString:@":\n"];
                for (NSString *key in [emvData allKeys])
                {
                    NSString *value = [emvData objectForKey:key];
                    [slipString appendString:@"\t"];
                    [self safeAppendString:key MotherString:slipString];
                    [slipString appendString:@" = "];
                    [self safeAppendString:value MotherString:slipString];
                    [slipString appendString:@"\n"];
                }
            }
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_operation"]];
            [slipString appendString:@": "];
            [self safeAppendString:[transaction operation] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            NSString *amountFormat = [NSString stringWithFormat:@"%@ %@", [transaction amountFormatWithoutCurrency], [transaction currencySignSafe]];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_amount"]];
            [slipString appendString:@": "];
            [self safeAppendString:[NSString stringWithFormat:amountFormat, [transaction amount]] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_tax"]];
            [slipString appendString:@": "];
            [self safeAppendString:[NSString stringWithFormat:amountFormat, [transaction feeTotal]] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            [slipString appendString:[Utility localizedStringWithKey:@"payment_result_transaction_state"]];
            [slipString appendString:@": "];
            [self safeAppendString:[transaction stateDisplay] MotherString:slipString];
            [slipString appendString:@"\n"];
            
            if ([transaction inputType] != TransactionInputType_CASH &&
                [transaction inputType] != TransactionInputType_CREDIT &&
                [transaction inputType] != TransactionInputType_PREPAID &&
                [transaction inputType] != TransactionInputType_LINK)
            {
                if ([mTransactionData RequiredSignature])
                    [slipString appendString:[Utility localizedStringWithKey:@"payment_result_client_signature"]];
                else
                    [slipString appendString:[Utility localizedStringWithKey:@"payment_result_client_pin"]];
                [slipString appendString:@"\n"];
            }
            
            [card release];
        }
        
        NSMutableString *dataString = [[NSMutableString alloc] init];
        
        if ([mTransactionData Type] == TransactionDataType_PAYMENT)
        {
            [dataString appendString:@"Type: Payment"];
            [dataString appendFormat:@"\nID: %@", [mTransactionData ID]];
            [dataString appendFormat:@"\n\nSlip:\n%@", slipString];
        }
        else if ([mTransactionData Type] == TransactionDataType_SCHEDULE)
        {
            [dataString appendString:@"Type: Schedule"];
            [dataString appendFormat:@"\nID: %@", [mTransactionData ID]];
        }
        else if ([mTransactionData Type] == TransactionDataType_REVERSE)
        {
            [dataString appendString:@"Type: Reverse"];
            [dataString appendFormat:@"\nID: %@", [mTransactionData ID]];
            [dataString appendFormat:@"\n\nSlip:\n%@", slipString];
        }
        
        [txtData setText:dataString];
        [dataString release];
        
        NSLog(@"Slip:");
        NSLog(@"\n%@", slipString);
    }
    
    [btnOk addTarget:self action:@selector(btnOkClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)safeAppendString:(NSString *)string MotherString:(NSMutableString *)motherString
{
    if (motherString && string)
    {
        @try
        {
            [motherString appendString:string];
        }
        @catch (NSException *exception)
        {
            NSLog(@"%@", exception);
        }
    }
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
