//
//  Login.h
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 02.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payment.h"

@interface Initial : UIViewController<UIActionSheetDelegate, PaymentDelegate>
{
IBOutlet UITextField *txtEmail;
IBOutlet UITextField *txtPassword;
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
}

-(Initial *)init;

@end
