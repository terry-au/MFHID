//
// Created by Terry Lewis on 11/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <cmath>
#include "Vector2D.h"

const Vector2D Vector2D::sZeroVector = Vector2D(0.0f, 0.0f);

Vector2D::Vector2D(float mX, float mY) : mX(mX), mY(mY) {
}

float Vector2D::magnitude() {
    return sqrt(mX * mX + mY * mY);
}

float Vector2D::getX() const {
    return mX;
}

void Vector2D::setMX(float mX) {
    Vector2D::mX = mX;
}

float Vector2D::getY() const {
    return mY;
}

void Vector2D::setMY(float mY) {
    Vector2D::mY = mY;
}

const Vector2D Vector2D::zero() {
    return sZeroVector;
}
