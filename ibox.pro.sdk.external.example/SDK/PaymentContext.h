//
//  PaymentContext.h
//  ibox.pro.sdk.external
//
//  Created by Axon on 5/12/15.
//  Copyright (c) 2015 ibox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentContext : NSObject

@property (nonatomic, assign) double Amount;
@property (nonatomic, retain) NSString *Description;
@property (nonatomic, retain) NSData *Image;
@property (nonatomic, retain) NSString *ReceiptMail;
@property (nonatomic, retain) NSString *ReceiptPhone;
@property (nonatomic, retain) NSString *ProductCode;
@property (nonatomic, retain) NSArray *ProductData;

@end
