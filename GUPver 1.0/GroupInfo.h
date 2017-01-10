//
//  GroupInfo.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface GroupInfo : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{int noOfSection;
    IBOutlet UITableView *groupInfoTable;
    IBOutlet UIButton *favorite,*share;
    IBOutlet UIImageView *displayPic;
    NSArray *getData,*getDataPublic;
    //,*groupPic,*groupDesc,*groupAdmin,*groupCategory,*groupMembers,*createdOn;
    NSURLConnection *groupInfoConn,*memberConnection;
   
    NSMutableData *groupInfoResponse, *memberRsponce;
    NSMutableArray *contactId,*contactName,*contactLoc,*contactIsAdmin,*contactPic;
    
    NSString *categoryName,*admin,*creationDate,*groupDesc,*groupName,*groupPic,*grouptype,*groupid,*location,*memberCount;
    
    UIActivityIndicatorView *activityIndicator;
    UIActivityIndicatorView *imageActivityIndicator;
    UIView *freezer;
    
    NSURLConnection *addFavConn,*leaveGroupConn;
    NSMutableData *addFavResponse,*leaveGroupResponse;
    
    NSString *adminList;
    MBProgressHUD *HUD;
    
    
}
@property(strong,nonatomic)NSString *groupType;
@property (strong, nonatomic) NSString  *groupId;
@property(strong,nonatomic)NSString *startLoading;
@property(strong,nonatomic)NSString *viewType;
@property (weak, nonatomic) IBOutlet UILabel *groupDesc;
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *categoryInfo;
@property (weak, nonatomic) IBOutlet UILabel *createdInfo;
@property (strong, nonatomic) IBOutlet UILabel *typeInfo;
@property (weak, nonatomic) IBOutlet UILabel *totalMembers;
@property (weak, nonatomic) IBOutlet UILabel *sharelabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *leaveBtn;

-(void)refreshGroupInfo;
-(IBAction)shareGroupInfo:(id)sender;
-(IBAction)addToFavorite:(id)sender;
-(void)startActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *inviteMember;

- (IBAction)openGroupMember:(id)sender;
- (IBAction)leaveGroup:(id)sender;
- (IBAction)inviteMember:(id)sender;

@end
