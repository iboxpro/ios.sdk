//
//  Reverse.h
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 01.08.16.
//  Copyright © 2016 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payment.h"

@interface Reverse : UIViewController<PaymentDelegate>
{
IBOutlet UIButton *btnClose;
IBOutlet UITextField *txtAmount;
IBOutlet UITextField *txtReverse;
IBOutlet UITextField *txtEmail;
IBOutlet UITextField *txtPhone;
IBOutlet UIView *viewAuxDataContainer;
IBOutlet UITextView *txtAuxData;
IBOutlet UIButton *btnOk;

IBOutlet NSLayoutConstraint *ctrDividerTop;
IBOutlet NSLayoutConstraint *ctrScrollBottom;
    
@private TransactionItem *mTransaction;
@private UITapGestureRecognizer *mTapGestureRecognizer;
}

-(Reverse *)init;
-(void)setTransaction:(TransactionItem *)transaction;

@end
