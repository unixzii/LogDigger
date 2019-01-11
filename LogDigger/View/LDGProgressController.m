//
//  LDGProgressController.m
//  LogDigger
//
//  Created by Hongyu on 2019/1/11.
//  Copyright © 2019 Cyandev. All rights reserved.
//

#import "LDGProgressController.h"

@interface LDGProgressController ()
@property (weak) IBOutlet NSTextField *labelTextField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@end

@implementation LDGProgressController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.title = self.title;
    self.labelTextField.stringValue = self.informativeText;
    [self.progressIndicator startAnimation:nil];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    if (self.windowLoaded) {
        self.window.title = title;
    }
}

- (void)setInformativeText:(NSString *)informativeText {
    _informativeText = informativeText;
    
    if (self.windowLoaded) {
        self.labelTextField.stringValue = informativeText;
    }
}

@end
