//
// Created by Terry Lewis on 12/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import "FoohidDriverManager.h"
#import "STPrivilegedTask.h"

@implementation FoohidDriverManager {

}

typedef NS_ENUM(NSInteger, MFHIDCommand) {
    MFHIDCommandFixPermissions,
    MFHIDCommandDriverExists,
    MFHIDCommandDriverLoaded,
    MFHIDCommandLoadDriver,
    MFHIDCommandUnloadDriver,
    MFHIDCommandFixAndLoadDriver
};

+ (NSString *)stringForCommand:(MFHIDCommand)command {
    switch (command) {
        case MFHIDCommandFixPermissions:
            return @"--fixPermissions";
        case MFHIDCommandDriverExists:
            return @"--driverExists";
        case MFHIDCommandDriverLoaded:
            return @"--driverLoaded";
        case MFHIDCommandLoadDriver:
            return @"--fixAndLoadDriver";
        case MFHIDCommandUnloadDriver:
            return @"--unloadDriver";
        case MFHIDCommandFixAndLoadDriver:
            return @"--fixAndLoad";
    }
    return nil;
}

+ (BOOL)launchMFHIDHelperWithCommand:(MFHIDCommand)command result:(int *)result {
    NSString *argument = [self stringForCommand:command];
    if (!argument){
        return NO;
    }

    // Create task
    STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
    NSString *mfhidHelperPath = [NSBundle.mainBundle pathForResource:@"mfhid_helper" ofType:nil];
    [privilegedTask setLaunchPath:mfhidHelperPath];
    NSArray *args = [NSArray arrayWithObject:argument];
    [privilegedTask setArguments:args];

    // Setting working directory is optional, defaults to /
    NSString *path = [[NSBundle mainBundle] resourcePath];
    [privilegedTask setCurrentDirectoryPath:path];

    // Launch it, user is prompted for password
    OSStatus err = [privilegedTask launch];
    if (err != errAuthorizationSuccess) {
        if (err == errAuthorizationCanceled) {
            return -1;
        } else {
            return -1;
        }
    }
    if (result != NULL){
        *result = privilegedTask.terminationStatus;
    }
    return privilegedTask.terminationStatus == 0;
}

+ (MFHIDResult)fixAndLoadDriver {
    int result = -1;
    [self launchMFHIDHelperWithCommand:MFHIDCommandFixAndLoadDriver result:&result];
    return result;
}

+ (BOOL)driverLoaded {
    return [self launchMFHIDHelperWithCommand:MFHIDCommandDriverLoaded result:NULL];
}

+ (BOOL)driverExists {
    return [self launchMFHIDHelperWithCommand:MFHIDCommandDriverLoaded result:NULL];;
}

+ (BOOL)fixDriverPermissions {
    return [self launchMFHIDHelperWithCommand:MFHIDCommandDriverLoaded result:NULL];
}


@end