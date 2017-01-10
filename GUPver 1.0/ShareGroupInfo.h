//
//  ShareGroupInfo.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/19/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <GooglePlus/GooglePlus.h>
@class GPPSignInButton;


@interface ShareGroupInfo : UIViewController<UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,GPPSignInDelegate,UINavigationControllerDelegate,UIDocumentInteractionControllerDelegate>{
    
    GPPSignIn *signIn;
     UIButton *doneButton;
    BOOL isIpad;
    MFMessageComposeViewController *messageController;
    IBOutlet UITableView *table;
}

-(IBAction)skip:(id)sender;
-(IBAction)done:(id)sender;
@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property(strong,nonatomic)MFMailComposeViewController  *mc;
@property (nonatomic, retain) NSString  *postText;
@property (nonatomic, retain) NSMutableArray *imageURl;

@property (nonatomic, retain) NSString  *groupId;
@property (nonatomic, retain) NSString  *groupName;
@property (nonatomic, retain) NSString  *noOfLikes;
@property (nonatomic, retain) NSString  *noOfComments;

@property (nonatomic, retain) NSString  *groupType;
@property (nonatomic, retain) NSString  *groupJID;
@property (nonatomic, retain) NSString  *hideUnhideSkipDoneButton;
@property (retain) UIDocumentInteractionController * documentInteractionController;
@end
