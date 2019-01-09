//
//  LDGDocument.m
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import "LDGDocument.h"
#import "LDGFilterSettingsController.h"
#import "LDGLogModel.h"
#import "LDGLogItem.h"
#import "LDGSimpleQuery.h"
#import "LDGFilterController.h"
#import "LDGFilterMatch.h"

static NSString * const kLogTypeName = @"Log File";
static NSString * const kLogCellIdentifier = @"LogCell";
static NSString * const kFilterCellIdentifier = @"FilterCell";

@interface _LDGFilterCell : NSTableCellView
@property (weak) LDGQuery *representedQuery;
@end

@implementation _LDGFilterCell
@end

@interface LDGDocument () <NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate, NSTextDelegate, LDGFilterControllerDelegate>

@property (weak) IBOutlet NSButton *statusView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableView *filterTableView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSLayoutConstraint *searchFieldTrailingConstraint;

@property (strong) LDGLogModel *logModel;
@property (strong) LDGFilterController *filterController;

@property (strong) NSArray<LDGFilterMatch *> *currentMatches;

@end

@implementation LDGDocument {
    NSWindow *_window;
    CGFloat _maxColumnWidth;
    BOOL _viewportAdjustingScheduled;
}

+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName {
    return [typeName isEqualToString:kLogTypeName];
}

- (void)delete:(id)sender {
    if (self.filterTableView == _window.firstResponder) {
        LDGQuery *selectedQuery = self.filterController.queries[self.filterTableView.selectedRow];
        [self.filterController removeFilterQuery:selectedQuery];
        [self.filterTableView reloadData];
        
        [self.filterController triggerFiltering];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.action == @selector(delete:)) {
        if (self.tableView == _window.firstResponder) {
            return self.tableView.selectedRow >= 0;
        }
        if (self.filterTableView == _window.firstResponder) {
            return self.filterTableView.selectedRow >= 0;
        }
    }
    return [super validateMenuItem:menuItem];
}

- (NSString *)windowNibName {
    return @"LDGDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    
    self.filterTableView.target = self;
    self.filterTableView.doubleAction = @selector(showFilterSettings:);
    self.searchField.centersPlaceholder = YES;
    _window = aController.window;
    
    [self _updateProgressIndicator];
    [self _updateStatusView];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!content) {
        return NO;
    }
    
    self.logModel = [[LDGLogModel alloc] initWithString:content];
    self.filterController = [[LDGFilterController alloc] init];
    self.filterController.logModel = self.logModel;
    self.filterController.delegate = self;
    self.filterController.includesUnmatchedItems = YES;
    
    return YES;
}

- (void)showFilterSettings:(id)sender {
    LDGFilterSettingsController *vc = [[LDGFilterSettingsController alloc] initWithNibName:nil bundle:nil];
    vc.query = self.filterController.queries[self.filterTableView.clickedRow];
    vc.completionHandler = ^{
        [self.filterController triggerFiltering];
    };
    NSView *clickedRow = [self.filterTableView rowViewAtRow:self.filterTableView.clickedRow makeIfNecessary:NO];
    
    NSPopover *popover = [[NSPopover alloc] init];
    popover.contentViewController = vc;
    popover.behavior = NSPopoverBehaviorTransient;
    [popover showRelativeToRect:clickedRow.bounds ofView:clickedRow preferredEdge:NSRectEdgeMaxY];
}

- (IBAction)showLineEditor:(id)sender {
    NSText *editor = [_window fieldEditor:YES forObject:nil];
    NSTableCellView *cell = [self.tableView viewAtColumn:0
                                                     row:self.tableView.selectedRow
                                         makeIfNecessary:NO];
    
    [cell addSubview:editor];
    
    editor.string = cell.textField.stringValue;
    editor.font = cell.textField.font;
    editor.frame = cell.textField.frame;
    editor.backgroundColor = [NSColor textBackgroundColor];
    editor.delegate = self;
    
    [_window makeFirstResponder:editor];
    editor.selectedRange = NSMakeRange(0, editor.string.length);
}

- (IBAction)switchShowMatchedItemsOnly:(id)sender {
    self.filterController.includesUnmatchedItems = ((NSButton *) sender).state != NSControlStateValueOn;
    [self.filterController triggerFiltering];
}

- (IBAction)jumpToNextMatch:(id)sender {
    NSUInteger cur = MAX(0, self.tableView.selectedRow) + 1;
    LDGQuery *selectedQuery = nil;
    
    if (self.currentMatches.count == 0 || !self.filterController.hasEffectiveQueries) {
        goto finally;
    }

    // Jump across the selected filter if the filter list is focused.
    if (self.filterTableView == _window.firstResponder && self.filterTableView.selectedRow >= 0) {
        selectedQuery = self.filterController.queries[self.filterTableView.selectedRow];
    }
 
    for (; cur < self.currentMatches.count; cur++) {
        LDGFilterMatch *match = self.currentMatches[cur];
        if (match.query) {
            if (selectedQuery) {
                if (match.query != selectedQuery) {
                    continue;
                }
            }
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:cur] byExtendingSelection:NO];
            [self.tableView scrollRowToVisible:cur];
            return;
        }
    }

