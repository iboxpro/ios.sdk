//
//  AcceptPayment.h
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 02.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentController.h"

@class PaymentContext;

@protocol PaymentDelegate<NSObject>
@optional
-(void)paymentFinished:(TransactionData *)transactionData;
@end

@interface Payment : UIViewController<PaymentControllerDelegate>
{
IBOutlet UIButton *btnClose;
IBOutlet UILabel *lblText;
    
@private id<PaymentDelegate> mDelegate;
@private PaymentContext *mPaymentContext;
@private TransactionData *mTransactionData;
@private UIAlertController *mErrorAlert;
@private int mFiscalCounter;
}

-(Payment *)init;
-(void)setPaymentContext:(PaymentContext *)paymentContext;
-(void)setDelegate:(id<PaymentDelegate>)delegate;

@end
