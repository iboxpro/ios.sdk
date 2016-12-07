//
//  HistoryItem.h
//  iboxSDK
//
//  Created by Oleg on 19.04.13.
//  Copyright (c) 2013 Devreactor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DescriptionProduct.h"

typedef enum
{
    TransactionInputType_Swipe = 2,
    TransactionInputType_Chip = 3,
    TransactionInputType_Prepaid = 8,
    TransactionInputType_Cash = 10
} TransactionInputType;

typedef enum
{
    TransactionItemReverseMode_None,
    TransactionItemReverseMode_Return,
    TransactionItemReverseMode_ReturnPartial,
    TransactionItemReverseMode_Cancel,
    TransactionItemReverseMode_CancelPartial,
} TransactionItemReverseMode;

typedef enum
{
    TransactionItemDisplayMode_Declined = 0,
    TransactionItemDisplayMode_Success = 1,
    TransactionItemDisplayMode_Reverse = 2,
    TransactionItemDisplayMode_Reversed = 3
} TransactionItemDisplayMode;

@interface TransactionItem : NSObject

-(DescriptionProduct *)customFieldsProduct;
-(TransactionInputType)inputType;
-(TransactionItemReverseMode)reverseMode;
-(TransactionItemDisplayMode)displayMode;
-(NSString *)ID;
-(NSString *)date;
-(NSString *)currencyID;
-(NSString *)amountFormat;
-(NSString *)amountFormatWithoutCurrency;
-(NSString *)currencySign;
-(NSString *)descriptionOfTransaction;
-(NSString *)cardNumber;
-(NSString *)cardType;
-(NSString *)status;
-(NSString *)stateLine1;
-(NSString *)stateLine2;
-(NSString *)invoice;
-(NSString *)signatureURL;
-(NSString *)photoURL;
-(NSString *)scheduleID;
-(NSArray *)products;
-(NSArray *)customFields;
-(double)amount;
-(double)amountNetto;
-(double)amountEff;
-(double)feeTotal;
-(double)latitude;
-(double)longitude;
-(BOOL)hasSignature;
-(BOOL)hasPhoto;
-(BOOL)hasGPSData;
-(BOOL)withOrder;
-(BOOL)withCustomFields;
-(BOOL)cashPayment;
-(int)productsCount;
-(int)currencyDecimalsCount;
-(int)state;
-(int)subState;

@end