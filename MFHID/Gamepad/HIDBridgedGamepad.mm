//
//  HIDBridgedGamepad.m
//  MFHID
//
//  Created by Terry Lewis on 10/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "HIDBridgedGamepad.h"
#import "HIDController.h"
#import "../Other/FoohidDriverManager.h"

@implementation HIDBridgedGamepad {
    HIDController *_hidController;
}

- (instancetype)initWithController:(GCController *)controller {
    if (self = [super init]) {
        _status = HIDBridgedGamepadStatusDisconnected;
        _controller = controller;
        if (controller.extendedGamepad) {
            _gamepadType = HIDBridgedGamepadTypeExtended;
            _gamepad = controller.extendedGamepad;
        } else if (controller.gamepad) {
            _gamepadType = HIDBridgedGamepadTypeStandard;
            _gamepad = controller.gamepad;
        } else {
            return nil;
        }
    }
    return self;
}

- (void)activate {
    [self configureGamepad];
}

- (void)deactivate {
    [self unconfigureGamepad];
}

- (NSString *)localisedControllerTypeString {
    switch (self.gamepadType) {
        case HIDBridgedGamepadTypeStandard:
            return NSLocalizedString(@"Standard", @"Standard");
        case HIDBridgedGamepadTypeExtended:
            return NSLocalizedString(@"Extended", @"Extended");
        default:
            return NSLocalizedString(@"Unknown", @"Unknown");
    }
}

- (void)onFailedToInitialiseDriver {
    NSLog(@"Failed to initialise driver.");
}


- (void)dealloc {
    [self unconfigureGamepad];
}

- (BOOL)attemptToFixDriverIssues:(HIDBridgedGamepadDriverError *)driverError {
    MFHIDHelperExitCode result = [FoohidDriverManager fixAndLoadDriver];
    switch (result) {
        case MFHIDHelperExitCodeSuccess:
            *driverError = HIDBridgedGamepadDriverErrorNone;
            return YES;
        case MFHIDHelperExitCodeErrorLoadingDriver:
            *driverError = HIDBridgedGamepadDriverErrorFailedToLoadDriver;
            break;
        case MFHIDHelperExitCodeErrorDriverNotFound:
            *driverError = HIDBridgedGamepadDriverErrorDriverNotFound;
            break;
        case MFHIDHelperExitCodeErrorArgs:
        case MFHIDHelperExitCodeErrorSeteuid:
        case MFHIDHelperExitCodeErrorFixingPermissions:
        case MFHIDHelperExitCodeFailure:;
        case MFHIDHelperExitCodeErrorUnknown:
            *driverError = HIDBridgedGamepadDriverErrorUnknown;
    }
    return NO;
}

