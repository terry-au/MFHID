//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Settings : NSObject

@property (nonatomic) BOOL showDevicesWindowOnStart;

@property (nonatomic) BOOL showStatusBarIcon;

@property (nonatomic) BOOL showInDock;

//@property (nonatomic) float leftStickDeadzoneX;
//
//@property (nonatomic) float leftStickDeadzoneY;
//
//@property (nonatomic) float rightStickDeadzoneX;
//
//@property (nonatomic) float rightStickDeadzoneY;

@property (nonatomic) NSInteger leftStickDeadzone;

@property (nonatomic) NSInteger rightStickDeadzone;

+ (instancetype)sharedSettings;

- (void)loadSettings;
@end
