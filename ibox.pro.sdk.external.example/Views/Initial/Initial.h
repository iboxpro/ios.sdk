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

@interface Initial : UIViewController<PaymentDelegate, ReaderScannerDelegate>
{
IBOutlet UIActivityIndicatorView *viewActivity;
IBOutlet UITextField *txtAmount;
IBOutlet UITextField *txtDescription;
IBOutlet UITextField *txtExtId;
IBOutlet UITextField *txtPayType;
IBOutlet UIButton *btnHistory;
IBOutlet UIButton *btnPayType;
IBOutlet UIButton *btnForgetBTReader;
IBOutlet UIButton *btnOk;
IBOutlet UISegmentedControl *sgmProduct;
IBOutlet UIView *viewProductContainer;
IBOutlet UITextField *txtProductTitle;
IBOutlet UIButton *btnProductEdit;
IBOutlet UITextView *txtAuxData;
IBOutlet UILabel *lblProductData;
    
IBOutlet NSLayoutConstraint *ctrFieldsHeight;
IBOutlet NSLayoutConstraint *ctrDescriptionHeight;
IBOutlet NSLayoutConstraint *ctrPayTypeHeight;
IBOutlet NSLayoutConstraint *ctrScrollBottom;
    
@private UIAlertController *mLoginAlert;
@private NSString *mEmail;
@private NSString *mPassword;
@private UITapGestureRecognizer *mTapGestureRecognizer;
}

@property (retain, nonatomic) DescriptionProduct *SelectedProduct;
@property (retain, nonatomic) NSArray *ProductData;
@property (retain, nonatomic) NSArray *Products;

-(Initial *)init;

@end
