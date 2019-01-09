//
//  LDGQuery.h
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class LDGLogItem;

@interface LDGQuery : NSObject

@property (assign) BOOL enabled;

/* Styles applied to the matched items. */
@property (copy) NSColor *textColor;
@property (copy) NSColor *backgroundColor;

/* Display text shown in the inspector pane. */
@property (readonly) NSString *displayText;

- (BOOL)isItemMatched:(LDGLogItem *)item;

@end

NS_ASSUME_NONNULL_END
