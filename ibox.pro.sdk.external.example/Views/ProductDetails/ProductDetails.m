//
//  ProductDetails.m
//  ibox.pro.sdk.external.example
//
//  Created by Oleh Piskorskyj on 13/02/2020.
//  Copyright © 2020 DevReactor. All rights reserved.
//

#import "ProductDetails.h"
#import "Utility.h"
#import "ProductDetailsCell.h"
#import "PaymentController.h"
#import "DRToast.h"

@implementation ProductDetails

@synthesize Products = mProducts;

#pragma mark - Ctor/Dtor
-(ProductDetails *)init
{
    self = [super initWithNibName:@"ProductDetails" bundle:NULL];
    if (self)
    {
        mSelectedProduct = NULL;
    }
    return self;
}

-(void)dealloc
{
    if (mProducts) [mProducts release];
    if (mSelectedProduct) [mSelectedProduct release];
    [btnClose release];
    [btnOk release];
    [btnProductTitle release];
    [txtProductTitle release];
    [TableView release];
    [ctrBtnContainerBottom release];
    [btnPrepare release];
    [lblPreparable release];
    [super dealloc];
}

#pragma mark - View controller life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    [Utility updateTextWithViewController:self];
    
    mCells = [[NSMutableArray alloc] init];
    
    [self updateControls];
    [self initData];
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
    [self tap];
    
    if (mCells && [mCells count])
    {
        NSMutableArray *fieldsData = [[NSMutableArray alloc] init];
        for (ProductDetailsCell *cell in mCells)
        {
            if (![Utility stringIsNullOrEmty:[[cell txtValue] text]])
            {
                DescriptionProductField *field = [cell data];
                
                NSMutableDictionary *fildData = [[NSMutableDictionary alloc] init];
                [fildData setObject:[[cell txtValue] text] forKey:[field code]];
                [fieldsData addObject:fildData];
                [fildData release];
            }
        }
        
        if (mDoneAction)
            mDoneAction(mSelectedProduct, NULL, fieldsData, mActionOwner);
        
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

-(void)btnCloseClick
{
    if (mDoneAction)
        mDoneAction(NULL, NULL, NULL, mActionOwner);
    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void)btnProductTitleClick
{
    UIAlertController *actionSheet = [UIAlertController  alertControllerWithTitle:[Utility localizedStringWithKey:@"initial_product"] message:NULL preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:[Utility localizedStringWithKey:@"common_cancel"] style:UIAlertActionStyleCancel handler:NULL]];
    for (DescriptionProduct *product in mProducts)
    {
        [actionSheet addAction:[UIAlertAction actionWithTitle:[product title] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            int index = (int)[[actionSheet actions] indexOfObject:action] - 1;
            DescriptionProduct *product = NULL;
            if (index < 0)
            {
                if (mProducts && [mProducts count])
                    product = [mProducts firstObject];
            }
            else
                product = [mProducts objectAtIndex:index];
            [self setSelectedProduct:product];
        }]];
    }
    [self presentViewController:actionSheet animated:TRUE completion:NULL];
}

-(void)btnPrepareClick
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator setFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
    [indicator setCenter:self.view.center];
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    [indicator startAnimating];
    
    NSMutableDictionary *fieldsData = [[NSMutableDictionary alloc] init];
    for (ProductDetailsCell *cell in mCells)
    {
        if (![Utility stringIsNullOrEmty:[[cell txtValue] text]])
        {
            DescriptionProductField *field = [cell data];
            [fieldsData setObject:[[cell txtValue] text] forKey:[field code]];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        APIPrepareResult *result = [[PaymentController instance] prepareWithProductCode:[mSelectedProduct code] PrepareData:fieldsData];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            [indicator release];
            
            if (result)
            {
                if ([result valid] && ![result errorCode])
                {
                    NSMutableArray *filteredData = [[NSMutableArray alloc] init];
                    NSMutableArray *preperableData = [result fieldsData];
                    NSString *amountValue = NULL;
                    
                    for (NSDictionary *fieldData in  preperableData)
                    {
                        NSString *code = [[fieldData allKeys] firstObject];
                        
                        if ([[code uppercaseString] isEqualToString:@"AMOUNT"])
                            amountValue = [[fieldData allValues] firstObject];
                        else
                        {
                            NSArray *fields = [mSelectedProduct fields];
                            for (DescriptionProductField *field in fields)
                            {
                                if ([code isEqualToString:[field code]])
                                {
                                    [filteredData addObject:fieldData];
                                    break;
                                }
                            }
                            [fields release];
                        }
                    }
                    
                    if ([filteredData count] < 1)
                        [filteredData release];
                    else
                    {
                        if (mDoneAction)
                            mDoneAction(mSelectedProduct, amountValue, filteredData, mActionOwner);
                        
                        [self.navigationController popViewControllerAnimated:TRUE];
                    }
                    
                    [preperableData release];
                }
                else
                    [[[DRToast alloc] initWithMessage:[result errorMessage]] show];

                [result release];
            }
        });
    });
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    float bottomMargin = 260.0f;
    [ctrBtnContainerBottom setConstant:bottomMargin];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:NULL];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [ctrBtnContainerBottom setConstant:0.0f];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:NULL];
}

-(void)tap
{
    for (ProductDetailsCell *cell in mCells)
        [cell resignFirstResponder];
}

#pragma mark - Table view source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mCells count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [mCells objectAtIndex:indexPath.row];
}

#pragma mark - Public methods
-(void)setDoneAction:(void (^)(DescriptionProduct *, NSString *, NSArray *, void *))action Owner:(void *)owner
{
    mActionOwner = owner;
    mDoneAction = action;
}

#pragma mark - Other methods
-(void)updateControls
{
    [TableView setDataSource:self];
    
    [btnOk addTarget:self action:@selector(btnOkClick) forControlEvents:UIControlEventTouchUpInside];
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [btnProductTitle addTarget:self action:@selector(btnProductTitleClick) forControlEvents:UIControlEventTouchUpInside];
    [btnPrepare addTarget:self action:@selector(btnPrepareClick) forControlEvents:UIControlEventTouchUpInside];
    
    mTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [mTapGestureRecognizer setNumberOfTapsRequired:1];
    [mTapGestureRecognizer setNumberOfTouchesRequired:1];
}

-(void)initData
{
    DescriptionProduct *product = [mProducts firstObject];
    [self setSelectedProduct:product];
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

-(void)setSelectedProduct:(DescriptionProduct *)product
{
    if (mSelectedProduct != product)
    {
        if (mSelectedProduct)
            [mSelectedProduct release];
        [product retain];
        mSelectedProduct = product;
        
        [txtProductTitle setText:NULL];
        [lblPreparable setHidden:TRUE];
        [btnPrepare setHidden:TRUE];
        [mCells removeAllObjects];
        
        if (product)
        {
            [txtProductTitle setText:[product title]];
            
            NSArray *fields = NULL;
            if (![product preparable])
                fields = [mSelectedProduct fields];
            else
            {
                fields = [mSelectedProduct preparableFields];
                [lblPreparable setHidden:FALSE];
                [btnPrepare setHidden:FALSE];
            }
            
            for (int i = 0; i < [fields count]; i++)
            {
                DescriptionProductField *field = [fields objectAtIndex:i];
                ProductDetailsCell *cell = [ProductDetailsCell cell];
                [cell setData:field];
                [mCells addObject:cell];
            }
            
            [fields release];
        }
        
        [TableView reloadData];
    }
}

@end
