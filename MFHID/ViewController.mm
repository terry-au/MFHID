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
    HIDBridgedGamepad *gamepad;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.searchForControllersIndicator.hidden = YES;

    [self.searchForControllersButton setTarget:self];
    [self.searchForControllersButton setAction:@selector(searchForControllersButtonClicked:)];

    self.connectControllerButton.target = self;
    self.connectControllerButton.action = @selector(connectControllerButtonClicked:);


    // Do any additional setup after loading the view.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self connectControllerButtonClicked:self];
    });
}

- (void)searchForControllersButtonClicked:(id)sender {
    NSLog(@"Searching for controllers...");
    NSLog(@"Have: %@", [GCController controllers]);
    self.searchForControllersIndicator.hidden = NO;
    [self.searchForControllersIndicator startAnimation:self];
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
        NSLog(@"Controllers: %@", GCController.controllers);
        self.searchForControllersIndicator.hidden = YES;
        [self.searchForControllersIndicator stopAnimation:self];
    }];
}

- (void)connectControllerButtonClicked:(id)sender {
    NSArray<GCController *> *controllers = [GCController controllers];
    if (controllers.count > 0) {
        GCController *controller = [controllers firstObject];
        _gamepad = controller.extendedGamepad;
        NSLog(@"Gamepad: %@", _gamepad);
        [self configureGamepad];
    } else {
        NSLog(@"No gamepads found.");
    }
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
