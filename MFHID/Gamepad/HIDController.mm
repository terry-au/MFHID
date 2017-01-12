//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <cstdint>
#import <iostream>
#import <IOKit/IOKitLib.h>
#import <cmath>
#import "HIDController.h"
#import "HIDBridgedGamepad.h"
#import "Vector2D.h"

using namespace std;

#define SERVICE_NAME "it_unbit_foohid"

#define FOOHID_CREATE   0   // create selector
#define FOOHID_DESTROY  1   // destroy selector
#define FOOHID_SEND     2   // send selector
#define FOOHID_LIST     3   // list selector

#define DEVICE_NAME "MFHID Gamepad"
#define DEVICE_SN "SN 121212"

#define ANALOGUE_STICK_MAX 127

uint32_t const input_count = INPUT_COUNT;

unsigned char report_descriptor[52] = {
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

HIDController::HIDController(HIDBridgedGamepad *gamepad) {
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
    mLeftThumbStick = Vector2D::zero();
    mRightThumbStick = Vector2D::zero();

    mReport.buttons = 0;
    mReport.left_x = 0;
    mReport.left_y = 0;
    mReport.right_x = 0;
    mReport.right_y = 0;

    for (int i = 0; i < mSendMessage.field_count; ++i) {
        mSendMessage.fields[i] = 0;
    }

    mDriverInitialised = false;

    mBridgedGamepad = gamepad;
}

void HIDController::listDevices() {
    uint32_t output_count = 2;
    uint64_t output[2] = {0, 0};

    uint16_t buf_len = 4096;
    char *buf = new char(buf_len);
    uint64_t input[2];
    input[0] = (uint64_t) buf;
    input[1] = (uint64_t) buf_len;
    kern_return_t ret = IOConnectCallScalarMethod(mIoConnect, FOOHID_LIST, input, 2, output, &output_count);
    if (ret == KERN_SUCCESS) {
        cout << "Listing devices: successful." << buf << endl;
        delete buf;
    } else {
        cout << "Listing devices: unsuccessful." << endl;
    }
}

HIDController::~HIDController() {
    HIDController::mBridgedGamepad = nil;
    if (mDriverInitialised) {
        uint32_t send_count = 2;
        uint64_t send[send_count];
        send[0] = (uint64_t) mInput[0];  // device name
        send[1] = strlen((char *) mInput[0]);  // name length

        kern_return_t ret = IOConnectCallScalarMethod(mIoConnect, FOOHID_DESTROY, send, send_count, NULL, 0);
        if (ret == KERN_SUCCESS) {
            cout << "Successfully destroyed foohid device." << endl;
        } else {
            cout << "Unable to destroy foohid device." << endl;;
        }
        IOObjectRelease(mIoConnect);
    }
}

//typedef NS_ENUM(int8_t, joystick_axis_t){
//
//};

void HIDController::updateHidButtonState(int bitIndex, bool value, uint16_t *ptr) {
    // If there is a change, update the bits.
    if (((*ptr >> bitIndex) & 1) != value) {
        if (value) {
            *ptr |= 1 << bitIndex;
        } else {
            *ptr &= ~(1 << bitIndex);
        }
#if DEBUG == 1
        logButtons();
#endif
        invokeDriver();
    }
}

void HIDController::updateJoystickState(float xValue, int8_t *xStick, float yValue, int8_t *yStick) {
    if (xStick) {
        *xStick = xValue * ANALOGUE_STICK_MAX;
    }
    if (yStick) {
        *yStick = yValue * ANALOGUE_STICK_MAX;
    }
#if DEBUG == 1
    logThumbticks();
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

const Vector2D &HIDController::getLeftThumbStick() const {
    return mLeftThumbStick;
}

void HIDController::setLeftThumbStick(const Vector2D &mLeftThumbStick) {
    HIDController::mLeftThumbStick = mLeftThumbStick;
    updateJoystickState(mLeftThumbStick.getX(), &mReport.left_x, mLeftThumbStick.getY(), &mReport.left_y);
}

const Vector2D &HIDController::getRightThumbStick() const {
    return mRightThumbStick;
}

void HIDController::setRightThumbStick(const Vector2D &mRightThumbStick) {
    HIDController::mRightThumbStick = mRightThumbStick;
    updateJoystickState(mRightThumbStick.getX(), &mReport.right_x, mRightThumbStick.getY(), &mReport.right_y);
}

HIDBridgedGamepad *HIDController::getBridgedGamepad() const {
    return HIDController::mBridgedGamepad;
}

void HIDController::setBridgedGamepad(HIDBridgedGamepad *bridgedGamepad) {
    HIDController::mBridgedGamepad = bridgedGamepad;
}

void HIDController::invokeDriver() {
    if (!mDriverInitialised) {
        if (!initialiseDriver()){
            return;
        }
    }

    sendHIDMessage();
}

bool HIDController::initialiseDriver() {
    if (HIDController::mDriverInitialised){
        return true;
    }
    io_iterator_t ioIterator;
    io_service_t ioService;

    // Get a reference to the IOService
    kern_return_t ret = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(SERVICE_NAME), &ioIterator);

    if (ret != KERN_SUCCESS) {
        cout << "Unable to access IOService." << endl;
        [HIDController::getBridgedGamepad() onFailedToInitialiseDriver];
        IOObjectRelease(ioIterator);
        return false;
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
        cout << "Unable to open IOService." << endl;
        [HIDController::getBridgedGamepad() onFailedToInitialiseDriver];
        if (ioService){
            IOObjectRelease(ioService);
        }
        return false;
    }

    // Fill up the input arguments.
    mInput[0] = (uint64_t) strdup(DEVICE_NAME);     // device name
    mInput[1] = strlen((char *) mInput[0]);          // name length
    mInput[2] = (uint64_t) report_descriptor;       // report descriptor
    mInput[3] = sizeof(report_descriptor);          // report descriptor len
    mInput[4] = (uint64_t) strdup(DEVICE_SN);       // serial number
    mInput[5] = strlen((char *) mInput[4]);          // serial number len
    mInput[6] = (uint64_t) 1;                       // vendor ID
    mInput[7] = (uint64_t) 2;                       // device ID

    ret = IOConnectCallScalarMethod(mIoConnect, FOOHID_CREATE, mInput, input_count, NULL, 0);
    if (ret != KERN_SUCCESS) {
        cout << "Unable to create HID device. May be fine if created previously." << endl;
    }

#if DEBUG == 1
    cout << "IOConnect [Initialise]: " << &mIoConnect << endl;
#endif
    mDriverInitialised = true;
    return true;
}

void HIDController::sendHIDMessage() {
    // Arguments to be passed through the HID message.

//    uint32_t field_count = 4;
//    uint64_t fields[field_count];
    mSendMessage.fields[0] = (uint64_t) mInput[0];  // device name
    mSendMessage.fields[1] = strlen((char *) mInput[0]);  // name length
    mSendMessage.fields[2] = (uint64_t) &mReport;  // mouse struct
    mSendMessage.fields[3] = sizeof(struct gamepad_report_t);  // mouse struct len

    kern_return_t ret = IOConnectCallScalarMethod(mIoConnect, FOOHID_SEND, mSendMessage.fields, mSendMessage.field_count, NULL, 0);
    if (ret != KERN_SUCCESS) {
        cout << "Unable to send message to HID device" << endl;
    }
}

void HIDController::logButtons() {
    cout << bitset<sizeof(mReport.buttons) * CHAR_BIT>(mReport.buttons) << endl;
}

void HIDController::logThumbticks() {
    cout << "L-X: " << (int) mReport.left_x << endl << "L-Y: " << (int) mReport.left_y << endl;
    cout << "R-X: " << (int) mReport.right_x << endl << "R-Y: " << (int) mReport.right_y << endl;
}

void HIDController::sendEmptyState() {
    if (allButtonsReleased()) {
        sendHIDMessage();
    }
}

bool HIDController::allButtonsReleased() {
    return mReport.buttons == 0 &&
            mReport.left_x == 0 &&
            mReport.left_y == 0 &&
            mReport.right_x == 0 &&
            mReport.right_y == 0;
}
