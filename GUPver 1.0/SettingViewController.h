//
//  SettingViewController.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
@interface SettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,MFMailComposeViewControllerDelegate>
{
    IBOutlet UITableView *settingsTable;
    int blockedUsersCount;
    NSURLConnection *LOGOUT;
    NSMutableData *LOGOUTRESPONSE;
     MBProgressHUD *HUD;
}
-(void)initialiseView;

@end
