//
//  LDGFilterOperation.h
//  LogDigger
//
//  Created by Hongyu on 2019/1/13.
//  Copyright © 2019 Cyandev. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <vector>

#include "LDGFilterWorkItem.h"

NS_ASSUME_NONNULL_BEGIN

@class LDGQuery;

/**
 A work unit of the whole filter work.
 */
@interface LDGFilterOperation : NSOperation

@property (assign) std::vector<logdigger::filter_work_item> *workItems;
@property (assign) NSRange iterationRange;
@property (strong) NSArray<LDGQuery *> *queries;

@end

NS_ASSUME_NONNULL_END
