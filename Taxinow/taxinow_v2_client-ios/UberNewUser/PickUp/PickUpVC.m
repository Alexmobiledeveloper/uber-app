//
//  PickUpVC.m
//  UberNewUser
//
//  Created by Elluminati - macbook on 27/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "PickUpVC.h"
#import "SWRevealViewController.h"
#import "AFNHelper.h"
#import "AboutVC.h"
#import "ContactUsVC.h"
#import "ProviderDetailsVC.h"
#import "CarTypeCell.h"
#import "UIImageView+Download.h"
#import "CarTypeDataModal.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "UberStyleGuide.h"
#import "EastimateFareVC.h"
#import "UIImageView+Download.h"
#import "UIView+Utils.h"
#import <GoogleMaps/GoogleMaps.h>



@interface PickUpVC ()
{
    NSString *strForUserId,*strForUserToken,*strForLatitude,*strForLongitude,*strForRequestID,*strForDriverLatitude,*strForDriverLongitude,*strForTypeid,*strForCurLatitude,*strForCurLongitude,*strMinFare,*strPassCap,*strETA,*Referral,*dist_price,*time_price,*driver_id;
    NSString  *str_price_per_unit_distance, *str_base_distance,*strPayment_Option, *strForDriverList;
    NSMutableArray *arrForInformation,*arrForApplicationType,*arrForAddress,*arrDriver,*arrType;
    NSMutableDictionary *driverInfo;
    GMSMapView *mapView_;
    BOOL is_paymetCard,is_Fare;
}

@end

