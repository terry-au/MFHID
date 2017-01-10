//
//  HIDBridgedGamepad.m
//  MFHID
//
//  Created by Terry Lewis on 10/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "HIDBridgedGamepad.h"
#import "HIDController.h"

@implementation HIDBridgedGamepad{
    HIDController *_hidController;
}

- (instancetype)initWithController:(GCController *)controller{
    if (self = [super init]) {
        if (controller.extendedGamepad != nil) {
            _gamepadType = HIDBridgedGamepadTypeExtended;
            _gamepad = controller.extendedGamepad;
        }else if (controller.gamepad != nil) {
            _gamepadType = HIDBridgedGamepadTypeStandard;
            _gamepad = controller.gamepad;
        }else{
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    delete _hidController;
}

- (void)configureGamepad {
    if (_hidController != NULL) {
        delete _hidController;
    }
    
    _hidController = new HIDController();
    
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
        _hidController->setPauseButtonPressed(false);
    }];
    
    if (self.gamepadType == HIDBridgedGamepadTypeExtended) {
        GCExtendedGamepad *extendedGamepad = (GCExtendedGamepad *)mfiGamepad;
        // Triggers.
        [extendedGamepad.leftTrigger setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            _hidController->setLeftTriggerPressed(pressed);
        }];
        
        [extendedGamepad.rightTrigger setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
            _hidController->setRightTriggerPressed(pressed);
        }];
        
        // Analogue sticks.
        
        [extendedGamepad.leftThumbstick setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
            _hidController->setLeftAnalogueXY(xValue, yValue);
        }];
        
        [extendedGamepad.rightThumbstick setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
            _hidController->setRightAnalogueXY(xValue, yValue);
        }];
    }
}

@end
