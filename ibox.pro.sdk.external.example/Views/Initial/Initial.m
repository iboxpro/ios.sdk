//
//  Login.m
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 02.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "Initial.h"
#import "Utility.h"
#import "Consts.h"
#import "PaymentController.h"
#import "Payment.h"
#import "Schedule.h"
#import "ProductDetails.h"
#import "AdditionalData.h"
#import "PaymentResult.h"
#import "History.h"
#import "ReaderScanner.h"
#import "PaymentContext.h"
#import "LinkPayment.h"
#import "DRToast.h"

@implementation Initial

@synthesize SelectedProduct = mSelectedProduct;
@synthesize ProductData = mProductData;
@synthesize Products = mProducts;

#pragma mark - Ctor/Dtor
-(Initial *)init
{
    self = [super initWithNibName:@"Initial" bundle:NULL];
    if (self)
    {
        mEmail = NULL;
        mPassword = NULL;
        mLoginAlert = NULL;
        [self setSelectedProduct:NULL];
        [self setProductData:NULL];
        [self setProducts:NULL];
    }
    return self;
}

-(void)dealloc
{
    if (mEmail) [mEmail release];
    if (mPassword) [mPassword release];
    if (mSelectedProduct) [mSelectedProduct release];
    if (mProductData) [mProductData release];
    if (mProducts) [mProducts release];
    [txtAmount release];
    [txtDescription release];
    [txtPayType release];
    [btnPayType release];
    [btnOk release];
    [btnForgetBTReader release];
    [ctrDescriptionHeight release];
    [ctrFieldsHeight release];
    [sgmProduct release];
    [btnHistory release];
    [viewActivity release];
    [ctrPayTypeHeight release];
    [ctrScrollBottom release];
    [viewProductContainer release];
    [txtProductTitle release];
    [lblProductData release];
    [btnProductEdit release];
    [txtExtId release];
    [txtAuxData release];
    [swcSingleStep release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    NSLog(@"SDK version: %@", [[PaymentController instance] version]);
    
    [super viewDidLoad];
    [self updateControls];
    [self showLoginAlert];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self enableKeyboardObservers];
    [self.view addGestureRecognizer:mTapGestureRecognizer];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.view removeGestureRecognizer:mTapGestureRecognizer];
    [self disableKeyboardObservers];
    [super viewWillDisappear:animated];
}

#pragma mark - Events
-(void)btnOkClick
{
    Account *account = [[Utility appDelegate] account];
    if (![Utility stringIsNullOrEmty:mPassword] &&
        ![Utility stringIsNullOrEmty:mEmail] && account)
    {
        [txtDescription resignFirstResponder];
        [txtPayType resignFirstResponder];
        [txtAmount resignFirstResponder];
        [txtAuxData resignFirstResponder];
        
        UIAlertController *actionSheet = [UIAlertController  alertControllerWithTitle:[Utility localizedStringWithKey:@"initial_payment"] message:NULL preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:TRUE completion:NULL];
        }]];
        NSArray *paymentOptions = [account paymentOptions];
        for (PaymentOption *paymentOption in paymentOptions)
        {
            NSMutableString *cellTitle = [[NSMutableString alloc] init];
            if ([paymentOption inputType] == TransactionInputType_SWIPE ||
                [paymentOption inputType] == TransactionInputType_EMV ||
                [paymentOption inputType] == TransactionInputType_NFC)
            {
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_card"]];
            }
            else if ([paymentOption inputType] == TransactionInputType_CASH)
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_cash"]];
            else if ([paymentOption inputType] == TransactionInputType_PREPAID)
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_prepaid"]];
            else if ([paymentOption inputType] == TransactionInputType_CREDIT)
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_credit"]];
            else if ([paymentOption inputType] == TransactionInputType_LINK)
                [cellTitle appendString:[Utility localizedStringWithKey:@"initial_payment_type_link"]];
            
            if ([paymentOption acquirer])
                [cellTitle appendFormat:@" - %@", [[paymentOption acquirer] name]];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:cellTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                int index = (int)[[actionSheet actions] indexOfObject:action] - 1;
                PaymentOption *paymentOption = [paymentOptions objectAtIndex:index];
                
                PaymentContext *paymentContext = [[PaymentContext alloc] init];
                [self updatePaymentContext:paymentContext];
                
                if ([paymentOption inputType] == TransactionInputType_SWIPE ||
                    [paymentOption inputType] == TransactionInputType_EMV ||
                    [paymentOption inputType] == TransactionInputType_NFC)
                {
                    [paymentContext setInputType:TransactionInputType_NFC];
                }
                else if ([paymentOption inputType] == TransactionInputType_CASH)
                {
                    [paymentContext setAmountCash:[paymentContext Amount]];
                    [paymentContext setInputType:TransactionInputType_CASH];
                }
                else
                {
                    [paymentContext setInputType:[paymentOption inputType]];
                }
                
                if ([paymentOption acquirer])
                    [paymentContext setAcquirer:[[paymentOption acquirer] code]];
                
                Payment *payment = [[Payment alloc] init];
                [payment setPaymentContext:paymentContext];
                [payment setDelegate:self];
                [self.navigationController pushViewController:payment animated:FALSE];
                [paymentContext release];
                [payment release];
            }]];
            
            [cellTitle release];
        }
        [paymentOptions release];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"initial_payment_type_recurrent"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            RecurrentPaymentContext *recurrentPaymentContext = [[RecurrentPaymentContext alloc] init];
            [self updatePaymentContext:recurrentPaymentContext];
            
            Schedule *schedule = [[Schedule alloc] init];
            [schedule setRecurrentPaymentContext:recurrentPaymentContext];
            [self.navigationController pushViewController:schedule animated:FALSE];
            [recurrentPaymentContext release];
            [schedule release];
        }]];
        
        [self presentViewController:actionSheet animated:TRUE completion:NULL];
    }
    else
        [self showLoginAlert];
}

