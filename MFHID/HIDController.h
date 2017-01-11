//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#ifndef MFHID_HIDCONTROLLER_H
#define MFHID_HIDCONTROLLER_H

#define INPUT_COUNT 8

struct gamepad_report_t{
    uint16_t buttons;
    int8_t left_x;
    int8_t left_y;
    int8_t right_x;
    int8_t right_y;
};

class HIDController {
public:
    HIDController();

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

    float getLeftAnalogueX() const;

    void setLeftAnalogueX(float leftAnalogueX);

    float getLeftAnalogueY() const;

    void setLeftAnalogueY(float leftAnalogueY);

    float getRightAnalogueX() const;

    void setRightAnalogueX(float rightAnalogueX);

    float getRightAnalogueY() const;

    void setRightAnalogueY(float rightAnalogueY);

    void setLeftAnalogueXY(float leftAnalogueX, float leftAnalogueY);

    void setRightAnalogueXY(float rightAnalogueX, float rightAnalogueY);

private:
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
    float mLeftAnalogueX;
    float mLeftAnalogueY;

    float mRightAnalogueX;
    float mRightAnalogueY;

    // Deadzones
    float rightAnalogueDeadzone;
public:
    float getRightAnalogueDeadzone() const;

    void setRightAnalogueDeadzone(float rightAnalogueDeadzone);

    float getLeftAnalogueDeadzone() const;

    void setLeftAnalogueDeadzone(float leftAnalogueDeadzone);

private:
    float leftAnalogueDeadzone;

    // Interface.
    bool mDriverInitialised;
    gamepad_report_t mReport;
    uint64_t mInput[INPUT_COUNT];
    io_connect_t mIoConnect;

    void logBits();

    void invokeDriver();

    void updateHidButtonState(int bitIndex, bool value, uint16_t *ptr);

    void sendHIDMessage();

    void initialiseDriver();

    void updateJoystickState(float leftXValue, int8_t *leftXStick, float leftYValue, int8_t *leftYStick);

    void logJoysticks();
};


#endif //MFHID_HIDCONTROLLER_H
