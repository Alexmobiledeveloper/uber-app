//
//  AppDelegate.h
//  UberNewUser
//
//  Created by Elluminati - macbook on 27/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"


@class MBProgressHUD,ProviderDetailsVC;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MBProgressHUD *HUD;
    UIView *viewLoading;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ProviderDetailsVC *vcProvider;
+(AppDelegate *)sharedAppDelegate;

-(void) showHUDLoadingView:(NSString *)strTitle;
-(void) hideHUDLoadingView;
-(void)showToastMessage:(NSString *)message;

-(void)showLoadingWithTitle:(NSString *)title;
-(void)hideLoadingView;
-(id)setBoldFontDiscriptor:(id)objc;

- (void)userLoggedIn;
- (NSString *)applicationCacheDirectoryString;
- (BOOL)connected;

@end
