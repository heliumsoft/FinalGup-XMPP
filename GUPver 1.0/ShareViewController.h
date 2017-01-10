//
//  ShareViewController.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <GooglePlus/GooglePlus.h>
@class GPPSignInButton;

@interface ShareViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,GPPSignInDelegate,UIAlertViewDelegate>
{
    GPPSignIn *signIn;
    IBOutlet UITableView *shareTable;
    BOOL isIpad;
    MFMessageComposeViewController *messageController;
}
@property(strong,nonatomic)MFMailComposeViewController *mc ;
@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
-(void)initialiseView;

@end
