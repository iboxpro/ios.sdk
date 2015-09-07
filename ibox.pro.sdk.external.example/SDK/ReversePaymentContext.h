//
//  ReversePaymentContext.h
//  ibox.pro.sdk.external
//
//  Created by Axon on 9/2/15.
//  Copyright (c) 2015 ibox. All rights reserved.
//

#import "PaymentContext.h"

typedef enum
{
    ReverseMode_Cancel,
    ReverseMode_Return
} ReverseMode;

@interface ReversePaymentContext : PaymentContext

@property (nonatomic, retain) NSString *TransactionID;
@property (nonatomic, assign) ReverseMode ReverseType;

@end

