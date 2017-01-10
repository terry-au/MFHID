//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <cstdint>
#import <iostream>
#include "HIDController.h"

using namespace std;

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

    report.buttons = 0;
    report.left_x = 0;
    report.left_y = 0;
    report.right_x = 0;
    report.right_y = 0;
}

void HIDController::setBit(int bitIndex, bool value, uint16_t *ptr){
    if (value){
        *ptr |= 1 << bitIndex;
    }else{
        *ptr &= ~(1 << bitIndex);
    }
    logBits();
}

bool HIDController::isButtonAPressed() const {
    return mButtonAPressed;
}

void HIDController::setButtonAPressed(bool buttonAPressed) {
    HIDController::mButtonAPressed = buttonAPressed;
    setBit(0, buttonAPressed, &report.buttons);
}

bool HIDController::isButtonBPressed() const {
    return mButtonBPressed;
}

void HIDController::setButtonBPressed(bool buttonBPressed) {
    HIDController::mButtonBPressed = buttonBPressed;
    setBit(1, buttonBPressed, &report.buttons);
}

bool HIDController::isButtonXPressed() const {
    return mButtonXPressed;
}

void HIDController::setButtonXPressed(bool buttonXPressed) {
    HIDController::mButtonXPressed = buttonXPressed;
    setBit(2, buttonXPressed, &report.buttons);
}

bool HIDController::isButtonYPressed() const {
    return mButtonYPressed;
}

void HIDController::setButtonYPressed(bool buttonYPressed) {
    HIDController::mButtonYPressed = buttonYPressed;
    setBit(3, buttonYPressed, &report.buttons);
}

bool HIDController::isDpadUpPressed() const {
    return mDpadUpPressed;
}

void HIDController::setDpadUpPressed(bool dpadUpPressed) {
    HIDController::mDpadUpPressed = dpadUpPressed;
    setBit(4, dpadUpPressed, &report.buttons);
}

bool HIDController::isDpadRightPressed() const {
    return mDpadRightPressed;
}

void HIDController::setDpadRightPressed(bool dpadRightPressed) {
    HIDController::mDpadRightPressed = dpadRightPressed;
    setBit(5, dpadRightPressed, &report.buttons);
}

bool HIDController::isDpadDownPressed() const {
    return mDpadDownPressed;
}

void HIDController::setDpadDownPressed(bool dpadDownPressed) {
    HIDController::mDpadDownPressed = dpadDownPressed;
    setBit(6, dpadDownPressed, &report.buttons);
}

bool HIDController::isDpadLeftPressed() const {
    return mDpadLeftPressed;
}

void HIDController::setDpadLeftPressed(bool dpadLeftPressed) {
    HIDController::mDpadLeftPressed = dpadLeftPressed;
    setBit(7, dpadLeftPressed, &report.buttons);
}

bool HIDController::isLeftShoulderPressed() const {
    return mLeftShoulderPressed;
}

void HIDController::setLeftShoulderPressed(bool leftShoulderPressed) {
    HIDController::mLeftShoulderPressed = leftShoulderPressed;
    setBit(8, leftShoulderPressed, &report.buttons);
}

bool HIDController::isLeftTriggerPressed() const {
    return mLeftTriggerPressed;
}

void HIDController::setLeftTriggerPressed(bool leftTriggerPressed) {
    HIDController::mLeftTriggerPressed = leftTriggerPressed;
    setBit(9, leftTriggerPressed, &report.buttons);
}

bool HIDController::isRightShoulderPressed() const {
    return mRightShoulderPressed;
}

void HIDController::setRightShoulderPressed(bool rightShoulderPressed) {
    HIDController::mRightShoulderPressed = rightShoulderPressed;
    setBit(10, rightShoulderPressed, &report.buttons);
}

bool HIDController::isRightTriggerPressed() const {
    return mRightTriggerPressed;
}

void HIDController::setRightTriggerPressed(bool rightTriggerPressed) {
    HIDController::mRightTriggerPressed = rightTriggerPressed;
    setBit(11, rightTriggerPressed, &report.buttons);
}

bool HIDController::isPauseButtonPressed() const {
    return mPauseButtonPressed;
}

void HIDController::setPauseButtonPressed(bool pauseButtonPressed) {
    HIDController::mPauseButtonPressed = pauseButtonPressed;
    setBit(12, pauseButtonPressed, &report.buttons);
}

float HIDController::getLeftAnalogueX() const {
    return mLeftAnalogueX;
}

void HIDController::setLeftAnalogueX(float leftAnalogueX) {
    HIDController::mLeftAnalogueX = leftAnalogueX;
}

float HIDController::getLeftAnalogueY() const {
    return mLeftAnalogueY;
}

void HIDController::setLeftAnalogueY(float leftAnalogueY) {
    HIDController::mLeftAnalogueY = leftAnalogueY;
}

float HIDController::getRightAnalogueX() const {
    return mRightAnalogueX;
}

void HIDController::setRightAnalogueX(float rightAnalogueX) {
    HIDController::mRightAnalogueX = rightAnalogueX;
}

float HIDController::getRightAnalogueY() const {
    return mRightAnalogueY;
}

void HIDController::setRightAnalogueY(float rightAnalogueY) {
    HIDController::mRightAnalogueY = rightAnalogueY;
}

void HIDController::sendHIDMessage() {

}

void printBits(size_t const size, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;

    for (i=size-1;i>=0;i--)
    {
        for (j=7;j>=0;j--)
        {
            byte = (b[i] >> j) & 1;
            printf("%u", byte);
        }
    }
    puts("");
}

void HIDController::logBits() {
    printBits(sizeof(uint16_t), &report.buttons);
}
