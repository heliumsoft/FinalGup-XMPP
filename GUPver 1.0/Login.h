//
//  Login.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "FHSTwitterEngine.h"
#import "MBProgressHUD.h"
@class GPPSignInButton;
@interface Login : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,FHSTwitterEngineAccessTokenDelegate,GPPSignInDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>{
    
    BOOL statusBarHidden;
    IBOutlet UIView *splashscreen;
    IBOutlet UIImageView *logo;
    IBOutlet UIScrollView *mainScroll;
   
    __weak IBOutlet UILabel *notamem;
    __weak IBOutlet UIButton *forget;
    __weak IBOutlet UILabel *loginusing;
    IBOutlet UITableView *loginform;
    CGRect TXFRAME;
    NSString *userId;
    BOOL ispasswordreset;
    int ii;
    NSString *googlePlusID;
    NSMutableURLRequest *request1;
    NSURLConnection *connection1,*updateUser;
    NSMutableData *eventsResponse,*updateResponce;
   // UIView *freezer;
   // UIActivityIndicatorView *progress;
    UIAlertView *notifyGp;
    GPPSignIn *signIn;
    NSString * appVersionString ;
     MBProgressHUD *HUD;
}
@property (weak, nonatomic) IBOutlet UIButton *loginb;

-(IBAction)openSignUp:(id)sender;
-(IBAction)openHomePage:(id)sender;
-(IBAction)googleplus:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *signup;

- (IBAction)facebook:(id)sender;
-(IBAction)showLoginWindow:(id)sender;

-(IBAction)forgotPassword:(id)sender;
-(void)updateLoginText:(NSString*)EID;
-(void)freezerRemove;
-(void)freezerAnimate;
- (BOOL) validateEmail: (NSString *) emailstring ;
-(void)gmailLoginOnGupWithUserId:(NSString*)gplusUserId;
@property (nonatomic, strong) NSTimer *SwitchTimer;
@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property(strong,nonatomic) IBOutlet UITextField *emailId,*password;;

@end
