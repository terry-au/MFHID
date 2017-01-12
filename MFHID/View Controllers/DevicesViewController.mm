//
//  DevicesViewController.m
//  MFHID
//
//  Created by Terry Lewis on 9/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "DevicesViewController.h"
#import "HIDBridgedGamepad.h"
#import "StatusBarManager.h"
#import "Settings.h"

@interface DevicesViewController () <HIDBridgedGamepadDelegate>

@end

@implementation DevicesViewController {
    HIDBridgedGamepad *_selectedGamepad;
    NSArray<HIDBridgedGamepad *> *_connectedControllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchForControllersIndicator.hidden = YES;

    [self.searchForControllersButton setTarget:self];
    [self.searchForControllersButton setAction:@selector(searchForControllersButtonClicked:)];

    self.controllerActionButton.target = self;
    self.controllerActionButton.action = @selector(controllerActionButtonClicked:);

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refreshTableView) name:GCControllerDidConnectNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refreshTableView) name:GCControllerDidDisconnectNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateGamepadSettingsNotification:) name:kGamepadRelatedSettingsChangedNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self refreshTableView];
    });
}

- (void)searchForControllersButtonClicked:(id)sender {
    [self searchForControllers];
}

- (void)refreshTableView{
    NSMutableArray *HIDControllers = NSMutableArray.array;
    for (GCController *controller in GCController.controllers) {
        HIDBridgedGamepad *gamepad = [[HIDBridgedGamepad alloc] initWithController:controller];
        if (gamepad){
            [HIDControllers addObject:gamepad];
        }
    }
    _connectedControllers = [NSArray arrayWithArray:HIDControllers];
    [self.tableView reloadData];

    if (self.tableView.selectedRowIndexes.count == 0 && self.tableView.numberOfRows > 0){
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
}

- (void)searchForControllers{
    StatusBarManager.sharedManager.statusBarEnabled = !StatusBarManager.sharedManager.statusBarEnabled;
    self.searchForControllersIndicator.hidden = NO;
    [self.searchForControllersIndicator startAnimation:self];
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
        self.searchForControllersIndicator.hidden = YES;
        [self.searchForControllersIndicator stopAnimation:self];
        [self refreshTableView];
    }];
}

- (void)controllerActionButtonClicked:(id)sender {
    NSInteger selectedRow = self.tableView.selectedRowIndexes.firstIndex;
    if (selectedRow != NSNotFound){
        HIDBridgedGamepad *selectedGamepad = _connectedControllers[selectedRow];

        if (selectedGamepad.status == HIDBridgedGamepadStatusConnected){
            [self disconnectAction];
        }else{
            [self connectAction];
        }
        [self updateActionButton];
        [self.tableView reloadData];
    }
}

- (void)connectAction{
    [self disconnectAction];

    NSUInteger selectedIndex = [[self.tableView selectedRowIndexes] firstIndex];
    if (selectedIndex == NSNotFound){
        return;
    }

    _selectedGamepad = _connectedControllers[selectedIndex];
    _selectedGamepad.delegate = self;
    [self configureGamepadSettings];
    [_selectedGamepad activate];
}

- (void)disconnectAction{
    if (_selectedGamepad){
        [_selectedGamepad deactivate];
        _selectedGamepad.delegate = nil;
        _selectedGamepad = nil;
    }
}

- (void)updateGamepadSettingsNotification:(id)updateGamepadSettingsNotification {
    [self configureGamepadSettings];
}

- (void)configureGamepadSettings {
    Settings *sharedSettings = Settings.sharedSettings;
    _selectedGamepad.leftThumbstickDeadzoneEnabled = sharedSettings.leftThumbstickDeadzoneEnabled;
    _selectedGamepad.rightThumbstickDeadzoneEnabled = sharedSettings.rightThumbstickDeadzoneEnabled;
    _selectedGamepad.leftThumbstickDeadzone = (float)sharedSettings.leftStickDeadzone/100.0f;
    _selectedGamepad.rightThumbstickDeadzone = (float)sharedSettings.rightStickDeadzone/100.0f;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    NSLog(@"%li", _connectedControllers.count);
    return _connectedControllers.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    static NSString *ControllerVendorCellID = @"ControllerVendorCell";
    static NSString *ControllerSpecificationCellID = @"ControllerSpecificationCell";
    static NSString *ControllerStatusCellID = @"ControllerStatusCell";
    
    NSString *cellIdentifier = nil;
    
    HIDBridgedGamepad *gamepad = _connectedControllers[row];
    NSString *text = nil;
    NSImage *image = nil;
    if (tableColumn == tableView.tableColumns[0]) {
        cellIdentifier = ControllerVendorCellID;
        text = gamepad.controller.vendorName;
        image = [NSImage imageNamed:@"Controller"];
    }else if(tableColumn == tableView.tableColumns[1]){
        cellIdentifier = ControllerSpecificationCellID;
        text = gamepad.localisedControllerTypeString;
    }else if(tableColumn == tableView.tableColumns[2]){
        cellIdentifier = ControllerStatusCellID;
        text = gamepad.localisedStatusString;
    }
    
    NSTableCellView *cell = [tableView makeViewWithIdentifier:cellIdentifier owner:nil];
    if (text) {
        cell.textField.stringValue = text;
    }
    if (image){
        cell.imageView.image = image;
    }
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self updateActionButton];
}

- (void)bridgedGamepadDidUpdateStatus:(HIDBridgedGamepad *)bridgedGamepad {
    [self.tableView reloadData];
}

- (void)bridgedGamepadFailedInitialise:(HIDBridgedGamepad *)bridgedGamepad driverError:(HIDBridgedGamepadDriverError)driverError {
    NSString *informativeText = nil;
    switch (driverError){
        case HIDBridgedGamepadDriverErrorNone:
            return;
        case HIDBridgedGamepadDriverErrorUnknown:
            informativeText = NSLocalizedString(@"An unknown error occurred when loading the foohid driver.",
                    @"An unknown error occurred when loading the foohid driver.");
            break;
        case HIDBridgedGamepadDriverErrorDriverNotFound:
            informativeText = NSLocalizedString(@"The foohid driver is not installed. Would you like to install it now?",
                    @"The foohid driver is not installed. Would you like to install it now?");
            break;
        case HIDBridgedGamepadDriverErrorFailedToLoadDriver:
            informativeText = NSLocalizedString(@"Failed to load the foohid driver.",
                    @"Failed to load the foohid driver.");
            break;
    }

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(@"Error", @"Error");
    alert.informativeText = @"Failed to initialise HID driver.";
    alert.alertStyle = NSAlertStyleCritical;

    if (driverError == HIDBridgedGamepadDriverErrorDriverNotFound){
        [alert addButtonWithTitle:@"Download"];
        [alert addButtonWithTitle:@"Cancel"];
        NSModalResponse modalResponse = [alert runModal];
        if (modalResponse == NSAlertFirstButtonReturn) {
            [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://github.com/unbit/foohid/releases"]];
        }
    }else{
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
}


- (void)updateActionButton {
    NSInteger selectedRow = self.tableView.selectedRowIndexes.firstIndex;
    if (_selectedGamepad){
        NSInteger selectedGamepadIndex = [_connectedControllers indexOfObject:_selectedGamepad];
        if (selectedRow == selectedGamepadIndex){
            self.controllerActionButton.title = @"Disconnect";
        }
    }else{
        self.controllerActionButton.title = @"Connect";
    }

    if (selectedRow == NSNotFound){
        self.controllerActionButton.enabled = NO;
    }else{
        self.controllerActionButton.enabled = YES;
    }
}


@end
