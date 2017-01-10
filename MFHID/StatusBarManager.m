//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import "StatusBarManager.h"
#import <AppKit/AppKit.h>

@interface StatusBarManager ()
@property (nonatomic, strong) NSStatusItem *statusItem;
@end

@implementation StatusBarManager {

}
+ (instancetype)sharedManager {
    static StatusBarManager *sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)setStatusBarEnabled:(BOOL)statusBarEnabled {
    if (_statusBarEnabled != statusBarEnabled) {
        _statusBarEnabled = statusBarEnabled;
        if (self.statusBarEnabled) {
            [self enableStatusBar];
        } else {
            [self disableStatusBar];
        }
    }
}

- (void)disableStatusBar {
    self.statusItem.menu = nil;
    self.statusItem = nil;
}

- (void)enableStatusBar {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:@"StatusBarItem"];
    self.statusItem.alternateImage = [NSImage imageNamed:@"StatusBarItem-Alt"];
    self.statusItem.highlightMode = YES;

    NSMenu *menu = [[NSMenu alloc] init];

    NSMenuItem *devicesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Devices" action:@selector(showDevicesWindow:) keyEquivalent:@""];
    NSMenuItem *preferencesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(showPreferencesWindow:) keyEquivalent:@""];
    NSMenuItem *separatorMenuItem = [NSMenuItem separatorItem];
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitApplication) keyEquivalent:@"Q"];

    [menu addItem:devicesMenuItem];
    [menu addItem:preferencesMenuItem];
    [menu addItem:separatorMenuItem];
    [menu addItem:quitMenuItem];

    self.statusItem.menu = menu;
}


@end