//
//  ViewController.h
//  MFHID
//
//  Created by Terry Lewis on 9/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSButton *searchForControllersButton;
@property (weak) IBOutlet NSProgressIndicator *searchForControllersIndicator;
@property (weak) IBOutlet NSButton *connectControllerButton;

@end
