//
//  SettingsTabViewController.m
//  MFHID
//
//  Created by Terry Lewis on 11/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    CGColorRef backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.05f].CGColor;
    self.leftThumbstickView.wantsLayer = YES;
    self.leftThumbstickView.layer.cornerRadius = 5;
    self.leftThumbstickView.layer.masksToBounds = YES;
    self.leftThumbstickView.layer.backgroundColor = backgroundColor;
    
    self.rightThumbstickView.wantsLayer = YES;
    self.rightThumbstickView.layer.cornerRadius = 5;
    self.rightThumbstickView.layer.masksToBounds = YES;
    self.rightThumbstickView.layer.backgroundColor = backgroundColor;
    
    self.leftDeadzoneStepper.target = self;
    self.leftDeadzoneStepper.action = @selector(deadZoneStepperIncremented:);
    
    self.rightDeadzoneStepper.target = self;
    self.rightDeadzoneStepper.action = @selector(deadZoneStepperIncremented:);
    
    
    [self updateSteppers];
}

- (void)loadSettings{
    self.leftDeadZoneValueTextField.stringValue =
}

- (void)viewWillAppear{
    [super viewWillAppear];
}

- (void)updateSteppers{
    self.leftDeadzoneStepper.integerValue = self.leftDeadZoneValueTextField.stringValue.integerValue;
    self.rightDeadzoneStepper.integerValue = self.rightDeadZoneValueTextField.stringValue.integerValue;
}

- (void)deadZoneStepperIncremented:(NSStepper *)sender{
    if (sender == self.leftDeadzoneStepper) {
        
    }else if(sender == self.rightDeadzoneStepper){
        
    }
}



@end
