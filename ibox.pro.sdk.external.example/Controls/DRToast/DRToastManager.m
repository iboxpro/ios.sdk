//
//  DRToastManager.m
//  iboxPro
//
//  Created by Axon on 7/30/15.
//  Copyright (c) 2015 Maxim Rudenko. All rights reserved.
//

#import "DRToastManager.h"

@implementation DRToastManager

#pragma mark - Singleton
static DRToastManager *sharedSingleton;
+(DRToastManager *)instance
{
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[DRToastManager alloc] init];
        
        return sharedSingleton;
    }
}

+(void)destroy
{
    if (sharedSingleton)
    {
        [sharedSingleton release];
        sharedSingleton = NULL;
    }
}

-(id)init
{
    self = [super init];
    return self;
}

-(void)dealloc
{
    if (mToast) [mToast release];
    [super dealloc];
}

#pragma mark - Public methods
-(DRToast *)toast
{
    return mToast;
}

-(void)setToast:(DRToast *)toast
{
    if (toast != mToast)
    {
        if (mToast)
            [mToast release];
        [toast retain];
        mToast = toast;
    }
}

-(void)destroyToast:(DRToast *)toast
{
    [toast release];
}

#pragma mark - Other methods


@end
