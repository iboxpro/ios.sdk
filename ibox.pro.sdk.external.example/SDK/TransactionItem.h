//
//  HistoryItem.h
//  iboxSDK
//
//  Created by Oleg on 19.04.13.
//  Copyright (c) 2013 Devreactor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DescriptionProduct.h"

@interface TransactionItem : NSObject

-(DescriptionProduct *)customFieldsProduct;
-(NSString *)ID;
-(NSString *)date;
-(NSString *)amountFormat;
-(NSString *)amountFormatWithoutCurrency;
-(NSString *)currencySign;
-(NSString *)descriptionOfTransaction;
-(NSString *)cardNumber;
-(NSString *)cardType;
-(NSString *)status;
-(NSString *)invoice;
-(NSString *)signatureURL;
-(NSString *)photoURL;
-(NSString *)scheduleID;
-(NSArray *)products;
-(NSArray *)customFields;
-(double)amount;
-(double)amountNetto;
-(double)feeTotal;
-(double)latitude;
-(double)longitude;
-(BOOL)hasSignature;
-(BOOL)hasPhoto;
-(BOOL)hasGPSData;
-(BOOL)canCancel;
-(BOOL)canReturn;
-(BOOL)withOrder;
-(BOOL)withCustomFields;
-(BOOL)cashPayment;
-(int)productsCount;
-(int)currencyDecimalsCount;
-(int)state;
-(int)subState;
-(int)inputType;

@end