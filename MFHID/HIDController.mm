//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <cstdint>
#import <iostream>
#include <IOKit/IOKitLib.h>
#import <thread>
#include "HIDController.h"

using namespace std;

#define SERVICE_NAME "it_unbit_foohid"

#define FOOHID_CREATE 0  // create selector
#define FOOHID_SEND 2  // send selector

#define DEVICE_NAME "Foohid Virtual Gamepad"
#define DEVICE_SN "SN 123456"

#define ANALOGUE_MIN -127
#define ANALOGUE_MAX 127

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

    mReport.buttons = 0;
    mReport.left_x = 0;
    mReport.left_y = 0;
    mReport.right_x = 0;
    mReport.right_y = 0;

    mDriverInvoked = false;
}

void HIDController::setBit(int bitIndex, bool value, uint16_t *ptr){
    // If there is a change, update the bits.
    if (((*ptr >> bitIndex) & 1) != value){
        if (value){
            *ptr |= 1 << bitIndex;
        }else{
            *ptr &= ~(1 << bitIndex);
        }
        logBits();
        if (mDriverInvoked == false){
            invokeDriverThreadIfRequired();
        }
    }
}

bool HIDController::isButtonAPressed() const {
    return mButtonAPressed;
}

void HIDController::setButtonAPressed(bool buttonAPressed) {
    HIDController::mButtonAPressed = buttonAPressed;
    setBit(0, buttonAPressed, &mReport.buttons);
}

bool HIDController::isButtonBPressed() const {
    return mButtonBPressed;
}

void HIDController::setButtonBPressed(bool buttonBPressed) {
    HIDController::mButtonBPressed = buttonBPressed;
    setBit(1, buttonBPressed, &mReport.buttons);
}

bool HIDController::isButtonXPressed() const {
    return mButtonXPressed;
}

void HIDController::setButtonXPressed(bool buttonXPressed) {
    HIDController::mButtonXPressed = buttonXPressed;
    setBit(2, buttonXPressed, &mReport.buttons);
}

bool HIDController::isButtonYPressed() const {
    return mButtonYPressed;
}

void HIDController::setButtonYPressed(bool buttonYPressed) {
    HIDController::mButtonYPressed = buttonYPressed;
    setBit(3, buttonYPressed, &mReport.buttons);
}

bool HIDController::isDpadUpPressed() const {
    return mDpadUpPressed;
}

void HIDController::setDpadUpPressed(bool dpadUpPressed) {
    HIDController::mDpadUpPressed = dpadUpPressed;
    setBit(4, dpadUpPressed, &mReport.buttons);
}

bool HIDController::isDpadRightPressed() const {
    return mDpadRightPressed;
}

void HIDController::setDpadRightPressed(bool dpadRightPressed) {
    HIDController::mDpadRightPressed = dpadRightPressed;
    setBit(5, dpadRightPressed, &mReport.buttons);
}

bool HIDController::isDpadDownPressed() const {
    return mDpadDownPressed;
}

void HIDController::setDpadDownPressed(bool dpadDownPressed) {
    HIDController::mDpadDownPressed = dpadDownPressed;
    setBit(6, dpadDownPressed, &mReport.buttons);
}

bool HIDController::isDpadLeftPressed() const {
    return mDpadLeftPressed;
}

void HIDController::setDpadLeftPressed(bool dpadLeftPressed) {
    HIDController::mDpadLeftPressed = dpadLeftPressed;
    setBit(7, dpadLeftPressed, &mReport.buttons);
}

bool HIDController::isLeftShoulderPressed() const {
    return mLeftShoulderPressed;
}

void HIDController::setLeftShoulderPressed(bool leftShoulderPressed) {
    HIDController::mLeftShoulderPressed = leftShoulderPressed;
    setBit(8, leftShoulderPressed, &mReport.buttons);
}

bool HIDController::isLeftTriggerPressed() const {
    return mLeftTriggerPressed;
}

