//
//  LandingPage.m
//  GUP
//
//  Created by Milind Prabhu on 7/31/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import "LandingPage.h"
#import "SBJSON.h"
#import "AppDelegate.h"
#import "GroupTableCell.h"
#import "DatabaseManager.h"
#import "viewPrivateGroup.h"
#import "GroupInfo.h"
#import "ChatScreen.h"
#import "newGroupCell.h"
#import "AFNetworking.h"

@interface LandingPage ()

@end

@implementation LandingPage{
    NSIndexPath *path;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title =@"Recommended Groups";
        
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    expndRow = -1;
    // Do any additional setup after loading the view from its nib.
    [self.navigationController.navigationBar.backItem hidesBackButton];
    groupIds  = [[NSMutableArray alloc] init];
    groupNames  = [[NSMutableArray alloc] init];
    adminNames  = [[NSMutableArray alloc] init];
    groupDisplayThumbnails  = [[NSMutableArray alloc] init];
    groupTypes  = [[NSMutableArray alloc] init];
    groupLocations  = [[NSMutableArray alloc] init];
    popularityFactor  = [[NSMutableArray alloc] init];
    selectedGroup  = [[NSMutableArray alloc] init];
    done.hidden = YES;
    
    [done.titleLabel setFont:[UIFont fontWithName:@"Dosis-Bold" size:18]];
    
    [skip.titleLabel setFont:[UIFont fontWithName:@"Dosis-Bold" size:18]];
    
    [self setActivityIndicator];
    [self listGroupsAssociatedToCategory];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Table View Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        static NSString *groupTableIdentifier = @"GroupTableItem";
    
        newGroupCell *cell= (newGroupCell *)[tableView dequeueReusableCellWithIdentifier:groupTableIdentifier];
    
        if (cell == nil)
        {
            cell = [[newGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupTableIdentifier];
        }
    cell.groupDelegate = self;
    [cell drawCell:[groupData objectAtIndex:indexPath.row] withIndex:indexPath.row];
    
    //[cell drawCell:[groupTypes objectAtIndex:indexPath.row] imgUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,groupDisplayThumbnails[indexPath.row]]] name:[groupNames objectAtIndex:indexPath.row] description:]
    
//        UIImageView *iconImage= [[UIImageView alloc]initWithFrame:CGRectMake(18, 18, 18, 18)];
//        if ([[groupTypes objectAtIndex:indexPath.row]isEqualToString:@"private#local"]) {
//            iconImage.image =[UIImage imageNamed:@"private_local"];
//        }
//        else if ([[groupTypes objectAtIndex:indexPath.row]isEqualToString:@"private#global"])
//        {
//            iconImage.image =[UIImage imageNamed:@"private_global"];
//        }
//        else if ([[groupTypes objectAtIndex:indexPath.row]isEqualToString:@"public#local"])
//        {
//            iconImage.image =[UIImage imageNamed:@"pin15"];
//        }
//        else{
//            iconImage.image =[UIImage imageNamed:@"globe15"];
//        }
//        [cell.imageView addSubview:iconImage];
    
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            NSData *imgData = [NSData dataWithContentsOfURL:];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                cell.imageView.image = [UIImage imageWithData:imgData];
//                
//                
//            });
//            
//        });
//        
//        cell.textLabel.text = [groupNames objectAtIndex:indexPath.row];
//        if([[groupTypes objectAtIndex:indexPath.row]isEqualToString:@"private#local"]||[[groupTypes objectAtIndex:indexPath.row]isEqualToString:@"private#global"])
//            cell.detailTextLabel.text =[NSString stringWithFormat:@"Created by: %@",[adminNames objectAtIndex:indexPath.row]];
//        else
//            cell.detailTextLabel.text =[groupLocations objectAtIndex:indexPath.row];
//      //  if ( [[[self appDelegate].ver objectAtIndex:0] intValue] >= 7)
//      //      [cell setAccessoryType: UITableViewCellAccessoryDetailButton];
//      //  else
//            [cell setAccessoryType: UITableViewCellAccessoryDetailButton];
        
        return cell;
   
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{  if(expndRow == indexPath.row){
    return 60+[[[groupData objectAtIndex:indexPath.row] objectForKey:@"height"] floatValue];
    }
    return 90;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   
}

-(void)setActivityIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{  // check whether the user is the admin of the group.
    NSString *appUserId =[[DatabaseManager getSharedInstance]getAppUserID];
    
    NSLog(@"group id check:%@ userid:%@",[groupIds objectAtIndex:indexPath.row],appUserId);
    int is_admin=[[DatabaseManager getSharedInstance]isAdminOrNot:[groupIds objectAtIndex:indexPath.row] contactId:appUserId];
    NSLog(@"is_admin%i",is_admin);
    if (is_admin == 1) {
        viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
        viewGroupAsAdmin.title = [groupNames objectAtIndex:indexPath.row];
        viewGroupAsAdmin.groupId = [groupIds objectAtIndex:indexPath.row];
        viewGroupAsAdmin.groupType =[groupTypes objectAtIndex:indexPath.row];
        viewGroupAsAdmin.viewType = @"Explore";
        [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
    }
    else
    {
        
        GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
        viewGroupPage.title = [groupNames objectAtIndex:indexPath.row];
        viewGroupPage.groupId = [groupIds objectAtIndex:indexPath.row];
        viewGroupPage.groupType = [groupTypes objectAtIndex:indexPath.row];
        viewGroupPage.viewType = @"Explore";
        [self.navigationController pushViewController:viewGroupPage animated:YES];
        
    }
}


-(void)listGroupsAssociatedToCategory
{
    
    NSString *postData = [NSString stringWithFormat:@"category_id=1&user_id=%@",[[DatabaseManager getSharedInstance]getAppUserID]];
    NSLog(@"$[%@]",postData);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //NSString *postData = [NSString stringWithFormat:@"username=%@",userName];
    //NSLog(@"$[username=%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/fetch_cat_groups_rec.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    listGroupsConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [listGroupsConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [listGroupsConn start];
    listGroupsResponse = [[NSMutableData alloc] init];
    
}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == listGroupsConn) {
        
        [listGroupsResponse setLength:0];
    }
    if (connection == initiateGroupJoinConn) {
        [initiateGroupJoinResponse setLength:0];
    }
    if (connection == addGroupConn) {
        [addGroupResponse setLength:0];
    }
    if (connection == addFavGroupConn) {
        [addFavGroupResponse setLength:0];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == listGroupsConn) {
        [listGroupsResponse appendData:data];
    }
    if (connection == initiateGroupJoinConn) {
        [initiateGroupJoinResponse appendData:data];
    }
    if (connection == addGroupConn) {
        [addGroupResponse appendData:data];
    }
    if (connection == addFavGroupConn) {
        [addFavGroupResponse appendData:data];
    }}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(BOOL)checkifSelected:(NSInteger)row{
    if([selectedGroup  containsObject:[NSString stringWithFormat:@"%ld",(long)row]]){
        
        return true;
        
    }else{
        
        return false;
    }
}
-(BOOL)checkiffull:(NSInteger)row{
    if(expndRow==row){
        
        return true;
        
    }else{
        
        return false;
    }
}
-(void)expandCellHeight:(UIButton*)btn withIndex:(NSInteger)row{
    newGroupCell *pcell;
    if ([[btn superview] isKindOfClass:[newGroupCell class]]) {
        pcell = (newGroupCell *)[btn superview];
    }
    else if ([[[btn superview] superview] isKindOfClass:[newGroupCell class]]){
        pcell = (newGroupCell *)[[btn superview] superview];
    }
    expndRow = row;
    NSIndexPath *morePath =[GroupsListTable indexPathForCell:pcell];
    [GroupsListTable beginUpdates];
    [GroupsListTable reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:GroupsListTable heightForRowAtIndexPath:morePath];
    [GroupsListTable endUpdates];
}

-(CGSize)calculateHeight:(NSString*)data{
    
    CGFloat width = 210;
    UIFont *font = [UIFont fontWithName:@"Dosis-Regular" size:10.0f];
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:data attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    size.width = size.width +25;
    size.height = size.height +25;
    return size;
}

-(void)groupSelected:(UIButton*)btn withIndex:(NSInteger)row{
    
    if([selectedGroup  containsObject:[NSString stringWithFormat:@"%ld",(long)row]]){
        
        [selectedGroup removeObject:[NSString stringWithFormat:@"%ld",(long)row]];
        
    }else{
        
        [selectedGroup addObject:[NSString stringWithFormat:@"%ld",(long)row]];
    }
    
    if(selectedGroup.count>0){
        
        done.hidden = false;
        skip.hidden = true;
        
    }else{
        
        skip.hidden = false;
        done.hidden = true;
    }
    newGroupCell *pcell;
    if ([[btn superview] isKindOfClass:[newGroupCell class]]) {
        pcell = (newGroupCell *)[btn superview];
    }
    else if ([[[btn superview] superview] isKindOfClass:[newGroupCell class]]){
        pcell = (newGroupCell *)[[btn superview] superview];
    }
    NSIndexPath *morePath =[GroupsListTable indexPathForCell:pcell];
    [GroupsListTable beginUpdates];
    [GroupsListTable reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:GroupsListTable heightForRowAtIndexPath:morePath];
    [GroupsListTable endUpdates];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == listGroupsConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:listGroupsResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"group_list"];
        NSLog(@"results: %@", results);
        NSDictionary *groups=results[@"list"];
        NSLog(@"groups: %@", groups);
        if ([groups count]==0 )
        {
           // [HUD hide:YES];
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:[NSString stringWithFormat:@"There are no groups"]
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            alert.tag=11;
            [alert show];
        }
        else
        {
            
            NSLog(@"====EVENTS==3 %@",res);
            groupData = [[NSMutableArray alloc]init];
            
            for (NSDictionary *result in groups) {
                NSMutableDictionary *datav = [[NSMutableDictionary alloc]init];
                [datav setObject:@"This group is for food lovers, who are concerned about their health and This group is for food lovers, who are concerned about their health and;" forKey:@"description"];
                  [datav setObject:@"22" forKey:@"member_count"];
                 [datav addEntriesFromDictionary:result];
                CGSize size =[self calculateHeight:[datav objectForKey:@"description"]];
                [datav setObject:[NSString stringWithFormat:@"%f",size.height] forKey:@"height"];
                [groupData addObject:datav];
                [adminNames addObject:result[@"admin_name"]];
                [groupDisplayThumbnails addObject:result[@"display_pic_50"]];
                [groupIds addObject:result[@"group_id"]];
                [groupNames addObject:result[@"group_name"]];
                [groupLocations addObject:result[@"location_name"]];
                [groupTypes addObject:result[@"type"]];
                [popularityFactor addObject:result[@"popularity"]];
                
            }
            
            [GroupsListTable reloadData];
            [HUD hide:YES];
        }
        
    }
    
    if (connection == initiateGroupJoinConn) {
        NSLog(@"====EVENTS");
        NSString *str1 = [[NSMutableString alloc] initWithData:initiateGroupJoinResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str1);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str1];
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
            
        }
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag=1;
            [alert show];
        }
        
        
        //initiateGroupJoinConn=nil;
        
        //[initiateGroupJoinConn cancel];
        
    }
    if (connection == addGroupConn) {
        NSLog(@"====EVENTS");
        NSString *str1 = [[NSMutableString alloc] initWithData:addGroupResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str1);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        
        NSDictionary *res= [jsonparser objectWithString:str1];
        
        NSLog(@" result %@",res);
        
        NSDictionary *response= res[@"response"];
        NSMutableArray *adminIdList= [[NSMutableArray alloc]init];
        
        adminIdList=response[@"admin_ids"];
        
        NSLog(@"admin id list: %@",adminIdList);
        
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        NSLog(@"status = %@ error =  %@",status,error);
        if ([status isEqualToString:@"0"]){
            
            [HUD hide:YES];
            
            [selectIDS removeObject:selectedGroupId];
            
           
            
            NSString *checkIfGroupExists=[NSString stringWithFormat:@"select * from group_invitations where group_id=%@",selectedGroupId];
            BOOL groupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfGroupExists];
            if (groupExistOrNot) {
                NSString *updateQuery=[NSString stringWithFormat:@"update  group_invitations set group_id = '%@', group_name = '%@', group_pic = '%@', group_type ='%@' where group_id = '%@' ",selectedGroupId,[selectedGroupName normalizeDatabaseElement],selectedGroupPic,selectedGroupType,selectedGroupId];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateQuery];
            }
            else
            {
                
                NSString *insertQuery=[NSString stringWithFormat:@"insert into group_invitations (group_id, group_name, group_pic, group_type) values ('%@','%@','%@','%@')",selectedGroupId,[selectedGroupName normalizeDatabaseElement],selectedGroupPic,selectedGroupType];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
            }
            
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            for (int j=0; j<[adminIdList count]; j++)
            {
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                
                [attributeDic setValue:[[adminIdList objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *userName=[[DatabaseManager getSharedInstance]getAppUserName];
                NSString *body=[NSString stringWithFormat:@"%@ want to join your group %@",userName,selectedGroupName  ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                //[elementDic setValue:@"1" forKey:@"grpUpdate"];
                
                [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
                // if ([[memberId objectAtIndex:j]isEqualToString:userID])
                //   [elementDic setValue:@"1" forKey:@"grpDelete"];
                //  if ([userID isEqual:[memberId objectAtIndex:j]] ) {
                [elementDic setValue:@"1" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"is_notify"];
                // }
                //  else
                //  {
                //     [elementDic setValue:@"0" forKey:@"is_notify"];
                //      [elementDic setValue:@"0" forKey:@"show_notification"];
                //  }
                [elementDic setValue:@"1" forKey:@"isgroup"];
                // NSLog(@"gid %@",groupId);
                //  [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
                
                
            }
            
            if(selectIDS.count==0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Group has been added to your profile."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegateObj setTabBar];
            }
            //ChatScreen *chatScreen = [[ChatScreen alloc]init];
            //    chatScreen.chatType = @"group";
            //    chatScreen.chatTitle=selectedGroupName;
            //    [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[selectedGroupId integerValue],(NSString*)jabberUrl]];
            
            //     chatScreen.groupType=selectedGroupType ;
            //    [chatScreen retreiveHistory:nil];
            
            
        }
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        
        addGroupConn=nil;
        
        [addGroupConn cancel];
        
    }
    if (connection == addFavGroupConn) {
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:addFavGroupResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        NSLog(@"end connection");
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        NSDictionary *group=results[@"Group_Details"];
        NSString *status=results[@"status"];
        NSLog(@"status: %@",status);
        NSLog(@"groups: %@", group);
        NSDictionary *members=group[@"member_details"];
        NSLog(@"members: %@",members);
        NSDictionary *deletedMembers = group[@"deleted_members"];
        NSLog(@"deleted members%@",deletedMembers);
        NSString *error=results[@"error"];
        
        XMPPPresence *presence = [XMPPPresence presenceWithType:nil to:[XMPPJID jidWithString:[NSString stringWithFormat:@"group_%@@%@/user_%@",group[@"id"],groupJabberUrl,_registrationID]]];
        [presence addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"user_%@@%@",_registrationID,jabberUrl]];
        NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
        [presence addChild:x];
        [[self appDelegate].xmppStream sendElement:presence];
        
        if (![status isEqualToString:@"1"])
        {
            
            NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",group[@"id"]];
            BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
            if (publicGroupExistOrNot) {
                NSString *updatePublicGroup=[NSString stringWithFormat:@"update  groups_public set group_server_id = '%@', location_name = '%@', category_name = '%@', added_date ='%@',is_favourite ='1', group_name ='%@', group_type='%@', group_pic='%@', group_description='%@', total_members='%@' where group_server_id = '%@' ",group[@"id"],group[@"location_name"],group[@"category_name"],group[@"creation_date"],[group[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],group[@"group_type"],group[@"group_pic"],[group[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],group[@"member_count"],group[@"id"]];
                NSLog(@"query %@",updatePublicGroup);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updatePublicGroup];
            }
            else
            {
                
                NSString *insertPublicGroup=[NSString stringWithFormat:@"insert into groups_public (group_server_id, location_name, category_name, added_date,is_favourite, group_name,group_type, group_pic,group_description,total_members) values ('%@','%@','%@','%@','%d','%@','%@','%@','%@','%@')",group[@"id"],group[@"location_name"],group[@"category_name"],group[@"creation_date"],1,[group[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],group[@"group_type"],group[@"group_pic"],[group[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],group[@"member_count"]];
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
                    NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted!=1",group[@"id"],member[@"user_id"]];
                    BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                    if (memberExistOrNot) {
                        NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set group_id = '%@', contact_id = '%@', is_admin = '%@', contact_name ='%@', contact_location ='%@', contact_image='%@' where group_id = '%@' and contact_id='%@' ",group[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"],group[@"id"],member[@"user_id"]];
                        NSLog(@"query %@",updateMembers);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                    }
                    else
                    {
                        
//                        NSString *insertMembers=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",group[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],member[@"location_name"],member[@"profile_pic"]];
//                        NSLog(@"query %@",insertMembers);
//                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertMembers];
                    }
                    //download image and save in the cache
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
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
                    NSString *checkIfMemberToDeleteExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@ and deleted!=1",group[@"id"],deletedMember];
                    BOOL memberToDeleteExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberToDeleteExists];
                    if (memberToDeleteExistOrNot) {
                        // NSString *deleteMemberQuery=[NSString stringWithFormat:@"delete from group_members where group_id=%@ and contact_id=%@ ",group[@"id"],deletedMember];
                        // NSLog(@"query %@",deleteMemberQuery);
                        NSString *updateMemberQuery=[NSString stringWithFormat:@"update group_members set deleted=1 where group_id=%@ and contact_id=%@ ",group[@"id"],deletedMember];
                        NSLog(@"query %@",updateMemberQuery);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMemberQuery];
                    }
                    
                }
            }
            
            //download image and save in the cache
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,group[@"group_pic"]]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",group[@"group_pic"]]];
                    NSLog(@"member pic path=%@",memberPicPath);
                    //Writing the image file
                    [imgData writeToFile:memberPicPath atomically:YES];
                    
                    
                });
                
            });
            
            [HUD hide:YES];
            //ChatScreen *chatScreen = [[ChatScreen alloc]init];
            NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and deleted!=1",group[@"id"]]];
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
                NSString *body=[NSString stringWithFormat:@"Your request to join %@ has been accepted",group[@"group_name"] ];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                [elementDic setValue:@"0" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",group[@"id"]);
                [elementDic setValue:group[@"id"] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            
            
             ChatScreen *chatScreen = [[ChatScreen alloc]init];
          //  chatScreen.chatType = @"group";
           // chatScreen.chatTitle=group[@"group_name"];
//            [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[group[@"id"] integerValue],(NSString*)jabberUrl]];
//            
//            chatScreen.groupType=group[@"group_type"] ;
//            [chatScreen retreiveHistory:nil];
//            
//            [self.navigationController pushViewController:chatScreen animated:YES];
           
           chatScreen.chatType = @"group";
            chatScreen.chatTitle=[group[@"group_name"] normalizeDatabaseElement];
            [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[group[@"id"] integerValue],(NSString*)jabberUrl]];
            
            chatScreen.groupType=group[@"group_type"] ;
            if ([chatScreen.chatHistory count]==0)
                [chatScreen retreiveHistory:nil];
            [self appDelegate].currentUser=@"";
            
            [selectIDS removeObject:group[@"id"]];
            
            if(selectIDS.count==0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Group has been added to your profile."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegateObj setTabBar];
            }
           
           
            
        }
        
        else
        {
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
//        addFavGroupConn=nil;
//        
//        [addFavGroupConn cancel];
    }
    
    
}

//uialertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",selectedGroupId,[[DatabaseManager getSharedInstance]getAppUserID]];
            NSLog(@"$[%@]",postData);
            
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/private_grp_request.php",gupappUrl]]];
            
            [request setHTTPMethod:@"POST"];
            
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            
            addGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            
            [addGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            
            [addGroupConn start];
            
            addGroupResponse = [[NSMutableData alloc] init];
        }
        
    }
    
}


-(IBAction)skip:(id)sender
{
   
    AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegateObj setTabBar];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
}
-(IBAction)done:(id)sender
{

    [self joinAllGroup];
    
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
    
}


-(void)joinAllGroup{
    
    [self setActivityIndicator];
    
    NSMutableArray *users= [[NSMutableArray alloc] init];
    
    NSMutableArray *privateg= [[NSMutableArray alloc] init];
    
    NSMutableArray *publicg= [[NSMutableArray alloc] init];
    
    [selectedGroup enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSInteger row = [obj integerValue];
        
        
        if ([[groupTypes objectAtIndex:row]isEqualToString:@"private#local"]||[[groupTypes objectAtIndex:row]isEqualToString:@"private#global"]) {
            
            [privateg addObject:[groupIds objectAtIndex:row]];
        }
        else
        {
            
            [publicg addObject:[groupIds objectAtIndex:row]];
            
        }

       
        
        if(idx==selectedGroup.count-1){
            
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
            AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
            
            NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
            
            [requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
            [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            manager.responseSerializer = responseSerializer;
            manager.requestSerializer = requestSerializer;
            manager.requestSerializer.timeoutInterval = 60*4;
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            [data setValue:privateg forKey:@"private_group"];
            [data setValue:publicg forKey:@"public_group"];
            [data setValue:users forKey:@"users"];
            [data setValue:[[DatabaseManager getSharedInstance]getAppUserID] forKey:@"user_id"];
            
            NSString *url =[NSString stringWithFormat:@"%@/scripts/multi_group_user_join.php",gupappUrl];
            [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [HUD hide:YES];
//                NSData * data = (NSData*)responseObject;
//                NSError *error = nil;
//                //NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                
               
                
                AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegateObj setTabBar];

                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [HUD hide:YES];
                
            }];
            
            
        }
        
    }];
    
}


@end
