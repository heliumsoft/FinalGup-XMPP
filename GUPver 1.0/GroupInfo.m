//
//  GroupInfo.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "GroupInfo.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "JSON.h"
#import "ViewMembers.h"
#import "ShareGroupInfo.h"
#import "AppDelegate.h"
#import "MarqueeLabel.h"
#import "ContactList.h"
#import <QuartzCore/QuartzCore.h>
#import "ChatScreen.h"

@interface GroupInfo (){
//    UIActivityIndicatorView *spinner;
    NSInteger cellPath;
}

@end

@implementation GroupInfo
@synthesize groupType,groupId,startLoading,viewType;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title=@"Group Name";
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    
    contactId = [[NSMutableArray alloc]init];
    contactName = [[NSMutableArray alloc]init];
    contactLoc = [[NSMutableArray alloc]init];
    contactIsAdmin = [[NSMutableArray alloc]init];
    contactPic = [[NSMutableArray alloc]init];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_detail_android.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    memberConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [memberConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [memberConnection start];
    memberRsponce = [[NSMutableData alloc] init];
}
- (void)viewDidLoad{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //[share setImage:[UIImage imageNamed:@"share_orange.png"] forState:UIControlStateNormal];
//    share.tintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
//    favorite.tintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
    
    NSString *checkIfAlreadyAddAsFav;
    checkIfAlreadyAddAsFav=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groupId];
    BOOL addedFav=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfAlreadyAddAsFav];
    NSLog(@"bool added %d",addedFav);
