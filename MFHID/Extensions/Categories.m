//
//  Categories.m
//  MFHID
//
//  Created by Terry Lewis on 10/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "Categories.h"

// Essential overrides to allow using the controller without the app being in focus.
@implementation _GCControllerManager (Overrides)

- (BOOL)isAppInBackground{
    // NOPE!
    return NO;
}

- (void)CBApplicationWillResignActive{
    // No, it won't!
}

@end
