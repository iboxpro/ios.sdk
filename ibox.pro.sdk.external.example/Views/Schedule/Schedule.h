//
//  Schedule.h
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 5/14/15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payment.h"

@class RecurrentPaymentContext;
@class PaymentController;

@interface Schedule : UIViewController<UITextFieldDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, PaymentDelegate>
{
IBOutlet UITextField *txtEmail;
IBOutlet UITextField *txtPhone;
IBOutlet UIButton *btnClose;
IBOutlet UILabel *lblRepeat;
IBOutlet UIButton *btnRepeat;
IBOutlet UILabel *lblWeekDay;
IBOutlet UIButton *btnWeekDay;
IBOutlet UILabel *lblMonth;
IBOutlet UIButton *btnMonth;
IBOutlet UITextField *txtDates;
IBOutlet UIDatePicker *viewStartTimePicker;
IBOutlet UIDatePicker *viewStartDatePicker;
IBOutlet UIPickerView *viewEndCountPicker;
IBOutlet UIDatePicker *viewEndDatePicker;
IBOutlet UIPickerView *viewDayPicker;
IBOutlet UISegmentedControl *sgmEndType;
IBOutlet UISegmentedControl *sgmStart;
IBOutlet UIButton *btnOk;
    
IBOutlet NSLayoutConstraint *cntStartHeight;
IBOutlet NSLayoutConstraint *cntWeekDayHeight;
IBOutlet NSLayoutConstraint *cntEndHeight;
IBOutlet NSLayoutConstraint *cntMonthHeight;
IBOutlet NSLayoutConstraint *cntDayHeight;
IBOutlet NSLayoutConstraint *cntDaysHeight;
    
@private RecurrentPaymentContext *mRecurrentPaymentContext;
@private NSDateFormatter *mDateFormatter;
@private NSLocale *mLocale;
}

-(Schedule *)init;
-(void)setRecurrentPaymentContext:(RecurrentPaymentContext *)recurrentPaymentContext;

@end