@implementation PickUpVC

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
   // [[AppDelegate sharedAppDelegate] hideLoadingView];

    [self checkRequestInProgress];
    [self SetLocalization];
    Referral=@"";
    strForTypeid=@"0";
    strPayment_Option = @"1";
    self.btnCancel.hidden=YES;
    arrForAddress=[[NSMutableArray alloc]init];
    arrForApplicationType=[[NSMutableArray alloc]init];

    self.tableForCity.hidden=YES;
    self.viewForPreferral.hidden=YES;
    self.viewForReferralError.hidden=YES;
    is_Fare=NO;
    driverInfo=[[NSMutableDictionary alloc] init];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    self.viewForDriver.hidden=YES;
    [self.img_driver_profile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    if(![[pref valueForKey:PREF_IS_REFEREE] boolValue])
    {
        self.viewForPreferral.hidden=NO;
        self.navigationController.navigationBarHidden=YES;
        self.btnMyLocation.hidden=YES;
        self.btnETA.hidden=YES;
    }
    else
    {
       // [self setTimerToCheckDriverStatus];
    }
    if([[pref valueForKey:PREF_IS_REFEREE] boolValue])
    {
        self.navigationController.navigationBarHidden=NO;
        [self getAllApplicationType];
        [super setNavBarTitle:TITLE_PICKUP];
        [self customSetup];
        [self checkForAppStatus];
        [self getPagesData];
        [self.paymentView setHidden:YES];
        if(is_Fare==NO)
        {
            self.viewETA.hidden=YES;
            self.viewForFareAddress.hidden=YES;
           // [self getProviders];
        }
        else
            
        {
            self.viewETA.hidden=NO;
            self.viewForFareAddress.hidden=YES;
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            self.lblFareAddress.text=[pref valueForKey:PRFE_FARE_ADDRESS];
            self.lblFare.text=[NSString stringWithFormat:@"$ %@",[pref valueForKey:PREF_FARE_AMOUNT]];
            
            [self.btnFare setTitle:[NSString stringWithFormat:@"%@",[pref valueForKey:PRFE_FARE_ADDRESS]] forState:UIControlStateNormal];
            self.btnFare.titleLabel.numberOfLines=2;
            self.btnFare.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
        }
        [self cashBtnPressed:nil];
    }
        [self customFont];
        [self updateLocationManagerr];
        CLLocationCoordinate2D coordinate = [self getLocation];
        strForCurLatitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
        strForCurLongitude= [NSString stringWithFormat:@"%f", coordinate.longitude];
    
        strForLatitude=strForCurLatitude;
        strForLongitude=strForCurLatitude;
        [self getAddress];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForCurLatitude doubleValue] longitude:[strForCurLongitude doubleValue] zoom:14];
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.viewGoogleMap.frame.size.width, self.viewGoogleMap.frame.size.height) camera:camera];
        mapView_.myLocationEnabled = NO;
        mapView_.delegate=self;
        [self.viewGoogleMap addSubview:mapView_];
        [self.view bringSubviewToFront:self.tableForCity];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewForReferralError.hidden=YES;
    //[self performSegueWithIdentifier:SEGUE_TO_ACCEPT sender:self];
   // [self updateLocationManagerr];
    self.viewForDriver.hidden=YES;
    //arrForApplicationType=[[NSMutableArray alloc]init];
    
    self.viewForMarker.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-40);
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    if([[pref valueForKey:PREF_IS_REFEREE] boolValue])
    {
        self.navigationController.navigationBarHidden=NO;
       // [self getAllApplicationType];
        [super setNavBarTitle:TITLE_PICKUP];
        [self customSetup];
        [self checkForAppStatus];
        [self getPagesData];
        [self.paymentView setHidden:YES];
        if(is_Fare==NO)
        {
            self.viewETA.hidden=YES;
            self.viewForFareAddress.hidden=YES;
            [self getProviders];
        }
        else
        {
            self.viewETA.hidden=NO;
            self.viewForFareAddress.hidden=YES;
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            self.lblFareAddress.text=[pref valueForKey:PRFE_FARE_ADDRESS];
            self.lblFare.text=[NSString stringWithFormat:@"$ %@",[pref valueForKey:PREF_FARE_AMOUNT]];
            if(strETA.length>0)
            {
                self.lblETA.text=strETA;
            }
            else
            {
                self.lblETA.text=@"0 min";
            }
            //self.lblETA.text= [NSString stringWithFormat:@"%@", strETA];
            
            [self.btnFare setTitle:[NSString stringWithFormat:@"%@",[pref valueForKey:PRFE_FARE_ADDRESS]] forState:UIControlStateNormal];
            self.btnFare.titleLabel.numberOfLines=2;
            self.btnFare.titleLabel.lineBreakMode= NSLineBreakByWordWrapping;
        }
        [self cashBtnPressed:nil];
    }
      //  [self performSelector:@selector(showMapCurrentLocatinn) withObject:nil afterDelay:2.5];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    //[self performSegueWithIdentifier:SEGUE_TO_ACCEPT sender:self];

}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=NO;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.viewETA.hidden=YES;
    is_Fare=NO;
    self.viewForFareAddress.hidden=YES;
    self.lblFare.text=[NSString stringWithFormat:@"$ %@",strMinFare];
}
- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}
-(void)SetLocalization
{
    [self.btnPickMeUp setTitle:NSLocalizedString(@"PICK ME UP", nil) forState:UIControlStateNormal];
    [self.btnFare setTitle:NSLocalizedString(@"GET FARE ESTIMATE", nil) forState:UIControlStateNormal];
    [self.btnFare setTitle:NSLocalizedString(@"GET FARE ESTIMATE", nil) forState:UIControlStateSelected];
   // [self.btnClose setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
   // [self.btnClose setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateSelected];
    [self.btnPayCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.btnPayCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateSelected];
    [self.btnPayRequest setTitle:NSLocalizedString(@"Request", nil) forState:UIControlStateNormal];
    [self.btnPayRequest setTitle:NSLocalizedString(@"Request", nil) forState:UIControlStateSelected];
    [self.btnSelService setTitle:NSLocalizedString(@"SELECT SERVICE YOU NEED", nil) forState:UIControlStateNormal];
    [self.btnSelService setTitle:NSLocalizedString(@"SELECT SERVICE YOU NEED", nil) forState:UIControlStateSelected];
    [self.bReferralSkip setTitle:NSLocalizedString(@"SKIP", nil) forState:UIControlStateNormal];
    [self.bReferralSkip setTitle:NSLocalizedString(@"SKIP", nil) forState:UIControlStateSelected];
    [self.bReferralSubmit setTitle:NSLocalizedString(@"ADD", nil) forState:UIControlStateNormal];
    [self.bReferralSubmit setTitle:NSLocalizedString(@"ADD", nil) forState:UIControlStateSelected];
    [self.btnCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateSelected];
    [self.btnRatecard setTitle:NSLocalizedString(@"RATE CARD", nil) forState:UIControlStateNormal];
    [self.btnRatecard setTitle:NSLocalizedString(@"RATE CARD", nil) forState:UIControlStateSelected];
    
    self.lETA.text=NSLocalizedString(@"ETA", nil);
    self.lMaxSize.text=NSLocalizedString(@"MAX SIZE", nil);
    self.lMinFare.text=NSLocalizedString(@"MIN FARE", nil);
    self.lSelectPayment.text=NSLocalizedString(@"Select Your Payment Type", nil);
    self.lRefralMsg.text=NSLocalizedString(@"Referral_Msg", nil);
    self.lRate_basePrice.text=NSLocalizedString(@"Base Price :", nil);
    self.lRate_distancecost.text=NSLocalizedString(@"Distance Cost :", nil);
    self.lRate_TimeCost.text=NSLocalizedString(@"Time Cost :", nil);
    self.lblRateCradNote.text=NSLocalizedString(@"Rate_card_note", nil);
    self.txtAddress.placeholder=NSLocalizedString(@"SEARCH", nil);
    self.txtPreferral.placeholder=NSLocalizedString(@"Enter Referral Code", nil);
}
#pragma mark-
#pragma mark-

-(void)customFont
{
    self.txtAddress.font=[UberStyleGuide fontRegular];
    self.btnCancel=[APPDELEGATE setBoldFontDiscriptor:self.btnCancel];
    self.btnPickMeUp=[APPDELEGATE setBoldFontDiscriptor:self.btnPickMeUp];
    self.btnSelService=[APPDELEGATE setBoldFontDiscriptor:self.btnSelService];
    self.lRate_basePrice.font = [UberStyleGuide fontSemiBold:13.0f];
    self.lRate_distancecost.font = [UberStyleGuide fontSemiBold:13.0f];
    self.lRate_TimeCost.font = [UberStyleGuide fontSemiBold:13.0f];
    self.lblRate_BasePrice.font = [UberStyleGuide fontRegular:13.0f];
    self.lblRate_DistancePrice.font = [UberStyleGuide fontRegular:13.0f];
    self.lblRate_TimePrice.font = [UberStyleGuide fontRegular:13.0f];
}

#pragma mark -
#pragma mark - Location Delegate

-(CLLocationCoordinate2D) getLocation
{
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
        CLLocation *location = [locationManager location];
        CLLocationCoordinate2D coordinate = [location coordinate];
        return coordinate;
}

