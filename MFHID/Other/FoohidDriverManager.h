//
// Created by Terry Lewis on 12/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FoohidDriverManager : NSObject

+ (void)loadDriver;
+ (BOOL)driverLoaded;
+ (BOOL)driverExists;
+ (void)fixDriverPermissions;

@end