//
//  DRToastManager.h
//  iboxPro
//
//  Created by Axon on 7/30/15.
//  Copyright (c) 2015 Maxim Rudenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRToast;

@interface DRToastManager : NSObject
{
@private DRToast *mToast;
}

+(DRToastManager *)instance;
+(void)destroy;

-(DRToast *)toast;
-(void)setToast:(DRToast *)toast;
-(void)destroyToast:(DRToast *)toast;

@end
