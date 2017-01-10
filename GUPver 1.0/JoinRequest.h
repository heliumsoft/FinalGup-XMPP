//
//  JoinRequest.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface JoinRequest : UIViewController<UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate>
{
    IBOutlet UITableView *joinRequestTable;
    NSArray *profilePics;
    
    NSURLConnection *getGroupJoinRequestConn,*requestApprovalConn;
    NSMutableData *getGroupJoinRequestResponse,*requestApprovalResponse;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    NSMutableArray *userId,*userName,*userPic,*userLocation;
    NSIndexPath *selectedIndexPath;
    int flag;
    MBProgressHUD *HUD;
}

-(IBAction)acceptRequest:(id)sender event:(id)event;
-(IBAction)rejectRequest:(id)sender event:(id)event;

-(void)getGroupJoinRequest;
-(void)startActivityIndicator;
-(void)requestApproval;

@property (nonatomic, retain) NSString  *groupType;
@property (nonatomic, retain) NSString  *groupId;
@property (nonatomic, retain) NSString  *groupName;
@end
