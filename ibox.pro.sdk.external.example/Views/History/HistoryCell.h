//
//  HistoryCell.h
//  ibox.pro.sdk.external.example
//
//  Created by Axon on 7/10/15.
//  Copyright (c) 2015 DevReactor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRLabel.h"

@interface HistoryCell : UITableViewCell

@property (retain, nonatomic) IBOutlet DRLabel *lblTitle;
@property (retain, nonatomic) IBOutlet DRLabel *lblAdd;

@end