-(void)btnProductEditClick
{
    ProductDetails *productDetails = [[ProductDetails alloc] init];
    [productDetails setProducts:mProducts];
    [productDetails setDoneAction:^(DescriptionProduct *product, NSString *amount, NSArray *productData, void *owner) {
        Initial *this = (Initial *)owner;
        if (product && productData)
        {
            if (![Utility stringIsNullOrEmty:amount])
                [this->txtAmount setText:amount];
            
            [this setSelectedProduct:product];
            [this setProductData:productData];
            
            NSError *error = NULL;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:productData options:0 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if (!error && ![Utility stringIsNullOrEmty:jsonString])
            {
                [this->lblProductData setText:jsonString];
                [this.view layoutIfNeeded];
            }
        }
    } Owner:self];
    [self.navigationController pushViewController:productDetails animated:TRUE];
    [productDetails release];
}

-(void)btnPayTypeClick
{
    [txtDescription resignFirstResponder];
    [txtPayType resignFirstResponder];
    [txtAmount resignFirstResponder];
    
    NSArray *supportReaders = [[PaymentController instance] supportedReaders];
    if ((int)[supportReaders count] == 1)
    {
        PaymentControllerReaderType readerType = [(NSNumber *)[supportReaders firstObject] intValue];
        if (readerType == PaymentControllerReaderType_C15)
        {
            [[PaymentController instance] setReaderType:PaymentControllerReaderType_C15];
            [txtPayType setText:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"]];
        }
        else if (readerType == PaymentControllerReaderType_P15)
        {
            ReaderScanner *readerScanner = [[ReaderScanner alloc] init];
            [readerScanner setReaderType:PaymentControllerReaderType_P15];
            [readerScanner setReaderTypeLocalized:[Utility localizedStringWithKey:@"initial_reader_type_chippin"]];
            [readerScanner setDelegate:self];
            [self.navigationController pushViewController:readerScanner animated:TRUE];
            [readerScanner release];
        }
        else if (readerType == PaymentControllerReaderType_P17)
        {
            ReaderScanner *readerScanner = [[ReaderScanner alloc] init];
            [readerScanner setReaderType:PaymentControllerReaderType_P17];
            [readerScanner setReaderTypeLocalized:[Utility localizedStringWithKey:@"initial_reader_type_qposmini"]];
            [readerScanner setDelegate:self];
            [self.navigationController pushViewController:readerScanner animated:TRUE];
            [readerScanner release];
        }
    }
    else
    {
        UIAlertController *actionSheet = [UIAlertController  alertControllerWithTitle:[Utility localizedStringWithKey:@"initial_select_reader_type"] message:NULL preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_cancel"] style:UIAlertActionStyleCancel handler:NULL]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[PaymentController instance] setReaderType:PaymentControllerReaderType_C15];
            [txtPayType setText:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"]];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"initial_reader_type_chippin"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ReaderScanner *readerScanner = [[ReaderScanner alloc] init];
            [readerScanner setReaderType:PaymentControllerReaderType_P15];
            [readerScanner setReaderTypeLocalized:[Utility localizedStringWithKey:@"initial_reader_type_chippin"]];
            [readerScanner setDelegate:self];
            [self.navigationController pushViewController:readerScanner animated:TRUE];
            [readerScanner release];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"initial_reader_type_qposmini"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ReaderScanner *readerScanner = [[ReaderScanner alloc] init];
            [readerScanner setReaderType:PaymentControllerReaderType_P17];
            [readerScanner setReaderTypeLocalized:[Utility localizedStringWithKey:@"initial_reader_type_qposmini"]];
            [readerScanner setDelegate:self];
            [self.navigationController pushViewController:readerScanner animated:TRUE];
            [readerScanner release];
        }]];
        [self presentViewController:actionSheet animated:TRUE completion:NULL];
    }
    [supportReaders release];
}

