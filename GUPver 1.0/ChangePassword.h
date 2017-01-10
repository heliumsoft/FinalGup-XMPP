//
//  ChangePassword.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/6/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ChangePassword : UIViewController<UITextFieldDelegate,NSURLConnectionDelegate,MBProgressHUDDelegate>
{
    IBOutlet UITextField *newPassword,*confirmPassword;
    IBOutlet UIButton *changePassword;
    NSURLConnection *changePasswordConn;
    NSMutableData *changePasswordResponse;
    UIActivityIndicatorView *activityIndicator;
    MBProgressHUD *HUD;
}
-(IBAction)checkPasswordMatch:(id)sender;
-(void)changePassword;
@property(strong,nonatomic)IBOutlet UITextField *currentPassword;

@property (nonatomic, retain) NSString  *userId;

@end