-(void)updateLocationManagerr
{
    [locationManager startUpdatingLocation];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        // Use one or the other, not both. Depending on what you put in info.plist
        //[self.locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
#endif
    
    [locationManager startUpdatingLocation];
    
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    strForCurLatitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    strForCurLongitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
   // GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:newLocation.coordinate zoom:14];
    //[mapView_ animateWithCameraUpdate:updatedCamera];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    
}

#pragma mark-
#pragma mark- Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];

        }
    }
    
    
}


#pragma mark- Google Map Delegate

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    strForLatitude=[NSString stringWithFormat:@"%f",position.target.latitude];
    strForLongitude=[NSString stringWithFormat:@"%f",position.target.longitude];
}

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{

   // if([strForDriverList isEqualToString:@"No Service Provider found around you."])
    if(strForDriverList)
        NSLog(@"hello");
    else
    {
        [self getETA:[arrDriver objectAtIndex:0]];
        [self getAddress];
        [self getProviders];
    }
}
-(void)getAddress
{
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[strForLatitude floatValue], [strForLongitude floatValue], [strForLatitude floatValue], [strForLongitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    
    NSDictionary *getRoutes = [JSON valueForKey:@"routes"];
    NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
    NSArray *getAddress = [getLegs valueForKey:@"end_address"];
    if (getAddress.count!=0)
    {
        self.txtAddress.text=[[getAddress objectAtIndex:0]objectAtIndex:0];
    }
}
#pragma mark -
#pragma mark - Mapview Delegate

-(void)showMapCurrentLocatinn
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
   
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:14];
    [mapView_ animateWithCameraUpdate:updatedCamera];

    [self getAddress];
}


#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark- Searching Method

- (IBAction)Searching:(id)sender
{
    aPlacemark=nil;
    [placeMarkArr removeAllObjects];
    self.tableForCity.hidden=YES;
  //  CLGeocoder *geocoder;
    
    NSString *str=self.txtAddress.text;
    NSLog(@"%@",str);
    if(str == nil)
        self.tableForCity.hidden=YES;
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    //[dictParam setObject:str forKey:PARAM_ADDRESS];
    [dictParam setObject:str forKey:@"input"]; // AUTOCOMPLETE API
    [dictParam setObject:@"sensor" forKey:@"false"]; // AUTOCOMPLETE API
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewAutoCompletewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             //NSArray *arrAddress=[response valueForKey:@"results"];
             NSArray *arrAddress=[response valueForKey:@"predictions"]; //AUTOCOMPLTE API
             
             NSLog(@"AutoCompelete URL: = %@",[[response valueForKey:@"predictions"] valueForKey:@"description"]);
             
             if ([arrAddress count] > 0)
             {
                 self.tableForCity.hidden=NO;
                 
                 placeMarkArr=[[NSMutableArray alloc] initWithArray:arrAddress copyItems:YES];
                 //[placeMarkArr addObject:Placemark]; o
                 [self.tableForCity reloadData];
                 
                 if(arrAddress.count==0)
                 {
                     self.tableForCity.hidden=YES;
                 }
             }
             
         }
         
     }];
    
}

#pragma mark - Tableview Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    
    
    NSString *formatedAddress=[[placeMarkArr objectAtIndex:indexPath.row] valueForKey:@"description"]; // AUTOCOMPLETE API
    
    // cell.lblTitle.text=currentPlaceMark.name;
    cell.textLabel.text=formatedAddress;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    aPlacemark=[placeMarkArr objectAtIndex:indexPath.row];
    self.tableForCity.hidden=YES;
    // [self textFieldShouldReturn:nil];
    
    [self setNewPlaceData];
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return placeMarkArr.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)setNewPlaceData
{
    self.txtAddress.text = [NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]];
    [self textFieldShouldReturn:self.txtAddress];
}


#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:SEGUE_ABOUT])
    {
        AboutVC *obj=[segue destinationViewController];
        obj.arrInformation=arrForInformation;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_ACCEPT])
    {
        ProviderDetailsVC *obj=[segue destinationViewController];
        obj.strForLatitude=strForLatitude;
        obj.strForLongitude=strForLongitude;
        obj.strForWalkStatedLatitude=strForDriverLatitude;
        obj.strForWalkStatedLongitude=strForDriverLongitude;
    }
    else if([segue.identifier isEqualToString:@"contactus"])
    {
        ContactUsVC *obj=[segue destinationViewController];
        obj.dictContent=sender;
    }
    else if ([segue.identifier isEqualToString:@"segueToEastimate"])
    {
        EastimateFareVC *obj=[segue destinationViewController];
        obj.strForLatitude=strForLatitude;
        obj.strForLongitude=strForLongitude;
        obj.strMinFare=strMinFare;
        obj.str_base_distance = str_base_distance;
        obj.str_price_per_unit_distance = str_price_per_unit_distance;
    }
}

-(void)goToSetting:(NSString *)str
{
    [self performSegueWithIdentifier:str sender:self];
}

#pragma mark -
#pragma mark - UIButton Action

- (IBAction)eastimateFareBtnPressed:(id)sender
{
    is_Fare=YES;
    self.viewForRateCard.hidden=YES;
   [[AppDelegate sharedAppDelegate]showHUDLoadingView:@"Loading..."];
    [self performSegueWithIdentifier:@"segueToEastimate" sender:nil];
    
}

