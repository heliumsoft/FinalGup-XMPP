//
//  CreateGroup.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoom.h"

@interface CreateGroup : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate
,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSURLConnectionDelegate,MBProgressHUDDelegate,XMPPRoomDelegate,XMPPMUCDelegate>{
    IBOutlet UITableView *createGroupTable;
    int noOfSections;
    BOOL defaultImage;
    //NSString *publicGroupIdentifier;
    UITextField *groupNameTextField;
    UITextView *groupDescTextField;
    UITapGestureRecognizer *tapGesture;
    IBOutlet UIImageView *groupPic;
    
    UILabel *groupNameTitle;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIButton *createGroup;
    int status;
    UIImageView *accview;
    UIButton *butarray[4];
    XMPPJID *roomJID;
    //camera
    BOOL newMedia;
    UIImagePickerController *iPicker;
    NSData *imageData;
    
    XMPPRoomCoreDataStorage *roomMemory;
    XMPPRoom *xmpproom;
    
    CGRect TXFRAME;
    NSString *group_id;
    NSURLConnection *createGroupConn,*fetchCategoryConn,*uniquenessCheckConn;
    NSMutableData *createGroupResponse,*fetchCategoryResponse,*eventsResponse;
    
    NSString *groupType,*groupName,*groupDesc,*groupCategory,*globalType,*categoryID,*appUserId,*appUserLocationId,*appUserLocation,*appUserName,*appUserImage;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    BOOL flags[4];
    MBProgressHUD *HUD;
    UIImageView *accview1;
}

@property(nonatomic,strong) XMPPRoomCoreDataStorage *roomMemory;
@property(nonatomic,strong) XMPPRoom *xmpproom;

-(void)tapOnButton:(UIButton*)but;
-(void)viewPublicInfo:(id)sender;
-(void)viewPrivateInfo:(id)sender;
-(void)viewLocalInfo:(id)sender;
-(void)viewGlobalInfo:(id)sender;
-(IBAction)createGroup:(id)sender;
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer;
//- (void)loadCategories;
-(void)updateCategory:(NSString*)newCategory categoryId:(NSString*)catId;

@end
