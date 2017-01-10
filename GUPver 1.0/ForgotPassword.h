//
//  ForgotPassword.h
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 11/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
@interface ForgotPassword : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate>
{ 
     UITextField *emailID;
   
    id instance;
    NSString *emailPassed;
    NSMutableURLRequest *request1,*requestEmail;
    NSURLConnection *connection1,*connection2;
    NSMutableData *eventsResponse,*emailResponce;
    UIView *freezer;
    UIActivityIndicatorView *progress;
    CGRect TXFRAME;
    IBOutlet UIScrollView *mainScroll;
    
    __weak IBOutlet UIButton *submitbtn;
    MBProgressHUD *HUD;

}
-(IBAction)submmit:(id)sender;
-(void)SetEmailID:(NSString*)EmailID from:(id)inta;

@end
