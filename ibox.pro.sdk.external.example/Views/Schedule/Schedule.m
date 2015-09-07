//
//  Schedule.m
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 5/14/15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "Schedule.h"
#import "RecurrentPaymentContext.h"
#import "PaymentResult.h"

@implementation Schedule

#pragma mark - Ctor/Dtor
-(Schedule *)init
{
    self = [super initWithNibName:@"Schedule" bundle:NULL];
    return self;
}

-(void)dealloc
{
    if (mRecurrentPaymentContext) [mRecurrentPaymentContext release];
    if (mDateFormatter) [mDateFormatter release];
    if (mLocale) [mLocale release];
    [btnClose release];
    [lblRepeat release];
    [btnRepeat release];
    [btnWeekDay release];
    [lblWeekDay release];
    [cntWeekDayHeight release];
    [cntEndHeight release];
    [lblMonth release];
    [btnMonth release];
    [cntMonthHeight release];
    [cntDayHeight release];
    [viewDayPicker release];
    [viewEndCountPicker release];
    [sgmEndType release];
    [viewEndDatePicker release];
    [cntStartHeight release];
    [btnOk release];
    [viewStartDatePicker release];
    [viewStartTimePicker release];
    [sgmStart release];
    [cntDaysHeight release];
    [txtDates release];
    [txtEmail release];
    [txtPhone release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    mDateFormatter = [[NSDateFormatter alloc] init];
    mLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    [mDateFormatter setLocale:mLocale];
    
    [viewDayPicker setDataSource:self];
    [viewDayPicker setDelegate:self];
    [viewEndCountPicker setDataSource:self];
    [viewEndCountPicker setDelegate:self];
    
    [txtEmail setDelegate:self];
    [txtPhone setDelegate:self];
    [txtDates setDelegate:self];
    
    [sgmEndType addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [sgmStart addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    [self updateViews];
    
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [btnRepeat addTarget:self action:@selector(btnRepeatClick) forControlEvents:UIControlEventTouchUpInside];
    [btnWeekDay addTarget:self action:@selector(btnWeekDayClick) forControlEvents:UIControlEventTouchUpInside];
    [btnMonth addTarget:self action:@selector(btnMonthClick) forControlEvents:UIControlEventTouchUpInside];
    [btnOk addTarget:self action:@selector(btnOkClick) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex)
        return;
    
    if ([actionSheet tag] == 1)
    {
        if (buttonIndex == 1)
            [mRecurrentPaymentContext setType:ScheduleType_DelayedOnce];
        else if (buttonIndex == 2)
            [mRecurrentPaymentContext setType:ScheduleType_Weekly];
        else if (buttonIndex == 3)
            [mRecurrentPaymentContext setType:ScheduleType_Monthly];
        else if (buttonIndex == 4)
            [mRecurrentPaymentContext setType:ScheduleType_Quarterly];
        else if (buttonIndex == 5)
            [mRecurrentPaymentContext setType:ScheduleType_Annual];
        else if (buttonIndex == 6)
            [mRecurrentPaymentContext setType:ScheduleType_ArbitraryDates];
        
        [mRecurrentPaymentContext setMonth:1];
        [mRecurrentPaymentContext setDay:1];
    }
    else if ([actionSheet tag] == 2)
    {
        [mRecurrentPaymentContext setDay:(int)buttonIndex - 1];
    }
    else if ([actionSheet tag] == 3)
    {
        [mRecurrentPaymentContext setMonth:(int)buttonIndex];
    }
    
    [self updateViews];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail)
        [txtPhone becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return TRUE;
}

#pragma mark - UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == viewDayPicker)
        return 32;
    else if (pickerView == viewEndCountPicker)
        return 100;
    else
        return 0;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return pickerView.frame.size.width;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *titleString = @"";
    if (pickerView == viewEndCountPicker)
    {
        titleString = [NSString stringWithFormat:@"%d", (int)row + 1];
    }
    else if (pickerView == viewDayPicker)
    {
        if (row < 31)
            titleString = [NSString stringWithFormat:@"%d", (int)row + 1];
        else
            titleString = @"Последний день";
    }
    return titleString;
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

#pragma mark - PaymentDelegate
-(void)paymentFinished:(TransactionData *)transactionData
{
    if (!transactionData)
        return;
    
    PaymentResult *paymentResult = [[PaymentResult alloc] init];
    [paymentResult setTransactionData:transactionData];
    [self.navigationController pushViewController:paymentResult animated:TRUE];
    [paymentResult release];
}

#pragma mark - Events
-(void)btnCloseClick
{
    [self.navigationController popViewControllerAnimated:FALSE];
}

-(void)btnRepeatClick
{
    [txtEmail resignFirstResponder];
    [txtPhone resignFirstResponder];
    [txtDates resignFirstResponder];
    
    UIActionSheet *repeatMenu = [[UIActionSheet alloc] initWithTitle:@"Периодичность" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:NULL otherButtonTitles:NULL];
    [repeatMenu setTag:1];
    [repeatMenu addButtonWithTitle:@"Только один раз"];
    [repeatMenu addButtonWithTitle:@"Еженедельно"];
    [repeatMenu addButtonWithTitle:@"Каждый месяц"];
    [repeatMenu addButtonWithTitle:@"Ежеквартально"];
    [repeatMenu addButtonWithTitle:@"Каждый год"];
    [repeatMenu addButtonWithTitle:@"В заданые дни"];
    [repeatMenu showInView:self.view];
    [repeatMenu release];
}

-(void)btnWeekDayClick
{
    [txtEmail resignFirstResponder];
    [txtPhone resignFirstResponder];
    [txtDates resignFirstResponder];
    
    UIActionSheet *weekDayMenu = [[UIActionSheet alloc] initWithTitle:@"День недели" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:NULL otherButtonTitles:NULL];
    [weekDayMenu setTag:2];
    for (int i = 0; i < 7; i++)
        [weekDayMenu addButtonWithTitle:[[mDateFormatter standaloneWeekdaySymbols] objectAtIndex:i]];
    [weekDayMenu showInView:self.view];
    [weekDayMenu release];
}

-(void)btnMonthClick
{
    [txtEmail resignFirstResponder];
    [txtPhone resignFirstResponder];
    [txtDates resignFirstResponder];
    
    UIActionSheet *monthMenu = [[UIActionSheet alloc] initWithTitle:@"Месяц" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:NULL otherButtonTitles:NULL];
    [monthMenu setTag:3];
    if (mRecurrentPaymentContext.Type == ScheduleType_Annual)
    {
        for (int i = 0; i < 12; i++)
            [monthMenu addButtonWithTitle:[[mDateFormatter standaloneMonthSymbols] objectAtIndex:i]];
    }
    else if (mRecurrentPaymentContext.Type == ScheduleType_Quarterly)
    {
        for (int i = 0; i < 3; i++)
            [monthMenu addButtonWithTitle:[NSString stringWithFormat:@"%d", i + 1]];
    }
    [monthMenu showInView:self.view];
    [monthMenu release];
}

-(void)btnOkClick
{
    [self updateContext];
    
    Payment *payment = [[Payment alloc] init];
    [payment setPaymentContext:mRecurrentPaymentContext];
    [payment setDelegate:self];
    [self.navigationController pushViewController:payment animated:FALSE];
    [payment release];
}

-(void)segmentedControlAction:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl == sgmEndType)
    {
        [viewEndDatePicker setHidden:sgmEndType.selectedSegmentIndex];
        [viewEndCountPicker setHidden:!sgmEndType.selectedSegmentIndex];
    }
    else if (segmentedControl == sgmStart)
    {
        [viewStartDatePicker setHidden:sgmStart.selectedSegmentIndex];
        [viewStartTimePicker setHidden:!sgmStart.selectedSegmentIndex];
    }
}

#pragma mark - Public methods
-(void)setRecurrentPaymentContext:(RecurrentPaymentContext *)recurrentPaymentContext
{
    if (mRecurrentPaymentContext != recurrentPaymentContext)
    {
        if (mRecurrentPaymentContext)
            [mRecurrentPaymentContext release];
        [recurrentPaymentContext retain];
        mRecurrentPaymentContext = recurrentPaymentContext;
    }
}

#pragma mark - Other methods
-(void)updateViews
{
    [cntStartHeight setConstant:200.0f];
    [cntEndHeight setConstant:200.0f];
    [cntWeekDayHeight setConstant:0.0f];
    [cntMonthHeight setConstant:0.0f];
    [cntDayHeight setConstant:0.0f];
    [cntDaysHeight setConstant:0.0f];
    
    NSString *typeString = @"";
    if (mRecurrentPaymentContext.Type == ScheduleType_Weekly)
    {
        typeString = @"Еженедельно";
        [cntWeekDayHeight setConstant:46.0f];
        [lblWeekDay setText:[[mDateFormatter standaloneWeekdaySymbols] objectAtIndex:mRecurrentPaymentContext.Day]];
    }
    else if (mRecurrentPaymentContext.Type == ScheduleType_Monthly)
    {
        typeString = @"Каждый месяц";
        [cntDayHeight setConstant:200.0f];
    }
    else if (mRecurrentPaymentContext.Type == ScheduleType_Quarterly)
    {
        typeString = @"Ежеквартально";
        [cntDayHeight setConstant:200.0f];
        [cntMonthHeight setConstant:46.0f];
        [lblMonth setText:[NSString stringWithFormat:@"%d", mRecurrentPaymentContext.Month]];
    }
    else if (mRecurrentPaymentContext.Type == ScheduleType_Annual)
    {
        typeString = @"Каждый год";
        [cntDayHeight setConstant:200.0f];
        [cntMonthHeight setConstant:46.0f];
        [lblMonth setText:[[mDateFormatter standaloneMonthSymbols] objectAtIndex:mRecurrentPaymentContext.Month - 1]];
    }
    else if (mRecurrentPaymentContext.Type == ScheduleType_ArbitraryDates)
    {
        typeString = @"В заданые дни";
        [cntEndHeight setConstant:0.0f];
        [cntStartHeight setConstant:0.0f];
        [cntDaysHeight setConstant:73.0f];
    }
    else if (mRecurrentPaymentContext.Type == ScheduleType_DelayedOnce)
    {
        typeString = @"Только один раз";
        [cntEndHeight setConstant:0.0f];
    }
    [lblRepeat setText:typeString];
    
    [self.view layoutIfNeeded];
}

-(void)updateContext
{
    [mRecurrentPaymentContext setReceiptMail:txtEmail.text];
    [mRecurrentPaymentContext setReceiptPhone:txtPhone.text];
    
    [mRecurrentPaymentContext setStartDate:[self dateStringWithDate:[viewStartDatePicker date] Mask:@"yyyy-MM-dd"]];
    [mRecurrentPaymentContext setHour:[[self dateStringWithDate:[viewStartTimePicker date] Mask:@"HH"] intValue]];
    [mRecurrentPaymentContext setMinute:[[self dateStringWithDate:[viewStartTimePicker date] Mask:@"mm"] intValue]];
    
    if (sgmEndType.selectedSegmentIndex)
    {
        [mRecurrentPaymentContext setEndType:ScheduleEndType_Count];
        [mRecurrentPaymentContext setEndCount:(int)[viewEndCountPicker selectedRowInComponent:0] + 1];
        [mRecurrentPaymentContext setEndDate:NULL];
    }
    else
    {
        [mRecurrentPaymentContext setEndType:ScheduleEndType_Date];
        [mRecurrentPaymentContext setEndCount:0];
        [mRecurrentPaymentContext setEndDate:[self dateStringWithDate:[viewEndDatePicker date] Mask:@"yyyy-MM-dd"]];
    }
    
    if (mRecurrentPaymentContext.Type == ScheduleType_Weekly)
    {
    }
    else if (mRecurrentPaymentContext.Type == ScheduleType_Monthly ||
             mRecurrentPaymentContext.Type == ScheduleType_Quarterly ||
             mRecurrentPaymentContext.Type == ScheduleType_Annual)
    {
        [mRecurrentPaymentContext setDay:(int)[viewDayPicker selectedRowInComponent:0] + 1];
    }
    else if (mRecurrentPaymentContext.Type == ScheduleType_ArbitraryDates)
    {
        [mRecurrentPaymentContext setStartDate:NULL];
        [mRecurrentPaymentContext setEndDate:NULL];
        [mRecurrentPaymentContext setEndType:ScheduleEndType_Date];
        
        NSArray *dates = [txtDates.text componentsSeparatedByString:@";"];
        [mRecurrentPaymentContext setDates:dates];
    }
    else if (mRecurrentPaymentContext.Type == ScheduleType_DelayedOnce)
    {
        [mRecurrentPaymentContext setEndDate:NULL];
        [mRecurrentPaymentContext setEndType:ScheduleEndType_Date];
    }
}

-(NSString *)dateStringWithDate:(NSDate *)date Mask:(NSString *)mask
{
    [mDateFormatter setDateFormat:mask];
    return [mDateFormatter stringFromDate:date];
}

@end