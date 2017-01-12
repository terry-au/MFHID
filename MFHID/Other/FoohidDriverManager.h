//
// Created by Terry Lewis on 12/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../../mfhid_helper/Types.h"


@interface FoohidDriverManager : NSObject

+ (MFHIDHelperExitCode)fixAndLoadDriver;
+ (BOOL)driverLoaded;
+ (BOOL)driverExists;
+ (BOOL)fixDriverPermissions;

@end