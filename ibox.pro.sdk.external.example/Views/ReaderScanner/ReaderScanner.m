//
//  ReaderScanner.m
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 31.03.17.
//  Copyright © 2017 DevReactor. All rights reserved.
//

#import "ReaderScanner.h"
#import "Utility.h"
#import "BTDevice.h"
#import "Consts.h"
#import "ReaderScannerCell.h"

@implementation ReaderScanner

#pragma mark - Ctor/Dtor
-(ReaderScanner *)init
{
    self = [super initWithNibName:@"ReaderScanner" bundle:NULL];
    return self;
}

-(void)dealloc
{
    if (mDevices) [mDevices release];
    [btnClose release];
    [TableView release];
    [viewActivity release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateControls];
    
    [[PaymentController instance] setDelegate:self];
    [[PaymentController instance] search4BTReadersWithType:mReaderType];
}

#pragma mark - Events
-(void)btnCloseClick
{
    [[PaymentController instance] setDelegate:NULL];
    [[PaymentController instance] stopSearch4BTReaders];
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - Table view source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mDevices count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ReaderScannerCell";
    ReaderScannerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        NSArray *items = [[NSBundle mainBundle] loadNibNamed:@"ReaderScannerCell" owner:self options:NULL];
        for(id item in items)
        {
            if ([item isKindOfClass:[ReaderScannerCell class]])
            {
                cell = item;
                break;
            }
        }
    }
    
    BTDevice *device = [mDevices objectAtIndex:(int)indexPath.row];
    [cell.lblTitle setText:[device name]];

    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BTDevice *device = [mDevices objectAtIndex:(int)indexPath.row];
    if (device)
    {
        [[PaymentController instance] saveBTDevice:device];
        
        if (mDelegate && [mDelegate respondsToSelector:@selector(ReaderScannerDelegateSelectedReader:ReaderType:ReaderTypeLocalized:)])
            [mDelegate ReaderScannerDelegateSelectedReader:device ReaderType:mReaderType ReaderTypeLocalized:mReaderTypeLocalized];
    }
    [self btnCloseClick];
}

#pragma mark - PaymentControllerDelegate
-(void)PaymentControllerRequestBTDevice:(NSArray *)devices
{
    [self setDevices:devices];
    [TableView reloadData];
}

-(void)PaymentControllerStartTransaction:(NSString *)transactionID{}
-(void)PaymentControllerReaderEvent:(PaymentControllerReaderEventType)event{}
-(void)PaymentControllerDone:(TransactionData *)transactionData{}
-(void)PaymentControllerError:(PaymentControllerErrorType)error Message:(NSString *)message{}
-(void)PaymentControllerRequestCardApplication:(NSArray *)applications{}
-(void)PaymentControllerScheduleStepsStart{}
-(void)PaymentControllerScheduleStepsCreated:(NSArray *)scheduleSteps{}

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
}

-(void)setDevices:(NSArray *)devices
{
    if (mDevices != devices)
    {
        if (mDevices)
            [mDevices release];
        [devices retain];
        mDevices = devices;
    }
}

#pragma mark - Public methods
-(void)setDelegate:(id<ReaderScannerDelegate>)delegate
{
    mDelegate = delegate;
}

-(void)setReaderType:(PaymentControllerReaderType)readerType
{
    mReaderType = readerType;
}

-(void)setReaderTypeLocalized:(NSString *)readerTypeLocalized
{
    if (mReaderTypeLocalized != readerTypeLocalized)
    {
        if (mReaderTypeLocalized)
            [mReaderTypeLocalized release];
        [readerTypeLocalized retain];
        mReaderTypeLocalized = readerTypeLocalized;
    }
}

-(PaymentControllerReaderType)readerType
{
    return mReaderType;
}

-(NSString *)readerTypeLocalized
{
    return mReaderTypeLocalized;
}

@end
