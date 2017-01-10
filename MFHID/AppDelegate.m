//
//  AppDelegate.m
//  MFHID
//
//  Created by Terry Lewis on 9/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "AppDelegate.h"
#import "DevicesViewController.h"

@interface AppDelegate () <NSApplicationDelegate>

@property (nonatomic, retain) DevicesViewController *devicesViewController;
@property (nonatomic, retain) NSWindow *window;
@property (nonatomic, retain) NSWindowController *windowController;

@end

static NSString *kAwakenInstanceNotificationName = @"com.terry1994.MFHID-AwakenInstance";

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self checkSingleInstance];
    [self setupWindowController];
    [self setupStatusItem];
}

- (void)checkSingleInstance {
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSArray *runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    NSDistributedNotificationCenter *distributedNotificationCenter = NSDistributedNotificationCenter.defaultCenter;
    if (runningApplications.count > 1) {
        [distributedNotificationCenter postNotificationName:kAwakenInstanceNotificationName object:nil];
        [NSApplication.sharedApplication terminate:self];
    }
    [distributedNotificationCenter addObserver:self
                                      selector:@selector(awakenNotificationReceived:)
                                          name:kAwakenInstanceNotificationName
                                        object:nil];
}

- (void)awakenNotificationReceived:(id)awakenNotificationReceived {
    [self.windowController showWindow:nil];
    [self.windowController.window makeKeyAndOrderFront:self];
    [self.windowController.window makeMainWindow];
}

- (void)setupWindowController{
    NSWindowStyleMask styleMask = NSTitledWindowMask|NSResizableWindowMask|NSMiniaturizableWindowMask|NSClosableWindowMask;
    NSSize screenSize = NSScreen.mainScreen.frame.size;
    NSRect windowRect = NSMakeRect(0, 0, screenSize.width/2, screenSize.height/2);
    self.window = [[NSWindow alloc] initWithContentRect:windowRect
                                              styleMask:styleMask
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];

    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
    self.devicesViewController = [storyboard instantiateControllerWithIdentifier:@"DevicesWindowViewController"];
    self.windowController = [[NSWindowController alloc] initWithWindow:self.window];
    [self.windowController showWindow:nil];
    [self.windowController.window makeKeyAndOrderFront:self];
    [self.windowController.window makeMainWindow];
    self.windowController.contentViewController = self.devicesViewController;
    [self.windowController.window center];
}

- (void)setupStatusItem {
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {

    if (!self.devicesViewController) {
        NSViewController *viewController = NSApplication.sharedApplication.mainWindow.contentViewController;
        if ([viewController isKindOfClass:[DevicesViewController class]]) {
            self.devicesViewController = (DevicesViewController *)viewController;
        }
    }
}

- (void)showPreferencesWindow:(id)showPreferencesWindow {

}

- (void)showDevicesWindow:(id)showDevicesWindow {
    [NSApplication.sharedApplication.keyWindow.contentView addSubview:self.devicesViewController.view];
}

- (void)quitApplication {
    [NSApplication.sharedApplication terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
