//
//  ProviderDetailsVC.m
//  UberNewUser
//
//  Created by Deep Gami on 29/10/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ProviderDetailsVC.h"
#import "SWRevealViewController.h"
#import "sbMapAnnotation.h"
#import "UIImageView+Download.h"
#import "FeedBackVC.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "Constants.h"
#import "RateView.h"
#import "UIView+Utils.h"
#import "UberStyleGuide.h"

@interface ProviderDetailsVC ()
{
   
    
    NSDate *dateForwalkStartedTime;
    //float distance;
    BOOL isTimerStaredForMin,isWalkInStarted,pathDraw;
   // NSMutableDictionary *dictBillInfo;
    NSMutableArray *arrPath;
    GMSMutablePath *pathUpdates;
    NSString *strUSerImage,*strLastName;
    NSString *strProviderPhone,*strTime,*strDistance,*strForDestLat,*strForDestLong,*strForProviderLat,*strForProviderLong;
    GMSMapView *mapView_;
    GMSMarker *client_marker,*driver_marker;
    GMSMutablePath *pathpoliline;
    NSDictionary *dictCard;
    BOOL iscash,isFirst, isPinDest;

}

@end

@implementation ProviderDetailsVC
@synthesize strForLongitude,strForLatitude,strForWalkStatedLatitude,strForWalkStatedLongitude,timerForTimeAndDistance,timerForCheckReqStatuss;
#pragma mark -
#pragma mark - View DidLoad

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self SetLocalization];
    self.statusView.hidden=YES;
    self.tableForCity.hidden=YES;
    self.viewForPromo.hidden=YES;
   // strForLatitude=@"37.30000";
   // strForLongitude=@"-122.031";
    APPDELEGATE.vcProvider=self;
    [super setNavBarTitle:TITLE_PICKUP];
    [self customSetup];
    [self updateLocationManager];
    //[self checkDriverStatus];
    arrPath=[[NSMutableArray alloc]init];
    pathUpdates = [GMSMutablePath path];
    pathUpdates = [[GMSMutablePath alloc]init];
    isTimerStaredForMin=NO;
    pathDraw=YES;
    isFirst=NO;
    isPinDest = NO;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForLatitude doubleValue] longitude:[strForLongitude doubleValue]zoom:14];
    mapView_=[GMSMapView mapWithFrame:CGRectMake(0, 0,self.viewForMap.frame.size.width,self.viewForMap.frame.size.height) camera:camera];
    mapView_.myLocationEnabled = NO;
    [self.viewForMap addSubview:mapView_];
    [APPDELEGATE.window bringSubviewToFront:self.statusView];
    mapView_.delegate=self;

    
    // Creates a marker in the client Location of the map.
    
    client_marker = [[GMSMarker alloc] init];
    client_marker.position = CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    client_marker.icon=[UIImage imageNamed:@"pin_client_org"];
    client_marker.map = mapView_;
    
    // Creates a marker in the client Location of the map.
    driver_marker = [[GMSMarker alloc] init];
    driver_marker.position = CLLocationCoordinate2DMake([strForWalkStatedLatitude doubleValue], [strForWalkStatedLongitude doubleValue]);
    driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
    driver_marker.map = mapView_;
    
    
      // Do any additional setup after loading the view.
    
    
    timerForCheckReqStatuss = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForTripStatus) userInfo:nil repeats:YES];
    isWalkInStarted=NO;
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    isWalkInStarted=[pref boolForKey:PREF_IS_WALK_STARTED];
    if(isWalkInStarted)
    {
        [self requestPath];
    }
    
    self.acceptView.hidden=NO;
    self.lblStatus.text=@"Status :  Accepted the Job";
    [self customFont];
}
-(void)viewDidAppear:(BOOL)animated
{
     [[AppDelegate sharedAppDelegate] hideLoadingView];

    [self.btnCancel setHidden:NO];
    [self.ratingView initRateBar];
    [self.ratingView setUserInteractionEnabled:NO];
    //self.statusView.hidden=YES;
   // [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
    [self.imgForDriverProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    [self checkForTripStatus];
    self.tableForCity.hidden=YES;
    self.txtAddress.placeholder=NSLocalizedString(@"Destination Address", nil);
    
}
-(void)SetLocalization
{
    [self.btnCall setTitle:NSLocalizedString(@"CALL", nil) forState:UIControlStateNormal];
    self.lAcceptJob.text=NSLocalizedString(@"DRIVER ACCEPTED THE JOB", nil);
    self.lblWalkerArrived.text=NSLocalizedString(@"DRIVER HAS ARRIVED AT YOUR PLACE", nil);
    self.lblJobStart.text=NSLocalizedString(@"YOUR TRIP HAS BEEN STARTED", nil);
    self.lblWalkerStarted.text=NSLocalizedString(@"DRIVER HAS STARTED TOWARDS YOU", nil);
    self.lblJobDone.text=NSLocalizedString(@"YOUR TRIP IS COMPLETED", nil);
    self.lblAccept.text=NSLocalizedString(@"DRIVER ACCEPTED THE JOB", nil);
    self.lPromoCode.text=NSLocalizedString(@"Promo Code", nil);
    self.txtPromo.placeholder=NSLocalizedString(@"Enter Promo Code", nil);
    [self.btnPromoApply setTitle:NSLocalizedString(@"APPLY", nil) forState:UIControlStateNormal];
    [self.btnPromoApply setTitle:NSLocalizedString(@"APPLY", nil) forState:UIControlStateSelected];
    [self.btnPromoCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.btnPromoCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateSelected];
    [self.btnPromoDone setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.btnPromoDone setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateSelected];
    [self.btnCash setTitle:NSLocalizedString(@"Cash", nil) forState:UIControlStateNormal];
}
/*#pragma mark-
#pragma mark- timer for oath draw

-(void)setTimerToCheckDriverStatus
{
    self.timerforpathDraw = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(setPathDrawBool) userInfo:nil repeats:YES];
}

-(void)setPathDrawBool
{
    pathDraw=YES;
}*/

#pragma mark-
#pragma mark- customFont

-(void)customFont
{
   /* self.lblDriverDetail.font=[UberStyleGuide fontRegular:13.0f];
    self.lblDriverName.font=[UberStyleGuide fontRegular:13.0f];
    self.lblJobDone.font=[UberStyleGuide fontRegular:13.0f];
    self.lblJobStart.font=[UberStyleGuide fontRegular:13.0f];
    self.lblWalkerArrived.font=[UberStyleGuide fontRegular:13.0f];
    self.lblWalkerStarted.font=[UberStyleGuide fontRegular:13.0f];*/
    
    self.lblAccept.font=[UberStyleGuide fontRegular];
    self.lblAccept.textColor=[UberStyleGuide colorDefault];
    
    self.btnCall=[APPDELEGATE setBoldFontDiscriptor:self.btnCall];
    self.btnDistance=[APPDELEGATE setBoldFontDiscriptor:self.btnDistance];
    self.btnMin=[APPDELEGATE setBoldFontDiscriptor:self.btnMin];
    
}
#pragma mark -
#pragma mark - Location Delegate


-(void)updateLocationManager
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
    //strForLatitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
   // strForLongitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    isWalkInStarted=[pref boolForKey:PREF_IS_WALK_STARTED];
    
    if(isWalkInStarted)
    {
        if (newLocation != nil) {
            if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude) {
                
            }else{
                
                [mapView_  clear];
                [pathUpdates addCoordinate:newLocation.coordinate];
                
                GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathUpdates];
                polyline.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
                polyline.strokeWidth = 5.f;
                polyline.geodesic = YES;
                polyline.map = mapView_;
                
                // Creates a marker in the client Location of the map.
                
                GMSMarker *markerOwner = [[GMSMarker alloc] init];
                markerOwner.position = CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
                markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
                markerOwner.map = mapView_;
                
                // Creates a marker in the client Location of the map.
                driver_marker = [[GMSMarker alloc] init];
                driver_marker.position = CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
                driver_marker.map = mapView_;
                
                
                
                

                
                if(pathpoliline.count!=0)
                {
                    
                   markerDriver = [[GMSMarker alloc] init];
                    markerDriver.position = CLLocationCoordinate2DMake([strForDestLat doubleValue], [strForDestLong doubleValue]) ;
                    markerDriver.icon = [UIImage imageNamed:@"pin_destination"];
                    markerDriver.map = mapView_;
                    
                    GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:pathpoliline];
                    
                    polyLinePath.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
                    polyLinePath.strokeWidth = 5.f;
                    polyLinePath.geodesic = YES;
                    polyLinePath.map = mapView_;
                
                }
            }
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    /*UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertLocation.tag=100;
    [alertLocation show];
*/
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
    if(alertView.tag==200)
    {
        if(buttonIndex == 1)
        {
            [self cancelRequest];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.revealBtnItem addTarget:self.revealViewController action:@selector( revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
        
        /*
         [self.revealButtonItem setTarget: self.revealViewController];
         [self.revealButtonItem setAction: @selector( revealToggle: )];
         */
        //[self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}
- (IBAction)onClickRevelButton:(id)sender
{
    [self.txtAddress resignFirstResponder];
    self.acceptView.hidden=YES;
    self.statusView.hidden=YES;
}
#pragma mark -
#pragma mark - Mapview Delegate

-(void)showDriverLocatinOnMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForWalkStatedLatitude doubleValue] longitude:[strForWalkStatedLongitude doubleValue]zoom:14];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 416) camera:camera];
    //self.view = mapView_;
    [self.viewForMap addSubview:mapView_];
   // mapView_.delegate=self;

    driver_marker = [[GMSMarker alloc] init];
    driver_marker.position = CLLocationCoordinate2DMake([strForWalkStatedLatitude doubleValue], [strForWalkStatedLongitude doubleValue]);
    driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
    driver_marker.map = mapView_;
