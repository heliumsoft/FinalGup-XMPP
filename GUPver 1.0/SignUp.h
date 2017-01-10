//
//  SignUp.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"


@interface SignUp : UIViewController<UIAlertViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
{
    //current location param(logi ,lati ,addr)
    CLLocationManager *locationManager;
    CGFloat Longitude,Latitude;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    int offset;
    NSMutableData *locationResponse;
    NSURLConnection *location_events;
    IBOutlet UIImageView *UserImage;
    IBOutlet UITableView *form;
    NSInteger locationID;
    NSString *addressName;
    NSString *location;
   NSString *userId;
    
    UITextField *userNameTextField,*emailIdTextField,*passwordTextField,*confirmPasswordTextField;
      float animatedDistance;
    IBOutlet UIScrollView *mainScroll;
    IBOutlet UITableView *signUptable;
    CGRect TXFRAME;
    UILabel *loc;
    NSMutableURLRequest *request1;
   UITextView *aboutme;
    __weak IBOutlet UITextField *username;
    
    UIActivityIndicatorView *nameVerification,*loadingLocation;
    BOOL usernameIsUnique;
    NSArray *locations;
    UITapGestureRecognizer *tapRecognizer;
    UIImagePickerController *Ipicker;
    //UIView *freezer;
    //UIActivityIndicatorView *progress;
   NSString * appVersionString ;
    MBProgressHUD *HUD;
}
@property(strong,nonatomic)NSURLConnection *connection1,*usernameUniqueCheck,*getLocation,*updateUser;
@property(strong,nonatomic) NSMutableData *SignUpResponse,*usernameUniqueCheckResponse,*getLoctionResponse,*updateResponce;
//-(IBAction)openTerms:(id)sender;
-(IBAction)openTabbar:(id)sender;
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer;
-(void)updateLocationLable:(NSString *)locationName locationID:(NSInteger)locID;

//- (IBAction)takePhoto:  (UIButton *)sender;
//- (IBAction)selectPhoto:(UIButton *)sender;
@end
