//
//  ContactList.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/16/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoom.h"

@interface ContactList : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MBProgressHUDDelegate>
{
    IBOutlet UITableView *contactListTable;
    NSMutableArray *contactNames,*contactThumbnails,*contactLocation,*contactId,*tempContactId,*tempContactName,*tempContactsThumbnails,*tempContactLocation,*selectedContacts,*selectedContactNames,*selectedContactLocation,*selectedCells,*selectedContactImage,*tempType,*type,*selectedType,*conId,*conName,*conImage,*conLocation;
    NSArray *testcontacts;
    IBOutlet UISearchBar *search;
    BOOL isFiltered;
     UIButton *skip,*done;
    NSURLConnection *addMembersConn;
    NSMutableData *addMembersResponse;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    NSString *CLtype;
    id Instance;
    NSString *myImage;
    
    MBProgressHUD *HUD;
    
    NSMutableArray *membersID,*grpID,*grpNAME,*grpPIC,*grpCAT,*grpTYPE,*selectedRosterArray,*rosterArray;
}
@property(nonatomic,strong)NSString *chatWithUserID;
@property(nonatomic,retain)NSMutableArray *memberID;
@property (nonatomic, retain) NSString  *groupStatus;
@property (nonatomic, retain) NSString  *groupJID;
@property (nonatomic, retain) NSString  *groupId;
@property (nonatomic, retain) XMPPRoom *xmppRoom;
@property (nonatomic, retain) NSString  *groupName;
@property (nonatomic, retain) NSString  *hideUnhideSkipDoneButton;
@property (nonatomic, retain) NSString  *viewType;
-(void)openHomePage:(id)sender;
-(IBAction)skip:(id)sender;
-(IBAction)done:(id)sender;
-(void)setBehaviourOfContactList:(NSString*)type from:(id)instance;
-(void)addMembers:(id)sender;
-(void)addMembersToGroup;
-(void)inviteMembers:(id)sender;
-(void)getPrivateGroupList;
-(void)getMembersList;
-(void)getmemberDetails:(NSString*)selectedGroupID;

@end
