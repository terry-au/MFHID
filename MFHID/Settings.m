//
// Created by Terry Lewis on 10/1/17.
// Copyright (c) 2017 Terry Lewis. All rights reserved.
//

#import "Settings.h"
#import "StatusBarManager.h"

extern NSNotificationName kGamepadRelatedSettingsChangedNotification = @"GamepadRelatedSettingsChangedNotification";

static NSString *kShowDevicesWindowOnStartSettingsKey = @"ShowDevicesWindowOnStart";
static NSString *kShowStatusBarIconSettingsKey = @"ShowStatusBarIcon";
static NSString *kShowInDockSettingsKey = @"ShowInDock";
//static NSString *kLeftStickDeadZoneXSettingsKey = @"LeftStickDeadZoneX";
//static NSString *kLeftStickDeadZoneYSettingsKey = @"LeftStickDeadZoneY";
//static NSString *kRightStickDeadZoneXSettingsKey = @"RightStickDeadZoneX";
//static NSString *kRightStickDeadZoneYSettingsKey = @"RightStickDeadZoneY";
static NSString *kLeftStickDeadZoneSettingsKey = @"LeftStickDeadZone";
static NSString *kRightStickDeadZoneSettingsKey = @"RightStickDeadZone";
static NSString *kLeftThumbstickDeadZoneEnabledSettingsKey = @"LeftThumbstickDeadZoneEnabled";
static NSString *kRightThumbstickDeadZoneEnabledSettingsKey = @"RightThumbstickDeadZoneEnabled";

@implementation Settings {
    NSUserDefaults *_userDefaults;
}

+ (instancetype)sharedSettings {
    static Settings *sharedSettings = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
       sharedSettings = [[self alloc] init];
    });
    return sharedSettings;
}

- (instancetype)init{
    if (self = [super init]){
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (BOOL)boolForSettingNamed:(NSString *)settingName defaultValue:(BOOL)defaultValue{
    id temp = [_userDefaults objectForKey:settingName];
    if (temp){
        return [temp boolValue];
    }
    return defaultValue;
}

- (NSInteger)integerForSettingNamed:(NSString *)settingName defaultValue:(float)defaultValue{
    id temp = [_userDefaults objectForKey:settingName];
    if (temp){
        return [temp integerValue];
    }
    return defaultValue;
}

- (void)loadSettings{
    _showDevicesWindowOnStart = [self boolForSettingNamed:kShowDevicesWindowOnStartSettingsKey defaultValue:YES];
    _showStatusBarIcon = [self boolForSettingNamed:kShowStatusBarIconSettingsKey defaultValue:YES];
    _showInDock = [self boolForSettingNamed:kShowInDockSettingsKey defaultValue:YES];

//    _leftStickDeadzoneX = [self integerForSettingNamed:kLeftStickDeadZoneXSettingsKey defaultValue:0.0f];
//    _leftStickDeadzoneY = [self integerForSettingNamed:kLeftStickDeadZoneYSettingsKey defaultValue:0.0f];
//    _rightStickDeadzoneX = [self integerForSettingNamed:kRightStickDeadZoneXSettingsKey defaultValue:0.0f];
//    _rightStickDeadzoneY = [self integerForSettingNamed:kRightStickDeadZoneYSettingsKey defaultValue:0.0f];

    _leftThumbstickDeadzoneEnabled = [self boolForSettingNamed:kLeftThumbstickDeadZoneEnabledSettingsKey defaultValue:NO];
    _rightThumbstickDeadzoneEnabled = [self boolForSettingNamed:kRightThumbstickDeadZoneEnabledSettingsKey defaultValue:NO];
    
    _leftStickDeadzone = [self integerForSettingNamed:kLeftStickDeadZoneSettingsKey defaultValue:0];
    _rightStickDeadzone = [self integerForSettingNamed:kRightStickDeadZoneSettingsKey defaultValue:0];
}

- (void)setShowDevicesWindowOnStart:(BOOL)showDevicesWindowOnStart {
    _showDevicesWindowOnStart = showDevicesWindowOnStart;
    [_userDefaults setBool:self.showDevicesWindowOnStart forKey:kShowDevicesWindowOnStartSettingsKey];
}

- (void)setShowStatusBarIcon:(BOOL)showStatusBarIcon {
    _showStatusBarIcon = showStatusBarIcon;
    [_userDefaults setBool:self.showStatusBarIcon forKey:kShowStatusBarIconSettingsKey];
    StatusBarManager.sharedManager.statusBarEnabled = self.showStatusBarIcon;
}

- (void)setShowInDock:(BOOL)showInDock{
    _showInDock = showInDock;
    [_userDefaults setBool:self.showInDock forKey:kShowInDockSettingsKey];
}

//- (void)setLeftStickDeadzoneX:(float)leftStickDeadzoneX {
//    _leftStickDeadzoneX = leftStickDeadzoneX;
//    [_userDefaults setFloat:self.leftStickDeadzoneX forKey:kLeftStickDeadZoneXSettingsKey];
//}
//
//- (void)setLeftStickDeadzoneY:(float)leftStickDeadzoneY {
//    _leftStickDeadzoneY = leftStickDeadzoneY;
//    [_userDefaults setFloat:self.leftStickDeadzoneY forKey:kLeftStickDeadZoneYSettingsKey];
//}
//
//- (void)setRightStickDeadzoneX:(float)rightStickDeadzoneX {
//    _rightStickDeadzoneX = rightStickDeadzoneX;
//    [_userDefaults setFloat:self.rightStickDeadzoneX forKey:kRightStickDeadZoneXSettingsKey];
//}
//
//- (void)setRightStickDeadzoneY:(float)rightStickDeadzoneY {
//    _rightStickDeadzoneY = rightStickDeadzoneY;
//    [_userDefaults setFloat:self.rightStickDeadzoneY forKey:kRightStickDeadZoneYSettingsKey];
//}

- (void)setLeftStickDeadzone:(NSInteger)leftStickDeadzone {
    _leftStickDeadzone = leftStickDeadzone;
    [_userDefaults setInteger:self.leftStickDeadzone forKey:kLeftStickDeadZoneSettingsKey];
}

- (void)setRightStickDeadzone:(NSInteger)rightStickDeadzone {
    _rightStickDeadzone = rightStickDeadzone;
    [_userDefaults setInteger:self.rightStickDeadzone forKey:kRightStickDeadZoneSettingsKey];
}

- (void)setLeftThumbstickDeadzoneEnabled:(BOOL)leftThumbstickDeadzoneEnabled {
    _leftThumbstickDeadzoneEnabled = leftThumbstickDeadzoneEnabled;
    [_userDefaults setBool:self.leftThumbstickDeadzoneEnabled forKey:kLeftThumbstickDeadZoneEnabledSettingsKey];
}

- (void)setRightThumbstickDeadzoneEnabled:(BOOL)rightThumbstickDeadzoneEnabled {
    _rightThumbstickDeadzoneEnabled = rightThumbstickDeadzoneEnabled;
    [_userDefaults setBool:self.rightThumbstickDeadzoneEnabled forKey:kRightThumbstickDeadZoneEnabledSettingsKey];
}


@end
