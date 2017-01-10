//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Settings : NSObject

@property (nonatomic) BOOL showDevicesWindowOnStart;

@property (nonatomic) BOOL showStatusBarIcon;

@property (nonatomic) float leftStickDeadzoneX;

@property (nonatomic) float leftStickDeadzoneY;

@property (nonatomic) float rightStickDeadzoneX;

@property (nonatomic) float rightStickDeadzoneY;

+ (instancetype)sharedSettings;

- (void)loadSettings;
@end