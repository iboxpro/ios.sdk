//
//  History.m
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 7/10/15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "History.h"
#import "Reverse.h"
#import "Utility.h"
#import "Consts.h"
#import "HistoryCell.h"
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
    
    [self setTrnsactionID:NULL];
    [self setInProcessTransactions:NULL];
    
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
    
    UIAlertController *trIdAlert = [UIAlertController  alertControllerWithTitle:[Utility localizedStringWithKey:@"history_input_transaction_id"] message:NULL preferredStyle:UIAlertControllerStyleAlert];
    [trIdAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:@"Transaction"];
        [textField setKeyboardType:UIKeyboardTypeDefault];
    }];
    [[[trIdAlert textFields] objectAtIndex:0] setText:@"C2CDB704-9E8F-4572-8F07-D5B4D60A90E7"];
    [trIdAlert addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_cancel"] style:UIAlertActionStyleCancel handler:NULL]];
    [trIdAlert addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        mPage = 0;
        [mData removeAllObjects];
        [TableView reloadData];
        
        UITextField *textfield = [[trIdAlert textFields] objectAtIndex:0];
        NSString *trnsactionID = [textfield text];
        [self setTrnsactionID:trnsactionID];
        [self updateHistory];
    }]];
    [self presentViewController:trIdAlert animated:TRUE completion:NULL];
}

