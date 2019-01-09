//
//  LDGFilterSettingsController.m
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import "LDGFilterSettingsController.h"
#import "../Core/LDGQuery.h"

@interface _LDGFilterSettingsPresetColor : NSObject

@property (copy) NSString *title;
@property (copy) NSColor *color;

+ (instancetype)presetColor:(NSColor *)color withTitle:(NSString *)title;

@end

@implementation _LDGFilterSettingsPresetColor

+ (instancetype)presetColor:(NSColor *)color withTitle:(NSString *)title {
    _LDGFilterSettingsPresetColor *instance = [[self alloc] init];
    instance.color = color;
    instance.title = title;
    return instance;
}

@end

static NSArray<_LDGFilterSettingsPresetColor *> *presets;

@interface LDGFilterSettingsController ()
@property (weak) IBOutlet NSPopUpButton *textColorPopUpButton;
@property (weak) IBOutlet NSPopUpButton *backgroundPopUpButton;
@end

@implementation LDGFilterSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupCommonColorsForButton:self.textColorPopUpButton withCurrentColor:self.query.textColor];
    [self _setupCommonColorsForButton:self.backgroundPopUpButton withCurrentColor:self.query.backgroundColor];
}

- (void)_setupCommonColorsForButton:(NSPopUpButton *)button withCurrentColor:(NSColor *)color {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        presets = @[
                    [_LDGFilterSettingsPresetColor presetColor:[NSColor systemRedColor] withTitle:@"Red"],
                    [_LDGFilterSettingsPresetColor presetColor:[NSColor systemBlueColor] withTitle:@"Blue"],
                    [_LDGFilterSettingsPresetColor presetColor:[NSColor systemPinkColor] withTitle:@"Pink"],
                    [_LDGFilterSettingsPresetColor presetColor:[NSColor systemGreenColor] withTitle:@"Green"],
                    [_LDGFilterSettingsPresetColor presetColor:[NSColor systemYellowColor] withTitle:@"Yellow"],
                    [_LDGFilterSettingsPresetColor presetColor:[NSColor systemOrangeColor] withTitle:@"Orange"],
                    [_LDGFilterSettingsPresetColor presetColor:[NSColor systemPurpleColor] withTitle:@"Purple"]
                    ];
    });
    
    NSMenu *menu = [[NSMenu alloc] init];
    
    // Initially for the default item.
    __block NSMenuItem *selectedItem = [[NSMenuItem alloc] initWithTitle:@"Default" action:nil keyEquivalent:@""];
    [menu addItem:selectedItem];
    [menu addItem:[NSMenuItem separatorItem]];
    [presets enumerateObjectsUsingBlock:^(_LDGFilterSettingsPresetColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:obj.title action:nil keyEquivalent:@""];
        if ([obj.color isEqualTo:color]) {
            selectedItem = item;
        }
        [menu addItem:item];
    }];
    button.menu = menu;
    [button selectItem:selectedItem];
}

- (IBAction)_changeColor:(id)sender {
    NSPopUpButton *button = sender;
    NSColor *color = nil;
    if (button.indexOfSelectedItem >= 2) {
        color = presets[button.indexOfSelectedItem - 2].color;
    }
    
    if (sender == self.textColorPopUpButton) {
        self.query.textColor = color;
    } else {
        self.query.backgroundColor = color;
    }
    
    self.completionHandler();
}

@end
