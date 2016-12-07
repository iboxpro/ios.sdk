//
//  History.h
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 7/10/15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransactionItem;

@interface History : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
IBOutlet UIButton *btnClose;
IBOutlet UIButton *btnTransaction;
IBOutlet UITableView *TableView;
IBOutlet UIActivityIndicatorView *viewActivity;
    
@private int mPage;
@private NSString *mTransactionID;
@private NSMutableArray *mData;
@private TransactionItem *mSelectedTransaction;
@private UIAlertView *mTrIdAlert;
}

-(History *)init;

@end
