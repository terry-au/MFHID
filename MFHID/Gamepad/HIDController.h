//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#ifndef MFHID_HIDCONTROLLER_H
#define MFHID_HIDCONTROLLER_H

#import "Vector2D.h"

#define INPUT_COUNT 8

@class HIDBridgedGamepad;

struct gamepad_report_t{
    uint16_t buttons;
    int8_t left_x;
    int8_t left_y;
    int8_t right_x;
    int8_t right_y;
};

struct foohid_message_send{
    const uint32_t field_count = 4;
    uint64_t fields[4];
};

class HIDController {
public:
    HIDController(HIDBridgedGamepad *gamepad);

    ~HIDController();
    
    bool initialiseDriver();

    bool isButtonAPressed() const;

    void setButtonAPressed(bool buttonAPressed);

    bool isButtonBPressed() const;

    void setButtonBPressed(bool buttonBPressed);

    bool isButtonXPressed() const;

    void setButtonXPressed(bool buttonXPressed);

    bool isButtonYPressed() const;

    void setButtonYPressed(bool buttonYPressed);

    bool isDpadUpPressed() const;

    void setDpadUpPressed(bool dpadUpPressed);

    bool isDpadRightPressed() const;

    void setDpadRightPressed(bool dpadRightPressed);

    bool isDpadDownPressed() const;

    void setDpadDownPressed(bool dpadDownPressed);

    bool isDpadLeftPressed() const;

    void setDpadLeftPressed(bool dpadLeftPressed);

    bool isLeftShoulderPressed() const;

    void setLeftShoulderPressed(bool leftShoulderPressed);

    bool isLeftTriggerPressed() const;

    void setLeftTriggerPressed(bool leftTriggerPressed);

    bool isRightShoulderPressed() const;

    void setRightShoulderPressed(bool rightShoulderPressed);

    bool isRightTriggerPressed() const;

    void setRightTriggerPressed(bool rightTriggerPressed);

    bool isPauseButtonPressed() const;

    void setPauseButtonPressed(bool pauseButtonPressed);

    HIDBridgedGamepad *getBridgedGamepad() const;

    void setBridgedGamepad(HIDBridgedGamepad *bridgedGamepad);

    void sendEmptyState();

    const Vector2D &getLeftThumbStick() const;

    void setLeftThumbStick(const Vector2D &mLeftThumbStick);

    const Vector2D &getRightThumbStick() const;

    void setRightThumbStick(const Vector2D &mRightThumbStick);

private:

    // Interface.
    bool mDriverInitialised;
    gamepad_report_t mReport;
    uint64_t mInput[INPUT_COUNT];
    io_connect_t mIoConnect;
    struct foohid_message_send mSendMessage;

    // Callback
    HIDBridgedGamepad *mBridgedGamepad;

    // Buttons
    bool mButtonAPressed;
    bool mButtonBPressed;
    bool mButtonXPressed;
    bool mButtonYPressed;

    bool mDpadUpPressed;
    bool mDpadRightPressed;
    bool mDpadDownPressed;
    bool mDpadLeftPressed;

    bool mLeftShoulderPressed;
    bool mLeftTriggerPressed;

    bool mRightShoulderPressed;
    bool mRightTriggerPressed;

    bool mPauseButtonPressed;

    // Analogue sticks.
    Vector2D mLeftThumbStick;
    Vector2D mRightThumbStick;

    void logButtons();

    void invokeDriver();

    void updateHidButtonState(int bitIndex, bool value, uint16_t *ptr);

    void sendHIDMessage();
    
    void listDevices();

    void updateJoystickState(float xValue, int8_t *xStick, float yValue, int8_t *yStick);

    void logThumbticks();

    bool allButtonsReleased();
};


#endif //MFHID_HIDCONTROLLER_H