-(void)btnHistoryClick
{
    if (![Utility stringIsNullOrEmty:mPassword] &&
        ![Utility stringIsNullOrEmty:mEmail])
    {
        History *history = [[History alloc] init];
        [self.navigationController pushViewController:history animated:TRUE];
        [history release];
    }
    else
        [self showLoginAlert];
}

-(void)btnForgetBTReaderClick
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:CONSTS_KEY_BT_READER];
    [prefs synchronize];
}

-(void)segmentedControlAction:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl == sgmProduct)
    {
        [self setSelectedProduct:NULL];
        [self setProductData:NULL];
        
        if (![sgmProduct selectedSegmentIndex])
        {
            [ctrDescriptionHeight setConstant:30.0f];
            [lblProductData setText:[Utility localizedStringWithKey:@"initial_product_no_data"]];
            [ctrFieldsHeight setConstant:0.0f];
        }
        else if ([sgmProduct selectedSegmentIndex] == 1)
        {
            [ctrDescriptionHeight setConstant:0.0f];
            
            if (mProducts && [mProducts count])
            {
                DescriptionProduct *product = [mProducts firstObject];
                [txtProductTitle setText:[product title]];
                [ctrFieldsHeight setConstant:6666.0f];
            }
        }
    }
    
    [self.view layoutIfNeeded];
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    float bottomMargin = [Utility keyboardHeightWithNotification:notification];
    [ctrScrollBottom setConstant:bottomMargin];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:NULL];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [ctrScrollBottom setConstant:0.0f];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:NULL];
}

-(void)tap
{
    [txtAmount resignFirstResponder];
    [txtDescription resignFirstResponder];
    [txtAuxData resignFirstResponder];
    [txtExtId resignFirstResponder];
}

#pragma mark - ReaderScannerDelegate
-(void)ReaderScannerDelegateSelectedReader:(BTDevice *)reader ReaderType:(PaymentControllerReaderType)readerType ReaderTypeLocalized:(NSString *)readerTypeLocalized
{
    if (reader)
    {
        [[PaymentController instance] setReaderType:readerType];
        [txtPayType setText:readerTypeLocalized];
    }
}

#pragma mark - PaymentDelegate
-(void)paymentFinished:(TransactionData *)transactionData readerInfo:(NSDictionary *)info
{
    
    if (!transactionData)
        return;
    
    if ([[transactionData Transaction] inputType] == TransactionInputType_LINK)
    {
        LinkPayment *linkPayment = [[LinkPayment alloc] init];
        [linkPayment setTransactionData:transactionData];
        [self.navigationController pushViewController:linkPayment animated:TRUE];
        [linkPayment release];
    }
    else
    {
        if ([transactionData RequiredSignature])
        {
            AdditionalData *additionalData = [[AdditionalData alloc] init];
            [additionalData setTransactionData:transactionData];
            [additionalData setReaderInfo:info];
            [self.navigationController pushViewController:additionalData animated:TRUE];
            [additionalData release];
        }
        else
        {
            PaymentResult *paymentResult = [[PaymentResult alloc] init];
            [paymentResult setTransactionData:transactionData];
            [paymentResult setReaderInfo:info];
            [self.navigationController pushViewController:paymentResult animated:TRUE];
            [paymentResult release];
        }
    }
}

