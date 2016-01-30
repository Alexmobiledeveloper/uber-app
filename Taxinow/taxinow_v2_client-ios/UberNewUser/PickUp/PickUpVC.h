//
//  PickUpVC.h
//  UberNewUser
//
//  Created by Elluminati - macbook on 27/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>


@interface PickUpVC : BaseVC<MKMapViewDelegate,CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,GMSMapViewDelegate,UIAlertViewDelegate>
{
    NSTimer *timerForCheckReqStatus;
    CLLocationManager *locationManager;
    NSDictionary* aPlacemark;
    NSMutableArray *placeMarkArr;

}

/////// Outlets

@property (weak, nonatomic) IBOutlet UITableView *tableForCity;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewGoogleMap;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) IBOutlet UIButton* revealButtonItem;
@property(nonatomic,weak)IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIView *viewForMarker;
@property (weak, nonatomic) IBOutlet UITextField *txtPreferral;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnMyLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnETA;
@property (weak, nonatomic) IBOutlet UIView *viewForPreferral;
@property (weak, nonatomic) IBOutlet UIView *viewForFareAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblFareAddress;
@property (weak, nonatomic) IBOutlet UIView *viewForReferralError;
@property (weak, nonatomic) IBOutlet UILabel *lblReferralMsg;

/////// Actions

- (IBAction)pickMeUpBtnPressed:(id)sender;
- (IBAction)cancelReqBtnPressed:(id)sender;

- (IBAction)myLocationPressed:(id)sender;
- (IBAction)selectServiceBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSelService;
@property (weak, nonatomic) IBOutlet UIButton *btnPickMeUp;

-(void)goToSetting:(NSString *)str;

@property (weak, nonatomic) IBOutlet UIView *paymentView;
- (IBAction)ETABtnPressed:(id)sender;
- (IBAction)cashBtnPressed:(id)sender;
- (IBAction)cardBtnPressed:(id)sender;
- (IBAction)requestBtnPressed:(id)sender;
- (IBAction)cancelBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCash;
@property (weak, nonatomic) IBOutlet UIButton *btnCard;
- (IBAction)btnSkipReferral:(id)sender;
- (IBAction)btnAddReferral:(id)sender;

//ETA View

@property (weak, nonatomic) IBOutlet UIView *viewETA;
@property (weak, nonatomic) IBOutlet UILabel *lblETA;
@property (weak, nonatomic) IBOutlet UILabel *lblSize;
@property (weak, nonatomic) IBOutlet UILabel *lblFare;
- (IBAction)eastimateFareBtnPressed:(id)sender;
- (IBAction)closeETABtnPressed:(id)sender;
- (IBAction)RateCardBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnRatecard;
@property (weak, nonatomic) IBOutlet UIView *viewForRateCard;
// Payment Method

////for Localization

@property (weak, nonatomic) IBOutlet UIButton *btnFare;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UILabel *lMinFare;
@property (weak, nonatomic) IBOutlet UILabel *lETA;
@property (weak, nonatomic) IBOutlet UILabel *lMaxSize;
@property (weak, nonatomic) IBOutlet UILabel *lSelectPayment;
@property (weak, nonatomic) IBOutlet UIButton *btnPayCancel;

@property (weak, nonatomic) IBOutlet UIButton *btnPayRequest;

@property (weak, nonatomic) IBOutlet UILabel *lRefralMsg;
@property (weak, nonatomic) IBOutlet UIButton *bReferralSubmit;

@property (weak, nonatomic) IBOutlet UIButton *bReferralSkip;

//// view for rate card

@property (weak, nonatomic) IBOutlet UILabel *lRate_basePrice;
@property (weak, nonatomic) IBOutlet UILabel *lRate_distancecost;

@property (weak, nonatomic) IBOutlet UILabel *lRate_TimeCost;

@property (weak, nonatomic) IBOutlet UILabel *lblRate_BasePrice;
@property (weak, nonatomic) IBOutlet UILabel *lblRate_DistancePrice;
@property (weak, nonatomic) IBOutlet UILabel *lblRate_TimePrice;

@property (weak, nonatomic) IBOutlet UILabel *lblRateCradNote;

@property (weak, nonatomic) IBOutlet UILabel *lblCarType;

///// for driver detail

@property (weak, nonatomic) IBOutlet UIView *viewForDriver;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driverName;
@property (weak, nonatomic) IBOutlet UIImageView *img_driver_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driverRate;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driver_Carname;
@property (weak, nonatomic) IBOutlet UILabel *lbl_driver_CarNumber;







@end
