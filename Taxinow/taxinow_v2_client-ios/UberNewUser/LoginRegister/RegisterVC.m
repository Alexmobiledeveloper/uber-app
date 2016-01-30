//
//  RegisterVC.m
//  Uber
//
//  Created by Elluminati - macbook on 23/06/14.
//  Copyright (c) 2014 Elluminati MacBook Pro 1. All rights reserved.
//

#import "RegisterVC.h"
#import "MyThingsVC.h"
#import "FacebookUtility.h"
#import <GooglePlus/GooglePlus.h>
#import "AppDelegate.h"
#import "GooglePlusUtility.h"
#import "UIImageView+Download.h"
#import "AFNHelper.h"
#import "Base64.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVBase.h>
#import <AVFoundation/AVFoundation.h>
#import "UtilityClass.h"
#import "MyThingsVC.h"
#import "Constants.h"
#import "UIView+Utils.h"
#import "UberStyleGuide.h"

@interface RegisterVC ()
{
    AppDelegate *appDelegate;
    NSMutableArray *arrForCountry;
    NSString *strImageData,*strForRegistrationType,*strForSocialId,*strForToken,*strForID;
    BOOL isPicAdded;
}

@end

@implementation RegisterVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setBackBarItem];
    [super setNavBarTitle:TITLE_REGISTER];
    [self SetLocalization];
    arrForCountry=[[NSMutableArray alloc]init];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 500)];
    strForRegistrationType=@"manual";
    appDelegate=[AppDelegate sharedAppDelegate];
    self.viewForEmailInfo.hidden=YES;
    [self customFont];
    
    
    [self.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"cb_glossy_off.png"] forState:UIControlStateNormal];
    [self.btnRegister setBackgroundColor:[UIColor darkGrayColor]];
     [self.imgProPic applyRoundedCornersFullWithColor:[UIColor whiteColor]];

    self.btnRegister.enabled=FALSE;
    //[self performSegueWithIdentifier:SEGUE_MYTHINGS sender:self];
    isPicAdded=NO;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
}
-(void)viewWillAppear:(BOOL)animated
{
    [[FacebookUtility sharedObject] logOutFromFacebook];
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.btnNav_Register setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
}
-(void)SetLocalization
{
    self.lblEmailInfo.text=NSLocalizedString(@"INFO_EMAIL", nil);
    self.txtFirstName.placeholder=NSLocalizedString(@"FIRST NAME*", nil);
    self.txtLastName.placeholder=NSLocalizedString(@"LAST NAME*", nil);
    self.txtEmail.placeholder=NSLocalizedString(@"EMAIL*", nil);
    self.txtPassword.placeholder=NSLocalizedString(@"PASSWORD*", nil);
    self.txtNumber.placeholder=NSLocalizedString(@"NUMBER*", nil);
    [self.btnTerm setTitle:NSLocalizedString(@"I agree to the terms and conditions", nil) forState:UIControlStateNormal];
    [self.btnRegister setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.btnDone setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    self.lblSelectCountry.text=NSLocalizedString(@"Select Country", nil);
    
}

#pragma mark-
#pragma mark- Custom Font & Localization

-(void)customFont
{
    self.txtFirstName.font=[UberStyleGuide fontRegular];
    self.txtLastName.font=[UberStyleGuide fontRegular];
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtPassword.font=[UberStyleGuide fontRegular];
    //self.txtAddress.font=[UberStyleGuide fontRegular];
    //self.txtBio.font=[UberStyleGuide fontRegular];
    //self.txtZipCode.font=[UberStyleGuide fontRegular];
    
    self.btnNav_Register=[APPDELEGATE setBoldFontDiscriptor:self.btnNav_Register];
    self.btnRegister=[APPDELEGATE setBoldFontDiscriptor:self.btnRegister];
}

#pragma mark -
#pragma mark - UIPickerView Delegate and Datasource

- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.btnSelectCountry setTitle:[[arrForCountry objectAtIndex:row] valueForKey:@"phone-code"] forState:UIControlStateNormal];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return arrForCountry.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strForTitle=[NSString stringWithFormat:@"%@  %@",[[arrForCountry objectAtIndex:row] valueForKey:@"phone-code"],[[arrForCountry objectAtIndex:row] valueForKey:@"name"]];
    return strForTitle;
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - UITextField Delegate
-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer;
{
    [self.txtFirstName resignFirstResponder];
    [self.txtLastName resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtNumber resignFirstResponder];
    [self.txtAddress resignFirstResponder];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtFirstName resignFirstResponder];
    [self.txtLastName resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtNumber resignFirstResponder];
    [self.txtAddress resignFirstResponder];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField==self.txtNumber || textField==self.txtZipCode)
    {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0) || [string isEqualToString:@""];
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint offset;
    if(textField==self.txtFirstName)
    {
        offset=CGPointMake(0, 50);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    if(textField==self.txtLastName)
    {
        offset=CGPointMake(0, 80);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    if(textField==self.txtEmail)
    {
        offset=CGPointMake(0, 110);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    if(textField==self.txtPassword)
    {
        offset=CGPointMake(0, 170);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    
    else if(textField==self.txtNumber)
    {
        offset=CGPointMake(0, 210);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    else if(textField==self.txtAddress)
    {
        offset=CGPointMake(0, 240);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    else if(textField==self.txtBio)
    {
        offset=CGPointMake(0, 350);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    else if(textField==self.txtZipCode)
    {
        offset=CGPointMake(0, 390);
        [self.scrollView setContentOffset:offset animated:YES];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGPoint offset;
    offset=CGPointMake(0, 0);
    [self.scrollView setContentOffset:offset animated:YES];
    
    if(textField==self.txtFirstName)
        [self.txtLastName becomeFirstResponder];
    else if(textField==self.txtLastName)
        [self.txtEmail becomeFirstResponder];
    else if(textField==self.txtEmail)
        [self.txtPassword becomeFirstResponder];
    else if(textField==self.txtPassword)
        [self.txtNumber becomeFirstResponder];
//    else if(textField==self.txtNumber)
//        [self.txtAddress becomeFirstResponder];
//    else if(textField==self.txtAddress)
//        [self.txtBio becomeFirstResponder];
//    else if(textField==self.txtBio)
//        [self.txtZipCode becomeFirstResponder];
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark - UIButton Action

- (IBAction)pickerCancelBtnPressed:(id)sender
{
    self.viewForPicker.hidden=YES;
}
- (IBAction)pickerDoneBtnPressed:(id)sender
{
    self.viewForPicker.hidden=YES;
}
- (IBAction)fbbtnPressed:(id)sender
{
    strForRegistrationType=@"facebook";
    

    if (![[FacebookUtility sharedObject]isLogin])
    {
        [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             if (success)
             {
                 self.txtPassword.userInteractionEnabled=NO;
                 NSLog(@"Success");
                 appDelegate = [UIApplication sharedApplication].delegate;
                 [appDelegate userLoggedIn];
                 [[FacebookUtility sharedObject]fetchMeWithFBCompletionBlock:^(id response, NSError *error) {
                     if (response) {
                         NSLog(@"FB Response ->%@",response);
                         strForSocialId=[response valueForKey:@"id"];
                         self.txtEmail.text=[response valueForKey:@"email"];
                         NSArray *arr=[[response valueForKey:@"name"] componentsSeparatedByString:@" "];
                         self.txtFirstName.text=[arr objectAtIndex:0];
                         self.txtLastName.text=[arr objectAtIndex:1];
                         
                         [self.imgProPic downloadFromURL:[response valueForKey:@"link"] withPlaceholder:nil];
                         NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [response objectForKey:@"id"]];
                         [self.imgProPic downloadFromURL:userImageURL withPlaceholder:nil];
                         isPicAdded=YES;
                     }
                 }];
             }
         }];
    }
    else{
        NSLog(@"User Login Click");
        appDelegate = [UIApplication sharedApplication].delegate;
        [[FacebookUtility sharedObject]fetchMeWithFBCompletionBlock:^(id response, NSError *error) {
            [APPDELEGATE hideLoadingView];
            if (response) {
                NSLog(@"FB Response ->%@ ",response);
                strForSocialId=[response valueForKey:@"id"];

                self.txtEmail.text=[response valueForKey:@"email"];
                NSArray *arr=[[response valueForKey:@"name"] componentsSeparatedByString:@" "];
                self.txtFirstName.text=[arr objectAtIndex:0];
                self.txtLastName.text=[arr objectAtIndex:1];
                
                [self.imgProPic downloadFromURL:[response valueForKey:@"link"] withPlaceholder:nil];
                NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [response objectForKey:@"id"]];
                [self.imgProPic downloadFromURL:userImageURL withPlaceholder:nil];
                isPicAdded=YES;
            }
        }];
        [appDelegate userLoggedIn];
    }
}

- (IBAction)proPicBtnPressed:(id)sender
{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    UIActionSheet *actionpass;
    
    actionpass = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SELECT_PHOTO", @""),NSLocalizedString(@"TAKE_PHOTO", @""),nil];
    [actionpass showInView:window];
    
}

- (IBAction)selectCountryBtnPressed:(id)sender
{
    CGPoint offset;
    offset=CGPointMake(0, 0);
    [self.scrollView setContentOffset:offset animated:YES];
    
    [self.txtAddress resignFirstResponder];
    [self.txtFirstName resignFirstResponder];
    [self.txtLastName resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtZipCode resignFirstResponder];
    [self.txtBio resignFirstResponder];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countrycodes" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    arrForCountry = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    [self.pickerView reloadAllComponents];
    self.viewForPicker.hidden=NO;
}

- (IBAction)googleBtnPressed:(id)sender
{
    strForRegistrationType=@"google";

    
    if ([[GooglePlusUtility sharedObject]isLogin])
    {
    }
    else
    {
        [[GooglePlusUtility sharedObject]loginWithBlock:^(id response, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 self.txtPassword.userInteractionEnabled=NO;
                 NSLog(@"Gmail Response ->%@ ",response);
                 strForSocialId=[response valueForKey:@"userid"];
                 self.txtEmail.text=[response valueForKey:@"email"];
                 NSArray *arr=[[response valueForKey:@"name"] componentsSeparatedByString:@" "];
                 self.txtFirstName.text=[arr objectAtIndex:0];
                 self.txtLastName.text=[arr objectAtIndex:1];
                 [self.imgProPic downloadFromURL:[response valueForKey:@"profile_image"] withPlaceholder:nil];
                 isPicAdded=YES;
             }
         }];
    }
}

- (IBAction)nextBtnPressed:(id)sender
{
//    [self performSegueWithIdentifier:SEGUE_TO_APPLY_REFERRAL_CODE sender:self];

    
    if([[AppDelegate sharedAppDelegate]connected])
    {
    
    if(self.txtFirstName.text.length<1 || self.txtLastName.text.length<1 || self.txtEmail.text.length<1 || self.txtNumber.text.length<1)
    {
        
        if(self.txtFirstName.text.length<1)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_FIRST_NAME", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
        else if(self.txtLastName.text.length<1)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_LAST_NAME", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
        else if(self.txtEmail.text.length<1)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_EMAIL", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
        else if(self.txtNumber.text.length<1)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_NUMBER", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
        else if (self.txtPassword.text.length<6)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_PASSWORD_LENGTH", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
//        else if(isPicAdded==NO)
//        {
//            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Please Select Profile Picture", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//            [alert show];
//        }
    }
    else
    {
        if([[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
        {
            
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"Registering", nil)];
            
             NSString *strnumber=[NSString stringWithFormat:@"%@%@",self.btnSelectCountry.titleLabel.text,self.txtNumber.text];
            
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            NSString *strDeviceId=[pref objectForKey:PREF_DEVICE_TOKEN];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
            [dictParam setValue:self.txtFirstName.text forKey:PARAM_FIRST_NAME];
            [dictParam setValue:self.txtLastName.text forKey:PARAM_LAST_NAME];
            [dictParam setValue:strnumber forKey:PARAM_PHONE];
            [dictParam setValue:strDeviceId forKey:PARAM_DEVICE_TOKEN];
            [dictParam setValue:@"ios" forKey:PARAM_DEVICE_TYPE];
            [dictParam setValue:@"" forKey:PARAM_BIO];
            [dictParam setValue:@"" forKey:PARAM_ADDRESS];
            [dictParam setValue:@"" forKey:PARAM_STATE];
            [dictParam setValue:@"" forKey:PARAM_COUNTRY];
            [dictParam setValue:@"" forKey:PARAM_ZIPCODE];
            [dictParam setValue:strForRegistrationType forKey:PARAM_LOGIN_BY];
            
            if([strForRegistrationType isEqualToString:@"facebook"])
                [dictParam setValue:strForSocialId forKey:PARAM_SOCIAL_UNIQUE_ID];
            else if ([strForRegistrationType isEqualToString:@"google"])
                [dictParam setValue:strForSocialId forKey:PARAM_SOCIAL_UNIQUE_ID];
            else
                [dictParam setValue:self.txtPassword.text forKey:PARAM_PASSWORD];
            
            if(isPicAdded==YES)
            {

                UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.imgProPic.image];
            
            
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_REGISTER withParamDataImage:dictParam andImage:imgUpload withBlock:^(id response, NSError *error) {
                
                    [[AppDelegate sharedAppDelegate]hideLoadingView];
                    if (response)
                    {
                        if([[response valueForKey:@"success"] boolValue])
                        {
                            [APPDELEGATE showToastMessage:NSLocalizedString(@"REGISTER_SUCCESS", nil)];
                            strForID=[response valueForKey:@"id"];
                            strForToken=[response valueForKey:@"token"];
                            [pref setObject:response forKey:PREF_LOGIN_OBJECT];
                        
                            [pref setObject:[response valueForKey:@"token"] forKey:PREF_USER_TOKEN];
                            [pref setObject:[response valueForKey:@"id"] forKey:PREF_USER_ID];
                            [pref setObject:[response valueForKey:@"is_referee"] forKey:PREF_IS_REFEREE];
                            [pref setBool:YES forKey:PREF_IS_LOGIN];
                            [pref synchronize];
                            [self performSegueWithIdentifier:SEGUE_TO_APPLY_REFERRAL_CODE sender:self];
                        
                        }
                        else
                        {
                        
                            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                            [alert show];
                        }

                    }
                                NSLog(@"REGISTER RESPONSE --> %@",response);
                }];
                
                }
                else
                {
                    NSLog(@"not profile");
                    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                    [afn getDataFromPath:FILE_REGISTER withParamData:dictParam withBlock:^(id response, NSError *error) {
                        [[AppDelegate sharedAppDelegate]hideLoadingView];
                        if (response)
                        {
                            if([[response valueForKey:@"success"] boolValue])
                            {
                                [APPDELEGATE showToastMessage:NSLocalizedString(@"REGISTER_SUCCESS", nil)];
                                strForID=[response valueForKey:@"id"];
                                strForToken=[response valueForKey:@"token"];
                                [pref setObject:response forKey:PREF_LOGIN_OBJECT];
                            
                                [pref setObject:[response valueForKey:@"token"] forKey:PREF_USER_TOKEN];
                                [pref setObject:[response valueForKey:@"id"] forKey:PREF_USER_ID];
                                [pref setObject:[response valueForKey:@"is_referee"] forKey:PREF_IS_REFEREE];
                                [pref setBool:YES forKey:PREF_IS_LOGIN];
                                [pref synchronize];
                                [self performSegueWithIdentifier:SEGUE_TO_APPLY_REFERRAL_CODE sender:self];
                            
                            }
                            else
                            {
                                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                                [alert show];
                            }
                        
                        }
                        NSLog(@"REGISTER RESPONSE --> %@",response);
                    }];
                }
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_VALID_EMAIL", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
             [alert show];
         }
    }
    }
    
    else
    {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            [alert show];
    }
    //[self performSegueWithIdentifier:SEGUE_MYTHINGS sender:self];

}

- (IBAction)btnEmailInfoClick:(id)sender {
    
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==0)
    {
        btn.tag=1;
        self.viewForEmailInfo.hidden=NO;
    }
    else
    {
        btn.tag=0;
        self.viewForEmailInfo.hidden=YES;
    }
}


- (IBAction)checkBoxBtnPressed:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag == 0)
    {
        btn.tag=1;
        [btn setBackgroundImage:[UIImage imageNamed:@"cb_glossy_on.png"] forState:UIControlStateNormal];
        
        [self.btnRegister setBackgroundColor:[UIColor blackColor]];
        self.btnRegister.enabled=TRUE;
        
    }
    else
    {
        btn.tag=0;
        [btn setBackgroundImage:[UIImage imageNamed:@"cb_glossy_off.png"] forState:UIControlStateNormal];
        [self.btnRegister setBackgroundColor:[UIColor darkGrayColor]];
        self.btnRegister.enabled=FALSE;
    }
}

