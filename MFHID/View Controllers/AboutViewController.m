//
//  AboutViewController.m
//  MFHID
//
//  Created by Terry Lewis on 12/1/17.
//  Copyright © 2017 Terry Lewis. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.textView setEditable:YES];
    [self.textView checkTextInDocument:nil];
    [self.textView setEditable:NO];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    self.preferredContentSize = self.view.fittingSize;
}

- (IBAction)thirdPartyLicensesButtonClicked:(id)sender {
    NSString *licensesPath = [NSBundle.mainBundle pathForResource:@"Licenses" ofType:@"txt"];
    [NSWorkspace.sharedWorkspace openFile:licensesPath];
}

- (IBAction)donateWithPayPalButtonClicked:(id)sender {
    NSURL *donationURL = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=DCPZ7LNKWPN6W&lc=AU&item_name=terry1994&item_number=MFHID&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"];
    [NSWorkspace.sharedWorkspace openURL:donationURL];
}
@end
