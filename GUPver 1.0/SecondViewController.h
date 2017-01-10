//
//  SecondViewController.h
//  GUPver 1.0
//
//  Created by genora on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupSearchViewController.h"
#import "PrivateSearchViewController.h"
#import "FPPopoverController.h"
#import "MBProgressHUD.h"
#import "Afnetworking.h"
#import "newGroupCell.h"


@interface SecondViewController : UIViewController<UIPopoverControllerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UITextFieldDelegate,MBProgressHUDDelegate,groupDelegate,UINavigationControllerDelegate>
{
    int NoOfRows,filterCriteria;
    NSString *temporatyString;
    IBOutlet UITableView *searchTable;
    GroupSearchViewController *groupController;
    PrivateSearchViewController *privateController;
    NSArray *chatSegmentControllers;
    UIViewController *activeViewController;
    NSInteger activeIndex;
    IBOutlet UISearchBar *search;
    UIButton *FilterButton;
    UIButton *joinButton;
    //sortby popover
    //FPPopoverController *sortByPopUp;
    UITableView *sortByTable;
    UIViewController *contentViewController;
    NSMutableArray *selectedGroup,*groupData;
    NSInteger expndRow;
    //UINavigationController *navController;
    //UIPopoverController *pop;
    UIBarButtonItem *infoButtonItem;
    //UITableView *searchFilterTable;
    //UITableView *statusTable;
    IBOutlet UIButton *searchFilter;
    IBOutlet UILabel *sortByLabel;
    NSArray *sortByOptions;
    NSString *sortByString;
    
    //FPPopoverController *pop;
    UIButton *click;
    NSArray *thumbnails;
    
    // list groups associated with categories
    NSURLConnection *listGroupsConn;
    NSMutableData *listGroupsResponse;
    UIActivityIndicatorView *activityIndicator;
    
    NSMutableArray *groupIds,*groupNames,*adminNames,*groupDisplayThumbnails,*groupTypes,*groupLocations,*popularityFactor;
    NSMutableArray *tempGroupIds,*tempGroupNames,*tempAdminNames,*tempGroupDisplayThumbnails,*tempGroupTypes,*tempGroupLocations,*tempPopularityFactor;
    NSMutableArray *additionalGroupIds,*additionalGroupNames,*additionalAdminNames,*additionalGroupDisplayThumbnails,*additionalGroupTypes,*additionalGroupLocations,*additionalPopularityFactor;
    UIView *freezer;
    
    NSURLConnection *initiateGroupJoinConn,*addGroupConn,*addFavGroupConn;
    NSMutableData *initiateGroupJoinResponse,*addGroupResponse,*addFavGroupResponse;
   NSString *selectedGroupId,*selectedGroupName,*selectedGroupPic,*selectedGroupType;
    BOOL isFiltered;
    NSMutableDictionary *groups;
    NSString *userId;
    MBProgressHUD *HUD;
    
    UIBarButtonItem *filterButton;
    
    UIViewController *testviewcontroller;
    UITableViewController *filterTable;
    UINavigationController *navController;
    UIPopoverController *pop;
    UILabel *contactNameLabel;
    NSMutableArray *filterOptionsList;
    int privateFilter,publicFilter;
    NSMutableArray *array;
}

-(void)initialiseView;
//-(void)setupSegmentController;
-(void)setSearchFilter:(id)sender;
-(IBAction)openCategoryList:(id)sender;
-(void)listGroupsAssociatedToCategory;
-(void)setActivityIndicator;
-(void)sortBy:(NSString*)factor;

@property (nonatomic, retain) NSString *categoryId,*chatTitle;


@end
