//
//  HIDBridgedGamepad.h
//  MFHID
//
//  Created by Terry Lewis on 10/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameController/GameController.h>

@class HIDBridgedGamepad;

@protocol HIDBridgedGamepadDelegate
- (void)bridgedGamepad:(HIDBridgedGamepad *)bridgedGamepad didUpdateStatus:()status;
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
@property (nonatomic, readonly) BOOL active;
@property (nonatomic) BOOL leftThumbstickDeadzoneEnabled;
@property (nonatomic) BOOL rightThumbstickDeadzoneEnabled;
@property (nonatomic) float leftThumbstickDeadzone;
@property (nonatomic) float rightThumbstickDeadzone;
@property (nonatomic) id <HIDBridgedGamepadDelegate> delegate;

- (void)activate;
- (void)deactivate;

- (NSString *)localisedControllerTypeString;

- (void)onFailedToInitialiseDriver;

@end