- (void)configureGamepad {
    _hidController = new HIDController(self);
    if (!_hidController->initialiseDriver()) {
        HIDBridgedGamepadDriverError driverError;
        if (![self attemptToFixDriverIssues:&driverError]){
            self.status = HIDBridgedGamepadStatusDisconnected;
            [self handleFailureToInitialiseDriverWithError:driverError];
            return;
        }else{
            sleep(1);
            if (!_hidController->initialiseDriver()){
                self.status = HIDBridgedGamepadStatusDisconnected;
                [self handleFailureToInitialiseDriverWithError:HIDBridgedGamepadDriverErrorUnknown];
                return;
            }
        }
    }
    self.status = HIDBridgedGamepadStatusConnected;
    _hidController->sendEmptyState();


    GCGamepad *mfiGamepad = self.gamepad;

    // Buttons
    [mfiGamepad.buttonA setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setButtonAPressed(pressed);
    }];

    [mfiGamepad.buttonB setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setButtonBPressed(pressed);
    }];

    [mfiGamepad.buttonX setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setButtonXPressed(pressed);
    }];

    [mfiGamepad.buttonY setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setButtonYPressed(pressed);
    }];

    // Directional-pad.
    [mfiGamepad.dpad.up setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setDpadUpPressed(pressed);
    }];

    [mfiGamepad.dpad.right setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setDpadRightPressed(pressed);
    }];

    [mfiGamepad.dpad.down setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setDpadDownPressed(pressed);
    }];

    [mfiGamepad.dpad.left setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setDpadLeftPressed(pressed);
    }];


    // Shoulder buttons.
    [mfiGamepad.leftShoulder setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setLeftShoulderPressed(pressed);
    }];

    [mfiGamepad.rightShoulder setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        _hidController->setRightShoulderPressed(pressed);
    }];

    // Pause button.
    [mfiGamepad.controller setControllerPausedHandler:^(GCController *controller) {
        // The pause button doesn't act like a normal button.
        // Probably wise to turn it off otherwise it'll appear always on as the HID gamepad supports a binary state.
        _hidController->setPauseButtonPressed(true);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            _hidController->setPauseButtonPressed(false);
        });
    }];

    if (self.gamepadType == HIDBridgedGamepadTypeExtended) {
        GCExtendedGamepad *extendedGamepad = (GCExtendedGamepad *) mfiGamepad;
        // Triggers.
        [extendedGamepad.leftTrigger setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            _hidController->setLeftTriggerPressed(pressed);
        }];

        [extendedGamepad.rightTrigger setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            _hidController->setRightTriggerPressed(pressed);
        }];


        // Deadzone code from:
        // http://www.gamasutra.com/blogs/JoshSutphin/20130416/190541/Doing_Thumbstick_Dead_Zones_Right.php
        // Analogue sticks.
        [extendedGamepad.leftThumbstick setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
            Vector2D vector = Vector2D(xValue, yValue);
            float leftThumbstickDeadzone = self.leftThumbstickDeadzone;
            if (self.leftThumbstickDeadzoneEnabled && leftThumbstickDeadzone > 0) {
                if (vector.magnitude() < leftThumbstickDeadzone) {
                    vector = Vector2D::zero();
                } else {
                    vector = vector.normalised() * ((vector.magnitude() - leftThumbstickDeadzone) / (1 - leftThumbstickDeadzone));
                }
            }
            _hidController->setLeftThumbStick(vector);
        }];

        [extendedGamepad.rightThumbstick setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
            Vector2D vector = Vector2D(xValue, yValue);
            float rightThumbstickDeadzone = self.rightThumbstickDeadzone;
            if (self.rightThumbstickDeadzoneEnabled && rightThumbstickDeadzone > 0) {
                if (vector.magnitude() < rightThumbstickDeadzone) {
                    vector = Vector2D::zero();
                } else {
                    vector = vector.normalised() * ((vector.magnitude() - rightThumbstickDeadzone) / (1 - rightThumbstickDeadzone));
                }
            }
            _hidController->setRightThumbStick(vector);
        }];
    }
}

- (void)unconfigureGamepad {
    self.status = HIDBridgedGamepadStatusDisconnected;
    GCGamepad *mfiGamepad = self.gamepad;

    // Buttons
    [mfiGamepad.buttonA setValueChangedHandler:nil];
    [mfiGamepad.buttonB setValueChangedHandler:nil];
    [mfiGamepad.buttonX setValueChangedHandler:nil];
    [mfiGamepad.buttonY setValueChangedHandler:nil];

    // Directional-pad.
    [mfiGamepad.dpad.up setValueChangedHandler:nil];
    [mfiGamepad.dpad.right setValueChangedHandler:nil];
    [mfiGamepad.dpad.down setValueChangedHandler:nil];
    [mfiGamepad.dpad.left setValueChangedHandler:nil];

    // Shoulder buttons.
    [mfiGamepad.leftShoulder setValueChangedHandler:nil];
    [mfiGamepad.rightShoulder setValueChangedHandler:nil];

    // Pause button.
    [mfiGamepad.controller setControllerPausedHandler:nil];

    if (self.gamepadType == HIDBridgedGamepadTypeExtended) {
        GCExtendedGamepad *extendedGamepad = (GCExtendedGamepad *) mfiGamepad;
        // Triggers.
        [extendedGamepad.leftTrigger setValueChangedHandler:nil];
        [extendedGamepad.rightTrigger setValueChangedHandler:nil];

        // Analogue sticks.

        [extendedGamepad.leftThumbstick setValueChangedHandler:nil];
        [extendedGamepad.rightThumbstick setValueChangedHandler:nil];
    }

    if (_hidController != NULL){
        delete _hidController;
    }
}

- (void)handleFailureToInitialiseDriverWithError:(HIDBridgedGamepadDriverError)driverError{
    if ([self.delegate respondsToSelector:@selector(bridgedGamepadFailedInitialise:driverError:)]){
        [self.delegate bridgedGamepadFailedInitialise:self driverError:driverError];
    }
}

- (NSString *)localisedStatusString {
    NSString *message = nil;
    switch (self.status){
        case HIDBridgedGamepadStatusConnected:
            message = NSLocalizedString(@"Connected", @"Connected");
            break;
        case HIDBridgedGamepadStatusDisconnected:
            message = NSLocalizedString(@"Disconnected", @"Disconnected");
            break;
    }
    return message;
}

- (void)setStatus:(HIDBridgedGamepadStatus)status {
    _status = status;
    if ([self.delegate respondsToSelector:@selector(bridgedGamepadDidUpdateStatus:)]){
        [self.delegate bridgedGamepadDidUpdateStatus:self];
    }
}

@end
