//
//  viewPrivateGroup.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface viewPrivateGroup : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>
{
    NSString *groupPic,*groupDesc,*categoryName,*groupName,*groupLocation,*GName;
    IBOutlet UIScrollView *scrollView;
    
    IBOutlet UIImageView *groupImageView;
    
    CGRect TXFRAME;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *freezer;
    NSURLConnection *updateDescriptionConn,*updateNameConn,*memberConnection;
    NSMutableData *updateDescriptionResponse,*updateNameResponse,*memberRsponce;
    
    NSURLConnection *editCategoryConn,*uploadGroupPicConn,*editLocationConn,*deleteImageConn,*getGroupJoinRequestCountConn,*leaveGroupConn;//*makeAdminConn,*leaveAsAdminConn;
    NSMutableData *editCategoryResponse,*uploadGroupPicResponse,*editLocationResponse,*deleteImageResponse,*getGroupJoinRequestCountResponse,*leaveGroupResponse;//*makeAdminResponse,*leaveAsAdminResponse;
    
    NSString *categoryID;
    UITapGestureRecognizer *tapRecognizer;
    UIImagePickerController *iPicker;
    NSData *imageData;
    int groupJoinCount;
    int totalMembersCount;
    
    UIImage *chosenImage;
    UIActivityIndicatorView *imageActivityIndicator;
    
    MBProgressHUD *HUD;
}
- (IBAction)changeLocation:(id)sender;

@property(strong,nonatomic)NSString *groupType;
@property (strong, nonatomic) NSString  *groupId;
@property(strong,nonatomic)NSString *startLoading;
@property(strong,nonatomic)NSString *viewType;
@property (weak, nonatomic) IBOutlet UILabel *categoryInfo;
@property (weak, nonatomic) IBOutlet UILabel *createdInfo;
@property (strong, nonatomic) IBOutlet UILabel *typeInfo;
@property (weak, nonatomic) IBOutlet UILabel *totalMembers;
@property (weak, nonatomic) IBOutlet UILabel *sharelabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *pendinglabel;
@property (weak, nonatomic) IBOutlet UIButton *pendingImage;
@property (weak, nonatomic) IBOutlet UIButton *locationLbl;

-(void)updateCategory:(NSString*)newCategory categoryId:(NSString*)catId;
@property (weak, nonatomic) IBOutlet UITextField *groupName;
-(void)updateLocationLable:(NSString*)newLocation locationID:(NSInteger)locID;
@property (weak, nonatomic) IBOutlet UITextField *groupDesc;

-(void)uploadDisplayPicToServer;
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer;
-(IBAction)shareGroupInfo:(id)sender;
-(void)getGroupJoinRequestCount;
-(IBAction)leaveGroup:(id)sender;
-(void)refreshGroupInfo;
- (IBAction)Addmember:(id)sender;
- (IBAction)pendingGroups:(id)sender;
- (IBAction)manageMembers:(id)sender;


@end