- (IBAction)termsBtnPressed:(id)sender
{
    [self performSegueWithIdentifier:@"pushToTerms" sender:self];
}


#pragma mark
#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            [self selectPhotos];
        }
            break;
        case 1:
        {
            [self takePhoto];
        }
            break;
       
            
            
        default:
            break;
    }
}

#pragma mark
#pragma mark - Action to Share


- (void)selectPhotos
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing=YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

-(void)takePhoto
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
        imagePickerController.allowsEditing=YES;
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];

    }
    else
    {
        UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"CAM_NOT_AVAILABLE", nil)delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alt show];
    }  // Set up the image picker controller and add it to the view
}

#pragma mark
#pragma mark - ImagePickerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if([info valueForKey:UIImagePickerControllerEditedImage]==nil)
    {
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//
            UIImage *img=[UIImage imageWithData:data];
            [self setImage:img];
        } failureBlock:^(NSError *err) {
            NSLog(@"Error: %@",[err localizedDescription]);
        }];
    }
    else
    {
        [self setImage:[info valueForKey:UIImagePickerControllerEditedImage]];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)setImage:(UIImage *)image
{
    self.imgProPic.image=image;
    isPicAdded=YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark - Segue Methods

/*-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_MYTHINGS])
    {
        MyThingsVC *obj=[segue destinationViewController];
        obj.strForToken=strForToken;
        obj.strForID=strForID;
    }
}*/

@end