//    if (addedFav) {
//        [favorite setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
//    }else{
//        [favorite setImage:[UIImage imageNamed:@"favicon"] forState:UIControlStateNormal];
//    }
    // check if the group is default public local group
    NSString *defaultPublicLocalGroupName= [[DatabaseManager getSharedInstance]getAppUserLocationName];
    defaultPublicLocalGroupName = [defaultPublicLocalGroupName stringByReplacingOccurrencesOfString:@","
                                                                                         withString:@""];
    NSLog(@"default public group name: %@",defaultPublicLocalGroupName);
    NSLog(@"title %@",self.title);
    if ([self.title isEqualToString:[NSString stringWithFormat:@"GUP %@",defaultPublicLocalGroupName]]||[self.title isEqualToString:[NSString stringWithFormat:@"%@ Chat",defaultPublicLocalGroupName]]){
        
        favorite.hidden=true;
        
    }
    self.groupName.text = self.title;
    self.groupDesc.font = [UIFont fontWithName:@"Dosis-Regular" size:13];
    self.categoryInfo.font = [UIFont fontWithName:@"Dosis-SemiBold" size:15];
    self.createdInfo.font = [UIFont fontWithName:@"Dosis-Regular" size:11];
    self.totalMembers.font = [UIFont fontWithName:@"Dosis-SemiBold" size:15];
    self.typeInfo.font = [UIFont fontWithName:@"Dosis-SemiBold" size:15];
    self.sharelabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:15];
    self.groupName.font = [UIFont fontWithName:@"Dosis-SemiBold" size:16];
    self.inviteButton.titleLabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:16];
    self.leaveBtn.titleLabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:16];
    displayPic.layer.cornerRadius = 25;
    displayPic.clipsToBounds = YES;
    
    self.totalMembers.userInteractionEnabled = YES;
     self.sharelabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *titletap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openGroupMember)];
    [self.totalMembers addGestureRecognizer:titletap1];
    
    UITapGestureRecognizer *titletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareGroupInfo)];
    [self.sharelabel addGestureRecognizer:titletap];
    
    // Do any additional setup after loading the view from its nib.
    NSString *checkIfExists;
    if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]){
      if([groupType isEqualToString:@"private#local"])
        self.typeInfo.text =@"Local";
      else
          self.typeInfo.text =@"Global";
        checkIfExists=[NSString stringWithFormat:@"select * from groups_private where group_server_id=%@",groupId];
    }else{
        if([groupType isEqualToString:@"public#local"])
            self.typeInfo.text =@"Local";
        else
            self.typeInfo.text =@"Global";
        checkIfExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groupId];
    }
    BOOL existOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfExists];
    if (existOrNot) {
        if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]){
            
            favorite.hidden=true;
            noOfSection=2;
            // get private group info from db
            adminList=[[DatabaseManager getSharedInstance]getAdminList:groupId];
            getData = [[NSArray alloc]init];
            getData = [[DatabaseManager getSharedInstance]getPrivateGroupInfo:groupId];
            for (int i=0; i<6; i++) {
                NSLog(@"group data[%d] %@",i,getData[i]);
            }
            if([groupType isEqualToString:@"private#global"]){
                self.typeInfo.text =@"Global";
            }else{
                self.typeInfo.text = getData[7];
            }
            //[displayPic setImage:[UIImage imageNamed:getData[0]]];
            // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[0]]];
            NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
            NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
            UIImage *groupImage = [UIImage imageWithData:pngData];
            if (groupImage) {
                displayPic.image=groupImage;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                   NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getData[0]]]];
                   displayPic.image=[UIImage imageWithData:imgData];
                   dispatch_async(dispatch_get_main_queue(), ^{
                       NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                       NSLog(@"paths=%@",paths);
                       NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[0]]];
                       NSLog(@"group pic path=%@",groupPicPath);
                       //Writing the image file
                       [imgData writeToFile:groupPicPath atomically:YES];
                        
                        
                    });
                    
                });
                
            }
            else
            {
                imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
                [imageActivityIndicator setCenter:CGPointMake(42.5,42.5)];
                imageActivityIndicator.color = [UIColor blackColor];
                [displayPic addSubview:imageActivityIndicator];
                [imageActivityIndicator startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getData[0]]]];
                    displayPic.image=[UIImage imageWithData:imgData];
                    [imageActivityIndicator stopAnimating];
                    [imageActivityIndicator removeFromSuperview];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        NSLog(@"paths=%@",paths);
                        NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[0]]];
                        NSLog(@"group pic path=%@",groupPicPath);
                        //Writing the image file
                        [imgData writeToFile:groupPicPath atomically:YES];
                        
                        
                    });
                    
                });
                
            }

            
            
        }
        else
        {            

            noOfSection=2;
            // get public group info from db
            getDataPublic = [[NSArray alloc]init];
            getDataPublic = [[DatabaseManager getSharedInstance]getPublicGroupInfo:groupId];
            if ([getDataPublic count] == 0) {
                NSLog(@"blank");
            }
            else
            {
                for (int i=0; i<7; i++) {
                    NSLog(@"group data public[%d] %@",i,getDataPublic[i]);
                }
                if([groupType isEqualToString:@"public#global"]){
                    self.typeInfo.text =@"Global";
                }else{
                    self.typeInfo.text = getData[4];
                }
                //[displayPic setImage:[UIImage imageNamed:getDataPublic[0]]];
                // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getDataPublic[0]]];
                NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
                NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
                UIImage *groupImage = [UIImage imageWithData:pngData];
                if (groupImage) {
                    displayPic.image=groupImage;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getDataPublic[0]]]];
                        displayPic.image=[UIImage imageWithData:imgData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                            NSLog(@"paths=%@",paths);
                            NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getDataPublic[0]]];
                            NSLog(@"group pic path=%@",groupPicPath);
                            //Writing the image file
                            [imgData writeToFile:groupPicPath atomically:YES];
                            
                            
                        });
                        
                    });
                    
                }
                else
                {
                    imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
                    [imageActivityIndicator setCenter:CGPointMake(42.5,42.5)];
                    imageActivityIndicator.color = [UIColor blackColor];
                    [displayPic addSubview:imageActivityIndicator];
                    [imageActivityIndicator startAnimating];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getDataPublic[0]]]];
                        displayPic.image=[UIImage imageWithData:imgData];
                        [imageActivityIndicator stopAnimating];
                        [imageActivityIndicator removeFromSuperview];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                            NSLog(@"paths=%@",paths);
                            NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getDataPublic[0]]];
                            NSLog(@"group pic path=%@",groupPicPath);
                            //Writing the image file
                            [imgData writeToFile:groupPicPath atomically:YES];
                            
                            
                        });
                        
                    });
                    
                }
            }
        }
        
    }
    else{
        groupInfoTable.hidden=TRUE;
        share.hidden=TRUE;
        favorite.hidden=TRUE;
        [self startActivityIndicator];
        [self refreshGroupInfo];
      
        
    }
    
    
    [self plotData];
  

    
    
}

