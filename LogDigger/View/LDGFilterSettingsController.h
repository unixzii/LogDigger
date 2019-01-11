//
//  LDGFilterSettingsController.h
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class LDGQuery;

@interface LDGFilterSettingsController : NSViewController

@property (weak) LDGQuery *query;
@property (copy) void(^completionHandler)(void);

@end

NS_ASSUME_NONNULL_END
