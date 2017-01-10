//
//  PostListing.h
//  GUP
//
//  Created by Ram Krishna on 18/12/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SMMessageDelegate.h"
#import "postCell.h"
#import "XMPPRoom.h"

@interface PostListing : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,imageGesture,XMPPRoomDelegate,UIAlertViewDelegate>{
    UILabel *contactNameLabel;
    UIImageView *imageViewForStatus;
    MBProgressHUD *HUD ,*HUD1;
    NSURLConnection *fetchPostConn;
    NSMutableData *fetchPostResponse;
    NSURLConnection *fetchPreviousPostConn;
    NSMutableData *fetchPreviousPosResponse;
    NSMutableArray *postListData;
    int pageNo;
    BOOL requestFlag,latest,loadNew;
    BOOL deleteFlag;
    NSIndexPath *readMoreIndexPath;
    UILabel *notificationlabel;
    UIView *newPostNotificationView;
    BOOL timeFlag;
    BOOL isPrivate;
}
@property(strong,nonatomic) UITableView *postTable;
@property(strong,nonatomic) NSString *groupId;
@property(strong,nonatomic) NSString *groupName;
@property(nonatomic,retain) NSString  *chatType;
@property(strong,nonatomic) NSString *groupType;
@property(strong,nonatomic) NSString *chatTitle,*chatStatus;
@property(nonatomic,retain) NSString *chatWithUser;
-(void)initWithUser:(NSString *) userjid;

@end
