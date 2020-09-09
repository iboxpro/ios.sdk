//
//  ProductDetailsCell.m
//  ibox.pro.sdk.external.example
//
//  Created by Oleh Piskorskyj on 14/02/2020.
//  Copyright © 2020 DevReactor. All rights reserved.
//

#import "ProductDetailsCell.h"

@implementation ProductDetailsCell

#pragma mark - Ctors/Dtor
+(ProductDetailsCell *)cell
{
    ProductDetailsCell *cell = NULL;
    NSArray *items = [[NSBundle mainBundle] loadNibNamed:@"ProductDetailsCell" owner:self options:NULL];
    for (id item in items)
    {
        if ([item isKindOfClass:[ProductDetailsCell class]])
        {
            cell = item;
            break;
        }
    }
    return cell;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    /*
    mType = DescriptionPaymentCellType_Default;
    mHeight = [CoreUtility deviceType] == AppleDevice_IPAD ? 56.0f : 41.0f;
    
    [viewDivider setBackgroundColor:COLOR_2];
    [lblPhotoTitle setFont:txtMain.font];
    [lblPhotoTitle setTextColor:[txtMain ColorInactive]];
    
    [txtMain setDelegate:self];
    [txtMain addTarget:self action:@selector(textChanged) forControlEvents:UIControlEventEditingChanged];
    [txtMultiline setTopInset:[CoreUtility deviceType] == AppleDevice_IPAD ? 7.0f : 2.0f];
    [txtMultiline setTextChangedAction:^(void *owner) {
        DescriptionPaymentCell *this = (DescriptionPaymentCell *)owner;
        [this textChanged];
    } Owner:self];
    
    [btnPhoto addTarget:self action:@selector(btnPhotoClick) forControlEvents:UIControlEventTouchUpInside];
    [btnRemovePhoto addTarget:self action:@selector(btnRemovePhotoClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self setUserInteractionEnabled:[[AppUtility appDelegate] launchingType] != AppDelegateLaunchingType_URL_SCHEME];
    */
}

-(void)dealloc
{
    [_txtValue release];
    [_lblTitle release];
    [super dealloc];
}

#pragma mark - Public methods
-(DescriptionProductField *)data
{
    return mData;
}

-(void)setData:(DescriptionProductField *)data
{
    if (mData != data)
    {
        if (mData)
            [mData release];
        [data retain];
        mData = data;
        
        [self updateCell];
    }
}

-(void)resignFirstResponder
{
    [_txtValue resignFirstResponder];
}

-(void)becomeFirstResponder
{
    [_txtValue becomeFirstResponder];
}

#pragma mark - Other methods
-(void)updateCell
{
    if (mData)
    {
        [_txtValue setText:[mData defaultValue]];
        [_lblTitle setText:[mData title]];
    }
    else
    {
        [_txtValue setText:NULL];
        [_lblTitle setText:NULL];
    }
}

@end
