//
//  GamepadManager.h
//  MFHID
//
//  Created by Terry Lewis on 10/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameController/GameController.h>

@interface ControllerManager : NSObject

+ (instancetype)sharedInstance;

- (void)searchForMFIControllersWithCallback:(void(^)(NSArray *gamepads))callback;
- (NSArray<GCController *> *)connectedMFIControllers;

// Needn't be more than one.
- (instancetype)init NS_UNAVAILABLE;

@end
