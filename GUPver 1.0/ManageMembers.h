//
//  ManageMembers.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/14/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@interface ManageMembers : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate>
{
    NSArray *contactDisplayPic;
    NSMutableArray *memberId,*memberName,*memberLocation,*memberDisplayPic,*memberIsAdmin;
    IBOutlet UITableView *manageMembersTable;
    NSString *selectedMemberId;
    UIImageView *adminImage;
    UIButton *deleteButton;
    NSString *userID;
    
    NSURLConnection *deleteMemberConn,*makeAdminConn,*leaveAsAdminConn;
    NSMutableData *deleteMemberResponse,*makeAdminResponse,*leaveAsAdminResponse;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
     NSURLConnection *fetchContactsConn,*fetchGroupsConn;
    MBProgressHUD *HUD;
    NSMutableData *fetchContactsResponse,*fetchGroupsResponse;
     NSString *groupTimeStampValue;
   
}
-(IBAction)deleteMember:(id)sender event:(id)event;
-(void)addMember:(id)sender;
-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture;
-(void)loadMembers;
@property (strong, nonatomic) NSString  *appUserId;
@property (strong,nonatomic) NSString  *groupType;
@property (strong,nonatomic) NSString  *groupId;
@property (strong,nonatomic) NSString  *groupName;
@end
