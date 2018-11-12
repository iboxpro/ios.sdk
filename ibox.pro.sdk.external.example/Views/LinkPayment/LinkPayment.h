//
//  LinkPayment.h
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 26.09.17.
//  Copyright © 2017 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransactionData;
@class ExternalPayment;

@interface LinkPayment : UIViewController
{
IBOutlet UILabel *lblTitle;
IBOutlet UIImageView *imgQr;
IBOutlet UIView *viewDataWrapper;
IBOutlet UILabel *lblLink;
IBOutlet UIButton *btnLink;
IBOutlet UIButton *btnOk;
IBOutlet UIButton *btnNewPayment;
IBOutlet NSLayoutConstraint *ctrLinkWrapperHeight;
    
@private UISwipeGestureRecognizer *mSwipeGestureRecognizerLeft;
@private UISwipeGestureRecognizer *mSwipeGestureRecognizerRight;
    
@private TransactionData *mTransactionData;
@private int mPage;
}

@property (nonatomic, retain) ExternalPayment *ExternalPayment;
@property (nonatomic, retain) NSArray *Data;

-(LinkPayment *)init;
-(void)setTransactionData:(TransactionData *)data;

@end
