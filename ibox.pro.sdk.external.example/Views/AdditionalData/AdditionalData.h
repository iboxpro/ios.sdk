//
//  AdditionalData.h
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 04.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignatureView.h"

@class TransactionData;

@interface AdditionalData : UIViewController<UITextFieldDelegate>
{
IBOutlet UITextField *txtReceiptMail;
IBOutlet UITextField *txtReceiptPhone;
IBOutlet UIButton *btnOk;
IBOutlet UIView *viewCover;
IBOutlet SignatureView *viewSignature;
IBOutlet NSLayoutConstraint *ctrReceiptDataTop;
    
@private TransactionData *mTransactionData;
}

-(AdditionalData *)init;
-(void)setTransactionData:(TransactionData *)data;

@end
