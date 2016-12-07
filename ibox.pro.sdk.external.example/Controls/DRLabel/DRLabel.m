//
//  DRLabel.m
//  iboxPro
//
//  Created by Oleg on 15.07.13.
//  Copyright (c) 2013 Maxim Rudenko. All rights reserved.
//

#import "DRLabel.h"

@implementation DRLabel

#pragma mark - Ctors/Dctor
-(id)init
{
    self = [super init];
    if (self) [self internalInit];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self internalInit];
    return self;
}

-(void)internalInit
{
}

-(void)dealloc
{
    [super dealloc];
}

#pragma mark - Public methods
-(void)strikethrough
{
    if (![self text] || [[self text] isEqualToString:@""])
        return;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self text]];
    NSDictionary *attributes = @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle), NSStrikethroughColorAttributeName:[self textColor]};
    [attributedString setAttributes:attributes range:(NSRange){0, [attributedString length]}];
    [self setAttributedText:attributedString];
    [attributedString release];
}

-(void)strikethroughWithRange:(NSRange)range
{
    if (![self text] || [[self text] isEqualToString:@""])
        return;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self text]];
    NSDictionary *attributes = @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle), NSStrikethroughColorAttributeName:[self textColor]};
    [attributedString setAttributes:attributes range:range];
    [self setAttributedText:attributedString];
    [attributedString release];
}

@end