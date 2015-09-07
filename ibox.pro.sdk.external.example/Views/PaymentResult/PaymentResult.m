//
//  PaymentResult.m
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 04.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "PaymentResult.h"
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
    if (mTransactionData)
    {
        NSMutableString *dataString = [[NSMutableString alloc] init];
        
        if ([mTransactionData Type] == TransactionDataType_Payment)
        {
            [dataString appendString:@"Type:Payment"];
            [dataString appendFormat:@"\nID:%@", mTransactionData.ID];
            [dataString appendFormat:@"\nInvoice:%@", mTransactionData.Invoice];
            [dataString appendFormat:@"\nAmount:%.2lf", mTransactionData.Amount];
        }
        else if ([mTransactionData Type] == TransactionDataType_Schedule)
        {
            [dataString appendString:@"Type:Schedule"];
            [dataString appendFormat:@"\nID:%@", mTransactionData.ID];
        }
        else if ([mTransactionData Type] == TransactionDataType_Reverse)
        {
            [dataString appendString:@"Type:Reverse"];
            [dataString appendFormat:@"\nID:%@", mTransactionData.ID];
            [dataString appendFormat:@"\nInvoice:%@", mTransactionData.Invoice];
            [dataString appendFormat:@"\nAmount:%.2lf", mTransactionData.Amount];
        }
        
        [txtData setText:dataString];
        [dataString release];
    }
    
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
