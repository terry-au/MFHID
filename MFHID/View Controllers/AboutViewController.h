//
//  AboutViewController.h
//  MFHID
//
//  Created by Terry Lewis on 12/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutViewController : NSViewController
@property (weak) IBOutlet NSTextView *textView;
- (IBAction)thirdPartyLicensesButtonClicked:(id)sender;
- (IBAction)donateWithPayPalButtonClicked:(id)sender;

@end
