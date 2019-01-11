//
//  LDGLogModel.m
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import "LDGLogModel.h"
#import "LDGLogItem.h"

@interface LDGLogModel ()
@property (readwrite, copy) NSString *fullText;
@property (readwrite, copy) NSArray<LDGLogItem *> *items;
@end

@implementation LDGLogModel

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        _fullText = string;
        [self _parse];
    }
    return self;
}

- (void)_parse {
    NSMutableArray *items = [NSMutableArray array];
    [_fullText enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        LDGLogItem *item = [LDGLogItem new];
        item.lineText = line;
        [items addObject:item];
    }];
    self.items = [items copy];
}

@end
