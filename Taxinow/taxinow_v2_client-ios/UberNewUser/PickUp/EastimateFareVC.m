//
//  EastimateFareVC.m
//  TaxiNow
//
//  Created by Jignesh Chanchiya on 14/04/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import "EastimateFareVC.h"
#import "AFNHelper.h"
#import "Constants.h"


@interface EastimateFareVC ()
{
    int flag;
    NSMutableArray *Places,*Location;
    NSString *strForDestLatitude,*strForDestLongitude,*strForHomeLatitude,*strForHomeLongitude,*strForWorkLatitude,*strForWorkLongitude,*strForPerTime,*strForPerDist;
}

@end

@implementation EastimateFareVC
@synthesize strForLatitude,strForLongitude,strMinFare,str_base_distance,str_price_per_unit_distance;
- (void)viewDidLoad
{
   
    [super viewDidLoad];
    [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
    [self SetLocalization];
    self.navigationController.navigationBarHidden=NO;
    [super setBackBarItem];
    Places=[[NSMutableArray alloc] init];
    Location=[[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    flag=0;
    [[NSUserDefaults standardUserDefaults] setObject:@"FARE ESTIMATE" forKey:PRFE_FARE_ADDRESS];
    self.tableForCity.hidden=YES;
    self.txtHome.enabled=NO;
    self.txtWork.enabled=NO;
    self.navigationController.navigationBarHidden=NO;
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    self.txtHome.text=[pref objectForKey:PRFE_HOME_ADDRESS];
    self.txtWork.text=[pref objectForKey:PREF_WORK_ADDRESS];
    if([self.txtHome.text isEqualToString:@""])
    {
        self.btnHomeGetFare.hidden=YES;
    }
    else
    {
        flag=2;
        [self getLocationFromString:self.txtHome.text];
        self.btnHomeGetFare.hidden=NO;
    }
//    if([self.txtWork.text isEqualToString:@""])
//    {
//        self.btnWorkGetFare.hidden=YES;
//    }
//    else
//    {
//        flag=3;
//        [self getLocationFromString:self.txtWork.text];
//        self.btnWorkGetFare.hidden=NO;
//    }
    [self getPlaces];
}
-(void)SetLocalization
{
    self.txtDestination.placeholder=NSLocalizedString(@"Destination Address", nil);
    self.txtHome.placeholder=NSLocalizedString(@"Home Address", nil);
    self.txtWork.placeholder=NSLocalizedString(@"Work Address", nil);
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.btnMenu setTitle:NSLocalizedString(@"Fare Calulator", nil) forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getPlaces
{
  //  NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[strForLatitude floatValue], [strForLongitude floatValue], [strForLatitude floatValue], [strForLongitude floatValue]];
    [Places removeAllObjects];
    [Location removeAllObjects];
    NSString *url=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?sensor=true&key=AIzaSyCMZ7FAlsFppILtRC9uyWObCXGLs6H8UUg&location=%f,%f&radius=500",[strForLatitude floatValue],[strForLongitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]options: NSJSONReadingMutableContainers error: nil];
    NSMutableArray *result=[JSON valueForKey:@"results"];
    
    for (NSMutableDictionary *dict in result)
    {
        NSMutableDictionary *location=[dict valueForKey:@"geometry"];
        [Location addObject:[location valueForKey:@"location"]];
        [Places addObject:[dict valueForKey:@"name"]];
    }

}
#pragma mark
#pragma mark - UITextfield Delegate


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(self.txtDestination==textField)
    {
        flag=1;
        self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x
                                           , self.txtDestination.frame.origin.y+38.0f, self.tableForCity.frame.size.width, self.tableForCity.frame.size.height);
    }
    else if(self.txtHome==textField)
    {
        flag=2;
        self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x
                                           , self.txtHome.frame.origin.y+38.0f, self.tableForCity.frame.size.width, self.tableForCity.frame.size.height);
    }
    else if(self.txtWork==textField)
    {
        flag=3;
        self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x
                                           , self.txtWork.frame.origin.y+38.0f, self.tableForCity.frame.size.width, self.tableForCity.frame.size.height);
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.txtDestination==textField)
    {
        flag=1;
        self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x
                                           , self.txtDestination.frame.origin.y+38.0f, self.tableForCity.frame.size.width, self.tableForCity.frame.size.height);
    }
    else if(self.txtHome==textField)
    {
        flag=2;
        self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x
                                           , self.txtHome.frame.origin.y+38.0f, self.tableForCity.frame.size.width, self.tableForCity.frame.size.height);
    }
    else if(self.txtWork==textField)
    {
        flag=3;
        self.tableForCity.frame=CGRectMake(self.tableForCity.frame.origin.x, self.txtWork.frame.origin.y+38.0f, self.tableForCity.frame.size.width, self.tableForCity.frame.size.height);
    }
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.txtDestination==textField)
    {
          [self getLocationFromString:self.txtDestination.text];
    }
    else if(self.txtHome==textField)
    {
       
        self.btnHomeEdit.hidden=NO;
        self.btnHomeGetFare.hidden=NO;
        [self getLocationFromString:self.txtHome.text];
    }
    else if(self.txtWork==textField)
    {
       
        self.btnWorkEdit.hidden=NO;
        self.btnWorkGetFare.hidden=NO;
       [self getLocationFromString:self.txtWork.text];
        
    }
    
   
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.tableForCity.hidden=YES;
    // self.tableForCountry.frame=tempCountryRect;
    //  self.tblFilterArtist.frame=tempArtistRect;
    
    
    [textField resignFirstResponder];
    return YES;
}



