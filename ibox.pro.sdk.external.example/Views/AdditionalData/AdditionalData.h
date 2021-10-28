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
IBOutlet UIActivityIndicatorView *viewActivity;
IBOutlet UITextField *txtReceiptMail;
IBOutlet UITextField *txtReceiptPhone;
IBOutlet UIButton *btnOk;
IBOutlet UIView *viewCover;
IBOutlet SignatureView *viewSignature;
IBOutlet NSLayoutConstraint *ctrReceiptDataTop;
@private UITapGestureRecognizer *mTapGestureRecognizer;
    
@private TransactionData *mTransactionData;
@private NSDictionary    *mReaderInfo;
}

-(AdditionalData *)init;
-(void)setTransactionData:(TransactionData *)data;
-(void)setReaderInfo:(NSDictionary *)info;

@end
