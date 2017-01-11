//
//  SettingsTabViewController.m
//  MFHID
//
//  Created by Terry Lewis on 11/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"

@interface RangeNumberFormatter : NSNumberFormatter

@end

@implementation RangeNumberFormatter

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error{
    if([*partialStringPtr length] == 0) {
        return YES;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:*partialStringPtr];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    NSInteger value = [*partialStringPtr integerValue];
    if (value > self.maximum.integerValue || value < self.minimum.integerValue) {
        NSBeep();
        return NO;
    }
    
    return YES;
}

@end

@interface SettingsViewController () <NSTextFieldDelegate>

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
    
    const int kMinimumDeadzoneValue = 0;
    const int kMaximumDeadzoneValue = 50;
    
    self.leftDeadzoneStepper.target = self;
    self.leftDeadzoneStepper.action = @selector(deadZoneStepperIncremented:);
    self.leftDeadzoneStepper.maxValue = kMaximumDeadzoneValue;
    self.leftDeadzoneStepper.minValue = kMinimumDeadzoneValue;
    
    self.rightDeadzoneStepper.target = self;
    self.rightDeadzoneStepper.action = @selector(deadZoneStepperIncremented:);
    self.rightDeadzoneStepper.maxValue = kMaximumDeadzoneValue;
    self.rightDeadzoneStepper.minValue = kMinimumDeadzoneValue;
    
    RangeNumberFormatter *rangeNumberFormatter = [[RangeNumberFormatter alloc] init];
    rangeNumberFormatter.minimum = @(kMinimumDeadzoneValue);
    rangeNumberFormatter.maximum = @(kMaximumDeadzoneValue);
    self.leftDeadZoneValueTextField.formatter = rangeNumberFormatter;
    self.rightDeadZoneValueTextField.formatter = rangeNumberFormatter;
    
    self.leftDeadZoneValueTextField.delegate = self;
    self.rightDeadZoneValueTextField.delegate = self;
    
    self.showInDockCheckButton.target = self;
    self.showInDockCheckButton.action = @selector(checkboxButtonChanged:);
    
    [self loadStepperSettings];
    [self updateSteppers];
}

- (void)loadStepperSettings{
    self.leftDeadZoneValueTextField.stringValue = @(Settings.sharedSettings.leftStickDeadzone).stringValue;
    self.rightDeadZoneValueTextField.stringValue = @(Settings.sharedSettings.rightStickDeadzone).stringValue;
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
        Settings.sharedSettings.leftStickDeadzone = sender.integerValue;
    }else if(sender == self.rightDeadzoneStepper){
        Settings.sharedSettings.rightStickDeadzone = sender.integerValue;
    }
    [self loadStepperSettings];
}

- (void)textFieldTextChanged:(NSNotification *)aNotification{
    NSLog(@"Text changed.");
}

- (void)controlTextDidChange:(NSNotification *)obj{
    if (obj.object == self.leftDeadZoneValueTextField) {
        Settings.sharedSettings.leftStickDeadzone = self.leftDeadZoneValueTextField.stringValue.integerValue;
    }else if(obj.object == self.rightDeadZoneValueTextField){
        Settings.sharedSettings.rightStickDeadzone = self.rightDeadZoneValueTextField.stringValue.integerValue;
    }
}

- (void)checkboxButtonChanged:(NSButton *)sender{
    Settings *sharedSettings = Settings.sharedSettings;
    if (sender == self.showWindowWhenOpeningCheckButton) {
        sharedSettings.showDevicesWindowOnStart = sender.state == NSOnState;
    }else if(sender == self.showStatusBarIconCheckButton){
        sharedSettings.showStatusBarIcon = sender.state == NSOnState;
    }else if(sender == self.showInDockCheckButton){
        sharedSettings.showInDock = sender.state == NSOnState;
    }
}

@end
