//
//  AppDelegate.m
//  LogDigger
//
//  Created by Cyandev on 2018/12/29.
//  Copyright © 2018 Cyandev. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    NSURL *URL = [NSURL fileURLWithPath:filename];
    [[NSDocumentController sharedDocumentController]
     openDocumentWithContentsOfURL:URL
     display:YES
     completionHandler:^(NSDocument * _Nullable document,
                         BOOL documentWasAlreadyOpen,
                         NSError * _Nullable error) {
         // I don't care.
     }];
    return YES;
}

@end
