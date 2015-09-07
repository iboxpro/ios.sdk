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

@interface Payment : UIViewController<PaymentControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
IBOutlet UIButton *btnClose;
IBOutlet UILabel *lblText;
    
@private id<PaymentDelegate> mDelegate;
@private PaymentContext *mPaymentContext;
@private UIActionSheet *mCardAppsMenu;
@private UIActionSheet *mBTDevicesMenu;
}

-(Payment *)init;
-(void)setPaymentContext:(PaymentContext *)paymentContext;
-(void)setDelegate:(id<PaymentDelegate>)delegate;

@end