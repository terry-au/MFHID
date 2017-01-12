//
//  SettingsTabViewController.h
//  MFHID
//
//  Created by Terry Lewis on 11/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsViewController : NSViewController
@property (weak) IBOutlet NSView *leftThumbstickView;
@property (weak) IBOutlet NSView *rightThumbstickView;
@property (weak) IBOutlet NSButton *showWindowWhenOpeningCheckButton;
@property (weak) IBOutlet NSButton *showStatusBarIconCheckButton;
@property (weak) IBOutlet NSButton *showInDockCheckButton;
@property (weak) IBOutlet NSButton *enableLeftDeadZoneCheckButton;
@property (weak) IBOutlet NSButton *enableRightDeadzoneCheckButton;
@property (weak) IBOutlet NSTextField *leftDeadZoneValueTextField;
@property (weak) IBOutlet NSTextField *rightDeadZoneValueTextField;
@property (weak) IBOutlet NSStepper *leftDeadzoneStepper;
@property (weak) IBOutlet NSStepper *rightDeadzoneStepper;

@end