#pragma mark - Table view source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int sectionsCount = 1;
    if (mInProcessTransactions && [mInProcessTransactions count])
        sectionsCount += 1;
    return sectionsCount;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (mInProcessTransactions && [mInProcessTransactions count])
    {
        if (section == 0)
            return [Utility localizedStringWithKey:@"history_transactions_in_process"];
        else
            return [Utility localizedStringWithKey:@"history_transactions"];
    }
    else
        return [Utility localizedStringWithKey:@"history_transactions"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowsCount = 0;
    if (mInProcessTransactions && [mInProcessTransactions count])
    {
        if (section == 0)
            rowsCount = (int)[mInProcessTransactions count];
        else
            rowsCount = (int)[mData count];
    }
    else
        rowsCount = (int)[mData count];
    return rowsCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
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
    
    TransactionItem *transaction = NULL;
    if (mInProcessTransactions && [mInProcessTransactions count])
    {
        if (indexPath.section == 0)
            transaction = [mInProcessTransactions objectAtIndex:(int)indexPath.row];
        else
            transaction = [mData objectAtIndex:(int)indexPath.row];
    }
    else
        transaction = [mData objectAtIndex:(int)indexPath.row];
    
    [cell.lblTitle setText:([transaction descriptionOfTransaction] && ![[transaction descriptionOfTransaction] isEqualToString:@""]) ? [transaction descriptionOfTransaction] : [Utility localizedStringWithKey:@"common_no_description"]];
    
    NSString *amountString = [NSString stringWithFormat:CONSTS_AMOUNT_FORMAT, 0 + [transaction amount]];
    
    UIColor *color = NULL;
    BOOL strikethrough = FALSE;
    
    if ([transaction displayMode] == TransactionItemDisplayMode_SUCCESS)
        color = [UIColor blackColor];
    else if ([transaction displayMode] == TransactionItemDisplayMode_DECLINED)
        color = [UIColor redColor];
    else if ([transaction displayMode] == TransactionItemDisplayMode_REVERSE)
        color = [UIColor grayColor];
    else if ([transaction displayMode] == TransactionItemDisplayMode_REVERSED)
    {
        color = [UIColor grayColor];
        strikethrough = TRUE;
    }
    
    [cell.lblAdd setText:amountString];
    [cell.lblAdd setTextColor:color];
    [cell.lblTitle setTextColor:color];
    
    if (strikethrough)
    {
        [cell.lblTitle strikethrough];
        
        if ([transaction amountEff])
        {
            NSString *amountEffString = [NSString stringWithFormat:CONSTS_AMOUNT_FORMAT, 0 + [transaction amountEff]];
            NSString *amountTotslString = [NSString stringWithFormat:@"%@\n%@", amountString, amountEffString];
            
            [cell.lblAdd setText:amountTotslString];
            [cell.lblAdd strikethroughWithRange:[amountTotslString rangeOfString:amountString]];
        }
        else
            [cell.lblAdd strikethrough];
    }
    
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Account *account = [[Utility appDelegate] account];
    
    TransactionItem *transaction = NULL;
    if (mInProcessTransactions && [mInProcessTransactions count])
    {
        if (indexPath.section == 0)
            transaction = [mInProcessTransactions objectAtIndex:(int)indexPath.row];
        else
            transaction = [mData objectAtIndex:(int)indexPath.row];
    }
    else
        transaction = [mData objectAtIndex:(int)indexPath.row];
    mSelectedTransaction = transaction;
    
    Card *card = [transaction card];
    
    Acquirer *acquirer = NULL;
    NSString *acquirerID = [transaction acquirerID];
    if (acquirerID && ![acquirerID isEqualToString:@""])
        acquirer = [[[Utility appDelegate] account] acquirerWithCode:acquirerID];
    
    NSMutableString *message = [[NSMutableString alloc] init];
    [message appendFormat:@"Transaction ID:%@", [transaction ID]];
    [message appendString:@"\n---------------------------------------"];
    [message appendFormat:@"\nDate:%@", [transaction date]];
    [message appendString:@"\n---------------------------------------"];
    [message appendFormat:@"\nDescription:%@", ([transaction descriptionOfTransaction] && ![[transaction descriptionOfTransaction] isEqualToString:@""]) ? [transaction descriptionOfTransaction] : [Utility localizedStringWithKey:@"common_no_description"]];
    [message appendString:@"\n---------------------------------------"];
    [message appendFormat:@"\nAmount:%.2lf", [transaction amount]];
    if ([transaction displayMode] == TransactionItemDisplayMode_REVERSED)
    {
        if ([transaction amountEff])
        {
            [message appendString:@"\n---------------------------------------"];
            [message appendFormat:@"\nAmountEff:%.2lf", [transaction amountEff]];
        }
    }
    
    [message appendString:@"\n---------------------------------------"];
    [message appendFormat:@"\nCard type:%@", [card iin]];
    
    if ([transaction inputType] == TransactionInputType_SWIPE ||
        [transaction inputType] == TransactionInputType_EMV ||
        [transaction inputType] == TransactionInputType_NFC)
    {
        [message appendString:@"\n---------------------------------------"];
        [message appendFormat:@"\nCard number:%@", [card panMasked]];
    }
    else if ([transaction inputType] == TransactionInputType_LINK)
    {
        if (acquirer)
        {
            [message appendString:@"\n----------------------------------------"];
            [message appendFormat:@"\nAcquirer name:%@", [acquirer name]];
        }
    }
    
    [message appendString:@"\n---------------------------------------"];
    [message appendString:@"\nStatus:"];
    [message appendFormat:@"\n%@", [transaction stateLine1]];
    [message appendFormat:@"\n%@", [transaction stateLine2]];
    [message appendString:@"\n---------------------------------------"];
    [message appendFormat:@"\nInvoice:%@", [transaction invoice]];
    [message appendString:@"\n---------------------------------------"];
    
    if ([transaction withAuxData])
    {
        NSError *error = NULL;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[transaction auxData] options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error && ![Utility stringIsNullOrEmty:jsonString])
        {
            [message appendFormat:@"\nAuxData:%@", jsonString];
            [message appendString:@"\n---------------------------------------"];
        }
    }
    
    /*
    if ([transaction withPurchases])
    {
        NSArray *purchases = [transaction purchases];
        [message appendFormat:@"\nPurchases data:%@", [Purchase purchases2JsonString:purchases]];
        [message appendString:@"\n---------------------------------------"];
        [purchases release];
    }
    
    if ([transaction withTags])
    {
        NSArray *tags = [transaction tags];
        [message appendFormat:@"\nTags data:%@", [Tag tags2JsonString:tags]];
        [message appendString:@"\n---------------------------------------"];
        [tags release];
    }
    */
    
    if ([transaction hasPhoto]) [message appendFormat:@"\nPhoto URL:%@\n---------------------------------------", [transaction photoURL]];
    if ([transaction hasSignature]) [message appendFormat:@"\nSignature URL:%@\n---------------------------------------", [transaction signatureURL]];
    if ([transaction hasGPSData]) [message appendFormat:@"\nGPS data:%f;%f\n---------------------------------------", [transaction latitude], [transaction longitude]];
    
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
                if ([field type] == DescriptionProductFieldType_TEXT)
                    [message appendFormat:@"\nText field:%@ - %@", [field title], [field value]];
                else if ([field type] == DescriptionProductFieldType_IMAGE)
                    [message appendFormat:@"\nImage field:%@ - %@", [field title], [field value]];
            }
            [customFields release];
        }
        [message appendString:@"\n---------------------------------------"];
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
        [message appendString:@"\n---------------------------------------"];
    }
    
    [card release];
    
    FiscalInfo *fiscalInfo = [transaction fiscalInfo];
    if ([fiscalInfo status] == FiscalInfoStatus_SUCCESS)
    {
        NSString *fiscalData = [self fiscalInfo2String:fiscalInfo];
        if (![Utility stringIsNullOrEmty:fiscalData])
        {
            [message appendFormat:@"\n%@:", [Utility localizedStringWithKey:@"fiscal_info_title"]];
            [message appendFormat:@"\n%@", fiscalData];
            [message appendString:@"\n---------------------------------------"];
        }
    }
    
    NSString *reverseButtonTitle = NULL;
    if ([transaction reverseMode] == TransactionReverseMode_RETURN ||
        [transaction reverseMode] == TransactionReverseMode_RETURN_PARTIAL)
        reverseButtonTitle = [Utility localizedStringWithKey:@"history_return_payment"];
    else if ([transaction reverseMode] == TransactionReverseMode_CANCEL ||
             [transaction reverseMode] == TransactionReverseMode_CANCEL_PARTIAL ||
             [transaction reverseMode] == TransactionReverseMode_CANCEL_CNP ||
             [transaction reverseMode] == TransactionReverseMode_CANCEL_CNP_PARTIAL)
        reverseButtonTitle = [Utility localizedStringWithKey:@"history_cancel_payment"];

    UIAlertController *alert = [UIAlertController  alertControllerWithTitle:[Utility localizedStringWithKey:@"history_transaction_details"] message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_ok"] style:UIAlertActionStyleCancel handler:NULL]];
    if (![Utility stringIsNullOrEmty:reverseButtonTitle])
    {
        [alert addAction:[UIAlertAction actionWithTitle:reverseButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            Reverse *reverse = [[Reverse alloc] init];
            [reverse setTransaction:mSelectedTransaction];
            [self.navigationController pushViewController:reverse animated:TRUE];
            [reverse release];
        }]];
    }
    if (account && [account usesServerFiscalization])
    {
        if (!fiscalInfo || [fiscalInfo status] != FiscalInfoStatus_SUCCESS)
        {
            [alert addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_fiscalize"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self fiscalizeTransaction];
            }]];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:TRUE completion:NULL];
    });
    
    [fiscalInfo release];
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
    [Utility updateTextWithViewController:self];
    
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

