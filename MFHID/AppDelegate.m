//
//  AppDelegate.m
//  MFHID
//
//  Created by Terry Lewis on 9/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "AppDelegate.h"
#import "DevicesViewController.h"
#import "StatusBarManager.h"

@interface AppDelegate () <NSApplicationDelegate, StatusBarManagerDelegate>

@property (nonatomic, retain) NSWindow *window;
@property (nonatomic, retain) NSWindowController *devicesWindowController;
@property (nonatomic, retain) NSStoryboard *storyboard;

@end

static NSString *kAwakenInstanceNotificationName = @"com.terry1994.MFHID-AwakenInstance";

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self checkSingleInstance];
    [self setupWindowController];
    [self setupStatusItem];
}

- (NSStoryboard *)storyboard{
    if (!_storyboard){
        _storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
    }
    return _storyboard;
}

- (NSWindow *)window{
    if (!_window) {
        NSWindowStyleMask styleMask = NSWindowStyleMaskTitled|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskClosable;
        NSSize screenSize = NSScreen.mainScreen.frame.size;
        NSRect windowRect = NSMakeRect(0, 0, screenSize.width/2, screenSize.height/2);
        self.window = [[NSWindow alloc] initWithContentRect:windowRect
                                                  styleMask:styleMask
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
    }
    return _window;
}

- (void)checkSingleInstance {
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSArray *runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    NSDistributedNotificationCenter *distributedNotificationCenter = NSDistributedNotificationCenter.defaultCenter;
    if (runningApplications.count > 1) {
        [distributedNotificationCenter postNotificationName:kAwakenInstanceNotificationName object:nil];
        [self quitApplication];
    }
    [distributedNotificationCenter addObserver:self
                                      selector:@selector(awakenNotificationReceived:)
                                          name:kAwakenInstanceNotificationName
                                        object:nil];
}

- (void)awakenNotificationReceived:(id)awakenNotificationReceived {
    [self.devicesWindowController showWindow:nil];
    [self.devicesWindowController.window makeKeyAndOrderFront:self];
    [self.devicesWindowController.window makeMainWindow];
}

- (void)setupWindowController{
    self.devicesWindowController = [self.storyboard instantiateControllerWithIdentifier:@"DevicesWindowViewController"];
    [self.devicesWindowController showWindow:self.window];
    [self.devicesWindowController.window center];
}

- (void)setupStatusItem {
    [StatusBarManager.sharedManager setStatusBarEnabled:YES];
    StatusBarManager.sharedManager.delegate = self;
}

- (void)statusBarManagerDevicesButtonClicked:(StatusBarManager *)statusBarManager{
//    [NSApplication.sharedApplication.keyWindow.contentView addSubview:self.devicesViewController.view];
}

- (void)statusBarManagerQuitButtonClicked:(StatusBarManager *)statusBarManager{
    [self quitApplication];
}

- (void)statusBarManagerPreferencesButtonClicked:(StatusBarManager *)statusBarManager{
//    self.settingsWindowController = [self.storyboard instantiateControllerWithIdentifier:@"SettingsWindowController"];
//    [self.settingsWindowController showWindow:self.window];
}

- (void)quitApplication {
    [NSApplication.sharedApplication terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