- (IBAction)closeETABtnPressed:(id)sender
{
    self.viewETA.hidden=YES;
    self.viewForFareAddress.hidden=YES;
    self.lblFare.text=[NSString stringWithFormat:@"$ %@",strMinFare];
    is_Fare=NO;
}

- (IBAction)RateCardBtnPressed:(id)sender
{
    self.viewForRateCard.hidden=NO;
}


- (IBAction)ETABtnPressed:(id)sender {
    
    self.viewETA.hidden=NO;
    self.viewForRateCard.hidden=YES;
    [self.btnFare setTitle:NSLocalizedString(@"GET FARE ESTIMATE", nil) forState:UIControlStateNormal];
    [self.btnFare setTitle:NSLocalizedString(@"GET FARE ESTIMATE", nil) forState:UIControlStateSelected];
}

- (IBAction)cashBtnPressed:(id)sender
{
    [self.btnCash setSelected:YES];
    [self.btnCard setSelected:NO];
    is_paymetCard=NO;
    strPayment_Option = @"1";
}

- (IBAction)cardBtnPressed:(id)sender
{
    [self.btnCash setSelected:NO];
    [self.btnCard setSelected:YES];
    is_paymetCard=YES;
    strPayment_Option = @"0";
}

- (IBAction)requestBtnPressed:(id)sender
{
    if([CLLocationManager locationServicesEnabled])
    {
        if ([strForTypeid isEqualToString:@"0"]||strForTypeid==nil)
        {
            strForTypeid=@"1";
        }
        if(![strForTypeid isEqualToString:@"0"])
        {
            if(((strForLatitude==nil)&&(strForLongitude==nil))
               ||(([strForLongitude doubleValue]==0.00)&&([strForLatitude doubleValue]==0)))
            {
                [APPDELEGATE showToastMessage:NSLocalizedString(@"NOT_VALID_LOCATION", nil)];
            }
            else
            {
                if([[AppDelegate sharedAppDelegate]connected])
                {
                    
                    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"REQUESTING", nil)];
                   
                    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                    strForUserId=[pref objectForKey:PREF_USER_ID];
                    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
                    
                    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
                    [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
                    [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
                    //[dictParam setValue:@"22.3023117"  forKey:PARAM_LATITUDE];
                    //[dictParam setValue:@"70.7969645"  forKey:PARAM_LONGITUDE];
                    [dictParam setValue:@"1" forKey:PARAM_DISTANCE];
                    [dictParam setValue:strForUserId forKey:PARAM_ID];
                    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
                    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
                    if (is_paymetCard)
                    {
                        [dictParam setValue:@"0" forKey:PARAM_PAYMENT_OPT];
                    }
                    else
                    {
                        [dictParam setValue:@"1" forKey:PARAM_PAYMENT_OPT];
                    }
                   
                    
                    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                    [afn getDataFromPath:FILE_CREATE_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
                     {
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         
                         if (response)
                         {
                             self.paymentView.hidden=YES;
                             if([[response valueForKey:@"success"]boolValue])
                             {
                                 NSLog(@"pick up......%@",response);
                                 if([[response valueForKey:@"success"]boolValue])
                                 {
                                     NSMutableDictionary *walker=[response valueForKey:@"walker"];
                                     [self showDriver:walker];
                                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                                     
                                     strForRequestID=[response valueForKey:@"request_id"];
                                     [pref setObject:strForRequestID forKey:PREF_REQ_ID];
                                     [self setTimerToCheckDriverStatus];
                                     
                                     [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"COTACCTING_SERVICE_PROVIDER", nil)];
                                     [self.btnCancel setHidden:NO];
                                     [self.viewForDriver setHidden:NO];
                                     [APPDELEGATE.window addSubview:self.btnCancel];
                                     [APPDELEGATE.window bringSubviewToFront:self.btnCancel];
                                     [APPDELEGATE.window addSubview:self.viewForDriver];
                                     [APPDELEGATE.window bringSubviewToFront:self.viewForDriver];
                                 }
                             }
                             else
                             {
                                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                                 [alert show];
                             
                             }
                         }
                         
                         
                     }];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                    [alert show];
                }
            }
            
        }
        else
            [APPDELEGATE showToastMessage:NSLocalizedString(@"SELECT_TYPE", nil)];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
        
    }

}

- (IBAction)cancelBtnPressed:(id)sender
{
    [self.paymentView setHidden:YES];
}



- (IBAction)pickMeUpBtnPressed:(id)sender
{
    [self.paymentView setHidden:NO];


}

- (IBAction)cancelReqBtnPressed:(id)sender
{
    if([CLLocationManager locationServicesEnabled])
    {
        if([[AppDelegate sharedAppDelegate]connected])
        {
            [[AppDelegate sharedAppDelegate]hideLoadingView];
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CANCLEING", nil)];
            
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            strForUserId=[pref objectForKey:PREF_USER_ID];
            strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
            NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            [dictParam setValue:strReqId forKey:PARAM_REQUEST_ID];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_CANCEL_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if([[response valueForKey:@"success"]boolValue])
                     {
                         [timerForCheckReqStatus invalidate];
                         timerForCheckReqStatus=nil;
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         self.btnCancel.hidden=YES;
                         self.viewForDriver.hidden=YES;
                         //[self.btnCancel removeFromSuperview];
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                         
                     }
                     else
                     {}
                 }
                 
                 
             }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            [alert show];
        }

    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         alertLocation.tag=100;
         [alertLocation show];
         

    }
}

