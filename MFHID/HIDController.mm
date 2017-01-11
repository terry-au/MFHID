//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <cstdint>
#import <iostream>
#import <IOKit/IOKitLib.h>
#import <thread>
#import <cmath>
#import "HIDController.h"

using namespace std;

#define SERVICE_NAME "it_unbit_foohid"

#define FOOHID_CREATE 0  // create selector
#define FOOHID_SEND 2  // send selector

#define DEVICE_NAME "MFIHID Gamepad"
#define DEVICE_SN "SN 123456"

#define ANALOGUE_STICK_MAX 127

uint32_t const input_count = INPUT_COUNT;

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
    // Buttons
    mButtonAPressed = false;
    mButtonBPressed = false;
    mButtonXPressed = false;
    mButtonYPressed = false;
    
    mDpadUpPressed = false;
    mDpadRightPressed = false;
    mDpadDownPressed = false;
    mDpadLeftPressed = false;
    
    mLeftShoulderPressed = false;
    mLeftTriggerPressed = false;
    
    mRightShoulderPressed = false;
    mRightTriggerPressed = false;
    
    mPauseButtonPressed = false;
    
    // Analogue sticks.
    mLeftThumbstickX = 0;
    mLeftThumbstickY = 0;
    
    mRightThumbstickX = 0;
    mRightThumbstickY = 0;

    mReport.buttons = 0;
    mReport.left_x = 0;
    mReport.left_y = 0;
    mReport.right_x = 0;
    mReport.right_y = 0;
    logJoysticks();

    mDriverInitialised = false;
}

//typedef NS_ENUM(int8_t, joystick_axis_t){
//
//};

void HIDController::updateHidButtonState(int bitIndex, bool value, uint16_t *ptr){
    // If there is a change, update the bits.
    if (((*ptr >> bitIndex) & 1) != value){
        if (value){
            *ptr |= 1 << bitIndex;
        }else{
            *ptr &= ~(1 << bitIndex);
        }
#if DEBUG == 1
        logBits();
#endif
        invokeDriver();
    }
}

void HIDController::updateJoystickState(float xValue, int8_t *xStick, float yValue, int8_t *yStick, joystick_side_t joystickSide) {
    if (joystickSide == JoystickLeft && HIDController::isLeftThumbstickDeadzoneEnabled()){
        float deadzoneValue = HIDController::getLeftThumbstickDeadzoneValue();
        if (abs(xValue) < deadzoneValue){
            xValue = 0;
        }
        if (abs(yValue) < deadzoneValue){
            yValue = 0;
        }
    }else if (joystickSide == JoystickRight && HIDController::isRightThumbstickDeadzoneEnabled()){
        float deadzoneValue = HIDController::getRightThumbstickDeadzoneValue();
        if (abs(xValue) < deadzoneValue){
            xValue = 0;
        }
        if (abs(yValue) < deadzoneValue){
            yValue = 0;
        }
    }
    if (xStick){
        *xStick = xValue * ANALOGUE_STICK_MAX;
    }
    if (yStick){
        *yStick = yValue * ANALOGUE_STICK_MAX;
    }
#if DEBUG == 1
    logJoysticks();
#endif
    invokeDriver();
}

bool HIDController::isButtonAPressed() const {
    return mButtonAPressed;
}

void HIDController::setButtonAPressed(bool buttonAPressed) {
    HIDController::mButtonAPressed = buttonAPressed;
    updateHidButtonState(0, buttonAPressed, &mReport.buttons);
}

bool HIDController::isButtonBPressed() const {
    return mButtonBPressed;
}

void HIDController::setButtonBPressed(bool buttonBPressed) {
    HIDController::mButtonBPressed = buttonBPressed;
    updateHidButtonState(1, buttonBPressed, &mReport.buttons);
}

bool HIDController::isButtonXPressed() const {
    return mButtonXPressed;
}

void HIDController::setButtonXPressed(bool buttonXPressed) {
    HIDController::mButtonXPressed = buttonXPressed;
    updateHidButtonState(2, buttonXPressed, &mReport.buttons);
}

bool HIDController::isButtonYPressed() const {
    return mButtonYPressed;
}

void HIDController::setButtonYPressed(bool buttonYPressed) {
    HIDController::mButtonYPressed = buttonYPressed;
    updateHidButtonState(3, buttonYPressed, &mReport.buttons);
}

bool HIDController::isDpadUpPressed() const {
    return mDpadUpPressed;
}

void HIDController::setDpadUpPressed(bool dpadUpPressed) {
    HIDController::mDpadUpPressed = dpadUpPressed;
    updateHidButtonState(4, dpadUpPressed, &mReport.buttons);
}

