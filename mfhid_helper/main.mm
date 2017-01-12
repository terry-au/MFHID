//
//  main.m
//  mfhid_helper
//
//  Created by Terry Lewis on 12/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iostream>
#import "Types.h"

using namespace std;

static NSString *kDriverPath = @"/Library/Extensions/foohid.kext";
static NSString *kKextIdentifier = @"it.unbit.foohid";

int exec_cmd(NSString *cmd, NSString *args) {
    NSString *result = [NSString stringWithFormat:@"%@ \"%@\"", cmd, args];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return system([result UTF8String]);
#pragma clang diagnostic pop
}

BOOL fixPermissions() {
    if (exec_cmd(@"chmod -R 755", kDriverPath)) {
        return false;
    }
    if (exec_cmd(@"chown -R 0:0", kDriverPath)) {
        return false;
    }
    return true;
}

BOOL driverExists() {
    return [NSFileManager.defaultManager fileExistsAtPath:kDriverPath];
}

BOOL driverLoaded() {
    NSTask *kextStatTask = [[NSTask alloc] init];
    [kextStatTask setLaunchPath:@"/usr/sbin/kextstat"];

    NSPipe *out = [NSPipe pipe];
    [kextStatTask setStandardOutput:out];

    [kextStatTask launch];
    [kextStatTask waitUntilExit];

    NSFileHandle *fileHandle = [out fileHandleForReading];
    NSString *fileHandleString = [[NSString alloc] initWithData:fileHandle.readDataToEndOfFile encoding:NSUTF8StringEncoding];

    return [fileHandleString rangeOfString:kKextIdentifier].location != NSNotFound;
}

BOOL loadDriver() {
    return exec_cmd(@"kextload", kDriverPath) == 0;
}

BOOL unloadDriver() {
    return exec_cmd(@"kextunload", kDriverPath) == 0;
}

void showHelp() {
    cout << "usage: mfhid_helper [--fixPermissions] | [--driverExists] | " << endl;
    cout << "[--driverLoaded] | [--fixAndLoadDriver] | [--unloadDriver] | " << endl;
    cout << "[--fixAndLoad] | [--help]" << endl << endl;

    cout << "fixPermissions\t\t" << "Fix foohid driver permissions." << endl;
    cout << "driverExists\t\t" << "Check if foohid driver exists." << endl;
    cout << "driverLoaded\t\t" << "Check if foohid driver is loaded." << endl;
    cout << "fixAndLoadDriver\t\t" << "Load the foohid driver." << endl;
    cout << "unloadDriver\t\t" << "Unload the foohid driver." << endl;
    cout << "fixAndLoad\t\t" << "Fix the foohid driver's permissions and load it." << endl;
    cout << "help\t\t\t" << "Show this help page." << endl;
}

int main(int argc, const char *argv[]) {
    if (argc > 2) {
        cout << "Too many arguments" << endl;
        return MFHIDHelperExitCodeErrorArgs;
    }

    if (seteuid(0) != 0) {
        cout << "Failed to seteuid" << endl;
        return MFHIDHelperExitCodeErrorSeteuid;
    }

    string cmd = string(argv[1]);
    if (cmd == "--fixPermissions") {
        if (fixPermissions()) {
            cout << "Permissions fixed." << endl;
            return MFHIDHelperExitCodeSuccess;
        }else{
            return MFHIDHelperExitCodeFailure;
        }
    } else if (cmd == "--driverExists") {
        if (driverExists()) {
            cout << "Driver exists." << endl;
            return MFHIDHelperExitCodeSuccess;
        } else {
            cout << "Driver doesn't exist." << endl;
            return MFHIDHelperExitCodeFailure;
        }
    } else if (cmd == "--driverLoaded") {
        if (driverLoaded()) {
            cout << "Driver is loaded." << endl;
            return MFHIDHelperExitCodeSuccess;
        } else {
            cout << "Driver is not loaded." << endl;
            return MFHIDHelperExitCodeFailure;
        }
    } else if (cmd == "--fixAndLoadDriver") {
        if (loadDriver()) {
            cout << "Driver MFHIDHelperExitCodeSuccessfully loaded." << endl;
            return MFHIDHelperExitCodeSuccess;
        }else{
            cout << "Failed to load driver." << endl;
            return MFHIDHelperExitCodeFailure;
        }
        return MFHIDHelperExitCodeErrorLoadingDriver;
    } else if (cmd == "--unloadDriver") {
        if (unloadDriver()) {
            cout << "Driver MFHIDHelperExitCodeSuccessfully unloaded." << endl;
            return MFHIDHelperExitCodeSuccess;
        }
        cout << "Failed to unload driver." << endl;
        return MFHIDHelperExitCodeErrorUnloadingDriver;
    } else if (cmd == "--fixAndLoad") {
        if (driverLoaded()) {
            return MFHIDHelperExitCodeSuccess;
        }
        if (driverExists()) {
            fixPermissions();
            if (loadDriver()){
                if (driverLoaded()){
                    return MFHIDHelperExitCodeSuccess;
                }else{
                    return MFHIDHelperExitCodeErrorLoadingDriver;
                }
            }
            return MFHIDHelperExitCodeErrorDriverNotFound;
        }
    } else if (cmd == "--help") {
        showHelp();
        return MFHIDHelperExitCodeSuccess;
    } else {
        cout << "Unknown command." << endl;
        return MFHIDHelperExitCodeErrorUnknown;
    }
}