//    CLLocationCoordinate2D l;
//    l.latitude=[strForWalkStatedLatitude doubleValue];
//    l.longitude=[strForWalkStatedLongitude doubleValue];
//    SBMapAnnotation *annotation= [[SBMapAnnotation alloc]initWithCoordinate:l];
//    annotation.yTag=1002;
//    [self.mapView addAnnotation:annotation];
//    [self.mapView setRegion:MKCoordinateRegionMake([annotation coordinate], MKCoordinateSpanMake(.5, .5)) animated:YES];
}

-(void)showMapCurrentLocatin
{
    if([CLLocationManager locationServicesEnabled])
    {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForLatitude doubleValue] longitude:[strForLongitude doubleValue]zoom:14];
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 416) camera:camera];
        mapView_.myLocationEnabled = NO;
        //self.view = mapView_;
        [self.viewForMap addSubview:mapView_];
        //mapView_.delegate=self;
        // Creates a marker in the client Location of the map.
        client_marker = [[GMSMarker alloc] init];
        client_marker.position = CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
        client_marker.icon=[UIImage imageNamed:@"pin_client_org"];
        client_marker.map = mapView_;

//        CLLocationCoordinate2D l;
//        l.latitude=[strForLatitude doubleValue];
//        l.longitude=[strForLongitude doubleValue];
//        SBMapAnnotation *annotation= [[SBMapAnnotation alloc]initWithCoordinate:l];
//        annotation.yTag=1001;
//        [self.mapView addAnnotation:annotation];
//        [self.mapView setRegion:MKCoordinateRegionMake([annotation coordinate], MKCoordinateSpanMake(.5, .5)) animated:YES];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
   
}

