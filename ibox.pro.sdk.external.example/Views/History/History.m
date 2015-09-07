//
//  History.m
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 7/10/15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "History.h"
#import "HistoryCell.h"
#import "PaymentController.h"
#import "PaymentResult.h"
#import "AdditionalData.h"
#import "TransactionItem.h"
#import "TransactionProduct.h"
#import "DRToast.h"

@implementation History

#pragma mark - Ctor/Dtor
-(History *)init
{
    self = [super initWithNibName:@"History" bundle:NULL];
    if (self)
    {
        mPage = 1;
        mData = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc
{
    if (mTransactionID) [mTransactionID release];
    if (mData) [mData release];
    [btnClose release];
    [TableView release];
    [viewActivity release];
    [btnTransaction release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateControls];
    [self updateHistory];
}

#pragma mark - Events
-(void)btnCloseClick
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void)btnTransactionClick
{
    if (![viewActivity isHidden])
        return;
    
    mTrIdAlert = [[UIAlertView alloc] initWithTitle:@"Введите Transaction ID" message:NULL delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", NULL];
    [mTrIdAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [mTrIdAlert show];
    
    UITextField *textfield = [mTrIdAlert textFieldAtIndex:0];
    [textfield setText:@"C2CDB704-9E8F-4572-8F07-D5B4D60A90E7"];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int index = (int)buttonIndex;
    if (index)
    {
        if (alertView == mTrIdAlert)
        {
            mPage = 0;
            [mData removeAllObjects];
            [TableView reloadData];
            
            UITextField *textfield = [mTrIdAlert textFieldAtIndex:0];
            NSString *trnsactionID = [textfield text];
            [self setTrnsactionID:trnsactionID];
            [self updateHistory];
        }
        else
        {
            ReversePaymentContext *reverseContext = [[ReversePaymentContext alloc] init];
            [reverseContext setReverseType:[mSelectedTransaction canCancel] ? ReverseMode_Cancel : ReverseMode_Return];
            [reverseContext setTransactionID:[mSelectedTransaction ID]];
            [reverseContext setCash:[mSelectedTransaction cashPayment]];
            
            Payment *payment = [[Payment alloc] init];
            [payment setPaymentContext:reverseContext];
            [payment setDelegate:self];
            [self.navigationController pushViewController:payment animated:FALSE];
            [reverseContext release];
            [payment release];
        }
    }
}

#pragma mark - PaymentDelegate
-(void)paymentFinished:(TransactionData *)transactionData
{
    if (!transactionData)
        return;
    
    if ([transactionData RequiredSignature] && ![mSelectedTransaction cashPayment])
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

#pragma mark - Table view source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mData count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HistoryCell";
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        NSArray *items = [[NSBundle mainBundle] loadNibNamed:@"HistoryCell" owner:self options:NULL];
        for(id item in items)
        {
            if ([item isKindOfClass:[HistoryCell class]])
            {
                cell = item;
                break;
            }
        }
    }
    
    TransactionItem *transaction = [mData objectAtIndex:(int)indexPath.row];
    
    [cell.lblTitle setText:([transaction descriptionOfTransaction] && ![[transaction descriptionOfTransaction] isEqualToString:@""]) ? [transaction descriptionOfTransaction] : @"no description"];
    [cell.lblAdd setText:[NSString stringWithFormat:@"%.2lf", 0 + [transaction amount]]];
    
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionItem *transaction = [mData objectAtIndex:(int)indexPath.row];
    mSelectedTransaction = transaction;
    
    NSMutableString *message = [[NSMutableString alloc] init];
    [message appendFormat:@"Transaction ID:%@", [transaction ID]];
    [message appendString:@"\n----------------------------------------"];
    [message appendFormat:@"\nDate:%@", [transaction date]];
    [message appendString:@"\n----------------------------------------"];
    [message appendFormat:@"\nDescription:%@", ([transaction descriptionOfTransaction] && ![[transaction descriptionOfTransaction] isEqualToString:@""]) ? [transaction descriptionOfTransaction] : @"no description"];
    [message appendString:@"\n----------------------------------------"];
    [message appendFormat:@"\nAmount:%.2lf", [transaction amount]];
    [message appendString:@"\n----------------------------------------"];
    [message appendFormat:@"\nCard type:%@", [transaction cardType]];
    [message appendString:@"\n----------------------------------------"];
    [message appendFormat:@"\nCard number:%@", [transaction cardNumber]];
    [message appendString:@"\n----------------------------------------"];
    [message appendFormat:@"\nStatus:%@", [transaction status]];
    [message appendString:@"\n----------------------------------------"];
    [message appendFormat:@"\nInvoice:%@", [transaction invoice]];
    [message appendString:@"\n----------------------------------------"];
    if ([transaction hasPhoto]) [message appendFormat:@"\nPhoto URL:%@\n----------------------------------------", [transaction photoURL]];
    if ([transaction hasSignature]) [message appendFormat:@"\nSignature URL:%@\n----------------------------------------", [transaction signatureURL]];
    if ([transaction hasGPSData]) [message appendFormat:@"\nGPS data:%f;%f\n----------------------------------------", [transaction latitude], [transaction longitude]];
    
    if ([transaction withCustomFields])
    {
        NSArray *customFields = [transaction customFields];
        if (customFields && [customFields count])
        {
            DescriptionProduct *product = [transaction customFieldsProduct];
            [message appendFormat:@"\nCustom product name:%@", [product title]];
            [product release];
            
            for (DescriptionProductField *field in customFields)
            {
                if ([field type] == DescriptionProductFieldType_Text)
                    [message appendFormat:@"\nText field:%@ - %@", [field title], [field value]];
                else if ([field type] == DescriptionProductFieldType_Image)
                    [message appendFormat:@"\nImage field:%@ - %@", [field title], [field value]];
            }
            [customFields release];
        }
        [message appendString:@"\n----------------------------------------"];
    }
    else if ([transaction withOrder])
    {
        NSArray *products = [transaction products];
        if (products && [products count])
        {
            [message appendString:@"\nInventory products"];
            [message appendString:@"\n+ + +"];
            for (TransactionProduct *product in products)
            {
                [message appendFormat:@"\nName:%@", [product Name]];
                [message appendFormat:@"\nPrice:%.2lf", [product UnitPrice]];
                [message appendFormat:@"\nCount:%d", [product Count]];
                [message appendFormat:@"\nTotal price:%.2lf", [product Price]];
                if ([product HasImage]) [message appendFormat:@"\nImage URL:%@", [product ImageURLTN]];
            }
            [products release];
        }
        [message appendString:@"\n----------------------------------------"];
    }
    
    NSString *returnButtonTitle = NULL;
    if ([transaction canCancel])
        returnButtonTitle = @"Cancel";
    if ([transaction canReturn])
        returnButtonTitle = @"Return";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction details" message:message delegate:self cancelButtonTitle:@"Ок" otherButtonTitles:returnButtonTitle, NULL];
    [alert show];
    [alert release];
}

#pragma mark - Scroll view delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![viewActivity isHidden])
        return;
    
    float scrollOffsetBottom = 0.0f;
    if ([TableView contentSize].height < TableView.frame.size.height)
        scrollOffsetBottom = -[TableView contentOffset].y;
    else
        scrollOffsetBottom = ([TableView contentSize].height - [TableView contentOffset].y) - TableView.frame.size.height;
    
    if (scrollOffsetBottom < 0)
        [self updateHistory];
}

#pragma mark - Other methods
-(void)updateControls
{
    [self setAutomaticallyAdjustsScrollViewInsets:FALSE];
    [viewActivity setHidden:TRUE];
    
    [TableView setDataSource:self];
    [TableView setDelegate:self];
    
    UIView *emptyFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [TableView setTableFooterView:emptyFooterView];
    [emptyFooterView release];
    
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [btnTransaction addTarget:self action:@selector(btnTransactionClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setTrnsactionID:(NSString *)transactionID
{
    if (mTransactionID != transactionID)
    {
        if (mTransactionID)
            [mTransactionID release];
        [transactionID retain];
        mTransactionID = transactionID;
    }
}

#pragma mark - Public methods
-(void)updateHistory
{
    if (![viewActivity isHidden] || mPage == -1)
        return;
    
    [viewActivity setHidden:FALSE];
    [viewActivity startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        APIHistoryResult *result = NULL;
        if (mTransactionID)
            result = [[PaymentController instance] historyWithTransactionID:mTransactionID];
        else
            result = [[PaymentController instance] historyWithPage:mPage];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [viewActivity setHidden:TRUE];
            [viewActivity stopAnimating];
            
            if (result)
            {
                if ([result valid] && ![result errorCode])
                {
                    if (mTransactionID)
                    {
                        mPage = -1;
                        NSArray *transactions = [result transactions];
                        if ([transactions count]) [mData addObjectsFromArray:transactions];
                        [transactions release];
                    }
                    else
                    {
                        mPage++;
                        NSArray *transactions = [result transactions];
                        if ([transactions count])
                            [mData addObjectsFromArray:transactions];
                        else
                            mPage = -1;
                        [transactions release];
                    }
                    
                    [TableView reloadData];
                }
                else
                    [[[DRToast alloc] initWithMessage:[result errorMessage]] show];
                
                [result release];
            }
        });
    });
}


@end
