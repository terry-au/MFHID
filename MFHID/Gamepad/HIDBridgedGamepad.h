//
//  HIDBridgedGamepad.h
//  MFHID
//
//  Created by Terry Lewis on 10/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameController/GameController.h>

typedef NS_ENUM(NSInteger, HIDBridgedGamepadStatus){
    HIDBridgedGamepadStatusConnected,
    HIDBridgedGamepadStatusDisconnected,
};

typedef NS_ENUM(NSInteger, HIDBridgedGamepadDriverError){
    HIDBridgedGamepadDriverErrorUnknown = -1,
    HIDBridgedGamepadDriverErrorNone,
    HIDBridgedGamepadDriverErrorDriverNotFound,
    HIDBridgedGamepadDriverErrorFailedToLoadDriver
};

@class HIDBridgedGamepad;

@protocol HIDBridgedGamepadDelegate <NSObject>
- (void)bridgedGamepadDidUpdateStatus:(HIDBridgedGamepad *)bridgedGamepad;

- (void)bridgedGamepadFailedInitialise:(HIDBridgedGamepad *)bridgedGamepad driverError:(HIDBridgedGamepadDriverError)driverError;
@end

typedef NS_ENUM(NSInteger, HIDBridgedGamepadType){
    HIDBridgedGamepadTypeStandard,
    HIDBridgedGamepadTypeExtended
};

@interface HIDBridgedGamepad : NSObject


/**
 Initialises a HIDBridgedGamepad using an MFI gamepad.

 @param gamepad A GCGamepad or a GCExtendedGamepad.
 @return An HIDBridgedGamepad using an MFI gamepad.
 */
- (instancetype)initWithController:(GCController *)controller;

// A GCGamepad or a GCExtendedGamepad.
@property (nonatomic, retain, readonly) id gamepad;
@property (nonatomic, retain, readonly) GCController *controller;
@property (readonly) HIDBridgedGamepadType gamepadType;
//@property (nonatomic, readonly) BOOL active;
@property (nonatomic) BOOL leftThumbstickDeadzoneEnabled;
@property (nonatomic) BOOL rightThumbstickDeadzoneEnabled;
@property (nonatomic) float leftThumbstickDeadzone;
@property (nonatomic) float rightThumbstickDeadzone;
@property (nonatomic, strong) id <HIDBridgedGamepadDelegate> delegate;
@property (nonatomic) HIDBridgedGamepadStatus status;

- (void)activate;
- (void)deactivate;

- (NSString *)localisedControllerTypeString;

- (void)onFailedToInitialiseDriver;

- (NSString *)localisedStatusString;
@end
