//
//  AppDelegate.m
//  MFHID
//
//  Created by Terry Lewis on 9/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "AppDelegate.h"
#import "View Controllers/DevicesViewController.h"
#import "Other/StatusBarManager.h"
#import "Other/Settings.h"

@interface AppDelegate () <NSApplicationDelegate, StatusBarManagerDelegate>

@property (nonatomic, retain) NSWindow *window;
@property (nonatomic, retain) NSWindowController *windowController;
@property (nonatomic, retain) NSStoryboard *storyboard;

@end

static NSString const *kAwakenInstanceNotificationName = @"com.terry1994.MFHID-AwakenInstance";

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self checkSingleInstance];
    [self loadSettings];
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

- (NSWindowController *)windowController{
    if (!_windowController) {
        _windowController = [self.storyboard instantiateControllerWithIdentifier:@"DevicesWindowViewController"];
    }
    return _windowController;
}

- (void)checkSingleInstance {
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    NSArray *runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    NSDistributedNotificationCenter *distributedNotificationCenter = NSDistributedNotificationCenter.defaultCenter;
    if (runningApplications.count > 1) {
        [distributedNotificationCenter postNotificationName:kAwakenInstanceNotificationName object:nil];
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Error";
        alert.informativeText = [NSString stringWithFormat: @"Only one instance of %@ may be running. This application will now terminate and the running instance will be displayed.", NSBundle.mainBundle.infoDictionary[@"CFBundleName"]];;
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert runModal];
        [self quitApplication];
    }
    [distributedNotificationCenter addObserver:self
                                      selector:@selector(awakenNotificationReceived:)
                                          name:kAwakenInstanceNotificationName
                                        object:nil];
}

- (void)loadSettings{
    Settings *sharedSettings = Settings.sharedSettings;
    [sharedSettings addObserver:self forKeyPath:@"showInDock" options:0 context:nil];
    [sharedSettings loadSettings];
    
    if (sharedSettings.showDevicesWindowOnStart) {
        [self focusMainWindowCentred:YES];
    }
    
    if (sharedSettings.showStatusBarIcon) {
        [self setupStatusItem];
    }
    
    if (!sharedSettings.showInDock) {
        [self setDockIconVisible:sharedSettings.showInDock];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == Settings.sharedSettings) {
        if ([keyPath isEqualToString:@"showInDock"]) {
            [self setDockIconVisible:Settings.sharedSettings.showInDock];
        }
    }
}

- (void)setDockIconVisible:(BOOL)visible{
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    ProcessApplicationTransformState transformState;
    if (visible) {
        transformState = kProcessTransformToForegroundApplication;
    }else{
        transformState = kProcessTransformToUIElementApplication;
    }
    TransformProcessType(&psn, transformState);
    
    // Hack. Otherwise the window never comes back.
    if (transformState == kProcessTransformToUIElementApplication){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self focusMainWindowCentred:NO];
        });
    }
}

- (void)awakenNotificationReceived:(id)awakenNotificationReceived {
    [self focusMainWindowCentred:NO];
}

- (void)focusMainWindowCentred:(BOOL)centred{
    [self.windowController showWindow:self.window];
    [self.windowController.window makeKeyAndOrderFront:self];
    [self.windowController.window makeMainWindow];
    if (centred) {
        [self.windowController.window center];
    }
}

- (void)setupStatusItem {
    [StatusBarManager.sharedManager setStatusBarEnabled:YES];
    StatusBarManager.sharedManager.delegate = self;
}

- (void)statusBarManagerShowWindowButtonClicked:(StatusBarManager *)statusBarManager{
    [self focusMainWindowCentred:YES];
}

- (void)statusBarManagerQuitButtonClicked:(StatusBarManager *)statusBarManager{
    [self quitApplication];
}


- (void)quitApplication {
    [NSApplication.sharedApplication terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    [self focusMainWindowCentred:NO];
    return YES;
}

@end
