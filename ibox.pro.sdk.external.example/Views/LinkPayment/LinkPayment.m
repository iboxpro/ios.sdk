//
//  LinkPayment.m
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 26.09.17.
//  Copyright © 2017 DevReactor. All rights reserved.
//

#import "LinkPayment.h"
#import "Utility.h"
#import "PaymentController.h"
#import "DRToast.h"
#import "PaymentResult.h"

@implementation LinkPayment

@synthesize ExternalPayment = mExternalPayment;
@synthesize Data = mData;

#pragma mark - Ctor/Dtor
-(LinkPayment *)init
{
    self = [super initWithNibName:@"LinkPayment" bundle:NULL];
    return self;
}

-(void)dealloc
{
    if (mTransactionData) [mTransactionData release];
    if (mExternalPayment) [mExternalPayment release];
    if (mData) [mData release];
    if (mSwipeGestureRecognizerLeft) [mSwipeGestureRecognizerLeft release];
    if (mSwipeGestureRecognizerRight) [mSwipeGestureRecognizerRight release];
    [imgQr release];
    [lblLink release];
    [btnLink release];
    [btnOk release];
    [btnNewPayment release];
    [ctrLinkWrapperHeight release];
    [lblTitle release];
    [viewDataWrapper release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateControls];
    [self updateData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[PaymentController instance] setRequestTimeOut:240];
    [self checkPaymentStatus];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[PaymentController instance] setRequestTimeOut:30];
}

#pragma mark - Events
-(void)btnOkClick
{
    NSObject *data2Share = NULL;
    if (mExternalPayment)
    {
        if ([mExternalPayment type] == ExternalPaymentType_LINK)
        {
            if (mData && [mData count])
            {
                QRData *qrData = [mData firstObject];
                if (qrData) data2Share = [qrData value];
            }
        }
        else if ([mExternalPayment type] == ExternalPaymentType_QR)
        {
            if (mData && [mData count])
            {
                QRData *qrData = [mData objectAtIndex:mPage];
                if (qrData) data2Share = [Utility createQRWithString:[qrData value]];
            }
        }
    }
    
    if (!data2Share)
        [[[DRToast alloc] initWithMessage:[Utility localizedStringWithKey:@"common_error"]] show];
    else
    {
        NSMutableArray *sharingItems = [[NSMutableArray alloc] init];
        [sharingItems addObject:data2Share];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
        [self presentViewController:activityController animated:TRUE completion:^{
        }];
        [activityController release];
        [sharingItems release];
    }
}

-(void)btnNewPaymentClick
{
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

-(void)btnLinkClick
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:[lblLink text]];
    
    [[[DRToast alloc] initWithMessage:[Utility localizedStringWithKey:@"common_copy_to_clipboard"]] show];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)gr
{
    if (gr.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if (mPage < [mData count] - 1)
            [self setDataWithPage:mPage + 1];
    }
    else if (gr.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (mPage > 0)
            [self setDataWithPage:mPage - 1];
    }
}

#pragma mark - Other methods
-(void)updateControls
{
    [Utility updateTextWithViewController:self];
    
    mSwipeGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [mSwipeGestureRecognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [viewDataWrapper addGestureRecognizer:mSwipeGestureRecognizerLeft];
    
    mSwipeGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [mSwipeGestureRecognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [viewDataWrapper addGestureRecognizer:mSwipeGestureRecognizerRight];
    
    [btnOk addTarget:self action:@selector(btnOkClick) forControlEvents:UIControlEventTouchUpInside];
    [btnNewPayment addTarget:self action:@selector(btnNewPaymentClick) forControlEvents:UIControlEventTouchUpInside];
    [btnLink addTarget:self action:@selector(btnLinkClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)updateData
{
    mPage = 0;
    [self setData:NULL];
    [self setExternalPayment:NULL];

    if (mTransactionData)
    {
        TransactionItem *transaction = [mTransactionData Transaction];
        
        ExternalPayment *externalPayment = [transaction externalPayment];
        if (externalPayment)
        {
            [self setExternalPayment:externalPayment];
            
            NSArray *data = [mExternalPayment data];
            [self setData:data];
            [data release];
            
            if ([mExternalPayment type] == ExternalPaymentType_LINK)
            {
                if (mData && [mData count])
                {
                    QRData *qrData = [mData firstObject];
                    if (qrData)
                    {
                        [lblLink setText:[qrData value]];
                        [ctrLinkWrapperHeight setConstant:50.0f];
                        
                        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[lblLink text]];
                        [attrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, attrString.length)];
                        [lblLink setAttributedText:attrString];
                        [attrString release];
                    }
                }
            }
            else if ([mExternalPayment type] == ExternalPaymentType_QR)
            {
                [ctrLinkWrapperHeight setConstant:0.0f];
            }
        }
        [externalPayment release];
    }
    
    [self setDataWithPage:0];
}

-(void)checkPaymentStatus
{
    if (mTransactionData)
    {
        TransactionItem *transaction = [mTransactionData Transaction];
        if (transaction)
        {
            [[PaymentController instance] paymentStatusWithTrId:[transaction ID] DoneAction:^(APIResult *result) {
                if (result && [result valid] && ![result errorCode])
                {
                    PaymentResult *paymentResult = [[PaymentResult alloc] init];
                    [paymentResult setTransactionData:mTransactionData];
                    [self.navigationController pushViewController:paymentResult animated:TRUE];
                    [paymentResult release];
                }
                else
                {
                    [self checkPaymentStatus];
                }
            }];
        }
    }
}

-(void)setDataWithPage:(int)page
{
    if (mData && [mData count])
    {
        if (page < [mData count])
        {
            QRData *data = [mData objectAtIndex:page];
            if (data)
            {
                [lblTitle setText:[data title]];
                UIImage *dataImage = [Utility createQRWithString:[data value]];
                [imgQr setImage:dataImage];
                mPage = page;
            }
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
