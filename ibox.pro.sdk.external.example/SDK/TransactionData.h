//
//  TransactionData.h
//  ibox.pro.sdk.external.example
//
//  Created by AxonMacMini on 17.02.15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionItem.h"

typedef enum
{
    TransactionDataType_Payment,
    TransactionDataType_Schedule,
    TransactionDataType_Reverse
} TransactionDataType;

@interface TransactionData : NSObject

@property (nonatomic, assign) TransactionDataType Type;
@property (nonatomic, assign) double Amount;
@property (nonatomic, assign) BOOL RequiredSignature;
@property (nonatomic, retain) NSString *ID;
@property (nonatomic, retain) NSString *Invoice;
@property (nonatomic, retain) NSString *CardNumber;
@property (nonatomic, retain) TransactionItem *Transaction;

@end