-(void)plotData{
   
    if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
        
            if ([getData[1] isEqualToString:@""]) {
                
                self.groupDesc.text = @"No Description";
            }
            else
            {
                self.groupDesc.text  = getData[1];
            }
        
    }else{
            if ([getDataPublic[1] isEqualToString:@""]) {
                self.groupDesc.text  = @"No Description";
            }
            else
            {
                self.groupDesc.text  = getDataPublic[1];
            }
        
    }
    
    if([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"])
    {
        if ([getData count] == 0)
            self.categoryInfo.text = @"";
        else
           self.categoryInfo.text = [NSString stringWithFormat:@"Category: %@",getData[3]];
        
        if ([getData count] == 0)
            self.totalMembers.text = @"";
        else
            self.totalMembers.text = [NSString stringWithFormat:@"%@",getData[4]];
        
        if ([getData count] == 0)
            self.createdInfo.text = @"";
        else
            self.createdInfo.text = [NSString stringWithFormat:@"Created On %@",getData[5]];
        
    }else{
        if ([getDataPublic count] == 0)
            self.categoryInfo.text = @"";
        else
            self.categoryInfo.text = [NSString stringWithFormat:@"Category: %@",getDataPublic[2]];
        
        if ([getDataPublic count] == 0)
            self.totalMembers.text = @"";
        else
            self.totalMembers.text = [NSString stringWithFormat:@"%@ members",getDataPublic[3]];
        
        if ([getDataPublic count] == 0)
            self.createdInfo.text = @"";
        else
            self.createdInfo.text = [NSString stringWithFormat:@"Created On %@",getDataPublic[5]];
        
    }
        
    self.view.backgroundColor = [UIColor whiteColor];
}


-(void)startActivityIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}

- (IBAction)openGroupMember:(id)sender {

    ViewMembers *membersPage = [[ViewMembers alloc]init];
    membersPage.groupId = groupId;
    membersPage.startLoading = startLoading;
    membersPage.groupType=groupType;
    membersPage.groupName=self.title;
    membersPage.viewType=viewType;
    //detailPage.notificationId = [notificationIds objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:membersPage animated:YES];

}
- (void)openGroupMember{
    
   
        ViewMembers *membersPage = [[ViewMembers alloc]init];
        membersPage.groupId = groupId;
        membersPage.startLoading = startLoading;
        membersPage.groupType=groupType;
        membersPage.groupName=self.title;
        membersPage.viewType=viewType;
        //detailPage.notificationId = [notificationIds objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:membersPage animated:YES];
    
}


- (IBAction)leaveGroup:(id)sender {
    
    NSString *appUserId = [[DatabaseManager getSharedInstance]getAppUserID];
    
    [self startActivityIndicator];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",groupId,appUserId];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/leave_group.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    leaveGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [leaveGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [leaveGroupConn start];
    leaveGroupResponse = [[NSMutableData alloc] init];
}

