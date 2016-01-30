//
//  SliderVC.m
//  Employee
//
//  Created by Elluminati - macbook on 19/05/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "SliderVC.h"
#import "Constants.h"
#import "SWRevealViewController.h"
#import "PickUpVC.h"
#import "CellSlider.h"
#import "HistoryVC.h"
#import "AboutVC.h"
#import "PaymentVC.h"
#import "ProfileVC.h"
#import "PromotionsVC.h"
#import "ContactUsVC.h"
#import "UIView+Utils.h"
#import "UIImageView+Download.h"
#import "UberStyleGuide.h"
#import "AppDelegate.h"
#import "AFNHelper.h"

@interface SliderVC ()
{
    NSMutableArray *arrListName,*arrIdentifire;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSString *strContent;
}

@end

@implementation SliderVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrSlider=[[NSMutableArray alloc]initWithObjects:NSLocalizedString(@"Profile", nil),NSLocalizedString(@"History", nil),NSLocalizedString(@"Payment", nil),nil ];//@"Promotions",@"Logout", nil];
    arrImages=[[NSMutableArray alloc]initWithObjects:@"nav_profile",@"ub__nav_history",@"nav_payment",nil];//@"icon-29.png",@"icon-29.png",@"ub__nav_promotions.png",@"ub__nav_logout.png",nil];
    self.tblMenu.backgroundView=nil;
    self.tblMenu.backgroundColor=[UIColor clearColor];
    [self.imgProfilePic applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictInfo=[pref objectForKey:PREF_LOGIN_OBJECT];
    
    [self.imgProfilePic downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    
    self.lblName.font=[UberStyleGuide fontRegular:18.0f];
    
    self.lblName.text=[NSString stringWithFormat:@"%@ %@",[dictInfo valueForKey:@"first_name"],[dictInfo valueForKey:@"last_name"]];
    
    arrIdentifire=[[NSMutableArray alloc]initWithObjects:SEGUE_PROFILE,SEGUE_TO_HISTORY,SEGUE_PAYMENT, nil];
    
    NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
    NSMutableArray *arrImg=[[NSMutableArray alloc]init];
    for (int i=0; i<arrPage.count; i++)
    {
        NSMutableDictionary *temp1=[arrPage objectAtIndex:i];
        [arrTemp addObject:[NSString stringWithFormat:@"  %@",[temp1 valueForKey:@"title"]]];
        [arrImg addObject:@"nav_about"];
    }
    
    [arrSlider addObjectsFromArray:arrTemp];
    [arrIdentifire addObjectsFromArray:arrTemp];
    [arrIdentifire addObject:SEGUE_TO_REFERRAL_CODE];

    [arrImages addObjectsFromArray:arrImg];
    
    [arrSlider addObject:NSLocalizedString(@"  Referral", nil)];
    [arrImages addObject:@"nav_referral"];

    [arrSlider addObject:NSLocalizedString(@"Logout", nil)];
    [arrImages addObject:@"ub__nav_logout"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
    
    frontVC=[nav.childViewControllers objectAtIndex:0];
}

#pragma mark -
#pragma mark - UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrSlider count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellSlider *cell=(CellSlider *)[tableView dequeueReusableCellWithIdentifier:@"CellSlider"];
    if (cell==nil) {
        cell=[[CellSlider alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellSlider"];
    }
    cell.lblName.text=[arrSlider objectAtIndex:indexPath.row];
    cell.imgIcon.image=[UIImage imageNamed:[arrImages objectAtIndex:indexPath.row]];
    
    
    //[cell setCellData:[arrSlider objectAtIndex:indexPath.row] withParent:self];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[arrSlider objectAtIndex:indexPath.row]isEqualToString:@"  Logout"])
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Logout", nil) message:NSLocalizedString(@"Logout Msg", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
        alert.tag=100;
        [alert show];

        return;
    }
   
    if ((indexPath.row >2)&&(indexPath.row<(arrSlider.count-2)))
    {
        [self.revealViewController rightRevealToggle:self];
        
        UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
        
        self.ViewObj=(PickUpVC *)[nav.childViewControllers objectAtIndex:0];
        
        NSDictionary *dictTemp=[arrPage objectAtIndex:indexPath.row-3];
        strContent=[dictTemp valueForKey:@"content"];
        
        [self.ViewObj performSegueWithIdentifier:@"contactus" sender:dictTemp];
        return;
    }
    [self.revealViewController rightRevealToggle:self];
    
    UINavigationController *nav=(UINavigationController *)self.revealViewController.frontViewController;
    
    self.ViewObj=(PickUpVC *)[nav.childViewControllers objectAtIndex:0];
    
    if(self.ViewObj!=nil)
        [self.ViewObj goToSetting:[arrIdentifire objectAtIndex:indexPath.row]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *v=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
    v.backgroundColor=[UIColor clearColor];
    return nil;
}

- (void)onClickProfile:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_PROFILE sender:frontVC];
    }
}

- (void)onClickPayment:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_PAYMENT sender:frontVC];
    }
}

- (void)onClickPromotions:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_PROMOTIONS sender:frontVC];
    }
}

- (void)onClickShare:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_SHARE sender:frontVC];
    }
}

- (void)onClickSupport:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_SUPPORT sender:frontVC];
    }
}

- (void)onClickAbout:(id)sender
{
    if (frontVC) {
        [self.revealViewController rightRevealToggle:nil];
        [frontVC performSegueWithIdentifier:SEGUE_ABOUT sender:frontVC];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setObject:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
            [dictParam setObject:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];

//            [pref removeObjectForKey:PREF_USER_TOKEN];
//            [pref removeObjectForKey:PREF_REQ_ID];
//            [pref removeObjectForKey:PREF_IS_LOGOUT];
//            [pref removeObjectForKey:PREF_USER_ID];
//            [pref removeObjectForKey:PREF_IS_LOGIN];
            //[pref synchronize];
            
            if([[AppDelegate sharedAppDelegate]connected])
            {
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_LOGOUT withParamData:dictParam withBlock:^(id response, NSError *error)
                 {
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     if (response)
                     {
                         [pref removeObjectForKey:PREF_USER_TOKEN];
                         [pref removeObjectForKey:PREF_REQ_ID];
                         [pref removeObjectForKey:PREF_IS_LOGOUT];
                         [pref removeObjectForKey:PREF_USER_ID];
                         [pref removeObjectForKey:PREF_IS_LOGIN];
                         [pref synchronize];
                         [self.navigationController popToRootViewControllerAnimated:YES];
                     }
                     
                     
                 }];
                
            }
        }
    }
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
