//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#ifndef MFHID_HIDCONTROLLER_H
#define MFHID_HIDCONTROLLER_H

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

enum joystick_side_t{
    JoystickLeft,
    JoystickRight,
};

class HIDController {
public:
    HIDController();
    ~HIDController();
    
    void initialiseDriver();

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

    float getLeftThumbstickX() const;

    void setLeftThumbstickX(float leftThumbstickX);

    float getLeftThumbstickY() const;

    void setLeftThumbstickY(float leftThumbstickY);

    float getRightThumbstickX() const;

    void setRightThumbstickX(float rightThumbstickX);

    float getRightThumbstickY() const;

    void setRightThumbstickY(float rightThumbstickY);

    void setLeftThumbstickXY(float leftThumbstickX, float leftThumbstickY);

    void setRightThumbstickXY(float rightThumbstickX, float rightThumbstickY);

    bool isLeftThumbstickDeadzoneEnabled() const;

    void setLeftThumbstickDeadzoneEnabled(bool leftThumbstickDeadzoneEnabled);

    bool isRightThumbstickDeadzoneEnabled() const;

    void setRightThumbstickDeadzoneEnabled(bool rightThumbstickDeadzoneEnabled);

    float getRightThumbstickDeadzoneValue() const;

    void setRightThumbstickDeadzoneValue(float rightThumbstickDeadzoneValue);

    float getLeftThumbstickDeadzoneValue() const;

    void setLeftThumbstickDeadzoneValue(float leftThumbstickeDeadzoneValue);

    HIDBridgedGamepad *getBridgedGamepad() const;

    void setBridgedGamepad(HIDBridgedGamepad *bridgedGamepad);

    void sendEmptyState();

private:

    // Interface.
    bool mDriverInitialised;
    gamepad_report_t mReport;
    uint64_t mInput[INPUT_COUNT];
    io_connect_t mIoConnect;
    struct foohid_message_send mSendMessage;

    // Callback
    CFTypeRef mBridgedGamepad;

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
    float mLeftThumbstickX;
    float mLeftThumbstickY;

    float mRightThumbstickX;
    float mRightThumbstickY;

    // Deadzones
    bool mLeftThumbstickDeadzoneEnabled;
    bool mRightThumbstickDeadzoneEnabled;
    float mLeftThumbstickDeadzone;
    float mRightThumbstickDeadzone;

    void logBits();

    void invokeDriver();

    void updateHidButtonState(int bitIndex, bool value, uint16_t *ptr);

    void sendHIDMessage();
    
    void listDevices();

    void updateJoystickState(float xValue, int8_t *xStick, float yValue, int8_t *yStick, joystick_side_t joystickSide);

    void logJoysticks();

    bool allButtonsReleased();

    float getAdjustedLeftDeadzoneValue() const;

    float getAdjustedRightDeadzoneValue() const;
};


#endif //MFHID_HIDCONTROLLER_H
