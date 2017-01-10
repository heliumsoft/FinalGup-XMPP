//
//  SettingsBlocked.h
//  GUPver 1.0
//
//  Created by genora on 11/5/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SettingsBlocked : UIViewController<UITableViewDataSource,UITabBarDelegate,MBProgressHUDDelegate>
{
    IBOutlet UITableView *blockedTable;
    NSMutableArray *blockedUserId,*blockedUserName,*blockedUserPic,*blockedUserLocation,*selectedUserId;
    NSString *appUserId;
    
    NSURLConnection *fetchBlockedUsersConn,*unblockUsersConn;
    NSMutableData *fetchBlockedUsersResponse,*unblockUsersResponse;
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    
    MBProgressHUD *HUD;
}
-(void)unblockUsers:(id)sender;
-(void)loadBlockedUsers;
-(void)startActivityIndicator;
@end
