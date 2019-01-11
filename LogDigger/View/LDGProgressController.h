//
//  LDGProgressController.h
//  LogDigger
//
//  Created by Hongyu on 2019/1/11.
//  Copyright © 2019 Cyandev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDGProgressController : NSWindowController

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *informativeText;

@end

NS_ASSUME_NONNULL_END
