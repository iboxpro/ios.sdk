//
//  ProductDetailsCell.h
//  ibox.pro.sdk.external.example
//
//  Created by Oleh Piskorskyj on 14/02/2020.
//  Copyright © 2020 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DescriptionProductField.h"

@interface ProductDetailsCell : UITableViewCell
{
@private DescriptionProductField *mData;
}

@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UITextField *txtValue;

+(ProductDetailsCell *)cell;
-(DescriptionProductField *)data;
-(void)setData:(DescriptionProductField *)data;
-(void)resignFirstResponder;
-(void)becomeFirstResponder;


@end