#pragma mark-
#pragma mark- Searching Method

- (IBAction)Searching:(id)sender
{
    aPlacemark=nil;
    [placeMarkArr removeAllObjects];
    self.tableForCity.hidden=YES;
    //CLGeocoder *geocoder;
    
    NSString *str;
    
    if (flag==1)
    {
         str=self.txtDestination.text;
    }
    else if (flag==2)
    {
         str=self.txtHome.text;
    }
    else if (flag==3)
    {
         str=self.txtWork.text;
    }
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
                 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                 if (flag==1)
                 {
                     self.txtDestination.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     strForDestLatitude=[dictLocation valueForKey:@"lat"];
                     strForDestLongitude=[dictLocation valueForKey:@"lng"];
                     CLLocationCoordinate2D scoor=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
                     CLLocationCoordinate2D dcoor= CLLocationCoordinate2DMake([strForDestLatitude doubleValue], [strForDestLongitude doubleValue]);
                     [self calculateRoutesFrom:scoor to:dcoor];
                 }
                 else if (flag==2)
                 {
                     self.txtHome.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                     [pref setObject:self.txtHome.text forKey:PRFE_HOME_ADDRESS];
                     [pref synchronize];
                     NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                     strForHomeLatitude=[dictLocation valueForKey:@"lat"];
                     strForHomeLongitude=[dictLocation valueForKey:@"lng"];
                     if([self.txtWork.text isEqualToString:@""])
                     {
                         self.btnWorkGetFare.hidden=YES;
                     }
                     else
                     {
                         flag=3;
                         [self getLocationFromString:self.txtWork.text];
                         self.btnWorkGetFare.hidden=NO;
                     }


                 }
                else if (flag==3)
                {
                    self.txtWork.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                    [pref setObject:self.txtWork.text forKey:PREF_WORK_ADDRESS];
                    [pref synchronize];
                    NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                    strForWorkLatitude=[dictLocation valueForKey:@"lat"];
                    strForWorkLongitude=[dictLocation valueForKey:@"lng"];

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
    
    
    if(tableView==self.tableForCity)
    {
        NSString *formatedAddress=[[placeMarkArr objectAtIndex:indexPath.row] valueForKey:@"description"]; // AUTOCOMPLETE API
    
        // cell.lblTitle.text=currentPlaceMark.name;
        cell.textLabel.text=formatedAddress;
    }
    else if(tableView==self.tblPlaces)
    {
        cell.textLabel.text=[Places objectAtIndex:indexPath.row];
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView==self.tableForCity)
    {
        aPlacemark=[placeMarkArr objectAtIndex:indexPath.row];
        self.tableForCity.hidden=YES;
        // [self textFieldShouldReturn:nil];
    
        [self setNewPlaceData];
    }
    else if (tableView==self.tblPlaces)
    {
        NSMutableDictionary *dict=[Location objectAtIndex:indexPath.row];
        strForDestLatitude=[dict valueForKey:@"lat"];
        strForDestLongitude=[dict valueForKey:@"lng"];
        
        CLLocationCoordinate2D scoor=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
       CLLocationCoordinate2D dcoor= CLLocationCoordinate2DMake([strForDestLatitude doubleValue], [strForDestLongitude doubleValue]);
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        [pref setObject:[Places objectAtIndex:indexPath.row] forKey:PRFE_FARE_ADDRESS];
        [pref synchronize];
        [self calculateRoutesFrom:scoor to:dcoor];
        
    }
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.tableForCity)
    {
        return placeMarkArr.count;
    }
    else if (tableView==self.tblPlaces)
    {
        return Places.count;
    }
    else
        return 0;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)setNewPlaceData
{
    if (flag==1)
    {
        self.txtDestination.text=[NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]];
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        [pref setObject:[NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]] forKey:PRFE_FARE_ADDRESS];
        [pref synchronize];
        [self textFieldShouldReturn:self.txtDestination];

    }
    else if (flag==2)
    {
        self.txtHome.text=[NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]];
        [self textFieldShouldReturn:self.txtHome];
    }
    else if (flag==3)
    {
        self.txtWork.text=[NSString stringWithFormat:@"%@",[aPlacemark objectForKey:@"description"]];
        [self textFieldShouldReturn:self.txtWork];
    }
    
    
}