bool HIDController::isDpadRightPressed() const {
    return mDpadRightPressed;
}

void HIDController::setDpadRightPressed(bool dpadRightPressed) {
    HIDController::mDpadRightPressed = dpadRightPressed;
    updateHidButtonState(5, dpadRightPressed, &mReport.buttons);
}

bool HIDController::isDpadDownPressed() const {
    return mDpadDownPressed;
}

void HIDController::setDpadDownPressed(bool dpadDownPressed) {
    HIDController::mDpadDownPressed = dpadDownPressed;
    updateHidButtonState(6, dpadDownPressed, &mReport.buttons);
}

bool HIDController::isDpadLeftPressed() const {
    return mDpadLeftPressed;
}

void HIDController::setDpadLeftPressed(bool dpadLeftPressed) {
    HIDController::mDpadLeftPressed = dpadLeftPressed;
    updateHidButtonState(7, dpadLeftPressed, &mReport.buttons);
}

bool HIDController::isLeftShoulderPressed() const {
    return mLeftShoulderPressed;
}

void HIDController::setLeftShoulderPressed(bool leftShoulderPressed) {
    HIDController::mLeftShoulderPressed = leftShoulderPressed;
    updateHidButtonState(8, leftShoulderPressed, &mReport.buttons);
}

bool HIDController::isLeftTriggerPressed() const {
    return mLeftTriggerPressed;
}

void HIDController::setLeftTriggerPressed(bool leftTriggerPressed) {
    HIDController::mLeftTriggerPressed = leftTriggerPressed;
    updateHidButtonState(9, leftTriggerPressed, &mReport.buttons);
}

bool HIDController::isRightShoulderPressed() const {
    return mRightShoulderPressed;
}

void HIDController::setRightShoulderPressed(bool rightShoulderPressed) {
    HIDController::mRightShoulderPressed = rightShoulderPressed;
    updateHidButtonState(10, rightShoulderPressed, &mReport.buttons);
}

bool HIDController::isRightTriggerPressed() const {
    return mRightTriggerPressed;
}

void HIDController::setRightTriggerPressed(bool rightTriggerPressed) {
    HIDController::mRightTriggerPressed = rightTriggerPressed;
    updateHidButtonState(11, rightTriggerPressed, &mReport.buttons);
}

bool HIDController::isPauseButtonPressed() const {
    return mPauseButtonPressed;
}

void HIDController::setPauseButtonPressed(bool pauseButtonPressed) {
    HIDController::mPauseButtonPressed = pauseButtonPressed;
    updateHidButtonState(12, pauseButtonPressed, &mReport.buttons);
}

float HIDController::getLeftThumbstickX() const {
    return mLeftThumbstickX;
}

void HIDController::setLeftThumbstickX(float leftThumbstickX) {
    HIDController::mLeftThumbstickX = leftThumbstickX;
    updateJoystickState(leftThumbstickX, &mReport.left_x, 0, nullptr, JoystickLeft);
}

float HIDController::getLeftThumbstickY() const {
    return mLeftThumbstickY;
}

void HIDController::setLeftThumbstickY(float leftThumbstickY) {
    HIDController::mLeftThumbstickY = leftThumbstickY;
    updateJoystickState(leftThumbstickY, &mReport.left_y, 0, nullptr, JoystickLeft);
}

float HIDController::getRightThumbstickX() const {
    return mRightThumbstickX;
}

void HIDController::setRightThumbstickX(float rightThumbstickX) {
    HIDController::mRightThumbstickX = rightThumbstickX;
    updateJoystickState(rightThumbstickX, &mReport.right_x, 0, nullptr, JoystickRight);
}

float HIDController::getRightThumbstickY() const {
    return mRightThumbstickY;
}

void HIDController::setRightThumbstickY(float rightThumbstickY) {
    HIDController::mRightThumbstickY = rightThumbstickY;
    updateJoystickState(rightThumbstickY, &mReport.right_y, 0, nullptr, JoystickRight);
}

void HIDController::setLeftThumbstickXY(float leftThumbstickX, float leftThumbstickY) {
    HIDController::mLeftThumbstickX = leftThumbstickX;
    HIDController::mLeftThumbstickY = leftThumbstickY;
    updateJoystickState(leftThumbstickX, &mReport.left_x, leftThumbstickY, &mReport.left_y, JoystickLeft);
}

void HIDController::setRightThumbstickXY(float rightThumbstickX, float rightThumbstickY) {
    HIDController::mRightThumbstickX = rightThumbstickX;
    HIDController::mRightThumbstickX = rightThumbstickX;
    updateJoystickState(rightThumbstickX, &mReport.right_x, rightThumbstickY, &mReport.right_y, JoystickRight);
}