- (IBAction)myLocationPressed:(id)sender
{
    if ([CLLocationManager locationServicesEnabled])
    {
        CLLocationCoordinate2D coor;
        coor.latitude=[strForCurLatitude doubleValue];
         coor.longitude=[strForCurLongitude doubleValue];
         GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:14];
         [mapView_ animateWithCameraUpdate:updatedCamera];
       
        
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
}
- (IBAction)selectServiceBtnPressed:(id)sender
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        float closeY=(iOSDeviceScreenSize.height-self.btnSelService.frame.size.height);
       
        float openY=closeY-(self.bottomView.frame.size.height-self.btnSelService.frame.size.height);
        if (self.bottomView.frame.origin.y==closeY)
        {
            
            [UIView animateWithDuration:0.5 animations:^{
            
                self.bottomView.frame=CGRectMake(0, openY, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
              
            } completion:^(BOOL finished)
             {
             }];
            
        }
        else
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.bottomView.frame=CGRectMake(0, closeY, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
                } completion:^(BOOL finished)
             {
             }];
            
        }
        
    }
    
    
}

#pragma mark -
#pragma mark - Custom WS Methods

-(void)getAllApplicationType
{
    
    if([[AppDelegate sharedAppDelegate]connected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_APPLICATION_TYPE withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSMutableArray *arr=[[NSMutableArray alloc]init];
                     [arr addObjectsFromArray:[response valueForKey:@"types"]];
                     arrType=[response valueForKey:@"types"];
                     for(NSMutableDictionary *dict in arr)
                     {
                         CarTypeDataModal *obj=[[CarTypeDataModal alloc]init];
                         obj.id_=[dict valueForKey:@"id"];
                         obj.name=[dict valueForKey:@"name"];
                         obj.icon=[dict valueForKey:@"icon"];
                         obj.is_default=[dict valueForKey:@"is_default"];
                         obj.price_per_unit_time=[dict valueForKey:@"price_per_unit_time"];
                         obj.price_per_unit_distance=[dict valueForKey:@"price_per_unit_distance"];
                         obj.base_price=[dict valueForKey:@"base_price"];
                         obj.isSelected=NO;
                         [arrForApplicationType addObject:obj];
                     }
                     [self.collectionView reloadData];
                 }
                 //  [[AppDelegate sharedAppDelegate]hideLoadingView];
                 
                 
                 else
                 {}
             }
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }

}
-(void)setTimerToCheckDriverStatus
{
    if (timerForCheckReqStatus) {
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus = nil;
    }
    
     timerForCheckReqStatus = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForRequestStatus) userInfo:nil repeats:YES];
}
-(void)checkForAppStatus
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
  //  [pref removeObjectForKey:PREF_REQ_ID];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
    
    if(strReqId!=nil)
    {
        [self checkForRequestStatus];
    }
    else
    {
        [self RequestInProgress];
    }
}

-(void)checkForRequestStatus
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];

        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 
                 if([[response valueForKey:@"success"]boolValue] && [[response valueForKey:@"confirmed_walker"] integerValue]!=0)
                 {
                     NSLog(@"GET REQ--->%@",response);
                     NSString *strCheck=[response valueForKey:@"walker"];
                     
                     if(strCheck)
                     {
                         self.btnCancel.hidden=YES;
                         self.viewForDriver.hidden=YES;
                         //[self.btnCancel removeFromSuperview];
                         
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                         strForDriverLatitude=[dictWalker valueForKey:@"latitude"];
                         strForDriverLongitude=[dictWalker valueForKey:@"longitude"];
                         if ([[response valueForKey:@"is_walker_rated"]integerValue]==1)
                         {
                             [pref removeObjectForKey:PREF_REQ_ID];
                             return ;
                         }
                         
                         ProviderDetailsVC *vcFeed = nil;
                         for (int i=0; i<self.navigationController.viewControllers.count; i++)
                         {
                             UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
                             if ([vc isKindOfClass:[ProviderDetailsVC class]])
                             {
                                 vcFeed = (ProviderDetailsVC *)vc;
                             }
                             
                         }
                         if (vcFeed==nil)
                         {
                             [timerForCheckReqStatus invalidate];
                             timerForCheckReqStatus=nil;
                             [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"PLEASE_WAIT", nil)];
                             [self performSegueWithIdentifier:SEGUE_TO_ACCEPT sender:self];
                         }else
                         {
                             [self.navigationController popToViewController:vcFeed animated:NO];
                         }
                     }
                     
                 }
                 if([[response valueForKey:@"confirmed_walker"] intValue]==0 && [[response valueForKey:@"status"] intValue]==1)
                 {
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     [timerForCheckReqStatus invalidate];
                     timerForCheckReqStatus=nil;
                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                     [pref removeObjectForKey:PREF_REQ_ID];
                     
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER", nil)];
                     [APPDELEGATE hideLoadingView];
                     self.btnCancel.hidden=YES;
                     self.viewForDriver.hidden=YES;
                     // [self.btnCancel removeFromSuperview];
                     // [self showMapCurrentLocatinn];
                     
                 }
                 else
                 {
                     driverInfo=[response valueForKey:@"walker"];
                     [self showDriver:driverInfo];
                 }
             }
             
             else
             {}
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}
/*
-(void)checkDriverStatus
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
       // [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"COTACCTING_SERVICE_PROVIDER", nil)];
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             if([[response valueForKey:@"success"]boolValue])
             {
                 NSLog(@"GET REQ--->%@",response);
                 NSString *strCheck=[response valueForKey:@"walker"];
                 
                 if(strCheck)
                 {
                     [timerForCheckReqStatus invalidate];
                     timerForCheckReqStatus=nil;
                     [[AppDelegate sharedAppDelegate]hideLoadingView];

                     [self performSegueWithIdentifier:SEGUE_TO_ACCEPT sender:self];
                 }
                 [[AppDelegate sharedAppDelegate]hideLoadingView];

                 
             }
             else
             {}
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}*/
-(void)checkRequestInProgress
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_REQUEST_PROGRESS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
//                     NSMutableDictionary *charge_details=[response valueForKey:@"charge_details"];
//                     dist_price=[charge_details valueForKey:@"distance_price"];
//                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
//                     [pref setObject:dist_price forKey:PRFE_PRICE_PER_DIST];
//                     time_price=[charge_details valueForKey:@"price_per_unit_time"];
//                     [pref setObject:[charge_details valueForKey:@"price_per_unit_time"] forKey:PRFE_PRICE_PER_TIME];
//                   //  [pref setObject:[response valueForKey:@"request_id"] forKey:PREF_REQ_ID];
//                     [pref synchronize];
//                     
//                     self.lblRate_DistancePrice.text=[NSString stringWithFormat:@"$ %@",dist_price];
//                     self.lblRate_TimePrice.text=[NSString stringWithFormat:@"$ %@",time_price];
//                     
                     //[self checkForRequestStatus];
                 }
                 else
                 {}
             }
             
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}
-(void)RequestInProgress
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_REQUEST_PROGRESS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                      NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
//                     NSMutableDictionary *charge_details=[response valueForKey:@"charge_details"];
//                     dist_price=[charge_details valueForKey:@"distance_price"];
//                     [pref setObject:dist_price forKey:PRFE_PRICE_PER_DIST];
//                     time_price=[charge_details valueForKey:@"price_per_unit_time"];
//                     [pref setObject:[charge_details valueForKey:@"price_per_unit_time"] forKey:PRFE_PRICE_PER_TIME];
//                     self.lblRate_DistancePrice.text=[NSString stringWithFormat:@"$ %@",dist_price];
//                     self.lblRate_TimePrice.text=[NSString stringWithFormat:@"$ %@",time_price];
                     
                     [pref setObject:[response valueForKey:@"request_id"] forKey:PREF_REQ_ID];
                     [pref synchronize];
                     [self checkForRequestStatus];
                 }
                 else
                 {}
             }
             
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}

