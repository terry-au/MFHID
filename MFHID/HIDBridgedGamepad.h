//
//  HIDBridgedGamepad.h
//  MFHID
//
//  Created by Terry Lewis on 10/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameController/GameController.h>

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

@end
