//
//  JoinRequest.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "XMPPRoomMemoryStorage.h"
#import "JoinRequest.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "JSON.h"
#import "DatabaseManager.h"
#import "ViewContactProfile.h"


@interface JoinRequest ()

@end

@implementation JoinRequest

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Join Request";
    }
    return self;
}
@synthesize groupType,groupId,groupName;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    userId = [[NSMutableArray alloc]init];
    userName = [[NSMutableArray alloc]init];
    userPic = [[NSMutableArray alloc]init];
    userLocation = [[NSMutableArray alloc]init];
    [self getGroupJoinRequest];
}
-(void)viewDidAppear:(BOOL)animated{
    
}

#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%i",[userId count]);
    return [userId count];
    
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
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

    NSLog(@"%i",[userId count]);
    if (![userId count] == 0)
    {
        // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",userPic[indexPath.row]]];
        NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
        NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
        UIImage *profilePic = [UIImage imageWithData:pngData];
        if (profilePic){
            user_image.image=profilePic;
        }else{
            user_image.image=[UIImage imageNamed:@"defaultProfile"];
        }
        
        
        username.text = [userName objectAtIndex:indexPath.row];
        extraInfo.text =[userLocation objectAtIndex:indexPath.row];
        
        UIButton *accept = [UIButton buttonWithType:UIButtonTypeCustom];
        [accept addTarget:self action:@selector(acceptRequest:event:) forControlEvents:UIControlEventTouchDown];
        [accept setImage:[UIImage imageNamed:@"accept"] forState:UIControlStateNormal];
        accept.frame = CGRectMake(tableView.frame.size.width-90, cell.frame.origin.y+2,40, 40);
        accept.backgroundColor = [UIColor clearColor];
        [accept setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cell addSubview:accept];
        UIButton *reject= [UIButton buttonWithType:UIButtonTypeCustom];
        [reject addTarget:self action:@selector(rejectRequest:event:) forControlEvents:UIControlEventTouchDown];
        [reject setImage:[UIImage imageNamed:@"reject"] forState:UIControlStateNormal];
        reject.frame = CGRectMake(tableView.frame.size.width-45, cell.frame.origin.y+2,40, 40);
        reject.backgroundColor = [UIColor clearColor];
        [reject setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cell addSubview:reject];
        
        user_image.frame = CGRectMake(20, 10, 60, 60);
        username.frame = CGRectMake(100, 10, 180, 22);
        extraInfo.frame = CGRectMake(100, 32, 200, 15);
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewContactProfile *viewContactPage = [[ViewContactProfile alloc]init];
    viewContactPage.userId=[userId objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewContactPage animated:NO];
    
}

-(IBAction)acceptRequest:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:joinRequestTable];
    selectedIndexPath = [joinRequestTable indexPathForRowAtPoint: currentTouchPosition];
    flag=1;
    [self requestApproval];
    
    
}