void HIDController::setLeftTriggerPressed(bool leftTriggerPressed) {
    HIDController::mLeftTriggerPressed = leftTriggerPressed;
    setBit(9, leftTriggerPressed, &mReport.buttons);
}

bool HIDController::isRightShoulderPressed() const {
    return mRightShoulderPressed;
}

void HIDController::setRightShoulderPressed(bool rightShoulderPressed) {
    HIDController::mRightShoulderPressed = rightShoulderPressed;
    setBit(10, rightShoulderPressed, &mReport.buttons);
}

bool HIDController::isRightTriggerPressed() const {
    return mRightTriggerPressed;
}

void HIDController::setRightTriggerPressed(bool rightTriggerPressed) {
    HIDController::mRightTriggerPressed = rightTriggerPressed;
    setBit(11, rightTriggerPressed, &mReport.buttons);
}

bool HIDController::isPauseButtonPressed() const {
    return mPauseButtonPressed;
}

void HIDController::setPauseButtonPressed(bool pauseButtonPressed) {
    HIDController::mPauseButtonPressed = pauseButtonPressed;
    setBit(12, pauseButtonPressed, &mReport.buttons);
}

float HIDController::getLeftAnalogueX() const {
    return mLeftAnalogueX;
}

void HIDController::setLeftAnalogueX(float leftAnalogueX) {
    mReport.right_y = ANALOGUE_MAX * leftAnalogueX;
    HIDController::mLeftAnalogueX = leftAnalogueX;
}

float HIDController::getLeftAnalogueY() const {
    return mLeftAnalogueY;
}

void HIDController::setLeftAnalogueY(float leftAnalogueY) {
    mReport.right_y = ANALOGUE_MAX * leftAnalogueY;
    HIDController::mLeftAnalogueY = leftAnalogueY;
}

float HIDController::getRightAnalogueX() const {
    return mRightAnalogueX;
}

void HIDController::setRightAnalogueX(float rightAnalogueX) {
    mReport.right_y = ANALOGUE_MAX * rightAnalogueX;
    HIDController::mRightAnalogueX = rightAnalogueX;
}

float HIDController::getRightAnalogueY() const {
    return mRightAnalogueY;
}

void HIDController::setRightAnalogueY(float rightAnalogueY) {
    mReport.right_y = ANALOGUE_MAX * rightAnalogueY;
    HIDController::mRightAnalogueY = rightAnalogueY;
}

void HIDController::invokeDriverThreadIfRequired() {
    if (mDriverInvoked){
        cout << "The driver has already been invoked." << endl;
        return;
    }
    mDriverInvoked = true;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sendHIDMessage();
    });
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
    printBits(sizeof(uint16_t), &mReport.buttons);
}

void HIDController::sendHIDMessage() {

    // Get a reference to the IOService
    kern_return_t ret = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(SERVICE_NAME), &mIoIterator);

    if (ret != KERN_SUCCESS) {
        printf("Unable to access IOService.\n");
        exit(1);
    }

    // Iterate till success
    int found = 0;
    while ((mIoService = IOIteratorNext(mIoIterator)) != IO_OBJECT_NULL) {
        ret = IOServiceOpen(mIoService, mach_task_self(), 0, &mIoConnect);

        if (ret == KERN_SUCCESS) {
            found = 1;
            break;
        }

        IOObjectRelease(mIoService);
    }
    IOObjectRelease(mIoIterator);

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

    // Arguments to be passed through the HID message.
    uint32_t send_count = 4;
    uint64_t send[send_count];
    send[0] = (uint64_t)mInput[0];  // device name
    send[1] = strlen((char *)mInput[0]);  // name length
    send[2] = (uint64_t) &mReport;  // mouse struct
    send[3] = sizeof(struct gamepad_report_t);  // mouse struct len

    for(;;) {
        ret = IOConnectCallScalarMethod(mIoConnect, FOOHID_SEND, send, send_count, NULL, 0);
        if (ret != KERN_SUCCESS) {
            printf("Unable to send message to HID device.\n");
        }

        usleep(10000000);  // sleep for a second
    }
}