//-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    if ([annotation isKindOfClass:[MKUserLocation class]])
//        return nil;
//    
//    //Annotations
//    MKPinAnnotationView *pinAnnotation = nil;
//    if(annotation != self.mapView.userLocation)
//    {
//        // Dequeue the pin
//        static NSString *defaultPinID = @"myPin";
//        pinAnnotation = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//        if ( pinAnnotation == nil )
//            pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
//        
//        SBMapAnnotation *sbanno=(SBMapAnnotation *)annotation;
//        
//        if(sbanno.yTag==1001)
//            pinAnnotation.image = [UIImage imageNamed:@"pin_client_org"];
//        else
//            pinAnnotation.image = [UIImage imageNamed:@"pin_driver"];
//        
//        pinAnnotation.centerOffset = CGPointMake(0, -20);
//        pinAnnotation.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        pinAnnotation.canShowCallout=YES;
//        pinAnnotation.draggable=YES;
//    }
//    return pinAnnotation;
//}
//- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers {
//    
//    [self.mapView setVisibleMapRect:self.polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(1, 1, 1, 1) animated:YES];
//    
//}
//
//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
//{
//    if (!self.crumbView)
//    {
//        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
//    }
//    return self.crumbView;
//}
//
#pragma mark -
#pragma mark - Custom Methods

-(float)calculateDistanceFrom:(CLLocation *)locA To:(CLLocation *)locB
{
    CLLocationDistance distance;
    distance=[locA distanceFromLocation:locB];
    float Range=distance;
    return Range;
}
#pragma mark-
#pragma mark- Calculate Time & Distance