-(void)fiscalizeTransaction
{
    [viewActivity setHidden:FALSE];
    [viewActivity startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        APIFiscalizeResult *result = [[PaymentController instance] fiscalizeWithTrId:[mSelectedTransaction ID]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [viewActivity setHidden:TRUE];
            [viewActivity stopAnimating];
            
            if (result)
            {
                if ([result valid] && ![result errorCode])
                {
                    TransactionItem *transaction = [result transaction];
                    if (transaction)
                    {
                        FiscalInfo *fiscalInfo = [transaction fiscalInfo];
                        NSString *message = [self fiscalInfo2String:fiscalInfo];
                        if (![Utility stringIsNullOrEmty:message])
                            [[[DRToast alloc] initWithMessage:message Title:[Utility localizedStringWithKey:@"fiscal_info_title"] Duration:Long] show];
                    }
                }
                else
                {
                    [[[DRToast alloc] initWithMessage:[result errorMessage]] show];
                }
            }
        });
    });
}

-(NSString *)fiscalInfo2String:(FiscalInfo *)fiscalInfo
{
    NSMutableString *returnValue = NULL;
    if (fiscalInfo && [fiscalInfo status] == FiscalInfoStatus_SUCCESS)
    {
        returnValue = [[NSMutableString alloc] init];
        [returnValue appendFormat:@"%@\n", [fiscalInfo dateTime]];
        [returnValue appendFormat:@"%@%@\n", [Utility localizedStringWithKey:@"fiscal_info_invoice"], [fiscalInfo printerDocSerialNumber]];
        [returnValue appendFormat:@"%@%@\n", [Utility localizedStringWithKey:@"fiscal_info_fd"], [fiscalInfo documentNumber]];
        [returnValue appendFormat:@"%@%@\n", [Utility localizedStringWithKey:@"fiscal_info_fn"], [fiscalInfo storageNumber]];
        [returnValue appendFormat:@"%@%@\n", [Utility localizedStringWithKey:@"fiscal_info_fdp"], [fiscalInfo documentMark]];
        [returnValue appendFormat:@"%@%@\n", [Utility localizedStringWithKey:@"fiscal_info_zn"], [fiscalInfo printerSerialNumber]];
        [returnValue appendFormat:@"%@%@", [Utility localizedStringWithKey:@"fiscal_info_shift"], [fiscalInfo printerShift]];
    }
    return returnValue;
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

-(void)setInProcessTransactions:(NSArray *)transactions
{
    if (mInProcessTransactions != transactions)
    {
        if (mInProcessTransactions)
            [mInProcessTransactions release];
        [transactions retain];
        mInProcessTransactions = transactions;
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
                    NSArray *inProcessTransactions = [result inProcessTransactions];
                    [self setInProcessTransactions:inProcessTransactions];
                    [inProcessTransactions release];
                    
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