#pragma mark - Other methods
-(void)updateControls
{
    [Utility updateTextWithViewController:self];
    [viewActivity setHidden:TRUE];
    [txtAmount setText:@"100"];
    [txtDescription setText:@"Test payment"];
    
    NSArray *supportReaders = [[PaymentController instance] supportedReaders];
    if ((int)[supportReaders count] == 1)
    {
        PaymentControllerReaderType readerType = [(NSNumber *)[supportReaders firstObject] intValue];
        [[PaymentController instance] setReaderType:readerType];
        
        if (readerType == PaymentControllerReaderType_C15)
            [txtPayType setText:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"]];
        else if (readerType == PaymentControllerReaderType_P15)
            [txtPayType setText:[Utility localizedStringWithKey:@"initial_reader_type_chippin"]];
        else if (readerType == PaymentControllerReaderType_P17)
            [txtPayType setText:[Utility localizedStringWithKey:@"initial_reader_type_qposmini"]];
    }
    else
    {
        [[PaymentController instance] setReaderType:PaymentControllerReaderType_C15];
        [txtPayType setText:[Utility localizedStringWithKey:@"initial_reader_type_chipsign"]];
    }
    [supportReaders release];
    
    [[PaymentController instance] setRequestTimeout:30];
    [[PaymentController instance] setClientProductCode:@"_2CAN_REGISTER"];
    
    [sgmProduct setAlpha:0.0f];
    [sgmProduct addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    [ctrFieldsHeight setConstant:0.0f];
    
    [btnOk addTarget:self action:@selector(btnOkClick) forControlEvents:UIControlEventTouchUpInside];
    [btnProductEdit addTarget:self action:@selector(btnProductEditClick) forControlEvents:UIControlEventTouchUpInside];
    [btnPayType addTarget:self action:@selector(btnPayTypeClick) forControlEvents:UIControlEventTouchUpInside];
    [btnForgetBTReader addTarget:self action:@selector(btnForgetBTReaderClick) forControlEvents:UIControlEventTouchUpInside];
    [btnHistory addTarget:self action:@selector(btnHistoryClick) forControlEvents:UIControlEventTouchUpInside];
    
    mTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [mTapGestureRecognizer setNumberOfTapsRequired:1];
    [mTapGestureRecognizer setNumberOfTouchesRequired:1];
}

-(void)showLoginAlert
{
    mLoginAlert = [UIAlertController  alertControllerWithTitle:[Utility localizedStringWithKey:@"initial_authorization"] message:NULL preferredStyle:UIAlertControllerStyleAlert];
    [mLoginAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:@"Email"];
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    }];
    [mLoginAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setPlaceholder:@"Password"];
        [textField setSecureTextEntry:TRUE];
    }];
        
    [mLoginAlert addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_cancel"] style:UIAlertActionStyleCancel handler:NULL]];
    [mLoginAlert addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![viewActivity isHidden])
            return;
        
        [viewActivity setHidden:FALSE];
        [viewActivity startAnimating];
        
        NSString *email = [[[mLoginAlert textFields] objectAtIndex:0] text];
        NSString *password = [[[mLoginAlert textFields] objectAtIndex:1] text];
        
        [self setEmail:email];
        [self setPassword:password];
        
        [[PaymentController instance] setEmail:email Password:password];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            APIAuthenticationResult *result = [[PaymentController instance] authentication];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [viewActivity setHidden:TRUE];
                [viewActivity stopAnimating];
                
                if (result)
                {
                    if ([result valid] && ![result errorCode])
                    {
                        Account *account = [result account];
                        [[Utility appDelegate] setAccount:account];
                        [account release];
                        
                        [sgmProduct setSelectedSegmentIndex:0];
                        NSArray *products = [result products];
                        if (products && [products count])
                        {
                            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                [sgmProduct setAlpha:1.0f];
                            } completion:NULL];
                            [self setProducts:products];
                        }
                        else
                        {
                            [sgmProduct setSelectedSegmentIndex:0];
                            [sgmProduct setAlpha:0.0f];
                            [self setProducts:NULL];
                        }
                        
                        [products release];
                    }
                    else
                    {
                        [[[DRToast alloc] initWithMessage:[result errorMessage]] show];
                        
                        [self setEmail:NULL];
                        [self setPassword:NULL];
                    }
                    
                    [result release];
                }
            });
        });
    }]];
    [self presentViewController:mLoginAlert animated:TRUE completion:NULL];
}

-(void)updatePaymentContext:(PaymentContext *)paymentContext
{
    if (!paymentContext)
        return;
    
    [[PaymentController instance] setSingleStepAuthentication:[swcSingleStep isOn]];
    
    double amount = 0.0;
    NSString *amountString = [txtAmount text];
    amountString = [Utility stringWithDotComaDigitsOnly:amountString];
    if (![Utility stringIsNullOrEmty:amountString])
    {
        amountString = [amountString stringByReplacingOccurrencesOfString:@"," withString:@"."];
        amount = [amountString doubleValue];
    }
    
    [paymentContext setCurrency:CurrencyType_RUB];
    [paymentContext setAmount:amount];
    [paymentContext setExtID:[txtExtId text]];
    
    if (![sgmProduct selectedSegmentIndex])
        [paymentContext setDescription:[txtDescription text]];
    else if ([sgmProduct selectedSegmentIndex] == 1)
    {        
        [paymentContext setProductCode:[mSelectedProduct code]];
        [paymentContext setProductData:mProductData];
    }
    
    NSString *auxData = [txtAuxData text];
    if (![Utility stringIsNullOrEmty:auxData])
        [paymentContext setAuxData:auxData];
    
    [paymentContext setReceiptMail:@""];
    [paymentContext setReceiptPhone:@""];
}

-(void)enableKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:NULL];
}

-(void)disableKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setEmail:(NSString *)email
{
    if (mEmail != email)
    {
        if (mEmail)
            [mEmail release];
        [email retain];
        mEmail = email;
    }
}

-(void)setPassword:(NSString *)password
{
    if (mPassword != password)
    {
        if (mPassword)
            [mPassword release];
        [password retain];
        mPassword = password;
    }
}

@end
