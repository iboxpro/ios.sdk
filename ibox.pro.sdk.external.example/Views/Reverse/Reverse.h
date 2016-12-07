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
IBOutlet UIButton *btnOk;
@private TransactionItem *mTransaction;
}

-(Reverse *)init;
-(void)setTransaction:(TransactionItem *)transaction;

@end