-(IBAction)rejectRequest:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:joinRequestTable];
    selectedIndexPath = [joinRequestTable indexPathForRowAtPoint: currentTouchPosition];
    flag=2;
    [self requestApproval];
}
-(void)requestApproval{
    
    NSLog(@"selected index path %@",selectedIndexPath);
    [self startActivityIndicator];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@&flag=%i",groupId,[userId objectAtIndex:selectedIndexPath.row],flag];
    NSLog(@"postdata%@",postData);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/private_grp_request_approval.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    requestApprovalConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [requestApprovalConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [requestApprovalConn start];
    requestApprovalResponse = [[NSMutableData alloc] init];
    
    if(flag == 1){
        
      
        
        
    }
}

-(void)getGroupJoinRequest{
    
    [self startActivityIndicator];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
    NSLog(@"postdata%@",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/private_grp_request_listing.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    getGroupJoinRequestConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [getGroupJoinRequestConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [getGroupJoinRequestConn start];
    getGroupJoinRequestResponse = [[NSMutableData alloc] init];
    
}
-(void)startActivityIndicator{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == getGroupJoinRequestConn) {
        [getGroupJoinRequestResponse setLength:0];
    }
    if (connection == requestApprovalConn) {
        [requestApprovalResponse setLength:0];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    if (connection == getGroupJoinRequestConn) {
        [getGroupJoinRequestResponse appendData:data];
    }
    if (connection == requestApprovalConn) {
        [requestApprovalResponse appendData:data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == getGroupJoinRequestConn) {
        NSString *str = [[NSMutableString alloc] initWithData:getGroupJoinRequestResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *response= res[@"response"];
        
        int status =[response[@"error"] integerValue];
        NSDictionary *userList =response[@"user_list"];
        NSLog(@"list%@",userList);
        if (status==1){
            
            [HUD hide:YES];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:response[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            
        }else{
            NSLog(@"list requests");
            for (NSDictionary *result in userList) {
                
                NSString *requestUserId = result[@"user_id"];
                NSString *requestUserName = result[@"user_name"];
                NSString *requestUserPic = result[@"profile_pic"];
                NSString *requestUserLocation = result[@"location_name"];
                
                [userId addObject:requestUserId];
                [userName addObject:requestUserName];
                [userPic addObject:requestUserPic];
                [userLocation addObject:requestUserLocation];
                
                //load images
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,requestUserPic]]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // categoryImageView.image = [UIImage imageWithData:imgData];
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        NSLog(@"paths=%@",paths);
                        NSString *profilePicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",requestUserPic]];
                        NSLog(@"profile pic path=%@",profilePicPath);
                        
                        //Writing the image file
                        [imgData writeToFile:profilePicPath atomically:YES];
                        
                        
                    });
                    
                });
                
                
            }
            [joinRequestTable reloadData];
            [HUD hide:YES];
        }
        
        getGroupJoinRequestConn=nil;
        [getGroupJoinRequestConn cancel];
        
    }
    if (connection == requestApprovalConn) {
        
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:requestApprovalResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@" result %@",res);
        NSDictionary *response= res[@"response"];
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        NSLog(@"status = %@ error =  %@",status,error);
        if ([status isEqualToString:@"0"]){
            
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }else{
            [HUD hide:YES];
            if (flag==1) {
                
//                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"insert into group_members (group_id,contact_id,is_admin,contact_name,contact_location,contact_image) values ('%@','%@','%d','%@','%@','%@')",groupId,userId[selectedIndexPath.row],0,[userName[selectedIndexPath.row] normalizeDatabaseElement],userLocation[selectedIndexPath.row],userPic[selectedIndexPath.row]]];
                
            }
            NSUInteger t=[userId indexOfObject:[userId objectAtIndex:selectedIndexPath.row]];
            NSLog(@"index %i",t);
            
            NSLog(@"user id %@\n username %@\n userpic %@\n userlocation %@",userId,userName,userPic,userLocation);
            // update the private groups table
            int groupJoinCount = [[DatabaseManager getSharedInstance]fetchGroupJoinRequestCount:groupId];
            groupJoinCount=groupJoinCount-1;
            NSString *updateGroupJoinRequestCount=[NSString stringWithFormat:@"update  groups_private set group_join_request_count='%d' where group_server_id = '%@' ",groupJoinCount,groupId];
            NSLog(@"query %@",updateGroupJoinRequestCount);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateGroupJoinRequestCount];
            [joinRequestTable reloadData];
            
            
            if(flag==1)
            {
                NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@",groupId]];
                NSMutableArray    *membersID=[[NSMutableArray alloc]init];
                for (int i=0; i<[tempmembersID count];i++)
                {//if(![[tempmembersID objectAtIndex:i]isEqual:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]])
                    [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
                }
                
                XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"group_%@@%@",groupId,groupJabberUrl]];
                XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
                XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
                
                [xmppRoom activate:[self appDelegate].xmppStream];
                [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
                NSString *recieversID=[NSString stringWithFormat:@"user_%@@%@",[userId objectAtIndex:selectedIndexPath.row],jabberUrl];
                [xmppRoom inviteUser:[XMPPJID jidWithString:recieversID] withMessage:@""];
                
                NSLog(@"membersID %@",membersID);
                
                for (int j=0; j<[membersID count]; j++){
                    NSLog(@"%@ %@",membersID,membersID[j]);
                    NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                    [attributeDic setValue:@"chat" forKey:@"type"];
                    [attributeDic setValue:[[membersID objectAtIndex:j] JID] forKey:@"to"];
                    [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                    [attributeDic setValue:@"0" forKey:@"isResend"];
                    
                    NSString *body=[NSString stringWithFormat:@"Your request to join the group %@ has been Accepted",groupName];
                    NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                    // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                    [elementDic setValue:@"text" forKey:@"message_type"];
                    [elementDic setValue:@"1" forKey:@"gupNotification"];
                    [elementDic setValue:@"1" forKey:@"grpUpdate"];
                    NSString *UserID=   [userId objectAtIndex:selectedIndexPath.row];
                    if ([UserID isEqual:[membersID objectAtIndex:j]] ) {
                        [elementDic setValue:@"1" forKey:@"show_notification"];
                        [elementDic setValue:@"1" forKey:@"is_notify"];
                    }else{
                        [elementDic setValue:@"0" forKey:@"is_notify"];
                        [elementDic setValue:@"0" forKey:@"show_notification"];
                    }
                    //[elementDic setValue:@"1" forKey:@"show_notification"];
                    // [elementDic setValue:@"1" forKey:@"is_notify"];
                    [elementDic setValue:@"1" forKey:@"isgroup"];
                    NSLog(@"gid %@",groupId);
                    [elementDic setValue:groupId forKey:@"groupID"];
                    [elementDic setValue:body forKey:@"body"];
                    
                    [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
                    
                   
                    
                    
                }
                
            }else if (flag==2){
                
                NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@",groupId]];
                NSMutableArray    *membersID=[[NSMutableArray alloc]init];
                for (int i=0; i<[tempmembersID count];i++)
                {//if(![[tempmembersID objectAtIndex:i]isEqual:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]])
                    [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
                }
                
                NSLog(@"membersID %@",membersID);
                
                //4552
                NSString *selectedUserID=   [userId objectAtIndex:selectedIndexPath.row] ;
                //    for (int j=0; j<[membersID count]; j++)
                NSLog(@"user idkjl%@ ",selectedUserID);
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[selectedUserID JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"Your request to join the group %@ has been Rejected",groupName];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"gupNotification"];
                [elementDic setValue:@"1" forKey:@"grpDelete"];
                [elementDic setValue:@"1" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"is_notify"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",groupId);
                [elementDic setValue:groupId forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            [userId removeObjectAtIndex:t];
            [userName removeObjectAtIndex:t];
            [userPic removeObjectAtIndex:t];
            [userLocation removeObjectAtIndex:t];
            NSLog(@"print this user id count: %d",userId.count);
            if (userId.count == 0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There are no more Group Join Requests."   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                alert.tag=33;
                [alert show];
                
            }
            
        }
        
        requestApprovalConn=nil;
        [requestApprovalConn cancel];
        
    }
    [joinRequestTable reloadData];
} 

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==33){
        if (buttonIndex==0){
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    
}



- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