- (IBAction)inviteMember:(id)sender {
    
    ContactList *openContactList = [[ContactList alloc]init];
    //openContactList.memberID=memberId;
    openContactList.hideUnhideSkipDoneButton=@"hide";
    openContactList.groupStatus = groupType;
    openContactList.groupId = groupId;
    openContactList.groupName = groupName;
    openContactList.viewType=viewType;
    [self.navigationController pushViewController:openContactList animated:NO];
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSLog(@"start connection");
    
   

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshGroupInfo
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_detail.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    groupInfoConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [groupInfoConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [groupInfoConn start];
    groupInfoResponse = [[NSMutableData alloc] init];

}
//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == groupInfoConn) {
        
        [groupInfoResponse setLength:0];
        
    }
    if (connection == addFavConn) {
        
        [addFavResponse setLength:0];
        
    }
    if (connection == leaveGroupConn) {
        
        [leaveGroupResponse setLength:0];
        
    }
    if (connection == memberConnection) {
        
        [memberRsponce setLength:0];
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == groupInfoConn) {
        
        [groupInfoResponse appendData:data];
        
    }
    if (connection == addFavConn) {
        
        [addFavResponse appendData:data];
        
    }
    if (connection == leaveGroupConn) {
        
        [leaveGroupResponse appendData:data];
        
    }
    if (connection == memberConnection) {
        
        [memberRsponce appendData:data];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
        
    [HUD hide:YES];
    if (connection == groupInfoConn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == groupInfoConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:groupInfoResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        NSLog(@"end connection");
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        NSDictionary *groups=results[@"Group_Details"];
        NSString *status=results[@"status"];
        NSLog(@"status: %@",status);
        NSLog(@"groups: %@", groups);
        NSDictionary *members=groups[@"member_details"];
        NSLog(@"members: %@",members);
        //[imageView removeAllObjects];
        if ([status isEqualToString:@"1"])
        {
            favorite.hidden=true;
            share.hidden=true;
            groupInfoTable.hidden =true;
            displayPic.hidden = true;
            [HUD hide:YES];
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                   
                                                             message:@"Group does not exist."
                                   
                                                            delegate:nil
                                   
                                                   cancelButtonTitle:@"OK"
                                   
                                                   otherButtonTitles:nil];
            [alert show];
            
        }
        
        //NSLog(@"====EVENTS==3 %@",res);
        else{
        
        
            admin = groups[@"admin"];
            categoryName = groups[@"category_name"];
            creationDate = groups[@"creation_date"];
            groupDesc = groups[@"group_description"];
            groupName = groups[@"group_name"];
            groupPic = groups[@"group_pic"];
            grouptype = groups[@"group_type"];
            groupid = groups[@"id"];
            location = groups[@"location_name"];
            memberCount = groups[@"member_count"];
            
            
            NSLog(@"groupId: %@",groupid);
            NSLog(@"group name: %@",groupName);
            NSLog(@"group desc: %@",groupDesc);
            NSLog(@"group pic: %@",groupPic);
            NSLog(@"category name: %@",categoryName);
            NSLog(@"admin: %@",admin);
            NSLog(@"location: %@",location);
            NSLog(@"groupType: %@",grouptype);
            NSLog(@"created date: %@",creationDate);
            NSLog(@"member count: %@",memberCount);
            [getDataPublic[0] addObject: groupPic];
            [getDataPublic[1] addObject: groupDesc];
            [getDataPublic[2] addObject: categoryName];
            [getDataPublic[3] addObject: memberCount];
            [getDataPublic[4] addObject: location];
            [getDataPublic[5] addObject: creationDate];
            [getDataPublic[6] addObject: grouptype];
            adminList=@"";
            if (members) {
                
           
            for (NSDictionary *result in members)
             {
             NSString *contact_id= result[@"user_id"];
             NSString *contact_name = result[@"display_name"];
             NSString *contact_location = result[@"location_name"];
             NSString *contact_is_admin = result[@"is_admin"];
            if ([result[@"is_admin"]integerValue] == 1) {
               
                if ([adminList isEqualToString:@""]) {
                    adminList = [NSString stringWithFormat:@"%@",result[@"display_name"]];
                }
                else
                {
                    adminList = [NSString stringWithFormat:@"%@,%@",adminList,result[@"display_name"]];
                }
                NSLog(@"admin list %@",adminList);
            }
                 
             NSString *contact_pic = result[@"profile_pic"];
             NSLog(@"member id: %@",contact_id);
             NSLog(@"name: %@",contact_name);
             NSLog(@"location: %@",contact_location);
             NSLog(@"isadmin: %@",contact_is_admin);
             NSLog(@"contact pic: %@",contact_pic);
                 if(contact_id != nil) {
                     [contactId addObject:contact_id];
                 }
                 else
                 {
                     [contactId addObject:@""];
                 }

                 
             [contactName addObject:contact_name];
             [contactLoc addObject:contact_location];
             [contactIsAdmin addObject:contact_is_admin];
             [contactPic addObject:contact_pic];
             
             }
            }
            groupInfoTable.hidden=FALSE;
            share.hidden=FALSE;
        
        if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"])
        {
            
            favorite.hidden=true;
            noOfSection=2;
            // get private group info from db
            groupName=[groupName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            groupDesc=[groupDesc stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            
            NSString *query=[NSString stringWithFormat:@"insert into groups_private (group_server_id,created_on,created_by,group_name,group_pic,category_name,location_name,group_type,total_members,group_description) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",groupid,creationDate,admin,[groupName normalizeDatabaseElement],groupPic,categoryName,location,grouptype,memberCount,[groupDesc normalizeDatabaseElement]];
            NSLog(@"query %@",query);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            
            getData = [[NSArray alloc]init];
            getData = [[DatabaseManager getSharedInstance]getPrivateGroupInfo:groupId];
            
           /* for (int i=0; i<6; i++) {
                NSLog(@"group data[%d] %@",i,getData[i]);
            }*/
            NSString *deleteQuery = [NSString stringWithFormat:@"delete from groups_private where group_server_id=%@",groupId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteQuery];
            
            [HUD hide:YES];
            [self plotData];
            imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
            [imageActivityIndicator setCenter:CGPointMake(42.5,42.5)];
            imageActivityIndicator.color = [UIColor blackColor];
            [displayPic addSubview:imageActivityIndicator];
            [imageActivityIndicator startAnimating];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getData[0]]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [displayPic setImage:[UIImage imageWithData:imgData]];
                    [imageActivityIndicator stopAnimating];
                    [imageActivityIndicator removeFromSuperview];
                    
                });
                
            });

        }
        else
        {
           
            favorite.hidden=FALSE;
            noOfSection=2;
            groupName=[groupName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            groupDesc=[groupDesc stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *query=[NSString stringWithFormat:@"insert into groups_public (group_server_id,location_name,category_name,added_date,group_name,group_type,group_pic,group_description,total_members) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@')",groupid,location,categoryName,creationDate,[groupName normalizeDatabaseElement],grouptype,groupPic,[groupDesc normalizeDatabaseElement],memberCount];
            NSLog(@"query %@",query);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            // get public group info from db
            getDataPublic = [[NSArray alloc]init];
            getDataPublic = [[DatabaseManager getSharedInstance]getPublicGroupInfo:groupId];
            if ([getDataPublic count] == 0) {
                NSLog(@"blank");
            }
            else
            {
                for (int i=0; i<6; i++) {
                    NSLog(@"group data public[%d] %@",i,getDataPublic[i]);
                }
            NSString *deleteQuery = [NSString stringWithFormat:@"delete from groups_public where group_server_id=%@",groupId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteQuery];
                
                [HUD hide:YES];
                [self plotData];
                imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
                [imageActivityIndicator setCenter:CGPointMake(42.5,42.5)];
                imageActivityIndicator.color = [UIColor blackColor];
                [displayPic addSubview:imageActivityIndicator];
                [imageActivityIndicator startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,getDataPublic[0]]]];
                    
                dispatch_async(dispatch_get_main_queue(), ^{

                    [displayPic setImage:[UIImage imageWithData:imgData]];
                    [imageActivityIndicator stopAnimating];
                    [imageActivityIndicator removeFromSuperview];

                        
                    });
                    
                });
            }
        }
    }
        groupInfoConn=nil;
        
        [groupInfoConn cancel];
        
    }

    
    if (connection == addFavConn) {
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:addFavResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        NSLog(@"end connection");
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        NSDictionary *groups=results[@"Group_Details"];
        NSString *status=results[@"status"];
        NSLog(@"status: %@",status);
        NSLog(@"groups: %@", groups);
        NSDictionary *members=groups[@"member_details"];
        NSLog(@"members: %@",members);
        NSDictionary *deletedMembers = groups[@"deleted_members"];
        NSLog(@"deleted members%@",deletedMembers);
        NSString *error=results[@"error"];
        
        //[imageView removeAllObjects];
        if (![status isEqualToString:@"1"])
        {
            
            NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groups[@"id"]];
            BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
            if (publicGroupExistOrNot) {
                NSString *updatePublicGroup=[NSString stringWithFormat:@"update  groups_public set group_server_id = '%@', location_name = '%@', category_name = '%@', added_date ='%@',is_favourite ='1', group_name ='%@', group_type='%@', group_pic='%@', group_description='%@', total_members='%@' where group_server_id = '%@' ",groups[@"id"],groups[@"location_name"],groups[@"category_name"],groups[@"creation_date"],[groups[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"group_type"],groups[@"group_pic"],[groups[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"member_count"],groups[@"id"]];
                NSLog(@"query %@",updatePublicGroup);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updatePublicGroup];
            }
            else
            {
                
                NSString *insertPublicGroup=[NSString stringWithFormat:@"insert into groups_public (group_server_id, location_name, category_name, added_date,is_favourite, group_name,group_type, group_pic,group_description,total_members) values ('%@','%@','%@','%@','%d','%@','%@','%@','%@','%@')",groups[@"id"],groups[@"location_name"],groups[@"category_name"],groups[@"creation_date"],1,[groups[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"group_type"],groups[@"group_pic"],[groups[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"member_count"]];
                NSLog(@"query %@",insertPublicGroup);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertPublicGroup];
            }
            
            if ([members count]==0 )
            {
                NSLog(@"no members");
            }
            else
            {
                for (NSDictionary *member in members)
                {
                    NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted=0",groups[@"id"],member[@"user_id"]];
                    BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                    if (memberExistOrNot) {
                        NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set group_id = '%@', contact_id = '%@', is_admin = '%@', contact_name ='%@', contact_location ='%@', contact_image='%@' where group_id = '%@' and contact_id='%@' ",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"],groups[@"id"],member[@"user_id"]];
                        NSLog(@"query %@",updateMembers);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                    }
                    else
                    {
                        
//                        NSString *insertMembers=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"]];
//                        NSLog(@"query %@",insertMembers);
//                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertMembers];
                    }
                    //download image and save in the cache
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,member[@"profile_pic"]]]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //cell.imageView.image = [UIImage imageWithData:imgData];
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                            NSLog(@"paths=%@",paths);
                            NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",member[@"profile_pic"]]];
                            NSLog(@"member pic path=%@",memberPicPath);
                            //Writing the image file
                            [imgData writeToFile:memberPicPath atomically:YES];
                            
                            
                        });
                        
                    });
                    
                    
                }
            }
            if ([deletedMembers count]==0 )
            {
                NSLog(@"no members");
            }
            else
            {
                for (NSDictionary *deletedMember in deletedMembers)
                {
                    NSLog(@"deleted user id%@ \n",deletedMember);
                    NSString *checkIfMemberToDeleteExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@",groups[@"id"],deletedMember];
                    BOOL memberToDeleteExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberToDeleteExists];
                    if (memberToDeleteExistOrNot) {
                        // NSString *deleteMemberQuery=[NSString stringWithFormat:@"delete from group_members where group_id=%@ and contact_id=%@ ",groups[@"id"],deletedMember];
                        //NSLog(@"query %@",deleteMemberQuery);
                        // [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteMemberQuery];
                        NSString *updateMemberQuery=[NSString stringWithFormat:@"update group_members set deleted=1 where group_id=%@ and contact_id=%@ ",groups[@"id"],deletedMember];
                        NSLog(@"query %@",updateMemberQuery);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMemberQuery];
                    }
                    
                }
            }
            
            //download image and save in the cache
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,groups[@"group_pic"]]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",groups[@"group_pic"]]];
                    NSLog(@"member pic path=%@",memberPicPath);
                    //Writing the image file
                    [imgData writeToFile:memberPicPath atomically:YES];
                    
                    
                });
                
            });
            
            [HUD hide:YES];
            NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@",groups[@"id"]]];
            NSMutableArray    *membersID=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempmembersID count];i++)
            {//if(![[tempmembersID objectAtIndex:i]isEqual:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]])
                [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
            }
            
            NSLog(@"membersID %@",membersID);
            
            //4552
            for (int j=0; j<[membersID count]; j++)
            {NSLog(@"%@ %@",membersID,membersID[j]);
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[membersID objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"Your request to join %@ has been accepted",groups[@"group_name"] ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                [elementDic setValue:@"0" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",groups[@"id"]);
                [elementDic setValue:groups[@"id"] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            
            
            
            ChatScreen *chatScreen = [[ChatScreen alloc]init];
            
            chatScreen.chatType = @"group";
            chatScreen.chatTitle=groups[@"group_name"];
            [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[groups[@"id"] integerValue],(NSString*)jabberUrl]];
            
            chatScreen.groupType=groups[@"group_type"] ;
            [chatScreen retreiveHistory:nil];
             [self appDelegate].currentUser=@"";
            //[self.navigationController pushViewController:chatScreen animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
        }
        
        addFavConn=nil;
        
        [addFavConn cancel];
    }

    
    if (connection == leaveGroupConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:leaveGroupResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        
        NSDictionary *result = res[@"response"];
        NSLog(@"result: %@", result);
        NSString *leaveStatus = result[@"status"];
        NSLog(@"status: %@", leaveStatus);
        NSString *error=result[@"Error"];
        NSLog(@"error: %@", error);
        [HUD hide:YES];
        if ([leaveStatus isEqualToString:@"0"])
        {
            NSString *deleteQuery=[NSString stringWithFormat:@"delete from groups_public where group_server_id='%@'",groupId];
            NSLog(@"query %@",deleteQuery);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteQuery];
            NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and contact_id!=%@",groupId,[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]];
            NSMutableArray    *membersID=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempmembersID count];i++)
            {//if(![[tempmembersID objectAtIndex:i]isEqual:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]])
                [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
            }
            
            NSLog(@"membersID %@",membersID);
            
            //4552
            for (int j=0; j<[membersID count]; j++){
                NSLog(@"%@ %@",membersID,membersID[j]);
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[membersID objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"Your request to join %@ has been accepted",self.title ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                [elementDic setValue:@"0" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",groupId);
                [elementDic setValue:groupId forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            

            NSString *deleteMembers=[NSString stringWithFormat:@"delete from group_members where group_id='%@'",groupId];
            
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteMembers];
            
            //clear chat for the group
            
            [[self appDelegate] clearChatHistoryForGroup:groupId];
         //  [self.navigationController popToRootViewControllerAnimated:YES];
            [self.navigationController popViewControllerAnimated:YES];
            
           
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        leaveGroupConn=nil;
        
        [leaveGroupConn cancel];
    }
    
    if (connection == memberConnection) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:memberRsponce encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        
        NSDictionary *result = res[@"response"];
        NSLog(@"result: %@", result);
        NSString *leaveStatus = result[@"status"];
        NSLog(@"status: %@", leaveStatus);
        NSString *error=result[@"Error"];
        NSLog(@"error: %@", error);
        if ([leaveStatus isEqualToString:@"0"]) {
            NSDictionary *groupdDetail = result[@"Group_Details"];
            NSString *membercount = groupdDetail[@"member_count"];
            NSLog(@"%@",membercount);
            UITableViewCell *cell = (UITableViewCell*)[groupInfoTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellPath inSection:1]];
            cell.textLabel.text = [NSString stringWithFormat:@"Total Members   %@",membercount];
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        leaveGroupConn=nil;
//        [spinner startAnimating];
//        [spinner removeFromSuperview];
        [leaveGroupConn cancel];
    }


}

-(void)shareGroupInfo
{
    ShareGroupInfo *shareGroupInfoPage = [[ShareGroupInfo alloc]init];
    shareGroupInfoPage.groupId = groupId;
    shareGroupInfoPage.groupName = self.title;
    shareGroupInfoPage.hideUnhideSkipDoneButton = @"hide";
    [self.navigationController pushViewController:shareGroupInfoPage animated:YES];
}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(IBAction)shareGroupInfo:(id)sender
{
    ShareGroupInfo *shareGroupInfoPage = [[ShareGroupInfo alloc]init];
    shareGroupInfoPage.groupId = groupId;
    shareGroupInfoPage.groupName = self.title;
    shareGroupInfoPage.hideUnhideSkipDoneButton = @"hide";
    [self.navigationController pushViewController:shareGroupInfoPage animated:YES];
}

-(IBAction)addToFavorite:(id)sender
{
    
    if ([favorite currentImage] == [UIImage imageNamed:@"star"]) {
        //[favorite setImage:[UIImage imageNamed:@"favicon"] forState:UIControlStateNormal];
       
        
    }
    else {
        [favorite setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
        
       /* NSLog(@"You have clicked submit add%@%@",groupId,appUserId);

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@&flag=0",groupId,appUserId];
        NSLog(@"$[%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/private_grp_request.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        addFavConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [addFavConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [addFavConn start];
        addFavResponse = [[NSMutableData alloc] init];*/
        //check whter group is already added
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//           NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@&flag=0",groupId,appUserId];
//            NSLog(@"postdata%@",postData);
//            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_fav.php",gupappUrl]]];
//            [request setHTTPMethod:@"POST"];
//            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
//            addFavConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//            [addFavConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//            [addFavConn start];
//            addFavResponse = [[NSMutableData alloc] init];

    }
}

@end
