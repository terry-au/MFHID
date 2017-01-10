//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#ifndef MFHID_HIDCONTROLLER_H
#define MFHID_HIDCONTROLLER_H


class HIDController {
    bool buttonAPressed;
    bool buttonBPressed;
    bool buttonXPressed;
    bool buttonYPressed;

    bool dpadUpPressed;
    bool dpadRightPressed;
    bool dpadDownPressed;
    bool dpadLeftPressed;

    bool leftShoulderPressed;
    bool leftTriggerPressed;

    bool rightShoulderPressed;
    bool rightTriggerPressed;

    bool pauseButtonPressed;

    float leftAnalogueX;
    float leftAnalogueY;

    float rightAnalogueX;
    float rightAnalogueY;
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
};


#endif //MFHID_HIDCONTROLLER_H
