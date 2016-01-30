//
//  EastimateFareVC.h
//  TaxiNow
//
//  Created by Jignesh Chanchiya on 14/04/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import <CoreLocation/CoreLocation.h>

@interface EastimateFareVC : BaseVC<UITextFieldDelegate,CLLocationManagerDelegate>
{
    NSDictionary* aPlacemark;
    NSMutableArray *placeMarkArr;
   
}
@property (weak, nonatomic) IBOutlet UITextField *txtDestination;
@property (weak, nonatomic) IBOutlet UITextField *txtHome;
@property (weak, nonatomic) IBOutlet UITextField *txtWork;
@property (weak, nonatomic) IBOutlet UITableView *tblPlaces;
@property (weak, nonatomic) IBOutlet UITableView *tableForCity;
@property (weak,nonatomic) NSString   *strForLatitude,*strForLongitude,*strMinFare,   *str_price_per_unit_distance, *str_base_distance;
;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;


////// for Home & Work address
@property (weak, nonatomic) IBOutlet UIButton *btnHomeGetFare;
@property (weak, nonatomic) IBOutlet UIButton *btnWorkGetFare;

- (IBAction)onClickWorkGetFare:(id)sender;
- (IBAction)onClickHomeGetFare:(id)sender;
- (IBAction)onClickHomeEdit:(id)sender;
- (IBAction)onClickWorkEdit:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnHomeEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnWorkEdit;

@end