-(void)getPagesData
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];

    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@",FILE_PAGE,PARAM_ID,strForUserId];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             NSLog(@"Respond to Request= %@",response);
             [APPDELEGATE hideLoadingView];

             if (response)
             {
                 arrPage=[response valueForKey:@"informations"];
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     //   [APPDELEGATE showToastMessage:@"Requset Accepted"];
                 }
             }
             
         }];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}

-(void)getProviders
{
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
    [dictParam setValue:strForLatitude forKey:@"usr_lat"];
    [dictParam setValue:strForLongitude forKey:@"user_long"];
    
    
//    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"GET_PROVIDER", nil)];
    if([[AppDelegate sharedAppDelegate]connected])
    {
       
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_GET_PROVIDERS withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             NSLog(@"Respond to Get Provider= %@",response);
            // [APPDELEGATE hideLoadingView];
             
             if (response)
             {
                // [arrDriver removeAllObjects];
                 strForDriverList = [response valueForKey:@"error"];
                 
                 arrDriver=[response valueForKey:@"walker_list"];
                 
                 
                 
                 [self showProvider];
                 
             }
             else
             {
                 arrDriver=[[NSMutableArray alloc] init];
                 [self showProvider];
             }
             
         }];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];        [alert show];
    }
}
-(void)showProvider
{
   [mapView_ clear];
    BOOL is_first=YES;
    for (int i=0; i<arrDriver.count; i++)
    {
        NSDictionary *dict=[arrDriver objectAtIndex:i];
        NSString *strType=[NSString stringWithFormat:@"%@",[dict valueForKey:@"type"]];
        if ([strForTypeid isEqualToString:strType])
        {
            GMSMarker *driver_marker;
            driver_marker = [[GMSMarker alloc] init];
            driver_marker.position = CLLocationCoordinate2DMake([[dict valueForKey:@"latitude"]doubleValue],[[dict valueForKey:@"longitude"]doubleValue]);
            driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
            driver_marker.map = mapView_;
            if (is_first)
            {
                [self getETA:dict];
                is_first=NO;
            }
        }
     }
    is_first=YES;
}

