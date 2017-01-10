//
//  GamepadManager.m
//  MFHID
//
//  Created by Terry Lewis on 10/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "ControllerManager.h"

@implementation ControllerManager

+ (instancetype)sharedInstance{
    static ControllerManager *sharedIntance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIntance = [[self alloc] init];
    });
    return sharedIntance;
}

@end
