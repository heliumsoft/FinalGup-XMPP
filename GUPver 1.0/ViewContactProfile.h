//
//  ViewContactProfile.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 12/4/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
@interface ViewContactProfile : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    IBOutlet UITableView *viewContactTable;
    IBOutlet UIImageView *viewContactImageView;
    IBOutlet UILabel *userNameLabel,*userLocationLabel;
    NSArray *getData;
    IBOutlet UIView *customView;
    
    IBOutlet UILabel *aboutLbl;
    NSURLConnection *contactDetailConn;
    NSMutableData *contactDetailResponse;
    
    IBOutlet UIImageView *line;
    IBOutlet UILabel *adoutDiscriptionLbl;
    MBProgressHUD *HUD;
   
}
@property (nonatomic, retain) NSString  *userId;
@property (nonatomic, retain) NSString  *triggeredFrom;

-(void)refreshContactInfo;
@end