finally:
    NSBeep();
}

- (IBAction)switchFilterEnabled:(id)sender {
    _LDGFilterCell *cell = (id) [sender superview];
    cell.representedQuery.enabled = ([sender state] == NSControlStateValueOn);
    [self.filterController triggerFiltering];
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == self.filterTableView) {
        _LDGFilterCell *cell = [tableView makeViewWithIdentifier:kFilterCellIdentifier owner:self];
        cell.representedQuery = self.filterController.queries[row];
        cell.textField.stringValue = cell.representedQuery.displayText;
        return cell;
    }
    
    LDGLogItem *logItem;
    LDGFilterMatch *match;
    if (self.filterController.hasEffectiveQueries) {
        match = self.currentMatches[row];
        logItem = match.item;
    } else {
        logItem = self.logModel.items[row];
    }
    
    NSTableCellView *cell = [tableView makeViewWithIdentifier:kLogCellIdentifier owner:nil];
    NSTextField *textField = cell.textField;
    textField.textColor = [NSColor labelColor];
    textField.alphaValue = 1.0;
    textField.stringValue = logItem.lineText;
    
    if (match.query) {
        if (match.query.textColor) {
            textField.textColor = match.query.textColor;
        }
    } else if (match) {
        // Matches without queries are
        textField.alphaValue = 0.2;
    }
    
    _maxColumnWidth = MAX(_maxColumnWidth, textField.fittingSize.width);
    [self _scheduleViewportAdjusting];
    
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self _updateStatusView];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == self.tableView) {
        if (self.filterController.hasEffectiveQueries) {
            return self.currentMatches.count;
        }
        return self.logModel.items.count;
    } else {
        return self.filterController.queries.count;
    }
}

#pragma mark - NSSearchFieldDelegate

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [self _addSimpleFilter:textView.string];
        textView.string = @"";
        return YES;
    }
    return NO;
}

#pragma mark - NSTextDelegate

- (void)textDidEndEditing:(NSNotification *)notification {
    [[_window fieldEditor:YES forObject:nil] removeFromSuperview];
}

#pragma mark - LDGFilterControllerDelegate

- (void)filterControllerMatchesDidChange:(LDGFilterController *)filterController {
    self.currentMatches = filterController.matches;
    [self.tableView reloadData];
    [self _updateProgressIndicator];
    [self _updateStatusView];
}

#pragma mark - Privates

- (void)_scheduleViewportAdjusting {
    if (_viewportAdjustingScheduled) {
        return;
    }
    
    _viewportAdjustingScheduled = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_viewportAdjustingScheduled = NO;
        self.tableView.tableColumns.firstObject.width = self->_maxColumnWidth;
    }];
}

- (void)_addSimpleFilter:(NSString *)keyword {
    if (keyword.length == 0) {
        return;
    }
    
    LDGSimpleQuery *query = [[LDGSimpleQuery alloc] init];
    query.keyword = keyword;
    [self.filterController addFilterQuery:query];
    [self.filterTableView reloadData];
    
    [self.filterController triggerFiltering];
}

- (void)_updateProgressIndicator {
    CGFloat constraintConstant;
    if (self.filterController.filterInFlight) {
        constraintConstant = 36;
        [self.progressIndicator startAnimation:nil];
    } else {
        constraintConstant = 10;
        [self.progressIndicator stopAnimation:nil];
    }
    
    self.searchFieldTrailingConstraint.constant = constraintConstant;
}

- (void)_updateStatusView {
    NSString *string;
    if (self.tableView.selectedRowIndexes.count > 1) {
        string = [NSString stringWithFormat:@"Selected %ld items, total %ld items",
                  self.tableView.selectedRowIndexes.count,
                  self.tableView.numberOfRows];
    } else if (self.tableView.selectedRow >= 0) {
        string = [NSString stringWithFormat:@"%ld of %ld",
                  (self.tableView.selectedRow + 1),
                  self.tableView.numberOfRows];
    } else {
        string = [NSString stringWithFormat:@"Total %ld items",
                  self.tableView.numberOfRows];
    }
    
    NSAttributedString *attrString =
    [[NSAttributedString alloc]
     initWithString:string
     attributes:@{
                  NSFontAttributeName: self.statusView.font,
                  NSForegroundColorAttributeName: [NSColor textColor]
                  }];
    self.statusView.attributedTitle = attrString;
}

@end
