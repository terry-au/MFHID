//
//  HIDBridgedGamepad.m
//  MFHID
//
//  Created by Terry Lewis on 10/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "HIDBridgedGamepad.h"
#import "HIDController.h"
#import "Vector2D.h"

@implementation HIDBridgedGamepad {
    HIDController *_hidController;
}

- (instancetype)initWithController:(GCController *)controller {
    if (self = [super init]) {
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
    if (self.active) {
        return;
    }
    _active = YES;
    [self configureGamepad];
}

- (void)deactivate {
    if (!self.active) {
        return;
    }
    _active = NO;
}

- (NSString *)localisedControllerTypeString {
    switch (self.gamepadType){
        case HIDBridgedGamepadTypeStandard:
            return NSLocalizedString(@"Standard", @"Standard");
        case HIDBridgedGamepadTypeExtended:
            return NSLocalizedString(@"Extended", @"Extended");
        default:
            return NSLocalizedString(@"Unknown", @"Unknown");
    }
}


- (void)dealloc {
    [self unconfigureGamepad];
}

- (void)configureGamepad {
    if (_hidController != NULL) {

        delete _hidController;
    }

    _hidController = new HIDController();
    _hidController->initialiseDriver();
    _hidController->sendEmptyState();

    _hidController->setBridgedGamepad(self);

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

        // Analogue sticks.
        [extendedGamepad.leftThumbstick setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
            if (self.leftThumbstickDeadzoneEnabled){
                if (abs(xValue) < self.leftThumbstickDeadzone){
                    xValue = 0;
                }
                if (fabs(yValue) < self.leftThumbstickDeadzone){
                    yValue = 0;
                }
            }
            _hidController->setLeftThumbstickXY(xValue, yValue);
        }];

        [extendedGamepad.rightThumbstick setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
            if (self.rightThumbstickDeadzoneEnabled){
                if (abs(xValue) < self.rightThumbstickDeadzone){
                    xValue = 0;
                }
                if (fabs(yValue) < self.rightThumbstickDeadzone){
                    yValue = 0;
                }
                Vector2D vector = Vector2D(xValue, xValue);
                if(vector.magnitude() < self.rightThumbstickDeadzone){

                }
            }
            _hidController->setRightThumbstickXY(xValue, yValue);
        }];
    }
}

- (void)unconfigureGamepad{
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

    delete _hidController;
}

@end
