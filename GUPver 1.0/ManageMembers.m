//
//  ManageMembers.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/14/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ManageMembers.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "ContactList.h"
#import "DatabaseManager.h"
#import "JSON.h"
#import "CategoryList.h"

@interface ManageMembers ()

@end

@implementation ManageMembers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Manage Members";
    }
    return self;
}
@synthesize groupId,groupType,groupName;
-(void)viewDidAppear:(BOOL)animated
{
    [self fetchGroups];
    [manageMembersTable reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    contactDisplayPic = [NSArray arrayWithObjects:@"profile1", @"profile2", @"profile3", @"profile4", @"profile2", nil];
    NSLog(@"group type:%@%@",groupType,groupId);
    UIBarButtonItem *addMembersButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Add"
                                         style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(addMember:)];
    self.navigationItem.rightBarButtonItem = addMembersButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    _appUserId = [[DatabaseManager getSharedInstance]getAppUserID];
    //     [self fetchGroups];
    
}

-(void)fetchGroups{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSArray *groupArray = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select group_timestamp from master_table"]];
    groupTimeStampValue = [[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"GROUP_TIMESTAMP" ForRowIndex:0 givenOutput:groupArray];
    
    //    NSString *postData = [NSString stringWithFormat:@"user_id=%@&group_timestamp=%@",_appUserId,groupTimeStampValue];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
    //        NSString *postData = [NSString stringWithFormat:@"user_id=%@",appUserId];
    NSLog(@"$[groups%@]",postData);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_detail.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    fetchGroupsConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [fetchGroupsConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [fetchGroupsConn start];
    fetchGroupsResponse = [[NSMutableData alloc] init];
    
}

-(void)loadMembers
{
    [memberId removeAllObjects];
    [memberName removeAllObjects];
    [memberLocation removeAllObjects];
    [memberDisplayPic removeAllObjects];
    [memberIsAdmin removeAllObjects];
    
    memberName = [[NSMutableArray alloc]init];
    memberLocation = [[NSMutableArray alloc]init];
    memberDisplayPic = [[NSMutableArray alloc]init];
    memberIsAdmin = [[NSMutableArray alloc]init];
    memberId = [[NSMutableArray alloc]init];
    
    NSMutableArray *memberList = [[NSMutableArray alloc]init];
    memberList = [[DatabaseManager getSharedInstance]getGroupMembersList:groupId];
    
    if([memberList count]>0){
        for(int i=0;i<[memberList count];i++)
        {
            
            NSMutableArray *members = [memberList objectAtIndex:i];
            [memberId addObject:(NSString*)[members objectAtIndex:0]];
            [memberIsAdmin addObject:[members objectAtIndex:1]];
            [memberName addObject:[members objectAtIndex:2]];
            [memberLocation addObject:[members objectAtIndex:3]];
            [memberDisplayPic addObject:[members objectAtIndex:4]];
        }
        NSLog(@"member id%@",memberId);
        NSLog(@"member isadmin%@",memberIsAdmin);
        NSLog(@"member name%@",memberName);
        NSLog(@"member location%@",memberLocation);
        NSLog(@"member displaypic%@",memberDisplayPic);
    }
    
    else
    {
        NSLog(@"no contacts");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No Members"   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}



-(void)addMember:(id)sender
{
    ContactList *openContactList = [[ContactList alloc]init];
    openContactList.memberID=memberId;
    openContactList.hideUnhideSkipDoneButton=@"hide";
    openContactList.groupStatus = groupType;
    openContactList.groupId = groupId;
    openContactList.groupName = groupName;
    [self.navigationController pushViewController:openContactList animated:NO];
    
    
}

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if (section == 0)
    //   return  1;
    //if (section == 1)
    return  [memberId count];
    //else
    //    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
   UIImageView* user_image = [[UIImageView alloc] initWithFrame:CGRectZero];
    user_image.backgroundColor = [UIColor clearColor];
    user_image.opaque = YES;
    user_image.clearsContextBeforeDrawing = NO;
    user_image.layer.cornerRadius =23.0f;
    user_image.clipsToBounds = YES;
    user_image.userInteractionEnabled = YES;
    [cell addSubview:user_image];
    
    UILabel* username = [[UILabel alloc] initWithFrame:CGRectZero];
    username.backgroundColor = [UIColor clearColor];
    username.opaque = YES;
    username.clearsContextBeforeDrawing = NO;
    username.numberOfLines=1;
    username.font = [UIFont fontWithName:@"Dosis-Bold" size:18.0f];
    username.textColor= [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
    username.userInteractionEnabled = YES;
    [cell addSubview:username];

    UILabel* extraInfo = [[UILabel alloc] init];
    extraInfo.textColor = [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
    extraInfo.tag = 2;
    extraInfo.backgroundColor = [UIColor clearColor];
    [extraInfo setFont:[UIFont fontWithName:@"Dosis-Regular" size:10.0f]];
    [cell addSubview:extraInfo];
    UILongPressGestureRecognizer *groupLpgr = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(handleLongPress:)];
    groupLpgr.minimumPressDuration = 0.5; //seconds
    [cell addGestureRecognizer:groupLpgr];
    
   
    if(indexPath.section == 0)
    {
        
        // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",[memberDisplayPic objectAtIndex:indexPath.row]]];
        NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
        NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
        UIImage *profilePic = [UIImage imageWithData:pngData];
        if (profilePic) {
            user_image.image=profilePic;
        }
        else
        {
            user_image.image=[UIImage imageNamed:@"defaultProfile"];
        }
        
        //cell.imageView.image = [UIImage imageNamed:[memberDisplayPic objectAtIndex:indexPath.row]];
        username.text =[memberName objectAtIndex:indexPath.row];
        extraInfo.text = [memberLocation objectAtIndex:indexPath.row];
        
        if ([[memberIsAdmin objectAtIndex:indexPath.row]isEqualToString:@"1"]) {
            deleteButton=Nil;
            adminImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"admin"]];
            adminImage.frame = CGRectMake(tableView.frame.size.width-40, cell.frame.origin.y+5,30,30);
            [cell addSubview:adminImage];
            
        }
        else
        {
            adminImage=Nil;
            deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [deleteButton addTarget:self action:@selector(deleteMember:event:) forControlEvents:UIControlEventTouchDown];
            [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            deleteButton.frame = CGRectMake(tableView.frame.size.width-40, cell.frame.origin.y+5,30,30);
            [cell addSubview:deleteButton];
        }
        
        user_image.frame = CGRectMake(20, 10, 60, 60);
        username.frame = CGRectMake(100, 10, 180, 22);
        extraInfo.frame = CGRectMake(100, 32, 200, 15);

    }
    
    return cell;
    
    
    
    
}

-(IBAction)deleteMember:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:manageMembersTable];
    NSIndexPath *indexPath = [manageMembersTable indexPathForRowAtPoint: currentTouchPosition];
    userID=[memberId objectAtIndex:indexPath.row];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                     message:@"Are you sure you want to remove this member?"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK",nil];
    [alert setTag:1];
    [alert show];
    
}

//UIAlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1) {
        if (buttonIndex == 1) {
            //delete member
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.delegate = self;
            HUD.dimBackground = YES;
            HUD.labelText = @"Please Wait";
            
            NSLog(@"group id:%@, user id:%@",groupId,userID);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",groupId,userID];
            NSLog(@"$[delete member%@]",postData);
            
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/delete_grp_mem.php",gupappUrl]]];
            
            [request setHTTPMethod:@"POST"];
            
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            
            deleteMemberConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            
            [deleteMemberConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            
            [deleteMemberConn start];
            
            deleteMemberResponse = [[NSMutableData alloc] init];
        }
        
    }
}



