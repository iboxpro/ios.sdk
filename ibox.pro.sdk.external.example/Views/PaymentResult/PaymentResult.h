//
//  PaymentResult.h
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 04.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransactionData;

@interface PaymentResult : UIViewController
{
IBOutlet UITextView *txtData;
IBOutlet UIButton *btnOk;
    
@private TransactionData *mTransactionData;
}

-(PaymentResult *)init;
-(void)setTransactionData:(TransactionData *)data;

@end