-(void)updateTime:(NSString *)starTime
{/*
    NSString *currentTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]*1000];
    
    double start = [starTime doubleValue];
    double end=[currentTime doubleValue];
    
    NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]];
    
    NSLog(@"difference: %f", difference);
    
    int time=(difference/(1000*60));
    
    if(time==0)
    {
        time=1;
    }
    
    [self.btnMin setTitle:[NSString stringWithFormat:@"%d min",time] forState:UIControlStateNormal];
    */
    
    
    
    NSString *gmtDateString = starTime;
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *datee = [df dateFromString:gmtDateString];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    
    
    
    
     double dateTimeDiff=  [[NSDate date] timeIntervalSince1970] - [datee timeIntervalSince1970];
     int Diff=dateTimeDiff/60;
    strTime=[NSString stringWithFormat:@"%d %@",Diff,NSLocalizedString(@"Min", nil)];
     [self.btnMin setTitle:[NSString stringWithFormat:@"%d %@",Diff,NSLocalizedString(@"Min", nil)] forState:UIControlStateNormal];
     NSLog(@"Min %d",Diff);
    
}
-(void)checkForTripStatus
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             NSLog(@"GET REQ--->%@",response);
             if (response) {
                 
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     
                     NSMutableDictionary *dictOwner=[response valueForKey:@"owner"];
                     NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                     
                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                     
                     self.lblRateValue.text=[NSString stringWithFormat:@"%.1f",[[dictWalker valueForKey:@"rating"] floatValue]];
                     
                     RBRatings rate=([[dictWalker valueForKey:@"rating"]floatValue]*2);
                     [ self.ratingView setRatings:rate];
                     
                     strLastName=[dictWalker valueForKey:@"last_name"];
                     self.lblDriverName.text=[NSString stringWithFormat:@"%@ %@",[dictWalker valueForKey:@"first_name"],strLastName];
                     
                     self.lblDriverDetail.text=[dictWalker valueForKey:@"phone"];
                     strProviderPhone=[NSString stringWithFormat:@"%@",[dictWalker valueForKey:@"phone"]];
                     [self.imgForDriverProfile downloadFromURL:[dictWalker valueForKey:@"picture"] withPlaceholder:nil];
                     strUSerImage=[dictWalker valueForKey:@"picture"];
                     
                     self.lblCarNum.text=[dictWalker valueForKey:@"car_number"];
                     self.lblCarType.text=[dictWalker valueForKey:@"car_model"];
                     self.lblRate.text=[NSString stringWithFormat:@"%.2f",[[dictWalker valueForKey:@"rating"]floatValue]];
                        dictCard=[response valueForKey:@"card_details"];
                     strForDestLat=[dictOwner valueForKey:@"dest_latitude"];
                     strForDestLong=[dictOwner valueForKey:@"dest_longitude"];
                     if ([[dictOwner valueForKey:@"payment_type"]intValue]==1)
                     {
                         iscash=YES;
                         [self.btnCard setTitle:NSLocalizedString(@"Card", nil) forState:UIControlStateNormal];
                         [self.btnCard setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                         [self.btnCard setTitle:@"Card" forState:UIControlStateHighlighted];
                         [self.btnCard setBackgroundImage:nil forState:UIControlStateNormal];
                         [self.btnCash setBackgroundImage:[UIImage imageNamed:@"rectangle2"] forState:UIControlStateNormal];
                     }
                     else
                     {
                         iscash=NO;
                         [self.btnCard setTitle:[NSString stringWithFormat:@"****%@",[dictCard valueForKey:@"last_four"]] forState:UIControlStateNormal];
                         [self.btnCard setTitle:[NSString stringWithFormat:@"****%@",[dictCard valueForKey:@"last_four"]] forState:UIControlStateHighlighted];
                         [self.btnCard setBackgroundImage:[UIImage imageNamed:@"rectangle2"] forState:UIControlStateNormal];
                         [self.btnCard setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         
                         [self.btnCash setBackgroundImage:nil forState:UIControlStateNormal];
                         [self.btnCash setBackgroundColor:[UIColor whiteColor]];
                         [self.btnCash setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

                     }
                     if(isFirst==NO)
                     {
                         NSMutableDictionary *dictCharge=[response valueForKey:@"charge_details"];
                         [self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f %@",[[dictCharge valueForKey:@"total"] floatValue],[dictCharge valueForKey:@"unit"]] forState:UIControlStateNormal];
                         
                         strForLatitude=[dictOwner valueForKey:@"owner_lat"];
                         strForLongitude=[dictOwner valueForKey:@"owner_long"];
                        
                        
                         client_marker.position = CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
                         client_marker.icon=[UIImage imageNamed:@"pin_client_org"];
                         client_marker.map = mapView_;
                         isFirst=YES;
                         strForProviderLat=[dictWalker valueForKey:@"latitude"];
                         strForProviderLong=[dictWalker valueForKey:@"longitude"];
                         
                         driver_marker.position = CLLocationCoordinate2DMake([strForProviderLat doubleValue], [strForProviderLong doubleValue]);
                         driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
                         driver_marker.map = mapView_;
                         
                         CLLocationCoordinate2D clientCoStr;
                         clientCoStr.latitude=[strForLatitude doubleValue];
                         clientCoStr.longitude=[strForLongitude doubleValue];
                         CLLocationCoordinate2D driverCoStr;
                         driverCoStr.latitude=[strForProviderLat doubleValue];
                         driverCoStr.longitude=[strForProviderLong doubleValue];
                         
                        // [self showRouteFrom:clientCoStr to:driverCoStr];
                         
                         [self showRouteFromclientTodriver:clientCoStr to:driverCoStr];
                         //[self centerMapFirst:driverCoStr two:clientCoStr third:clientCoStr];
                         
//                         GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]) zoom:14];
//                         
//                         [mapView_ animateWithCameraUpdate:updatedCamera];
                         
                     }
                     else
                     {
                         
                     }
                    
                     if(self.txtAddress.text.length == 0 && [strForDestLat integerValue]!=0 && [strForDestLong integerValue]!=0)
                     {
                         [self getAddress];
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                        [pref setObject:self.txtAddress.text forKey:PRFE_DESTINATION_ADDRESS];
                         CLLocationCoordinate2D coor;
                         coor.latitude=[strForDestLat doubleValue];
                         coor.longitude=[strForDestLong doubleValue];
                         
                         CLLocationCoordinate2D coorStr;
                         coorStr.latitude=[strForLatitude doubleValue];
                         coorStr.longitude=[strForLongitude doubleValue];
                         
                         [self showRouteFrom:coorStr to:coor];
                     }
                     is_walker_started=[[response valueForKey:@"is_walker_started"] intValue];
                     is_walker_arrived=[[response valueForKey:@"is_walker_arrived"] intValue];
                     is_started=[[response valueForKey:@"is_walk_started"] intValue];
                     is_completed=[[response valueForKey:@"is_completed"] intValue];
                     is_dog_rated=[[response valueForKey:@"is_walker_rated"] intValue];
                     
                     strDistance=[NSString stringWithFormat:@"%.2f %@",[[response valueForKey:@"distance"] floatValue],[response valueForKey:@"unit"]];
                     [self checkDriverStatus];
                     if(!isWalkInStarted)
                     {
                         driver_marker.map=nil;
                         driver_marker = [[GMSMarker alloc] init];
                         driver_marker.position = CLLocationCoordinate2DMake([[dictWalker valueForKey:@"latitude"] doubleValue], [[dictWalker valueForKey:@"longitude"] doubleValue]);
                         driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
                         driver_marker.map = mapView_;
                     }

                     if(is_completed==1)
                     {
                         [self updateTime:[response valueForKey:@"start_time"]];
                         isWalkInStarted=NO;
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref setBool:isWalkInStarted forKey:PREF_IS_WALK_STARTED];
                         
                         
                         
                         dictBillInfo=[response valueForKey:@"bill"];
                         
                         FeedBackVC *vcFeed = nil;
                         for (int i=0; i<self.navigationController.viewControllers.count; i++)
                         {
                             UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
                             if ([vc isKindOfClass:[FeedBackVC class]])
                             {
                                 
                                 vcFeed = (FeedBackVC *)vc;
                             }
                             
                         }
                         if (vcFeed==nil)
                         {
                             [timerForCheckReqStatuss invalidate];
                             [timerForTimeAndDistance invalidate];
                             timerForTimeAndDistance=nil;
                             timerForCheckReqStatuss=nil;
                             [self.timerforpathDraw invalidate];
                             [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"PLEASE_WAIT", nil)];
                             [self performSegueWithIdentifier:SEGUE_TO_FEEDBACK sender:self];
                         }else{
                             [self.navigationController popToViewController:vcFeed animated:NO];
                         }
                         
                     }
                     
                     else if(is_started==1)
                     {
                         
                         [self.btnCancel setHidden:YES];
                         //[self setTimerToCheckDriverStatus];
                         [locationManager startUpdatingLocation];
                         [self updateTime:[response valueForKey:@"start_time"]];
                         [self.btnDistance setTitle:[NSString stringWithFormat:@"%.1f %@",[[response valueForKey:@"distance"] floatValue],[response valueForKey:@"unit"]] forState:UIControlStateNormal];
                         
                         isWalkInStarted=YES;
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref setBool:isWalkInStarted forKey:PREF_IS_WALK_STARTED];
                         
                         if(isTimerStaredForMin==NO)
                         {
                             isTimerStaredForMin=YES;
                             // [self checkTimeAndDistance];
                             dateForwalkStartedTime=[NSDate date];
                             // timerForTimeAndDistance= [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkTimeAndDistance) userInfo:nil repeats:YES];
                         }
                         strForWalkStatedLatitude=[dictWalker valueForKey:@"latitude"];
                         strForWalkStatedLongitude=[dictWalker valueForKey:@"longitude"];
                     }
                     strForWalkStatedLatitude=[dictWalker valueForKey:@"latitude"];
                     strForWalkStatedLongitude=[dictWalker valueForKey:@"longitude"];
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
-(void)requestPath
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
    NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];

    
    NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_REQUEST_PATH,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         
         NSLog(@"Page Data= %@",response);
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 [arrPath removeAllObjects];
                 arrPath=[response valueForKey:@"locationdata"];
                 [self drawPath];
             }
         }
         
     }];
}
-(int)checkDriverStatus
{
    if(is_walker_started==1)
    {
        [self.btnWalkerStart setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        self.lblStatus.text=@"Status : Provider has started moving towards you.";
        self.lblAccept.text=NSLocalizedString(@"DRIVER HAS STARTED TOWARDS YOU", nil);
        

        self.lblWalkerStarted.textColor=[UberStyleGuide colorDefault];
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        
        self.acceptView.hidden=NO;
        self.statusView.hidden=YES;

    }
    else
    {
        [self.btnWalkerStart setBackgroundImage:[UIImage imageNamed:Nil] forState:UIControlStateNormal];
        self.lblWalkerStarted.textColor=[UIColor darkGrayColor];
    }
    
    
    if(is_walker_arrived==1)
    {
        
        [self.btnWalkerArrived setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        self.lblStatus.text=@"Status : Provider has arrived at your place.";
        self.lblWalkerArrived.textColor=[UberStyleGuide colorDefault];
        self.lblAccept.text=NSLocalizedString(@"DRIVER HAS ARRIVED AT YOUR PLACE", nil);;
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        self.acceptView.hidden=NO;
        self.statusView.hidden=YES;
    }
    else
    {
        [self.btnWalkerArrived setBackgroundImage:[UIImage imageNamed:Nil] forState:UIControlStateNormal];
        self.lblWalkerArrived.textColor=[UIColor darkGrayColor];
    }
    
    
    if(is_started==1)
    {
        [self.btnJobStart setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        self.lblStatus.text=@"Status : Your trip has been started.";
        self.lblJobStart.textColor=[UberStyleGuide colorDefault];
        self.lblAccept.text=NSLocalizedString(@"YOUR TRIP HAS BEEN STARTED",nil);
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        self.acceptView.hidden=NO;
        self.statusView.hidden=YES;

    }
    else
    {
        self.lblJobStart.textColor=[UIColor darkGrayColor];
        [self.btnJobStart setBackgroundImage:[UIImage imageNamed:Nil] forState:UIControlStateNormal];
    }
    
    if(is_dog_rated==1)
    {
        
    }
    
    if(is_completed==1)
    {
        
        [self.btnJobDone setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        self.lblJobDone.textColor=[UberStyleGuide colorDefault];
        
        isWalkInStarted=NO;
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        [pref setBool:isWalkInStarted forKey:PREF_IS_WALK_STARTED];
        
        
        /*FeedBackVC *vcFeed = nil;
        for (int i=0; i<self.navigationController.viewControllers.count; i++)
        {
            UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
            if ([vc isKindOfClass:[FeedBackVC class]])
            {
                vcFeed = (FeedBackVC *)vc;
            }
            
        }
        if (vcFeed==nil)
        {
            [timerForCheckReqStatuss invalidate];
            [timerForTimeAndDistance invalidate];
            timerForTimeAndDistance=nil;
            timerForCheckReqStatuss=nil;
            [self.timerforpathDraw invalidate];
            [self performSegueWithIdentifier:SEGUE_TO_FEEDBACK sender:self];
        }else{
            [self.navigationController popToViewController:vcFeed animated:NO];
        }*/

    }
    else
    {
        [self.btnJobDone setBackgroundImage:[UIImage imageNamed:Nil] forState:UIControlStateNormal];
        self.lblJobDone.textColor=[UIColor darkGrayColor];
    }
    
    if (self.statusView.hidden==NO)
    {
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box_arived"] forState:UIControlStateNormal];
    }
    return 5;
}

#pragma mark -
#pragma mark - Draw Route Methods

-(void)drawPath
{
    NSMutableDictionary *dictPath=[[NSMutableDictionary alloc]init];
    NSString *templati,*templongi;
    
    for (int i=0; i<arrPath.count; i++)
    {
        dictPath=[arrPath objectAtIndex:i];
        templati=[dictPath valueForKey:@"latitude"];
        templongi=[dictPath valueForKey:@"longitude"];
        
        CLLocationCoordinate2D current;
        current.latitude=[templati doubleValue];
        current.longitude=[templongi doubleValue];
        [pathUpdates addLatitude:current.latitude longitude:current.longitude];
        
    }
    
    
}
//- (void)updateMapLocation:(CLLocation *)newLocation
//{
//    
//    self.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
//    self.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
//    for (MKAnnotationView *annotation in self.mapView.annotations) {
//        if ([annotation isKindOfClass:[SBMapAnnotation class]])
//        {
//            SBMapAnnotation *sbAnno = (SBMapAnnotation *)annotation;
//            if(sbAnno.yTag==1001)
//                [sbAnno setCoordinate:newLocation.coordinate];
//            if (!self.crumbs)
//            {
//                _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
//                [self.mapView addOverlay:self.crumbs];
//                
//                MKCoordinateRegion region =
//                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
//                [self.mapView setRegion:region animated:YES];
//            }
//            else{
//                MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
//                
//                if (!MKMapRectIsNull(updateRect))
//                {
//                    MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
//                    // Find out the line width at this zoom scale and outset the updateRect by that amount
//                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
//                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
//                    // Ask the overlay view to update just the changed area.
//                    [self.crumbView setNeedsDisplayInMapRect:updateRect];
//                    
//                    [self.mapView setVisibleMapRect:updateRect edgePadding:UIEdgeInsetsMake(1, 1, 1, 1) animated:YES];
//                }
//            }
//        }
//        
//    }
//}
- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        //printf("[%f,", [latitude doubleValue]);
        //printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

/*-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    //NSLog(@"api url: %@", apiUrl);
    NSError* error = nil;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
    NSString *encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

-(void) centerMap
{
    MKCoordinateRegion region;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees minLon = 180.0;
    for(int idx = 0; idx < routes.count; idx++)
    {
        CLLocation* currentLocation = [routes objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    region.center.latitude     = (maxLat + minLat) / 2.0;
    region.center.longitude    = (maxLon + minLon) / 2.0;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    
    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
   // [self.mapView setRegion:region animated:YES];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=region.center.latitude;
    coordinate.longitude=region.center.longitude;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 416) camera:camera];
}
*/

//-(void) showRouteFrom:(id < MKAnnotation>)f to:(id < MKAnnotation>  )t
//{
//    if(routes)
//    {
//        [self.mapView removeAnnotations:[self.mapView annotations]];
//    }
//    
//    [self.mapView addAnnotation:f];
//    [self.mapView addAnnotation:t];
//    
//    routes = [self calculateRoutesFrom:f.coordinate to:t.coordinate];
//    NSInteger numberOfSteps = routes.count;
//    
//    CLLocationCoordinate2D coordinates[numberOfSteps];
//    for (NSInteger index = 0; index < numberOfSteps; index++)
//    {
//        CLLocation *location = [routes objectAtIndex:index];
//        CLLocationCoordinate2D coordinate = location.coordinate;
//        coordinates[index] = coordinate;
//    }
//    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
//    [self.mapView addOverlay:polyLine];
//    [self centerMap];
//}

#pragma mark -
#pragma mark - MKPolyline delegate functions

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
    polylineView.lineWidth = 5.0;
    return polylineView;
}


#pragma mark- Searching Method

- (IBAction)Searching:(id)sender
{
    aPlacemark=nil;
    [placeMarkArr removeAllObjects];
    self.tableForCity.hidden=YES;
    CLGeocoder *geocoder;
    
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

#pragma mark
#pragma mark - UITextfield Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.txtAddress.text=@"";
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
   
  //  [self getLocationFromString:self.txtAddress.text];
    if(textField==self.txtAddress)
    {
        if(self.txtAddress.text.length == 0)
        {
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            self.txtAddress.text=[pref valueForKey:PRFE_DESTINATION_ADDRESS];
        }
        else
        {
             [self getLocationFromString:self.txtAddress.text];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField==self.txtPromo)
    {
        [self.txtPromo resignFirstResponder];
    }
    self.tableForCity.hidden=YES;
    
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
                 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                [pref setObject:self.txtAddress.text forKey:PRFE_DESTINATION_ADDRESS];
                 NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                 
                 strForDestLat=[dictLocation valueForKey:@"lat"];
                 strForDestLong=[dictLocation valueForKey:@"lng"];
                 CLLocationCoordinate2D coor;
                 coor.latitude=[strForDestLat doubleValue];
                 coor.longitude=[strForDestLong doubleValue];
                 
                 CLLocationCoordinate2D coorStr;
                 coorStr.latitude=[strForLatitude doubleValue];
                 coorStr.longitude=[strForLongitude doubleValue];
                 
                 [self showRouteFrom:coorStr to:coor];
                 
                 
                 
                 
                 /*GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:14];
                 [mapView_ animateWithCameraUpdate:updatedCamera];*/
                 [self setDestination];
                 
                 
             }
             
         }
         
     }];
}

