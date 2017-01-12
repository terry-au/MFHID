//
// Created by Terry Lewis on 12/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import "FoohidDriverManager.h"
#import "STPrivilegedTask.h"


@implementation FoohidDriverManager {

}

+ (void)loadDriver {
    NSLog(@"Loading driver...");
    NSURL *scriptURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CheckFoohid" ofType:@"scpt"]];
    NSDictionary *error = nil;
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    if (appleScript != nil) {
        NSAppleEventDescriptor *result = [appleScript executeAndReturnError:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }

}

+ (BOOL)driverLoaded {
    // Create task
    STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
    NSString *mfhidHelperPath = [NSBundle.mainBundle pathForResource:@"mfhid_helper" ofType:nil];
    [privilegedTask setLaunchPath:mfhidHelperPath];
    NSArray *args = [NSArray arrayWithObject:@"--fixAndLoad"];
    [privilegedTask setArguments:args];

    // Setting working directory is optional, defaults to /
     NSString *path = [[NSBundle mainBundle] resourcePath];
     [privilegedTask setCurrentDirectoryPath:path];

    // Launch it, user is prompted for password
    OSStatus err = [privilegedTask launch];
    if (err != errAuthorizationSuccess) {
        if (err == errAuthorizationCanceled) {
            NSLog(@"User cancelled");
        } else {
            NSLog(@"Something went wrong");
        }
    } else {
        NSLog(@"Task successfully launched");
    }
    return NO;
}

+ (BOOL)driverExists {
    STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
    return NO;
}

+ (void)fixDriverPermissions {

}


@end