//
//  ReferralCodeVC.h
//  UberforXOwner
//
//  Created by Deep Gami on 21/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

@interface ReferralCodeVC : BaseVC <MFMailComposeViewControllerDelegate>
- (IBAction)shareBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblCode;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UILabel *lblYour;
@property (weak, nonatomic) IBOutlet UIButton *btnNavigation;
@property (weak, nonatomic) IBOutlet UILabel *lblBalance;
@property (weak, nonatomic) IBOutlet UILabel *lblCredit;

@end