-(void)setDestination
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
    [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
    [dictParam setValue:[pref objectForKey:PREF_REQ_ID] forKey:PARAM_REQUEST_ID];
    [dictParam setValue:strForDestLat forKey:@"dest_lat"];
    [dictParam setValue:strForDestLong forKey:@"dest_long"];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_SET_DESTINATION withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if (response)
         {
             NSLog(@"destination response --> %@",response);
         }
     }];


}
-(void)getAddress
{
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[strForDestLat floatValue], [strForDestLong floatValue], [strForDestLat floatValue], [strForDestLong floatValue]];
    
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

#pragma mark-
#pragma mark- Show Route With Google

-(void)showRouteFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t
{
    if(routes)
    {
        [mapView_ clear];
    }
    
    markerOwner = [[GMSMarker alloc] init];
    markerOwner.position = f;
    markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
    markerOwner.map = mapView_;
    
   
    markerDriver = [[GMSMarker alloc] init];
    markerDriver.position = t ;
    markerDriver.icon = [UIImage imageNamed:@"pin_destination"];
    markerDriver.map = mapView_;
    
    driver_marker = [[GMSMarker alloc] init];
    driver_marker.position = CLLocationCoordinate2DMake([strForWalkStatedLatitude doubleValue], [strForWalkStatedLongitude doubleValue]);
    driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
    driver_marker.map = mapView_;

    
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@",saddr,daddr,GOOGLE_KEY_NEW];
    
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError* error = nil;
    NSData *data = [[NSData alloc]initWithContentsOfURL:apiUrl];
    
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    GMSPath *path =[GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
    GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:path];
    polyLinePath.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
    polyLinePath.strokeWidth = 5.f;
    polyLinePath.geodesic = YES;
    polyLinePath.map = mapView_;
    
    routes = json[@"routes"];
    
    NSString *points=[[[routes objectAtIndex:0] objectForKey:@"overview_polyline"] objectForKey:@"points"];
    
    NSArray *temp= [self decodePolyLine:[points mutableCopy]];
    
    [self centerMap:temp];
    
    CLLocationCoordinate2D driverCoorStr;
    driverCoorStr.latitude=[strForWalkStatedLatitude doubleValue];
    driverCoorStr.longitude=[strForWalkStatedLongitude doubleValue];

//    if(routes)
//    {
//        [mapView_ clear];
//    }
//    GMSMarker *markerOwner = [[GMSMarker alloc] init];
//    markerOwner.position = f;
//    markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
//    markerOwner.map = mapView_;
//    
//    GMSMarker *markerDriver = [[GMSMarker alloc] init];
//    markerDriver.position = t ;
//    markerDriver.icon = [UIImage imageNamed:@"pin_destination"];
//    markerDriver.map = mapView_;
//    
//    driver_marker = [[GMSMarker alloc] init];
//    driver_marker.position = CLLocationCoordinate2DMake([strForWalkStatedLatitude doubleValue], [strForWalkStatedLongitude doubleValue]);
//    driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
//    driver_marker.map = mapView_;

//
//    routes = [self calculateRoutesFrom:f to:t];
//    NSInteger numberOfSteps = routes.count;
//    
//    
//    pathpoliline=[GMSMutablePath path];
//    
//    CLLocationCoordinate2D coordinates[numberOfSteps];
//    for (NSInteger index = 0; index < numberOfSteps; index++)
//    {
//        CLLocation *location = [routes objectAtIndex:index];
//        CLLocationCoordinate2D coordinate = location.coordinate;
//        coordinates[index] = coordinate;
//        [pathpoliline addCoordinate:coordinate];
//    }
//    
//    GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:pathpoliline];
//    
//    polyLinePath.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
//    polyLinePath.strokeWidth = 5.f;
//    polyLinePath.geodesic = YES;
//    polyLinePath.map = mapView_;
//    
//    CLLocationCoordinate2D driverCoorStr;
//    driverCoorStr.latitude=[strForWalkStatedLatitude doubleValue];
//    driverCoorStr.longitude=[strForWalkStatedLongitude doubleValue];
//
//    [self centerMapFirst:f two:t third:driverCoorStr];
}
-(void)showRouteFromclientTodriver:(CLLocationCoordinate2D)client to:(CLLocationCoordinate2D)driver
{
    if(routes)
    {
        [mapView_ clear];
    }
    
    markerOwner = [[GMSMarker alloc] init];
    markerOwner.position = client;
    markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
    markerOwner.map = mapView_;
    
    
    markerDriver = [[GMSMarker alloc] init];
    markerDriver.position = driver ;
    markerDriver.icon = [UIImage imageNamed:@"pin_driver"];
    markerDriver.map = mapView_;
    
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", client.latitude, client.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", driver.latitude, driver.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@",saddr,daddr,GOOGLE_KEY_NEW];
    
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError* error = nil;
    NSData *data = [[NSData alloc]initWithContentsOfURL:apiUrl];
    
    NSDictionary *json =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    GMSPath *path =[GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
    GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:path];
    polyLinePath.strokeColor = [UIColor colorWithRed:(27.0f/255.0f) green:(151.0f/255.0f) blue:(200.0f/255.0f) alpha:1.0];
    polyLinePath.strokeWidth = 5.f;
    polyLinePath.geodesic = YES;
    polyLinePath.map = mapView_;
    
    routes = json[@"routes"];
    
    NSString *points=[[[routes objectAtIndex:0] objectForKey:@"overview_polyline"] objectForKey:@"points"];
    
    NSArray *temp= [self decodePolyLine:[points mutableCopy]];
    
    [self centerMap:temp];
    
    CLLocationCoordinate2D driverCoorStr;
    driverCoorStr.latitude=[strForWalkStatedLatitude doubleValue];
    driverCoorStr.longitude=[strForWalkStatedLongitude doubleValue];
}
-(void)centerMap:(NSArray*)locations
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    CLLocationCoordinate2D location;
    for (CLLocation *loc in locations)
    {
        location.latitude = loc.coordinate.latitude;
        location.longitude = loc.coordinate.longitude;
        // Creates a marker in the center of the map.
        bounds = [bounds includingCoordinate:location];
    }
    [mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:10.0f]];
}
//-(void) centerMap
//{
//    MKCoordinateRegion region;
//    CLLocationDegrees maxLat = -90.0;
//    CLLocationDegrees maxLon = -180.0;
//    CLLocationDegrees minLat = 90.0;
//    CLLocationDegrees minLon = 180.0;
//    for(int idx = 0; idx < routes.count; idx++)
//    {
//        CLLocation* currentLocation = [routes objectAtIndex:idx];
//        if(currentLocation.coordinate.latitude > maxLat)
//            maxLat = currentLocation.coordinate.latitude;
//        if(currentLocation.coordinate.latitude < minLat)
//            minLat = currentLocation.coordinate.latitude;
//        if(currentLocation.coordinate.longitude > maxLon)
//            maxLon = currentLocation.coordinate.longitude;
//        if(currentLocation.coordinate.longitude < minLon)
//            minLon = currentLocation.coordinate.longitude;
//    }
//    region.center.latitude     = (maxLat + minLat) / 2.0;
//    region.center.longitude    = (maxLon + minLon) / 2.0;
//    
//    
//    
//    
//    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
//    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
//    
//    region.span.latitudeDelta = 1.5;
//    region.span.longitudeDelta = 1.5;
//    
//    //[self.mapView setRegion:region animated:YES];
//    
//    CLLocationCoordinate2D coordinate;
//    coordinate.latitude=region.center.latitude;
//    coordinate.longitude=region.center.longitude;
//    
//    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:14];
//    
//    [mapView_ animateWithCameraUpdate:updatedCamera];
//}
-(void)centerMapFirst:(CLLocationCoordinate2D)pos1 two:(CLLocationCoordinate2D)pos2 third:(CLLocationCoordinate2D)pos3
{
    GMSCoordinateBounds* bounds =
    [[GMSCoordinateBounds alloc]initWithCoordinate:pos1 coordinate:pos2];
    bounds=[bounds includingCoordinate:pos3];
    CLLocationCoordinate2D location1 = bounds.southWest;
    CLLocationCoordinate2D location2 = bounds.northEast;
    
    float mapViewWidth = mapView_.frame.size.width;
    float mapViewHeight = mapView_.frame.size.height;
    
    MKMapPoint point1 = MKMapPointForCoordinate(location1);
    MKMapPoint point2 = MKMapPointForCoordinate(location2);
    
    MKMapPoint centrePoint = MKMapPointMake(
                                            (point1.x + point2.x) / 2,
                                            (point1.y + point2.y) / 2);
    CLLocationCoordinate2D centreLocation = MKCoordinateForMapPoint(centrePoint);
    
    double mapScaleWidth = mapViewWidth / fabs(point2.x - point1.x);
    double mapScaleHeight = mapViewHeight / fabs(point2.y - point1.y);
    double mapScale = MIN(mapScaleWidth, mapScaleHeight);
    
    double zoomLevel = 19.5 + log2(mapScale);
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:centreLocation zoom: zoomLevel];
    [mapView_ animateWithCameraUpdate:updatedCamera];
}
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    //NSLog(@"api url: %@", apiUrl);
    NSError* error = nil;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
    NSString *encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

