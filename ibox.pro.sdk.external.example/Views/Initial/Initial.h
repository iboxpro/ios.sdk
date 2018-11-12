//
//  Login.h
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 02.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderScanner.h"
#import "Payment.h"

@interface Initial : UIViewController<UIActionSheetDelegate, PaymentDelegate, ReaderScannerDelegate>
{
IBOutlet UIActivityIndicatorView *viewActivity;
IBOutlet UITextField *txtAmount;
IBOutlet UITextField *txtDescription;
IBOutlet UITextField *txtPayType;
IBOutlet UIButton *btnHistory;
IBOutlet UIButton *btnPayType;
IBOutlet UIButton *btnForgetBTReader;
IBOutlet UIButton *btnPing;
IBOutlet UIButton *btnOk;
IBOutlet UISegmentedControl *sgmProduct;
IBOutlet UITextField *txtFieldOne;
IBOutlet UITextField *txtFieldTwo;
    
IBOutlet NSLayoutConstraint *ctrFieldsHeight;
IBOutlet NSLayoutConstraint *ctrDescriptionHeight;

@private UIActionSheet *mReaderMenu;
@private UIActionSheet *mPaymentMenu;
@private UIAlertView *mLoginAlert;
@private NSString *mEmail;
@private NSString *mPassword;
}

-(Initial *)init;

@end
