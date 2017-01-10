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

@interface FirstViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UISearchBarDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    //IBOutlet UIView *contentView;
    // group table view
    NSArray *groupsChatList;
    NSArray *searchResults;
    NSArray *thumbnails;
    NSMutableArray *lastMsgReceivedTime,*unreadMsgsNo;
    IBOutlet UITableView *groupsTable;
    IBOutlet UISearchBar *search;
    
    // personal table view
    NSArray *privateChatList,*personalImages;
   
    
    IBOutlet UISegmentedControl *segControl;
    
    //GroupsView *groupController;
    //PrivateView *privateController;
    NSArray *statusOptions;
    NSArray *statusOptionsThumbnails;
    NSMutableArray *contactNames,*contactIds,*contactPics,*contactStatus,*getData,*tempContactNames,*tempContactPics,*tempContactStatus,*tempLastMsgReceivedTime,*tempUnreadMsgNo,*tempContactIds,*lastMsg,*tempLastMsg;
    //NSMutableDictionary *contactList,*tempcontactList;
    //UIViewController *activeViewController;
    //NSInteger activeIndex;
    UIBarButtonItem *statusButton;
    NSString *status;
    UIViewController *testviewcontroller;
    UITableView *statusTable;
    UINavigationController *navController;
    UIPopoverController *pop;
    UIBarButtonItem *infoButtonItem;
    UIBarButtonItem *addButton;

    FPPopoverController *popover;
    
    BOOL isFiltered;
    
    NSString *selectedContactId;
    
    //action sheet
    NSString *other1,*other2,*other0,*cancelTitle;
    
    
    
}
-(void)addGroup;
-(void)initialiseView;
-(void)setupSegmentController;
-(IBAction)setStatus:(id)sender;
-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture;
//-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture event:(id)event;
-(void)refreshChatList;


@end
