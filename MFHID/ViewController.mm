//
//  ViewController.m
//  MFHID
//
//  Created by Terry Lewis on 9/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "ViewController.h"
#import "HIDBridgedGamepad.h"

@implementation ViewController {
    HIDBridgedGamepad *_bridgedGamepad;
    NSArray *_connectedControllers;
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
    
    _connectedControllers = GCController.controllers;
    [self.tableView reloadData];
}

- (void)searchForControllers{
    self.searchForControllersIndicator.hidden = NO;
    [self.searchForControllersIndicator startAnimation:self];
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
        self.searchForControllersIndicator.hidden = YES;
        [self.searchForControllersIndicator stopAnimation:self];
        _connectedControllers = GCController.controllers;
    }];
}

- (void)connectControllerButtonClicked:(id)sender {
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
    
    GCController *controller = _connectedControllers[row];
    NSString *text = nil;
    NSImage *image = nil;
    if (tableColumn == tableView.tableColumns[0]) {
        cellIdentifier = ControllerVendorCellID;
        text = controller.vendorName;
        image = [NSImage imageNamed:@"Controller"];
    }else if(tableColumn == tableView.tableColumns[1]){
        cellIdentifier = ControllerTextCellID;
        controller.playerIndex = GCControllerPlayerIndexUnset;
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
