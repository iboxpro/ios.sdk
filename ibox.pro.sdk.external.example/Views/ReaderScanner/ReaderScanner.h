//
//  ReaderScanner.h
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 31.03.17.
//  Copyright © 2017 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentController.h"
#import "BTDevice.h"

@protocol ReaderScannerDelegate<NSObject>
-(void)ReaderScannerDelegateSelectedReader:(BTDevice *)reader ReaderType:(PaymentControllerReaderType)readerType ReaderTypeLocalized:(NSString *)readerTypeLocalized;
@end

@interface ReaderScanner : UIViewController<UITableViewDataSource, UITableViewDelegate, PaymentControllerDelegate>
{
IBOutlet UIButton *btnClose;
IBOutlet UITableView *TableView;
IBOutlet UIActivityIndicatorView *viewActivity;

@private id<ReaderScannerDelegate> mDelegate;
@private PaymentControllerReaderType mReaderType;
@private NSString *mReaderTypeLocalized;
@private NSArray *mDevices;
}

-(ReaderScanner *)init;
-(void)setDelegate:(id<ReaderScannerDelegate>)delegate;
-(void)setReaderType:(PaymentControllerReaderType)readerType;
-(void)setReaderTypeLocalized:(NSString *)readerTypeLocalized;
-(PaymentControllerReaderType)readerType;
-(NSString *)readerTypeLocalized;

@end