//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == deleteMemberConn) {
        
        [deleteMemberResponse setLength:0];
        
    }
    if (connection == makeAdminConn) {
        
        [makeAdminResponse setLength:0];
        
    }
    if (connection == leaveAsAdminConn) {
        
        [leaveAsAdminResponse setLength:0];
        
    }
    if (connection == fetchGroupsConn) {
        
        [fetchGroupsResponse setLength:0];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == deleteMemberConn) {
        
        [deleteMemberResponse appendData:data];
        
    }
    if (connection == makeAdminConn) {
        
        [makeAdminResponse appendData:data];
        
    }
    
    if (connection == leaveAsAdminConn) {
        
        [leaveAsAdminResponse appendData:data];
        
    }
    if (connection == fetchGroupsConn) {
        
        [fetchGroupsResponse appendData:data];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //[activityIndicator stopAnimating];
    [HUD hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == deleteMemberConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:deleteMemberResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        
        
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        
        NSDictionary *res= [jsonparser objectWithString:str];
        
        NSLog(@" result %@",res);
        
        NSDictionary *response= res[@"response"];
        
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        NSLog(@"status = %@ error =  %@",status,error);
        if ([status isEqualToString:@"0"])
        {
            NSLog(@"member id %@",memberId);
            for (int j=0; j<[memberId count]; j++)
            {
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                
                [attributeDic setValue:[[memberId objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"You have been removed from the group %@",groupName ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                
                
                if ([[memberId objectAtIndex:j]isEqualToString:userID])
                    [elementDic setValue:@"1" forKey:@"grpDelete"];
                if ([userID isEqual:[memberId objectAtIndex:j]] ) {
                    [elementDic setValue:@"1" forKey:@"show_notification"];
                    [elementDic setValue:@"1" forKey:@"is_notify"];
                }
                else
                {
                    [elementDic setValue:@"0" forKey:@"is_notify"];
                    [elementDic setValue:@"0" forKey:@"show_notification"];
                }
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",groupId);
                [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            [memberIsAdmin removeObjectAtIndex:[memberId indexOfObject:userID]];
            [memberName removeObjectAtIndex:[memberId indexOfObject:userID]];
            [memberLocation removeObjectAtIndex:[memberId indexOfObject:userID]];
            [memberDisplayPic removeObjectAtIndex:[memberId indexOfObject:userID]];
            [memberId removeObjectAtIndex:[memberId indexOfObject:userID]];
            
            
            //NSString *query=[NSString stringWithFormat:@"delete from group_members where group_id = '%@' and contact_id = '%@' ",groupId,userID];
            
            //NSLog(@"sub query %@",query);
            //[[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set deleted = 1 where group_id = '%@' and contact_id='%@' ",groupId,userID];
            NSLog(@"query %@",updateMembers);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
            int groupMembersCount=[[DatabaseManager getSharedInstance]countGroupMembers:groupId];
            NSString *updateQuery;
            if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"])
            {
                updateQuery=[NSString stringWithFormat:@"update  groups_private set total_members = '%d' where group_server_id = '%@' ",groupMembersCount,groupId];
            }
            else
            {
                updateQuery=[NSString stringWithFormat:@"update  groups_public set total_members = '%d' where group_server_id = '%@' ",groupMembersCount,groupId];
            }
            NSLog(@"update query %@",updateQuery);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateQuery];
            [HUD hide:YES];
            //             [self fetchGroups];
            [manageMembersTable reloadData];
            
            
        }else{
            [HUD hide:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
            
        }
        deleteMemberConn=nil;
        
        [deleteMemberConn cancel];
        
    }else{
        NSDictionary *response;
        NSString *notification;
        if (connection == makeAdminConn) {
            
            NSLog(@"====EVENTS");
            
            NSString *str = [[NSMutableString alloc] initWithData:makeAdminResponse encoding:NSASCIIStringEncoding];
            
            NSLog(@"Response:%@",str);
            SBJSON *jsonparser=[[SBJSON alloc]init];
            
            NSDictionary *res= [jsonparser objectWithString:str];
            
            NSLog(@" result %@",res);
            
            response= res[@"response"];
            
            NSLog(@"response %@",response);
            NSString *status = response[@"error"];
            NSString *error = response[@"error_message"];
            NSLog(@"status = %@ error =  %@",status,error);
            if ([status isEqualToString:@"0"]){
                NSString *query=[NSString stringWithFormat:@"update  group_members set is_admin = 1 where group_id = '%@' and contact_id = '%@' ",groupId,selectedMemberId];
                
                NSLog(@"sub query %@",query);
                notification=[NSString stringWithFormat:@"You have been assigned as the admin for the group %@",groupName];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
                //                [self fetchGroups];
                if ([response[@"error"] isEqualToString:@"0"])
                    for (int j=0; j<[memberId count]; j++)
                    {        NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                        [attributeDic setValue:@"chat" forKey:@"type"];
                        [attributeDic setValue:[[memberId objectAtIndex:j] JID] forKey:@"to"];
                        [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                        [attributeDic setValue:@"0" forKey:@"isResend"];
                        NSString *body=notification;
                        NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                        // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                        [elementDic setValue:@"text" forKey:@"message_type"];
                        [elementDic setValue:@"1" forKey:@"grpUpdate"];
                        NSLog(@"memid %@ ",memberId );
                        NSLog(@"memid %@ arry id %@",selectedMemberId,[memberId objectAtIndex:j]);
                        if ([selectedMemberId isEqual:[memberId objectAtIndex:j]] ) {
                            [elementDic setValue:@"1" forKey:@"show_notification"];
                            [elementDic setValue:@"1" forKey:@"is_notify"];
                        }
                        else
                        {
                            [elementDic setValue:@"0" forKey:@"show_notification"];
                            [elementDic setValue:@"0" forKey:@"is_notify"];
                        }
                        [elementDic setValue:@"1" forKey:@"isgroup"];
                        NSLog(@"gid %@",groupId);
                        [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
                        [elementDic setValue:body forKey:@"body"];
                        
                        [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
                    }
                [memberIsAdmin insertObject:@"1" atIndex:[memberId indexOfObject:selectedMemberId]];
                [manageMembersTable reloadData];
                //                [HUD removeFromSuperview];
                [HUD hide:YES];
            }
            else
            {
                [HUD hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            makeAdminConn=nil;
            [HUD hide:YES];
            [makeAdminConn cancel];
        }
        
        
        if (connection == fetchGroupsConn) {
            
            NSLog(@"====EVENTS");
            
            NSString *str = [[NSMutableString alloc] initWithData:fetchGroupsResponse encoding:NSASCIIStringEncoding];
            
            NSLog(@"Response:%@",str);
            SBJSON *jsonparser=[[SBJSON alloc]init];
            
            NSDictionary *res= [jsonparser objectWithString:str];
            
            NSLog(@" result %@",res);
            response= res[@"response"];
            NSLog(@"response %@",response);
            NSDictionary *groupDetail = response[@"Group_Details"];
            NSArray *memberList = groupDetail[@"member_details"];
            NSArray *deletedMembers = groupDetail[@"deleted_members"];
            NSLog(@"response %@",memberList);
            if([memberList count]>0){
                [memberId removeAllObjects];
                [memberName removeAllObjects];
                [memberLocation removeAllObjects];
                [memberDisplayPic removeAllObjects];
                [memberIsAdmin removeAllObjects];
                
                memberName = [[NSMutableArray alloc]init];
                memberLocation = [[NSMutableArray alloc]init];
                memberDisplayPic = [[NSMutableArray alloc]init];
                memberIsAdmin = [[NSMutableArray alloc]init];
                memberId = [[NSMutableArray alloc]init];
                //                for (NSString *deletedID in deletedMembers) {
                
                for(NSMutableDictionary *data in memberList){
                    BOOL flag = true;
                    for (NSString *dID in deletedMembers) {
                        
                        if([dID isEqualToString:[data objectForKey:@"user_id"]]){
                            flag = false;
                        }
                    }
                    //                    NSMutableArray *members = [memberList objectAtIndex:i];
                    if (flag) {
                        [memberId addObject:[data objectForKey:@"user_id"]];
                        [memberIsAdmin addObject:[data objectForKey:@"is_admin"]];
                        [memberName addObject:[data objectForKey:@"display_name"]];
                        [memberLocation addObject:[data objectForKey:@"location_name"]];
                        [memberDisplayPic addObject:[data objectForKey:@"profile_pic"]];
                        //                        break;
                    }
                    
                    //                    }
                    
                }
                NSLog(@"member id%@",memberId);
                NSLog(@"member isadmin%@",memberIsAdmin);
                NSLog(@"member name%@",memberName);
                NSLog(@"member location%@",memberLocation);
                NSLog(@"member displaypic%@",memberDisplayPic);
                [manageMembersTable reloadData];
            }else{
                [HUD hide:YES];
                NSLog(@"no contacts");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No Members"   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            fetchGroupsConn=nil;
            [fetchGroupsConn cancel];
            [HUD hide:YES];
            
        }
        
        if (connection == leaveAsAdminConn) {
            
            NSLog(@"====EVENTS");
            
            NSString *str = [[NSMutableString alloc] initWithData:leaveAsAdminResponse encoding:NSASCIIStringEncoding];
            
            NSLog(@"Response:%@",str);
            SBJSON *jsonparser=[[SBJSON alloc]init];
            
            NSDictionary *res= [jsonparser objectWithString:str];
            
            NSLog(@" result %@",res);
            
            response= res[@"response"];
            
            NSLog(@"response %@",response);
            NSString *status = response[@"error"];
            NSString *error = response[@"error_message"];
            NSLog(@"status = %@ error =  %@",status,error);
            if ([status isEqualToString:@"0"]){
                NSString *query1=[NSString stringWithFormat:@"update  group_members set is_admin = 0 where group_id = '%@' and contact_id = '%@' ",groupId,selectedMemberId];
                
                NSLog(@"sub query %@",query1);
                notification=[NSString stringWithFormat:@"%@ has left his Admin Rights",[[DatabaseManager getSharedInstance]getAppUserName]];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query1];
                if ([response[@"error"] isEqualToString:@"0"])
                    for (int j=0; j<[memberId count]; j++)
                    {        NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                        [attributeDic setValue:@"chat" forKey:@"type"];
                        [attributeDic setValue:[[memberId objectAtIndex:j] JID] forKey:@"to"];
                        [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                        [attributeDic setValue:@"0" forKey:@"isResend"];
                        NSString *body=notification;
                        NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                        // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                        [elementDic setValue:@"text" forKey:@"message_type"];
                        [elementDic setValue:@"1" forKey:@"grpUpdate"];
                        NSLog(@"memid %@ ",memberId );
                        NSLog(@"memid %@ arry id %@",selectedMemberId,[memberId objectAtIndex:j]);
                        if (![selectedMemberId isEqual:[memberId objectAtIndex:j]] ) {
                            [elementDic setValue:@"1" forKey:@"show_notification"];
                            [elementDic setValue:@"1" forKey:@"is_notify"];
                        }
                        else
                        {
                            [elementDic setValue:@"0" forKey:@"show_notification"];
                            [elementDic setValue:@"0" forKey:@"is_notify"];
                        }
                        [elementDic setValue:@"1" forKey:@"isgroup"];
                        NSLog(@"gid %@",groupId);
                        [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
                        [elementDic setValue:body forKey:@"body"];
                        
                        [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];  }
                //[self fetchGroups];
                //[manageMembersTable reloadData];
                //[self.navigationController popViewControllerAnimated:NO];
                //[self.navigationController popViewControllerAnimated:NO];
                [self.navigationController popToRootViewControllerAnimated:NO];
                [HUD hide:YES];
            }
            else
            {
                [HUD hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            leaveAsAdminConn=nil;
            
            [leaveAsAdminConn cancel];
        }
        
        
        
    }
}
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// Handle Long Press in the cell
-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:manageMembersTable];
    NSIndexPath *indexPath = [manageMembersTable indexPathForRowAtPoint: location];
    NSString *selectedIndividual = [memberName objectAtIndex:indexPath.row];
    NSLog(@"selected individual:%@",selectedIndividual);
    selectedMemberId = [memberId objectAtIndex:indexPath.row];
    NSLog(@"Selected index = %d and selected person = %@ and selected id = %@",indexPath.row,selectedIndividual,selectedMemberId);
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSString *appUserId =[[DatabaseManager getSharedInstance]getAppUserID];
        if ([[memberIsAdmin objectAtIndex:indexPath.row] isEqualToString:@"1"]&&[appUserId isEqualToString:[memberId objectAtIndex:indexPath.row]])
        {
            NSString *cancelTitle =@"Cancel";
            NSString *option1 =@"Leave as Admin";
            UIActionSheet *contactActionSheet = [[UIActionSheet alloc]
                                                 initWithTitle:@""
                                                 delegate:self
                                                 cancelButtonTitle:cancelTitle
                                                 destructiveButtonTitle:Nil
                                                 otherButtonTitles:option1, nil];
            [contactActionSheet showFromTabBar:self.tabBarController.tabBar];
        }
        else if([[memberIsAdmin objectAtIndex:indexPath.row] isEqualToString:@"0"])
        {
            NSString *cancelTitle =@"Cancel";
            NSString *option1 =@"Make Admin";
            UIActionSheet *contactActionSheet = [[UIActionSheet alloc]
                                                 initWithTitle:@""
                                                 delegate:self
                                                 cancelButtonTitle:cancelTitle
                                                 destructiveButtonTitle:Nil
                                                 otherButtonTitles:option1, nil];
            [contactActionSheet showFromTabBar:self.tabBarController.tabBar];
            
            
        }
    }
}

// action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{        //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"button title:%i,%@",buttonIndex ,buttonTitle);
    if ([buttonTitle isEqualToString:@"Make Admin"]) {
        NSLog(@"Make Admin");
        
        //[ addSubview:adminImage];
        int adminCount = [[DatabaseManager getSharedInstance]countGroupAdmins:groupId];
        NSLog(@"admin count=%d",adminCount);
        if (adminCount==3) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Admin limit reached."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }else{
            
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.delegate = self;
            HUD.dimBackground = YES;
            HUD.labelText = @"Please Wait";
            NSLog(@"group id:%@, user id:%@",groupId,selectedMemberId);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",groupId,selectedMemberId];
            NSLog(@"$[add admin%@]",postData);
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_admin.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            makeAdminConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [makeAdminConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [makeAdminConn start];
            makeAdminResponse = [[NSMutableData alloc] init];
            /*
             NSString *query=[NSString stringWithFormat:@"update  group_members set is_admin = 1 where group_id = '%@' and contact_id = '%@' ",groupId,selectedMemberId];
             
             NSLog(@"sub query %@",query);
             [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
             [self loadMembers];
             [manageMembersTable reloadData];*/
        }
        
        
    }
    
    if ([buttonTitle isEqualToString:@"Leave as Admin"]) {
        NSLog(@"Leave as Admin");
        int adminCount1 = [[DatabaseManager getSharedInstance]countGroupAdmins:groupId];
        NSLog(@"admin count=%d",adminCount1);
        if (adminCount1==1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Cannot leave as admin until you make some one else."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.delegate = self;
            HUD.dimBackground = YES;
            HUD.labelText = @"Please Wait";
            NSLog(@"group id:%@, user id:%@",groupId,selectedMemberId);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",groupId,selectedMemberId];
            NSLog(@"$[leave admin%@]",postData);
            
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/leave_admin.php",gupappUrl]]];
            
            [request setHTTPMethod:@"POST"];
            
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            
            leaveAsAdminConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            
            [leaveAsAdminConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            
            [leaveAsAdminConn start];
            
            leaveAsAdminResponse = [[NSMutableData alloc] init];
            /* NSString *query1=[NSString stringWithFormat:@"update  group_members set is_admin = 0 where group_id = '%@' and contact_id = '%@' ",groupId,selectedMemberId];
             
             NSLog(@"sub query %@",query1);
             [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query1];
             [self loadMembers];
             [manageMembersTable reloadData];*/
            
        }
        
        
        
    }
    
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 1)
    {
        //UITableViewCell *longPressedGroupCell=[manageMembersTable cellForRowAtIndexPath:indexPath];
        //int selectedCell = indexPath.row;
        
    }
    /*else if(indexPath.section == 0)
     {
     [self showEmail];
     
     }*/
    
    
    
}
#pragma Mailing delegates
/*- (void)showEmail
 {
 // Email Subject
 
 MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
 if ([MFMailComposeViewController canSendMail])
 {
 mc.mailComposeDelegate = self;
 [mc setSubject:@"Join this group"];
 [mc setMessageBody:[NSString stringWithFormat:@"%@ \n",groupName] isHTML:NO];
 // Present mail view controller on screen
 [self presentViewController:mc animated:YES completion:NULL];
 }
 
 }
 
 - (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
 {
 switch (result)
 {
 case MFMailComposeResultCancelled:
 NSLog(@"Mail cancelled");
 break;
 case MFMailComposeResultSaved:
 NSLog(@"Mail saved");
 break;
 case MFMailComposeResultSent:
 NSLog(@"Mail sent");
 break;
 case MFMailComposeResultFailed:
 NSLog(@"Mail sent failure: %@", [error localizedDescription]);
 break;
 default:
 break;
 }
 
 // Close the Mail Interface
 [self dismissViewControllerAnimated:YES completion:NULL];
 }
 */



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end