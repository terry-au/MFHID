//
//  main.m
//  mfhid_helper
//
//  Created by Terry Lewis on 12/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iostream>

using namespace std;

static NSString *kDriverPath = @"/Library/Extensions/foohid.kext";
static NSString *kKextIdentifier = @"it.unbit.foohid";

#define ERR_UNKNOWN -1
#define ERR_ARGS 1
#define ERR_SETEUID 2
#define ERR_DRIVER_NOT_FOUND 3
#define ERR_FIXING_PERMISSIONS 4
#define ERR_LOADING_DRIVER 5
#define ERR_UNLOADING_DRIVER 6
#define SUCCESS 0
#define FAILURE 100

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
    cout << "[--driverLoaded] | [--loadDriver] | [--unloadDriver] | " << endl;
    cout << "[--fixAndLoad] | [--help]" << endl << endl;

    cout << "fixPermissions\t\t" << "Fix foohid driver permissions." << endl;
    cout << "driverExists\t\t" << "Check if foohid driver exists." << endl;
    cout << "driverLoaded\t\t" << "Check if foohid driver is loaded." << endl;
    cout << "loadDriver\t\t" << "Load the foohid driver." << endl;
    cout << "unloadDriver\t\t" << "Unload the foohid driver." << endl;
    cout << "fixAndLoad\t\t" << "Fix the foohid driver's permissions and load it." << endl;
    cout << "help\t\t\t" << "Show this help page." << endl;
}

int main(int argc, const char *argv[]) {
    if (argc > 2) {
        cout << "Too many arguments" << endl;
        return ERR_ARGS;
    }

    if (seteuid(0) != 0) {
        cout << "Failed to seteuid" << endl;
        return ERR_SETEUID;
    }

    string cmd = string(argv[1]);
    if (cmd == "--fixPermissions") {
        if (fixPermissions()) {
            cout << "Permissions fixed." << endl;
            return SUCCESS;
        }else{
            return FAILURE;
        }
    } else if (cmd == "--driverExists") {
        if (driverExists()) {
            cout << "Driver exists." << endl;
            return SUCCESS;
        } else {
            cout << "Driver doesn't exist." << endl;
            return FAILURE;
        }
    } else if (cmd == "--driverLoaded") {
        if (driverLoaded()) {
            cout << "Driver is loaded." << endl;
            return SUCCESS;
        } else {
            cout << "Driver is not loaded." << endl;
            return FAILURE;
        }
    } else if (cmd == "--loadDriver") {
        if (loadDriver()) {
            cout << "Driver successfully loaded." << endl;
            return SUCCESS;
        }else{
            cout << "Failed to load driver." << endl;
            return FAILURE;
        }
        return ERR_LOADING_DRIVER;
    } else if (cmd == "--unloadDriver") {
        if (unloadDriver()) {
            cout << "Driver successfully unloaded." << endl;
            return SUCCESS;
        }
        cout << "Failed to unload driver." << endl;
        return ERR_UNLOADING_DRIVER;
    } else if (cmd == "--fixAndLoad") {
        if (driverLoaded()) {
            return SUCCESS;
        }
        if (driverExists()) {
            fixPermissions();
            if (loadDriver()){
                return SUCCESS;
            }
            return FAILURE;
        }
    } else if (cmd == "--help") {
        showHelp();
        return SUCCESS;
    } else {
        cout << "Unknown command." << endl;
        return ERR_UNKNOWN;
    }
}