#pragma mark -
#pragma mark - get FARE AMOUNT

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
        
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
        NSArray *getDistance = [getLegs valueForKey:@"distance"];
        
        //NSString *strETA = [[[getAddress objectAtIndex:0]objectAtIndex:0] valueForKey:@"text"];
        NSString *strDistance = [[[getDistance objectAtIndex:0]objectAtIndex:0] valueForKey:@"text"];
        NSArray *time=[strDistance  componentsSeparatedByString:@" "];
        NSString *strDistanceValue = [time objectAtIndex:0];
        NSString *strDistanceUnit = [time objectAtIndex:1];
        
        if([strDistanceUnit isEqualToString:@"mi"])
        {
            strForPerDist=[NSString stringWithFormat:@"%.2f",[strDistanceValue floatValue]*1.6];
        }
        else if ([strDistanceUnit isEqualToString:@"m"])
        {
            strForPerDist=[NSString stringWithFormat:@"%.2f",[strDistanceValue floatValue]/1000];
        }
        else if ([strDistanceUnit isEqualToString:@"km"])
        {
            strForPerDist=[NSString stringWithFormat:@"%.2f",[strDistanceValue floatValue]];
        }
        
        NSString *fare =  [NSString stringWithFormat:@"%.02f", [strMinFare floatValue] + ([strForPerDist floatValue]- [str_base_distance floatValue]) * [str_price_per_unit_distance floatValue]];
        
        NSLog(@"fr = %@",fare);
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        [pref setObject:fare forKey:PREF_FARE_AMOUNT];
        [pref synchronize];
        

    }
    [self.navigationController popViewControllerAnimated:YES];
      return nil;
}
#pragma mark -
#pragma mark - Home & Work Button Action


- (IBAction)onClickHomeGetFare:(id)sender
{
    CLLocationCoordinate2D scoor=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    CLLocationCoordinate2D dcoor= CLLocationCoordinate2DMake([strForHomeLatitude doubleValue], [strForHomeLongitude doubleValue]);
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref setObject:self.txtHome.text forKey:PRFE_FARE_ADDRESS];
    [pref synchronize];
    [self calculateRoutesFrom:scoor to:dcoor];
}
- (IBAction)onClickWorkGetFare:(id)sender
{
    CLLocationCoordinate2D scoor=CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    CLLocationCoordinate2D dcoor= CLLocationCoordinate2DMake([strForWorkLatitude doubleValue], [strForWorkLongitude doubleValue]);
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref setObject:self.txtWork.text forKey:PRFE_FARE_ADDRESS];
    [pref synchronize];
    [self calculateRoutesFrom:scoor to:dcoor];
}
- (IBAction)onClickHomeEdit:(id)sender
{
        self.txtHome.enabled=YES;
        self.btnHomeGetFare.hidden=YES;
        self.btnHomeEdit.hidden=YES;
        [self.txtHome becomeFirstResponder];
}

- (IBAction)onClickWorkEdit:(id)sender
{
    self.txtWork.enabled=YES;
    self.btnWorkGetFare.hidden=YES;
    self.btnWorkEdit.hidden=YES;
    [self.txtWork becomeFirstResponder];
}

@end