-(void)getETA:(NSDictionary *)dict
{
    CLLocationCoordinate2D scorr=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    CLLocationCoordinate2D dcorr=CLLocationCoordinate2DMake([[dict valueForKey:@"latitude"]doubleValue], [[dict valueForKey:@"longitude"]doubleValue]);
    [self calculateRoutesFrom:scorr to:dcorr];
    
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@",saddr,daddr,GOOGLE_KEY_NEW];
    
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError* error = nil;
    NSData *data = [[NSData alloc]initWithContentsOfURL:apiUrl];
    
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if ([[json objectForKey:@"status"]isEqualToString:@"REQUEST_DENIED"] || [[json objectForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"] || [[json objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"])
    {
        
    }
    else
    {
        NSDictionary *getRoutes = [json valueForKey:@"routes"];
        NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
        NSArray *getAddress = [getLegs valueForKey:@"duration"];
        if(getAddress.count>0)
        {
            strETA = [[[getAddress objectAtIndex:0]objectAtIndex:0] valueForKey:@"text"];
            self.lblETA.text= [NSString stringWithFormat:@"%@", strETA];
        }
        else
            
        {
            
            self.lblETA.text=@"0 min";
            
        }

    }
    return nil;
}
-(void)showDriver:(NSMutableDictionary *)walker
{
    if([driver_id integerValue]!=[[walker valueForKey:@"id"]integerValue ])
    
    //if(![driver_id isEqualToString:[NSString stringWithFormat:@"%@", [walker valueForKey:@"id"]]])
    {
             driver_id=[walker valueForKey:@"id"];
             self.lbl_driverName.text=[NSString stringWithFormat:@"%@ %@",[walker valueForKey:@"first_name"],[walker valueForKey:@"last_name"]];
             self.lbl_driverRate.text=[NSString stringWithFormat:@"%@", [walker valueForKey:@"rating"]];
             self.lbl_driver_Carname.text=[NSString stringWithFormat:@"%@",[walker valueForKey:@"car_model"]];
             self.lbl_driver_CarNumber.text=[NSString stringWithFormat:@"%@",[walker valueForKey:@"car_number"]];
             [self.img_driver_profile downloadFromURL:[walker valueForKey:@"picture"] withPlaceholder:nil];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrForApplicationType.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CarTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cartype" forIndexPath:indexPath];
   
    NSDictionary *dictType=[arrForApplicationType objectAtIndex:indexPath.row];
    if (strForTypeid==nil || [strForTypeid isEqualToString:@"0"])
    {
        if ([[dictType valueForKey:@"is_default"]intValue]==1)
        {
            for(CarTypeDataModal *obj in arrForApplicationType)
            {
                obj.isSelected = NO;
            }
            CarTypeDataModal *obj=[arrForApplicationType objectAtIndex:indexPath.row];
            obj.isSelected = YES;
            [self getETA:[arrDriver objectAtIndex:0]];
            NSDictionary *dict=[arrType objectAtIndex:indexPath.row];
            //strMinFare=[NSString stringWithFormat:@"%@",[dict valueForKey:@"min_fare"]];
            strMinFare=[NSString stringWithFormat:@"%@",[dict valueForKey:@"base_price"]];
            strPassCap=[NSString stringWithFormat:@"%@",[dict valueForKey:@"max_size"]];
            str_base_distance = [NSString stringWithFormat:@"%@",[dict valueForKey:@"base_distance"]];
            str_price_per_unit_distance =  [NSString stringWithFormat:@"%f",[[dict valueForKey:@"price_per_unit_distance"  ] floatValue]];
            if(strETA.length>0)
            {
                self.lblETA.text=strETA;
            }
            else
            {
                self.lblETA.text=@"0 min";
            }
            
            self.lblFare.text=[NSString stringWithFormat:@"$ %@",strMinFare];
            self.lblRate_BasePrice.text=[NSString stringWithFormat:@"$%ld for %@ %@",(long)[strMinFare integerValue],[dict valueForKey:@"base_distance"],[dict valueForKey:@"unit"]];
            self.lblRate_DistancePrice.text = [NSString stringWithFormat:@"$%ld / %@",(long)[[dict valueForKey:@"price_per_unit_distance"] integerValue],[dict valueForKey:@"unit"]];
            NSString *strMin = @"min";
            self.lblRate_TimePrice.text = [NSString stringWithFormat:@"$%ld / %@",(long)[[dict valueForKey:@"price_per_unit_time"] integerValue],strMin];
            self.lblCarType.text=obj.name;
            self.lblSize.text=[NSString stringWithFormat:@"%@ PERSONS",strPassCap];
            strForTypeid=[NSString stringWithFormat:@"%@",obj.id_];
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            [pref setObject:strMinFare forKey:PREF_FARE_AMOUNT];
            [pref synchronize];
        }
    }
    
    [cell setCellData:[arrForApplicationType objectAtIndex:indexPath.row]];
    
  //  cell.imgType.layer.masksToBounds = YES;
 //   cell.imgType.layer.opaque = NO;
//    cell.imgType.layer.cornerRadius=18;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    for(CarTypeDataModal *obj in arrForApplicationType) {
        obj.isSelected = NO;
    }
    CarTypeDataModal *obj=[arrForApplicationType objectAtIndex:indexPath.row];
    obj.isSelected = YES;
    NSDictionary *dict=[arrType objectAtIndex:indexPath.row];
    strMinFare=[NSString stringWithFormat:@"%@",[dict valueForKey:@"min_fare"]];
    strPassCap=[NSString stringWithFormat:@"%@",[dict valueForKey:@"max_size"]];
    str_base_distance = [NSString stringWithFormat:@"%@",[dict valueForKey:@"base_distance"]];
    //str_price_per_unit_distance =  [NSString stringWithFormat:@"%@",[dict valueForKey:@"price_per_unit_distance"]];
    str_price_per_unit_distance =  [NSString stringWithFormat:@"%f",[[dict valueForKey:@"price_per_unit_distance"  ] floatValue]];
    if ([strForTypeid intValue] !=[obj.id_ intValue])
    {
       // [self selectServiceBtnPressed:nil];
        if(strETA.length>0)
        {
            self.lblETA.text=strETA;
        }
        else
        {
            self.lblETA.text=@"0 min";
        }
        self.lblFare.text=[NSString stringWithFormat:@"$ %@",strMinFare];
       self.lblRate_BasePrice.text=[NSString stringWithFormat:@"$%d for %@ %@",[strMinFare integerValue],[dict valueForKey:@"base_distance"],[dict valueForKey:@"unit"]];
        self.lblRate_DistancePrice.text = [NSString stringWithFormat:@"$%d / %@",[[dict valueForKey:@"price_per_unit_distance"] integerValue],[dict valueForKey:@"unit"]];
        NSString *strMin = @"min";
        self.lblRate_TimePrice.text = [NSString stringWithFormat:@"$%d / %@",[[dict valueForKey:@"price_per_unit_time"] integerValue],strMin];
        self.lblCarType.text=obj.name;
        self.lblSize.text=[NSString stringWithFormat:@"%@ PERSONS",strPassCap];
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        [pref setObject:strMinFare forKey:PREF_FARE_AMOUNT];
        [pref synchronize];
    }
    strForTypeid=[NSString stringWithFormat:@"%@",obj.id_];
   
    [self showProvider];
    [self.collectionView reloadData];
}



#pragma mark
#pragma mark - UITextfield Delegate


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //NSString *strFullText=[NSString stringWithFormat:@"%@%@",textField.text,string];
    
    if(self.txtAddress==textField)
    {
        if(arrForAddress.count==1)
            self.tableView.frame=CGRectMake(self.tableView.frame.origin.x,86+134, self.tableView.frame.size.width, 44);
        else if(arrForAddress.count==2)
            self.tableView.frame=CGRectMake(self.tableView.frame.origin.x, 86+78, self.tableView.frame.size.width, 88);
        else if(arrForAddress.count==3)
            self.tableView.frame=CGRectMake(self.tableView.frame.origin.x, 86+34, self.tableView.frame.size.width, 132);
        else if(arrForAddress.count==0)
            self.tableView.hidden=YES;
        
        [self.tableView reloadData];
        
    }
    
    
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField==self.txtAddress)
    {
        self.txtAddress.text=@"";
    }
    if (textField==self.txtPreferral)
    {
        self.viewForReferralError.hidden=YES;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
      [self getLocationFromString:self.txtAddress.text];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.tableView.hidden=YES;
    
    // self.tableForCountry.frame=tempCountryRect;
    //  self.tblFilterArtist.frame=tempArtistRect;
    
    
    [textField resignFirstResponder];
    return YES;
}


