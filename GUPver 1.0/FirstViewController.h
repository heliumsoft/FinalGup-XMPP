//
//  FirstViewController.h
//  GUPver 1.0
//
//  Created by genora on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupsView.h"
#import "PrivateView.h"
#import "HomeTableCell.h"
#import "FPPopoverController.h"
#import "SMChatDelegate.h"
#import "MBProgressHUD.h"
#import "LandingPage.h"

@interface FirstViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UISearchBarDelegate,UIActionSheetDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    //IBOutlet UIView *contentView;
    // group table view
    NSArray *groupsChatList;
    NSArray *searchResults;
    NSArray *thumbnails;
    NSMutableArray *lastMsgReceivedTime,*unreadMsg,*lastMessageType,*lastMsg;
    IBOutlet UITableView *groupsTable;
    IBOutlet UISearchBar *search;
    NSString *myImage;
    // personal table view
    NSArray *privateChatList,*personalImages;
    
//      IBOutlet UISegmentedControl *segControl;
    
    //GroupsView *groupController;
    //PrivateView *privateController;
    NSArray *statusOptions;
    NSArray *statusOptionsThumbnails;
//    NSMutableArray *contactNames,*contactIds,*contactPics,*contactStatus,*getData,*tempContactNames,*tempContactPics,*tempContactStatus,*tempLastMsgReceivedTime,*tempUnreadMsg,*tempContactIds,*tempLastMsg,*tempLastMessageType,*muteNotify,*tempMuteNotify;
//    NSMutableArray *groupIds,*groupNames,*groupTypes,*groupMute,*groupRead,*tempGroupIds,*tempGroupNames,*tempGroupTypes,*tempGroupMute,*tempGroupRead,*groupFlag,*tempGroupFlag,*groupPics,*tempGroupPics;
    
    NSMutableArray *userData,*getData,*userSearchList;
    //NSMutableDictionary *contactList,*tempcontactList;
    //UIViewController *activeViewController;
    //NSInteger activeIndex;
    UIButton *statusButton;
    NSString *status;
    UIViewController *testviewcontroller;
    UITableView *statusTable;
    UINavigationController *navController;
    UIPopoverController *pop;
    UIBarButtonItem *infoButtonItem;
    UIBarButtonItem *addButton,*forward;
    
    FPPopoverController *popover;
    
    BOOL isFiltered;
    
    NSString *selectedContactId;
    
    //action sheet
    NSString *other1,*other2,*other0,*cancelTitle;
    
    UIActionSheet *groupActionSheet,*contactActionSheet;
    
    NSURLConnection *notifyBlockedUsersConn,*resendEmail,*groupMemberConn,*muteConnection,*unmuteConnection;
    NSMutableData *notifyBlockedUsersResponse,*resendEmailresponce,*groupMemberData,*muteData,*unmuteData;
    
    UIView *freezer;
    UIActivityIndicatorView *activityIndicator;
    NSMutableArray *receiversUserId,*receiversGroupId;
    
    NSIndexPath *selectedIndexPath,*indexPath1;
    NSUserDefaults *defaults;
    NSString *selectedGroup,*selectedGroupName,*selectedGroupType;
    
    NSURLConnection *leaveGroupConn,*reportGroupConn,*reportSpamConn;
    NSMutableData *leaveGroupResponse,*reportGroupResponse,*reportSpamResponse;
    NSURLConnection *fetchContactsConn,*fetchGroupsConn;
    NSMutableData *fetchContactsResponse,*fetchGroupsResponse;
    UIPopoverController *popover1;
    NSURLConnection *LOGOUT;
    NSMutableData *LOGOUTRESPONSE;
    MBProgressHUD *HUD;
    
    UIImageView *recieveContactMsg,*recieveGroupMsg;
    
    NSString *groupTimeStampValue;
    UILocalNotification *localNotification;
}
@property(strong,nonatomic)NSString *type,*messageToBeForwarded,*msgType;
@property(strong,nonatomic)id sender;

-(void)CancelForward;
-(void)addGroup;
-(void)initialiseView;
-(void)setupSegmentController;
-(IBAction)setStatus:(id)sender;
-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture;
-(void)handleLongPressForGroup:(UILongPressGestureRecognizer *)gesture;
-(void)refreshChatList;

//-(void)notifyBlockedUsers;
-(void)initiateChat;
-(void)refreshGroupList;
-(void)setActivityIndicator;
-(void)fetchContacts;
-(void)fetchGroups;
-(void)freezerAnimate;
-(void)freezerRemove;
@property (strong, nonatomic) NSString  *appUserId;

@end
