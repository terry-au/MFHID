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

@implementation DevicesViewController {
    HIDBridgedGamepad *_selectedGamepad;
    NSArray<HIDBridgedGamepad *> *_connectedControllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchForControllersIndicator.hidden = YES;

    [self.searchForControllersButton setTarget:self];
    [self.searchForControllersButton setAction:@selector(searchForControllersButtonClicked:)];

    self.connectControllerButton.target = self;
    self.connectControllerButton.action = @selector(connectControllerButtonClicked:);

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
    NSLog(@"Searching for controllers...");
    NSLog(@"Have: %@", [GCController controllers]);
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

- (void)connectControllerButtonClicked:(id)sender {
    if (_selectedGamepad){
        [_selectedGamepad deactivate];
    }

    NSUInteger selectedIndex = [[self.tableView selectedRowIndexes] firstIndex];
    if (selectedIndex == NSNotFound){
        return;
    }

    _selectedGamepad = _connectedControllers[selectedIndex];
    [self configureGamepadSettings];
    [_selectedGamepad activate];
//    NSArray<GCController *> *controllers = [GCController controllers];
//    if (controllers.count > 0) {
//        GCController *controller = [controllers firstObject];
//        _gamepad = controller.extendedGamepad;
//        NSLog(@"Gamepad: %@", _gamepad);
//        [self configureGamepad];
//    } else {
//        NSLog(@"No gamepads found.");
//    }
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
    static NSString *ControllerTextCellID = @"ControllerTextCell";
    
    NSString *cellIdentifier = nil;
    
    HIDBridgedGamepad *gamepad = _connectedControllers[row];
    NSString *text = nil;
    NSImage *image = nil;
    if (tableColumn == tableView.tableColumns[0]) {
        cellIdentifier = ControllerVendorCellID;
        text = gamepad.controller.vendorName;
        image = [NSImage imageNamed:@"Controller"];
    }else if(tableColumn == tableView.tableColumns[1]){
        cellIdentifier = ControllerTextCellID;
        text = gamepad.localisedControllerTypeString;
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

@end
