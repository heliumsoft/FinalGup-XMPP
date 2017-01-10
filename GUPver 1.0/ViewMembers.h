//
//  ViewMembers.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 12/9/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "newGroupCell.h"
#import "AFNetworking.h"
@interface ViewMembers : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MBProgressHUDDelegate,groupDelegate>

{
    IBOutlet UISearchBar *search;
    IBOutlet UITableView *membersList;
    NSMutableArray *displayPic,*displayName,*displayLocation,*userId,*tempUserId,*tempDisplayPic,*tempDisplayName,*tempDisplayLocation,*getData;
    BOOL isFiltered;
    
    NSURLConnection *viewMembersConn;
    NSMutableData *viewMembersResponse;
    
    MBProgressHUD *HUD;
    
   NSInteger expndRow;
   NSMutableArray *selectedGroup;
}
@property (strong, nonatomic) NSString  *groupId;
@property(strong,nonatomic)NSString *startLoading;
@property (strong,nonatomic) NSString  *groupType;
@property (strong,nonatomic) NSString  *groupName;
@property (strong,nonatomic) NSString  *viewType;


-(void)loadMembersFromServer;
-(void)inviteMembers:(id)sender;
@end