-(void)getLocationFromString:(NSString *)str
{
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:PARAM_ADDRESS];
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             NSArray *arrAddress=[response valueForKey:@"results"];
            
             if ([arrAddress count] > 0)
                 
             {
                 self.txtAddress.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                 
                 NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
             
                 strForLatitude=[dictLocation valueForKey:@"lat"];
                 strForLongitude=[dictLocation valueForKey:@"lng"];
                 [self getETA:[arrDriver objectAtIndex:0]];
                 CLLocationCoordinate2D coor;
                 coor.latitude=[strForLatitude doubleValue];
                 coor.longitude=[strForLongitude doubleValue];
                 
                 
                 GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:14];
                 [mapView_ animateWithCameraUpdate:updatedCamera];
                // [self getProviders];
                 
                 
             }
             
         }
         
     }];
}


#pragma mark -
#pragma mark - Referral btn Action

- (IBAction)btnSkipReferral:(id)sender
{
    Referral=@"1";
    [self createService];
}

- (IBAction)btnAddReferral:(id)sender
{
    Referral=@"0";
    [self createService];
}

-(void)createService
{
    self.viewForReferralError.hidden=YES;
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"REQUESTING", nil)];
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setObject:self.txtPreferral.text forKey:PARAM_REFERRAL_CODE];
        [dictParam setObject:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setObject:Referral forKey:PARAM_REFERRAL_SKIP];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_APPLY_REFERRAL withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSLog(@"%@",response);
                     if([[response valueForKey:@"success"]boolValue])
                     {
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref setObject:[response valueForKey:@"is_referee"] forKey:PREF_IS_REFEREE];
                         [pref synchronize];
                         self.viewForPreferral.hidden=YES;
                         self.btnMyLocation.hidden=NO;
                         self.btnETA.hidden=NO;
                         self.navigationController.navigationBarHidden=NO;
                         self.txtPreferral.text=@"";
                         if([Referral isEqualToString:@"0"])
                         {
                             [APPDELEGATE showToastMessage:[response valueForKey:@"error"]];
                         }
                        // [self setTimerToCheckDriverStatus];
                         self.navigationController.navigationBarHidden=NO;
                         [self getAllApplicationType];
                         [super setNavBarTitle:TITLE_PICKUP];
                         [self customSetup];
                         [self checkForAppStatus];
                         [self getPagesData];
                         [self getProviders];
                         [self.paymentView setHidden:YES];
                         self.viewETA.hidden=YES;
                         [self cashBtnPressed:nil];
                     }
                }
                else
                {
                    self.txtPreferral.text=@"";
                    self.viewForReferralError.hidden=NO;
                    self.lblReferralMsg.text=[response valueForKey:@"error"];
                    self.lblReferralMsg.textColor=[UIColor colorWithRed:205.0/255.0 green:0.0/255.0 blue:15.0/255.0 alpha:1];
                }
             }
             
             
         }];
    }
    else
    {
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
    
    
}

@end

