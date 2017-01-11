//
// Created by Terry Lewis on 11/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#ifndef MFHID_VECTOR2D_H
#define MFHID_VECTOR2D_H


class Vector2D {

private:
    float mX;
    float mY;
    static const Vector2D sZeroVector;
public:
    Vector2D(float mX, float mY);

    static const Vector2D zero();

    float getX() const;

    void setMX(float mX);

    float getY() const;

    void setMY(float mY);

    float magnitude();
};


#endif //MFHID_VECTOR2D_H
