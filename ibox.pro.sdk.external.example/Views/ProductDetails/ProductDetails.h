//
//  ProductDetails.h
//  ibox.pro.sdk.external.example
//
//  Created by Oleh Piskorskyj on 13/02/2020.
//  Copyright © 2020 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DescriptionProduct;

@interface ProductDetails : UIViewController<UITableViewDataSource>
{
IBOutlet UIButton *btnClose;
IBOutlet UIButton *btnOk;
IBOutlet UIButton *btnProductTitle;
IBOutlet UIButton *btnPrepare;
IBOutlet UITextField *txtProductTitle;
IBOutlet UITableView *TableView;
IBOutlet UILabel *lblPreparable;
IBOutlet NSLayoutConstraint *ctrBtnContainerBottom;
    
@private DescriptionProduct *mSelectedProduct;
@private NSMutableArray *mCells;
@private UITapGestureRecognizer *mTapGestureRecognizer;
@private void (^mDoneAction)(DescriptionProduct *, NSString *, NSArray *, void *);
@private void *mActionOwner;
}

@property (retain, nonatomic) NSArray *Products;

-(ProductDetails *)init;
-(void)setDoneAction:(void (^)(DescriptionProduct *, NSString *, NSArray *, void *))action Owner:(void *)owner;

@end
