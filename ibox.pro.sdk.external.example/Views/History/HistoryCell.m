//
//  HistoryCell.m
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 7/10/15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

-(void)dealloc
{
    [_lblTitle release];
    [_lblAdd release];
    [super dealloc];
}

@end
