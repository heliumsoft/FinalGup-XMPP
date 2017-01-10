//
//  SettingsDelete.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 1/20/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SettingsDelete : UIViewController<UITextFieldDelegate,UITextViewDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>
{
    IBOutlet UILabel *label;
    IBOutlet UITextField *password;
    IBOutlet UITextView *reasonForDeletion;
    IBOutlet UIScrollView *scrollView;
    CGRect TXFRAME;
    UIView *freezer;
    UIActivityIndicatorView *activityIndicator;
    NSURLConnection *deleteConn;
    NSMutableData *deleteData;
    IBOutlet UIView *topView,*bottomView;
    MBProgressHUD *HUD;
    NSInteger  socialLoginVariable;

    
}
-(void)deleteAccountFunction;

@end