bool HIDController::isLeftThumbstickDeadzoneEnabled() const {
    return mLeftThumbstickDeadzoneEnabled;
}

void HIDController::setLeftThumbstickDeadzoneEnabled(bool leftThumbstickDeadzoneEnabled) {
    HIDController::mLeftThumbstickDeadzoneEnabled = leftThumbstickDeadzoneEnabled;
}

bool HIDController::isRightThumbstickDeadzoneEnabled() const {
    return mRightThumbstickDeadzoneEnabled;
}

void HIDController::setRightThumbstickDeadzoneEnabled(bool rightThumbstickDeadzoneEnabled) {
    HIDController::mRightThumbstickDeadzoneEnabled = rightThumbstickDeadzoneEnabled;
}

float HIDController::getLeftThumbstickDeadzoneValue() const {
    return mLeftThumbstickDeadzone;
}

void HIDController::setLeftThumbstickDeadzoneValue(float leftThumbstickeDeadzoneValue) {
    HIDController::mLeftThumbstickDeadzone = leftThumbstickeDeadzoneValue;
}

float HIDController::getRightThumbstickDeadzoneValue() const {
    return mRightThumbstickDeadzone;
}

void HIDController::setRightThumbstickDeadzoneValue(float rightThumbstickDeadzoneValue) {
    HIDController::mRightThumbstickDeadzone = rightThumbstickDeadzoneValue;
}

void HIDController::invokeDriver() {
    if (!mDriverInitialised){
        initialiseDriver();
    }
    
    sendHIDMessage();
}

void HIDController::sendHIDMessage() {
    // Arguments to be passed through the HID message.
    uint32_t send_count = 4;
    uint64_t send[send_count];
    send[0] = (uint64_t)mInput[0];  // device name
    send[1] = strlen((char *)mInput[0]);  // name length
    send[2] = (uint64_t) &mReport;  // mouse struct
    send[3] = sizeof(struct gamepad_report_t);  // mouse struct len

    kern_return_t ret = IOConnectCallScalarMethod(mIoConnect, FOOHID_SEND, send, send_count, NULL, 0);
    if (ret != KERN_SUCCESS) {
        printf("Unable to send message to HID device.\n");
    }else{
        cout << "Sending " << mReport.buttons << endl;
    }
}

void HIDController::initialiseDriver() {
    if (mDriverInitialised){
        cout << "Driver already initialised." << endl;
        return;
    }
    
    mDriverInitialised = true;
    
    io_iterator_t ioIterator;
    io_service_t ioService;

    // Get a reference to the IOService
    kern_return_t ret = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(SERVICE_NAME), &ioIterator);

    if (ret != KERN_SUCCESS) {
        printf("Unable to access IOService.\n");
        exit(1);
    }

    // Iterate till success
    int found = 0;
    while ((ioService = IOIteratorNext(ioIterator)) != IO_OBJECT_NULL) {
        ret = IOServiceOpen(ioService, mach_task_self(), 0, &mIoConnect);

        if (ret == KERN_SUCCESS) {
            found = 1;
            break;
        }

        IOObjectRelease(ioService);
    }
    IOObjectRelease(ioIterator);

    if (!found) {
        printf("Unable to open IOService.\n");
        exit(1);
    }

    // Fill up the input arguments.
    mInput[0] = (uint64_t) strdup(DEVICE_NAME);  // device name
    mInput[1] = strlen((char *)mInput[0]);  // name length
    mInput[2] = (uint64_t) report_descriptor;  // report descriptor
    mInput[3] = sizeof(report_descriptor);  // report descriptor len
    mInput[4] = (uint64_t) strdup(DEVICE_SN);  // serial number
    mInput[5] = strlen((char *)mInput[4]);  // serial number len
    mInput[6] = (uint64_t) 2;  // vendor ID
    mInput[7] = (uint64_t) 3;  // device ID

    ret = IOConnectCallScalarMethod(mIoConnect, FOOHID_CREATE, mInput, input_count, NULL, 0);
    if (ret != KERN_SUCCESS) {
        printf("Unable to create HID device. May be fine if created previously.\n");
    }
}

void HIDController::logBits() {
    cout << bitset<sizeof(mReport.buttons) * CHAR_BIT>(mReport.buttons) << endl;
}

void HIDController::logJoysticks() {
    cout << "L-X: " << (int)mReport.left_x << endl << "L-Y: " << (int)mReport.left_y << endl;
    cout << "R-X: " << (int)mReport.right_x << endl << "R-Y: " << (int)mReport.right_y << endl;
}