#pragma  mark-
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSMutableDictionary *dictWalkInfo=[[NSMutableDictionary alloc]init];
    NSString *distance= strDistance;
    
    NSArray *arrDistace=[distance componentsSeparatedByString:@" "];
    float dist;
    dist=[[arrDistace objectAtIndex:0]floatValue];
    if (arrDistace.count>1)
    {
       
        if ([[arrDistace objectAtIndex:1] isEqualToString:@"kms"])
        {
            dist=dist*0.621371;
            
        }
    }
    [dictWalkInfo setObject:[NSString stringWithFormat:@"%f",dist] forKey:@"distance"];
    [dictWalkInfo setObject:strTime forKey:@"time"];
    if([segue.identifier isEqualToString:SEGUE_TO_FEEDBACK])
    {
        FeedBackVC *obj=[segue destinationViewController];
        obj.dictWalkInfo=dictWalkInfo;
       // obj.dictBillInfo=dictBillInfo;
        obj.strUserImg=strUSerImage;
        obj.strFirstName=self.lblDriverName.text;
    }
}
 
- (IBAction)contactProviderBtnPressed:(id)sender
{
    NSString *call=[NSString stringWithFormat:@"tel://%@",strProviderPhone];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call]];
}

- (IBAction)statusBtnPressed:(id)sender
{
    self.acceptView.hidden=YES;
    if (self.statusView.hidden==YES)
    {
        self.statusView.hidden=NO;
        [APPDELEGATE.window addSubview:self.statusView];
        [APPDELEGATE.window bringSubviewToFront:self.statusView];
      //  [APPDELEGATE.window bringSubviewToFront:self.statusView];
        
    }
    else
    {
        self.statusView.hidden=YES;
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        [APPDELEGATE.window bringSubviewToFront:self.statusView];
    }
}

