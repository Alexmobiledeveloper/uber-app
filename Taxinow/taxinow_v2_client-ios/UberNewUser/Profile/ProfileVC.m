//
//  ProfileVC.m
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVBase.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "UtilityClass.h"
#import "UIView+Utils.h"
#import "UberStyleGuide.h"

@interface ProfileVC ()
{
    NSString *strForUserId,*strForUserToken;
}

@end

@implementation ProfileVC

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
    [self SetLocalization];
    //[super setNavBarTitle:TITLE_PROFILE];
    self.viewForEmailInfo.hidden=YES;
    [super setBackBarItem];
    [self setDataForUserInfo];
    [self.proPicImgv applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    [self customFont];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.btnEdit.hidden=NO;
    self.btnUpdate.hidden=YES;
    [self.txtFirstName setTintColor:[UIColor whiteColor]];
    [self.txtLastName setTintColor:[UIColor whiteColor]];
    
    [self textDisable];
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.btnNavigation setTitle:NSLocalizedString(@"Profile", nil) forState:UIControlStateNormal];
}
-(void)SetLocalization
{
    self.txtFirstName.placeholder=NSLocalizedString(@"FIRST NAME", nil);
    self.txtLastName.placeholder=NSLocalizedString(@"LAST NAME", nil);
    self.txtEmail.placeholder=NSLocalizedString(@"EMAIL", nil);
    self.txtPhone.placeholder=NSLocalizedString(@"PHONE", nil);
    self.txtCurrentPWD.placeholder=NSLocalizedString(@"CURRENT PASSWORD", nil);
    self.txtNewPWD.placeholder=NSLocalizedString(@"NEW PASSWORD", nil);
    self.txtConformPWD.placeholder=NSLocalizedString(@"CONFORM PASSWORD", nil);
    [self.btnEdit setTitle:NSLocalizedString(@"EDIT PROFILE", nil) forState:UIControlStateNormal];
    [self.btnUpdate setTitle:NSLocalizedString(@"UPDATE PROFILE", nil) forState:UIControlStateNormal];
}
-(void)setDataForUserInfo
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictInfo=[pref objectForKey:PREF_LOGIN_OBJECT];
    
    [self.proPicImgv downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    self.txtFirstName.text=[dictInfo valueForKey:@"first_name"];
    self.txtLastName.text=[dictInfo valueForKey:@"last_name"];
    self.txtEmail.text=[dictInfo valueForKey:@"email"];
    self.txtPhone.text=[dictInfo valueForKey:@"phone"];
    self.lblEmailInfo.text=NSLocalizedString(@"This field is not editable.", nil);
    //self.txtAddress.text=[dictInfo valueForKey:@"address"];
    ///self.txtZipCode.text=[dictInfo valueForKey:@"zipcode"];
    //self.txtBio.text=[dictInfo valueForKey:@"bio"];

}
#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark-
#pragma mark - UIButton Action

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

- (IBAction)selectPhotoBtnPressed:(id)sender
{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    UIActionSheet *actionpass;
    
    actionpass = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SELECT_PHOTO", @""),NSLocalizedString(@"TAKE_PHOTO", @""),nil];
    actionpass.delegate=self;
    [actionpass showInView:window];
}

