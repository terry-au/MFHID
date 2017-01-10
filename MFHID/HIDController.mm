//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#include "HIDController.h"

static int report_descriptor[52] = {
        0x05, 0x01,                    // USAGE_PAGE (Generic Desktop)
        0x09, 0x05,                    // USAGE (Game Pad)
        0xa1, 0x01,                    // COLLECTION (Application)
        0xa1, 0x00,                    //   COLLECTION (Physical)
        0x05, 0x09,                    //     USAGE_PAGE (Button)
        0x19, 0x01,                    //     USAGE_MINIMUM (Button 1)
        0x29, 0x0d,                    //     USAGE_MAXIMUM (Button 13)
        0x15, 0x00,                    //     LOGICAL_MINIMUM (0)
        0x25, 0x01,                    //     LOGICAL_MAXIMUM (1)
        0x95, 0x0d,                    //     REPORT_COUNT (13)
        0x75, 0x01,                    //     REPORT_SIZE (1)
        0x81, 0x02,                    //     INPUT (Data,Var,Abs)
        0x95, 0x01,                    //     REPORT_COUNT (1)
        0x75, 0x03,                    //     REPORT_SIZE (3)
        0x81, 0x03,                    //     INPUT (Cnst,Var,Abs)
        0x05, 0x01,                    //     USAGE_PAGE (Generic Desktop)
        0x09, 0x30,                    //     USAGE (X)
        0x09, 0x31,                    //     USAGE (Y)
        0x09, 0x32,                    //     USAGE (Z)
        0x09, 0x33,                    //     USAGE (Rx)
        0x15, 0x81,                    //     LOGICAL_MINIMUM (-127)
        0x25, 0x7f,                    //     LOGICAL_MAXIMUM (127)
        0x75, 0x08,                    //     REPORT_SIZE (8)
        0x95, 0x04,                    //     REPORT_COUNT (4)
        0x81, 0x02,                    //     INPUT (Data,Var,Abs)
        0xc0,                          //   END_COLLECTION
        0xc0                           // END_COLLECTION
};

HIDController::HIDController() {
    bool buttonAPressed = false;
    bool buttonBPressed = false;
    bool buttonXPressed = false;
    bool buttonYPressed = false;

    bool dpadUpPressed = false;
    bool dpadRightPressed = false;
    bool dpadDownPressed = false;
    bool dpadLeftPressed = false;

    bool leftShoulderPressed = false;
    bool leftTriggerPressed = false;

    bool rightShoulderPressed = false;
    bool rightTriggerPressed = false;

    bool pauseButtonPressed = false;

    float leftAnalogueX = 0;
    float leftAnalogueY = 0;

    float rightAnalogueX = 0;
    float rightAnalogueY = 0;
}

bool HIDController::isButtonAPressed() const {
    return buttonAPressed;
}

void HIDController::setButtonAPressed(bool buttonAPressed) {
    HIDController::buttonAPressed = buttonAPressed;
}

bool HIDController::isButtonBPressed() const {
    return buttonBPressed;
}

void HIDController::setButtonBPressed(bool buttonBPressed) {
    HIDController::buttonBPressed = buttonBPressed;
}

bool HIDController::isButtonXPressed() const {
    return buttonXPressed;
}

void HIDController::setButtonXPressed(bool buttonXPressed) {
    HIDController::buttonXPressed = buttonXPressed;
}

bool HIDController::isButtonYPressed() const {
    return buttonYPressed;
}

void HIDController::setButtonYPressed(bool buttonYPressed) {
    HIDController::buttonYPressed = buttonYPressed;
}

bool HIDController::isDpadUpPressed() const {
    return dpadUpPressed;
}

void HIDController::setDpadUpPressed(bool dpadUpPressed) {
    HIDController::dpadUpPressed = dpadUpPressed;
}

bool HIDController::isDpadRightPressed() const {
    return dpadRightPressed;
}

void HIDController::setDpadRightPressed(bool dpadRightPressed) {
    HIDController::dpadRightPressed = dpadRightPressed;
}

bool HIDController::isDpadDownPressed() const {
    return dpadDownPressed;
}

void HIDController::setDpadDownPressed(bool dpadDownPressed) {
    HIDController::dpadDownPressed = dpadDownPressed;
}

bool HIDController::isDpadLeftPressed() const {
    return dpadLeftPressed;
}

void HIDController::setDpadLeftPressed(bool dpadLeftPressed) {
    HIDController::dpadLeftPressed = dpadLeftPressed;
}

bool HIDController::isLeftShoulderPressed() const {
    return leftShoulderPressed;
}

void HIDController::setLeftShoulderPressed(bool leftShoulderPressed) {
    HIDController::leftShoulderPressed = leftShoulderPressed;
}

bool HIDController::isLeftTriggerPressed() const {
    return leftTriggerPressed;
}

void HIDController::setLeftTriggerPressed(bool leftTriggerPressed) {
    HIDController::leftTriggerPressed = leftTriggerPressed;
}

bool HIDController::isRightShoulderPressed() const {
    return rightShoulderPressed;
}

void HIDController::setRightShoulderPressed(bool rightShoulderPressed) {
    HIDController::rightShoulderPressed = rightShoulderPressed;
}

bool HIDController::isRightTriggerPressed() const {
    return rightTriggerPressed;
}

void HIDController::setRightTriggerPressed(bool rightTriggerPressed) {
    HIDController::rightTriggerPressed = rightTriggerPressed;
}

bool HIDController::isPauseButtonPressed() const {
    return pauseButtonPressed;
}

void HIDController::setPauseButtonPressed(bool pauseButtonPressed) {
    HIDController::pauseButtonPressed = pauseButtonPressed;
}

float HIDController::getLeftAnalogueX() const {
    return leftAnalogueX;
}

void HIDController::setLeftAnalogueX(float leftAnalogueX) {
    HIDController::leftAnalogueX = leftAnalogueX;
}

float HIDController::getLeftAnalogueY() const {
    return leftAnalogueY;
}

void HIDController::setLeftAnalogueY(float leftAnalogueY) {
    HIDController::leftAnalogueY = leftAnalogueY;
}

float HIDController::getRightAnalogueX() const {
    return rightAnalogueX;
}

void HIDController::setRightAnalogueX(float rightAnalogueX) {
    HIDController::rightAnalogueX = rightAnalogueX;
}

float HIDController::getRightAnalogueY() const {
    return rightAnalogueY;
}

void HIDController::setRightAnalogueY(float rightAnalogueY) {
    HIDController::rightAnalogueY = rightAnalogueY;
}