#pragma mark-
#pragma mark- Cash or Card Btn Actions

- (IBAction)cardBtnPressed:(id)sender
{
    iscash=NO;
    [self changePaymentType];
}

- (IBAction)cashBtnPressed:(id)sender
{
    iscash=YES;
    [self changePaymentType];
}

-(void)changePaymentType
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"PLEASE_WAIT", nil)];
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        
        
        [dictParam setValue:[USERDEFAULT objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[USERDEFAULT objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:[USERDEFAULT objectForKey:PREF_REQ_ID] forKey:PARAM_REQUEST_ID];
        if (iscash)
        {
            [dictParam setValue:@"1" forKey:PARAM_CASH_CARD];
        }
        else
        {
            [dictParam setValue:@"0" forKey:PARAM_CASH_CARD];
        }
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_PAYMENT_TYPE withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                    
                     if(iscash)
                     {
                         [self.btnCard setTitle:NSLocalizedString(@"Card", nil) forState:UIControlStateNormal];
                         [self.btnCard setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                         [self.btnCard setTitle:NSLocalizedString(@"Card", nil) forState:UIControlStateNormal];
                         [self.btnCard setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                         [self.btnCard setBackgroundImage:nil forState:UIControlStateNormal];
                         [self.btnCard setBackgroundColor:[UIColor whiteColor]];
                         [self.btnCash setBackgroundImage:[UIImage imageNamed:@"rectangle2"] forState:UIControlStateNormal];
                         [self.btnCash setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                     }
                     else
                     {
                         [self.btnCard setBackgroundImage:[UIImage imageNamed:@"rectangle2"] forState:UIControlStateNormal];
                         [self.btnCard setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         [self.btnCash setBackgroundImage:nil forState:UIControlStateNormal];
                         [self.btnCash setBackgroundColor:[UIColor whiteColor]];
                         [self.btnCash setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                     }
                      [APPDELEGATE showToastMessage:NSLocalizedString(@"SUCCESS", nil)];
                                         
                 }
                 else
                 {
                     UIAlertView *alert =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
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

- (IBAction)cancelBtnPressed:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"CANCEL_REQUEST", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    alert.tag=200;
    [alert show];
    
}
-(void)cancelRequest
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [[AppDelegate sharedAppDelegate]hideLoadingView];
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CANCLEING", nil)];
        
        
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        
        [dictParam setValue:[USERDEFAULT objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[USERDEFAULT objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:[USERDEFAULT objectForKey:PREF_REQ_ID] forKey:PARAM_REQUEST_ID];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_CANCEL_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     [timerForCheckReqStatuss invalidate];
                     timerForCheckReqStatuss=nil;
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     [USERDEFAULT removeObjectForKey:PREF_REQ_ID];
                     is_walker_arrived=0;
                     is_walker_started=0;
                     is_completed=0;
                     is_started=0;
                     is_dog_rated=0;
                     
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                     [self.navigationController popViewControllerAnimated:YES];
                     
                 }
                 else
                 {
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     UIAlertView *alert =[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil) message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
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
#pragma mark-
#pragma mark- Promo Btn Actions

- (IBAction)promoBtnPressed:(id)sender
{
    self.viewForPromo.hidden=NO;
    self.btnPromoDone.hidden=YES;
    self.viewForPromoMessage.hidden=YES;
}

- (IBAction)promoDoneBtnPressed:(id)sender
{
    self.viewForPromo.hidden=YES;
    self.btnPromoApply.enabled=YES;
    self.btnPromoDone.hidden=YES;
    self.btnPromoCancel.hidden=NO;
    self.txtPromo.text=@"";
}

- (IBAction)promoCancelBtnPressed:(id)sender
{
    self.viewForPromo.hidden=YES;
    self.txtPromo.text=@"";
}

- (IBAction)promoApplyBtnPressed:(id)sender
{
    
    NSString *promoCode=self.txtPromo.text;
    if(promoCode.length > 0)
    {
    
    if([[AppDelegate sharedAppDelegate]connected])
    {

        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"REQUESTING", nil)];
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:promoCode forKey:PARAM_PROMO_CODE];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_APPLY_PROMO withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                      self.viewForPromoMessage.hidden=NO;
                      self.imgForPromoMsg.image=[UIImage imageNamed:@"check_box"];
                      self.lblPromoMsg.textColor=[UIColor colorWithRed:0.0/255.0 green:195.0/255.0 blue:109.0/255.0 alpha:1];
                      self.lblPromoMsg.text=[response valueForKey:@"error"];
                      //self.lblPromoMsg.text=@"your promo code add successfully";
                      self.btnPromoApply.enabled=NO;
                      self.btnPromoCancel.hidden=YES;
                      self.btnPromoDone.hidden=NO;
                 }
                 else
                 {
                     self.viewForPromoMessage.hidden=NO;
                     self.imgForPromoMsg.image=[UIImage imageNamed:@"error"];
                     self.lblPromoMsg.textColor=[UIColor colorWithRed:205.0/255.0 green:0.0/255.0 blue:15.0/255.0 alpha:1];
                     self.lblPromoMsg.text=[response valueForKey:@"error"];
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
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:NSLocalizedString(@"Please Promo", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
}


@end