- (IBAction)updateBtnPressed:(id)sender
{
    if (self.txtNewPWD.text.length > 0 || self.txtConformPWD.text.length > 0)
    {
        if ([self.txtNewPWD.text isEqualToString:self.txtConformPWD.text])
        {
            [self updateProfile];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Profile Update Fail" message:NSLocalizedString(@"NOT_MATCH_RETYPE",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        [self updateProfile];
    }
    
}
-(void)updateProfile
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        if([[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
        {
            
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"EDITING", nil)];
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            strForUserId=[pref objectForKey:PREF_USER_ID];
            strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
            [dictParam setValue:self.txtFirstName.text forKey:PARAM_FIRST_NAME];
            [dictParam setValue:self.txtLastName.text forKey:PARAM_LAST_NAME];
            [dictParam setValue:self.txtPhone.text forKey:PARAM_PHONE];
            [dictParam setValue:@"" forKey:PARAM_BIO];
            [dictParam setValue:self.txtCurrentPWD.text forKey:PARAM_OLD_PASSWORD];
            [dictParam setValue:self.txtNewPWD.text forKey:PARAM_NEW_PASSWORD];
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            
            [dictParam setValue:@"" forKey:PARAM_ADDRESS];
            [dictParam setValue:@"" forKey:PARAM_STATE];
            [dictParam setValue:@"" forKey:PARAM_COUNTRY];
            [dictParam setValue:@"" forKey:PARAM_ZIPCODE];
            
            
            UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.proPicImgv.image];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_UPADTE withParamDataImage:dictParam andImage:imgUpload withBlock:^(id response, NSError *error) {
                
                [[AppDelegate sharedAppDelegate]hideLoadingView];
                if (response)
                {
                    if([[response valueForKey:@"success"] boolValue])
                    {
                        
                        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                        [pref setObject:response forKey:PREF_LOGIN_OBJECT];
                        [pref synchronize];
                        [self setDataForUserInfo];
                        [APPDELEGATE showToastMessage:NSLocalizedString(@"PROFILE_EDIT_SUCESS", nil)];
                        [self textDisable];
                        self.btnUpdate.hidden=YES;
                        self.btnEdit.hidden=NO;
                        self.txtConformPWD.text=@"";
                        self.txtCurrentPWD.text=@"";
                        self.txtNewPWD.text=@"";
                        // [self.navigationController popViewControllerAnimated:YES];
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Status", nil) message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }


}
- (IBAction)editBtnPressed:(id)sender
{
    [self textEnable];
    [self.btnEdit setHidden:YES];
    [self.btnUpdate setHidden:NO];
    [self.txtFirstName becomeFirstResponder];
    [APPDELEGATE showToastMessage:@"You Can Edit Your Profile"];

}

#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.txtFirstName.font=[UberStyleGuide fontRegularBold:18.0f];
    self.txtLastName.font=[UberStyleGuide fontRegularBold:18.0f];
    self.txtPhone.font=[UberStyleGuide fontRegular];
    self.txtEmail.font=[UberStyleGuide fontRegular];
   // self.txtAddress.font=[UberStyleGuide fontRegular];
   // self.txtBio.font=[UberStyleGuide fontRegular];
   // self.txtZipCode.font=[UberStyleGuide fontRegular];
    
    self.btnNavigation.titleLabel.font=[UberStyleGuide fontRegular];
   self.btnEdit.titleLabel.font=[UberStyleGuide fontRegularBold];
    self.btnUpdate.titleLabel.font=[UberStyleGuide fontRegularBold];
}


-(void)textDisable
{
    self.txtFirstName.enabled = NO;
    self.txtLastName.enabled = NO;
    self.txtEmail.enabled = NO;
    self.txtPhone.enabled = NO;
    self.txtConformPWD.enabled=NO;
    self.txtCurrentPWD.enabled=NO;
    self.txtNewPWD.enabled=NO;
   // self.txtAddress.enabled = NO;
   // self.txtZipCode.enabled = NO;
   // self.txtBio.enabled = NO;
    self.btnProPic.enabled=NO;
}

-(void)textEnable
{
    self.txtFirstName.enabled = YES;
    self.txtLastName.enabled = YES;
    self.txtEmail.enabled = NO;
    self.txtPhone.enabled = YES;
    self.txtConformPWD.enabled=YES;
    self.txtCurrentPWD.enabled=YES;
    self.txtNewPWD.enabled=YES;
   // self.txtAddress.enabled = YES;
   // self.txtZipCode.enabled = YES;
   // self.txtBio.enabled = YES;
    self.btnProPic.enabled=YES;
}
#pragma mark
#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
        {
            [self takePhoto];
        }
            break;
        case 0:
        {
            [self selectPhotos];
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
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsEditing=YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
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
    self.proPicImgv.image=image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark
#pragma mark - UItextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    int y=0;
    if(textField==self.txtPhone)
        y=-100;
    else if(textField==self.txtCurrentPWD)
        y=-136;
    else if(textField==self.txtNewPWD)
        y=-150;
    else if(textField==self.txtConformPWD)
        y=-170;
    
    [UIView animateWithDuration:0.5 animations:^{
        
            self.view.frame=CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished)
     {
     }];
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.txtLastName)
    {
       
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    /*if (textField==self.txtFirstName)
    {
        [self.txtLastName becomeFirstResponder];
    }
    if (textField==self.txtLastName)
    {
         //[[UITextField appearance] setTintColor:[UIColor blackColor]];
        [self.txtEmail becomeFirstResponder];
    }
    if (textField==self.txtEmail)
    {
        [self.txtPhone becomeFirstResponder];
    }
    if (textField==self.txtPhone)
    {
     
        [self.txtAddress becomeFirstResponder];
    }
    if (textField==self.txtAddress)
    {
        [self.txtBio  becomeFirstResponder];
    }
    if (textField==self.txtBio)
    {
        [self.txtZipCode becomeFirstResponder];
    }*/

    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished)
     {
     }];
    
    [textField resignFirstResponder];
    return YES;
}

@end
