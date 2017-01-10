//
//  ExploreViewController.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/13/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "newGroupCell.h"
#import "AFNetworking.h"

@interface ExploreViewController : UIViewController<UITableViewDataSource,groupDelegate,UITableViewDelegate,UISearchBarDelegate,NSURLConnectionDelegate,MBProgressHUDDelegate>
{
    NSMutableArray *categoryThumbnails,*categoryNames,*categoryGroupNo,*categoryIds,*filterOptionsList;
    NSMutableArray *textLabel,*detailTextLabel,*imageView,*tableType,*typeArray,*resultIdArray,*userEmailId,*userStatus;
    NSMutableArray *tempTextLabel,*tempDetailTextLabel,*tempImageView,*tempTableType,*tempTypeArray,*tempResultIdArray,*tempUserEmailId,*tempUserStatus,*groupData;
    
    NSMutableArray * searchData;
    int searchVariable;
    IBOutlet UITableView *ExploreTableView;
    UILabel *categoryGroups;
    IBOutlet UISearchBar *search;
      NSInteger expndRow;
    UIButton *FilterButton;
    UIButton *joinButton;
    NSURLConnection *fetchLocationConn,*searchConn,*addContactConn;
    NSMutableData *fetchLocationResponse,*searchResponse,*addContactResponse;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    
    NSString *selectedContactId,*selectedContactEmail,*selectedContactName,*selectedContactPic,*selectedContactStatus,*selectedContactLocation;
    
    NSURLConnection *initiateGroupJoinConn,*addGroupConn,*addFavGroupConn,*groupCountConn,*multiJoinConn;
    NSMutableData *initiateGroupJoinResponse,*addGroupResponse,*addFavGroupResponse,*groupCountResponse,*multiJoinResponse;
    
    NSString *selectedGroupId,*selectedGroupName,*selectedGroupPic,*selectedGroupType;
    NSString *appUserId;
    
    
    NSMutableArray *categoryImageData,*selectIDS,*selectedGroup;
    UIImageView *categoryImageView;
    UILabel *categoryNameLabel;
    
    MBProgressHUD *HUD;
    IBOutlet UILabel *groupByCategoryLabel;
    
    UIBarButtonItem *filterButton;
    
   // NSString *status;
    UIViewController *testviewcontroller;
    UITableViewController *filterTable;
    UINavigationController *navController;
    UIPopoverController *pop;
    
    //NSMutableArray *someFilterVariable;
    int userFilter,privateFilter,publicFilter,pageno;

}

//-(void)cancel:(id)sender;
-(void)listCategories;
-(void)setActivityIndicator;
-(void)fetchGroupCount;
-(IBAction)setFilterTable:(id)sender;
-(void)donefiltering:(id)sender;
-(void)cancelPop:(id)sender;
-(void)clearArrays:(NSString*)variable;

@end
