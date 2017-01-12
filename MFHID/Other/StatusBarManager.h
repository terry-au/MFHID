//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StatusBarManager;

@protocol StatusBarManagerDelegate
- (void)statusBarManagerShowWindowButtonClicked:(StatusBarManager *)statusBarManager;
- (void)statusBarManagerQuitButtonClicked:(StatusBarManager *)statusBarManager;
@end

@interface StatusBarManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic) BOOL statusBarEnabled;
@property (nonatomic) id <StatusBarManagerDelegate> delegate;

@end
