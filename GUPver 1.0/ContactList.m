//
//  ContactList.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/16/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ContactList.h" 
#import "AppDelegate.h"
#import "userContactCell.h"
#import "ShareGroupInfo.h"
#import "DatabaseManager.h"
#import "JSON.h"
#import "ChatScreen.h"
@interface ContactList ()

@end

@implementation ContactList
@synthesize chatWithUserID;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)setBehaviourOfContactList:(NSString*)type from:(id)instance
{
    Instance=instance;
    CLtype=type;
}
@synthesize groupStatus,groupId,groupName,hideUnhideSkipDoneButton,memberID,viewType;
-(void)getProfileData
{
    DatabaseManager *getProfile;   //Get Profile Data From DATABASEMANAGER
    getProfile = [[DatabaseManager alloc] init];
    NSArray *getData = [[NSMutableArray alloc]init];
    getData=[getProfile getProfileData];
    myImage =getData[4];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    memberID=[[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
    if (![CLtype isEqualToString:@"vcard"])
        self.navigationItem.hidesBackButton = YES;
    NSLog(@"group status:%@",groupStatus);
    NSLog(@"group id:%@",groupId);
    [self getProfileData];
    
    UITextField *txfSearchField = [search valueForKey:@"_searchField"];
    txfSearchField.layer.cornerRadius =10.0;
    txfSearchField.layer.borderWidth =1.0f;
    txfSearchField.layer.borderColor =  [[UIColor colorWithRed:138/255.0 green:155/255.0 blue:160/255.0 alpha:1] CGColor];
    //[self setActivityIndicator];
    //[self listCategories];
    
    txfSearchField.font = [UIFont fontWithName:@"Dosis-Regular" size:17.0f];
    

    if ([groupStatus isEqualToString:@"private#local"]||[groupStatus isEqualToString:@"private#global"])
    {
        self.title = @"Add Members";
    }
    else if ([groupStatus isEqualToString:@"public#global"]|| [groupStatus isEqualToString:@"public#local"])
    {
        self.title = @"Invite Contacts";
    }
    else if ([CLtype isEqualToString:@"vcard"])
    {
        self.title = @"Contacts";
    }
    else
    {
        self.title = @"Invite Contacts";
    }
    
    if ([hideUnhideSkipDoneButton isEqualToString:@"hide"]) {
        // CGRect framee=contactListTable.frame;
        // framee.size.height+=90;
        //[contactListTable setFrame:CGRectMake(0, 0, 300, 500)];
        if ([viewType isEqualToString:@"Explore"]) {
            [contactListTable setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
        }
        else
        {
            [contactListTable setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
        }
        
        self.navigationItem.hidesBackButton = NO;
        // add add group button to the bar
        if ([groupStatus isEqualToString:@"private#local"]||[groupStatus isEqualToString:@"private#global"] || [groupStatus isEqualToString:@"private"])
        {
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                          initWithTitle:@"Add"
                                          style:UIBarButtonItemStyleBordered
                                          target:self
                                          action:@selector(addMembers:)];
            [addButton setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [UIColor colorWithRed:255/255.0 green:207/255.0 blue:13/255.0 alpha:1], NSForegroundColorAttributeName,[UIFont fontWithName:@"Dosis-Bold" size:20.0],NSFontAttributeName,nil]
                                        forState:UIControlStateNormal];

            self.navigationItem.rightBarButtonItem = addButton;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
        }
        else if ([groupStatus isEqualToString:@"public#global"]|| [groupStatus isEqualToString:@"public#local"] || [groupStatus isEqualToString:@"public"])
        {
            UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Invite"
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(inviteMembers:)];
            [inviteButton setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [UIColor colorWithRed:255/255.0 green:207/255.0 blue:13/255.0 alpha:1], NSForegroundColorAttributeName,[UIFont fontWithName:@"Dosis-Bold" size:20.0],NSFontAttributeName,nil]
                                   forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = inviteButton;
            self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
        }
        
        
        
    }
    else
    {
        
        
        skip = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
        [skip setTitle:@"Skip" forState:UIControlStateNormal];
        [skip addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
        [skip setTitleColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1] forState:UIControlStateNormal];
        skip.titleLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:20];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:skip];
        
        done = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [done addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        [done setTitleColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1] forState:UIControlStateNormal];
        done.titleLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:20];
        
        
        done.hidden = YES;
        
        [contactListTable setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-140)];
        
        self.navigationItem.hidesBackButton = YES;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    contactId = [[NSMutableArray alloc]init];
    contactNames = [[NSMutableArray alloc]init];
    contactThumbnails = [[NSMutableArray alloc]init];
    contactLocation = [[NSMutableArray alloc]init];
    type = [[NSMutableArray alloc]init];
    
    tempContactId = [[NSMutableArray alloc]init];
    tempContactName = [[NSMutableArray alloc]init];
    tempContactLocation = [[NSMutableArray alloc]init];
    tempContactsThumbnails = [[NSMutableArray alloc]init];
    tempType = [[NSMutableArray alloc]init];
    
    selectedContacts = [[NSMutableArray alloc]init];
    selectedContactNames = [[NSMutableArray alloc]init];
    selectedContactLocation = [[NSMutableArray alloc]init];
    selectedCells = [[NSMutableArray alloc]init];
    selectedContactImage = [[NSMutableArray alloc]init];
    selectedType = [[NSMutableArray alloc]init];
    
    [tempContactId removeAllObjects];
    [tempContactLocation removeAllObjects];
    [tempContactName removeAllObjects];
    [tempContactsThumbnails removeAllObjects];
    [tempType removeAllObjects];
    
    conId = [[NSMutableArray alloc]init];
    conName = [[NSMutableArray alloc]init];
    conImage = [[NSMutableArray alloc]init];
    conLocation = [[NSMutableArray alloc]init];
    selectedRosterArray= [[NSMutableArray alloc]init];
    
    NSMutableArray *contactList = [[NSMutableArray alloc]init];
    contactList = [[DatabaseManager getSharedInstance]getContactList];
    
    if([contactList count]>0){
        for(int i=0;i<[contactList count];i++)
        {
            
            NSMutableArray *contacts = [contactList objectAtIndex:i];
            //NSLog(@"getcategory categories %@\n",categories);
            if ([CLtype isEqualToString:@"vcard"])
            {
                NSLog(@"contacts %@\n chatWithUser%@",[contacts objectAtIndex:0],chatWithUserID);
                if (![[contacts objectAtIndex:0] isEqual:chatWithUserID]) {
                    
                    [tempContactId addObject:[contacts objectAtIndex:0]];
                    [tempContactName addObject:[contacts objectAtIndex:1]];
                    [tempContactsThumbnails addObject:[contacts objectAtIndex:2]];
                    [tempContactLocation addObject:[contacts objectAtIndex:3]];
                    [tempType addObject:@"user"];
                }
            }
            else
            {
                [self getMembersList];
                if (![membersID containsObject:[contacts objectAtIndex:0]])
                {
                    [tempContactId addObject:[contacts objectAtIndex:0]];
                    [tempContactName addObject:[contacts objectAtIndex:1]];
                    [tempContactsThumbnails addObject:[contacts objectAtIndex:2]];
                    [tempContactLocation addObject:[contacts objectAtIndex:3]];
                    [tempType addObject:@"user"];
                }
                
            }
        }
    }
    else
    {
        NSLog(@"no contacts");
    }
    if ([groupStatus isEqualToString:@"private#local"]||[groupStatus isEqualToString:@"private#global"] || [groupStatus isEqualToString:@"private"])
    {
        
      //  [self getPrivateGroupList];
        [tempContactId addObjectsFromArray:grpID];
        [tempContactName addObjectsFromArray:grpNAME];
        [tempContactsThumbnails addObjectsFromArray:grpPIC];
        [tempContactLocation addObjectsFromArray:grpCAT];
        [tempType addObjectsFromArray:grpTYPE];
    }
    NSLog(@"tempcontact id %@",tempContactId);
    NSLog(@"tempcontact name %@",tempContactName);
    NSLog(@"tempcontact thumbnail %@",tempContactsThumbnails);
    NSLog(@"tempcontact location %@",tempContactLocation);
    NSLog(@"tempcontact type %@",tempType);
    
    [contactId removeAllObjects];
    [contactNames removeAllObjects];
    [contactThumbnails removeAllObjects];
    [contactLocation removeAllObjects];
    [type removeAllObjects];
    [contactId addObjectsFromArray:tempContactId];
    [contactNames addObjectsFromArray:tempContactName];
    [contactThumbnails addObjectsFromArray:tempContactsThumbnails];
    [contactLocation addObjectsFromArray:tempContactLocation];
    [type addObjectsFromArray:tempType];
    
    
    
    if ([CLtype isEqualToString:@"vcard"])
    {
        skip.hidden=true;
        done.hidden=true;
        [contactListTable setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44-49)];
        self.navigationItem.hidesBackButton = NO;
    }
    
}

-(void)getPrivateGroupList
{
    NSArray *groupArray =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select group_server_id,group_name,group_pic,category_name,group_type from groups_private where created_by like '%@'",[[DatabaseManager getSharedInstance]getAppUserName]]];
    
    grpID=[[NSMutableArray alloc]init];
    grpNAME=[[NSMutableArray alloc]init];
    grpPIC=[[NSMutableArray alloc]init];
    grpCAT=[[NSMutableArray alloc]init];
    grpTYPE=[[NSMutableArray alloc]init];
    
    for (int i=0; i<[groupArray count];i++)
        
    {
        if (![[[groupArray objectAtIndex:i] objectForKey:@"GROUP_SERVER_ID"] isEqualToString:groupId]) {
            [grpID addObject:[[groupArray objectAtIndex:i] objectForKey:@"GROUP_SERVER_ID"]];
            [grpNAME addObject:[[groupArray objectAtIndex:i] objectForKey:@"GROUP_NAME"]];
            [grpPIC addObject:[[groupArray objectAtIndex:i] objectForKey:@"GROUP_PIC"]];
            [grpCAT addObject:[[groupArray objectAtIndex:i] objectForKey:@"CATEGORY_NAME"]];
            [grpTYPE addObject:[[groupArray objectAtIndex:i] objectForKey:@"GROUP_TYPE"]];
        }
        
    }
    
    NSLog(@"grpID %@",grpID);
    NSLog(@"grpNAME %@",grpNAME);
    NSLog(@"grpPIC %@",grpPIC);
    NSLog(@"grpCAT %@",grpCAT);
    NSLog(@"grpTYPE %@",grpTYPE);
    
}
-(void)getMembersList

{
    
    NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ AND deleted =0",groupId]];
    
    membersID=[[NSMutableArray alloc]init];
    
    for (int i=0; i<[tempmembersID count];i++)
        
    {
        
        [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
        
    }
    
    NSLog(@"membersID %@",membersID);
    
}
-(void)getmemberDetails:(NSString*)selectedGroupID

{
    
    NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id,contact_name,contact_location,contact_image from group_members where group_id=%@ AND deleted =0",selectedGroupID]];
    
    
    for (int i=0; i<[tempmembersID count];i++)
        
    {
        if (![conId containsObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]]) {
            [conId addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
            [conName addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_NAME"]] ;
            [conImage addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_IMAGE"]] ;
            [conLocation addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_LOCATION"]] ;
        }
        
    }
    
    
    
    
    NSLog(@"selected contacts:%@",selectedContacts);
    NSLog(@"selected contacts name:%@",selectedContactNames);
    NSLog(@"selected contacts location:%@",selectedContactLocation);
    NSLog(@"slected celss:%@",selectedCells);
    NSLog(@"type slected celss:%@",selectedType);
    
}





-(void)addMembers:(id)sender
{
    [self addMembersToGroup];
    // CreateGroup *addGroupPage = [[CreateGroup alloc]init];
    //[self.navigationController pushViewController:addGroupPage animated:YES];
}
-(void)inviteMembers:(id)sender
{
    NSLog(@"selcted contacts for public group:%@ msg %@ gid %@",selectedContacts,groupName,groupId);
    //HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //HUD.delegate = self;
    //HUD.dimBackground = YES;
    //HUD.labelText = @"Please Wait";
    if ([selectedContacts count] == 0) {
        NSLog(@"Please select users");
        //[HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please choose members."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
    else
    {
        //send messages via chat
        NSLog(@"selcted contacts for public group:%@ msg %@ gid %@",selectedContacts,groupName,groupId);
        ChatScreen *sendInvitation=[[ChatScreen alloc]init];
        NSString *timeInMiliseconds=[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
        sendInvitation.timeInMiliseconds=timeInMiliseconds;
        sendInvitation.chatType = @"personal";
         NSArray *master_table1=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name,logged_in_user_id,chat_wall_paper from master_table"];
        
        for (int i=0;i<[selectedContacts count]; i++)
        {
            NSString *msgToBesend=[NSString stringWithFormat:@"You are invited to join the group %@. To join the group, just search for the group under Explore and select the group.$$$%@",groupName,groupId];
            msgToBesend =[msgToBesend stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *goodValue=[msgToBesend UTFEncoded];
            NSString *groupID=@"";//[chatType isEqual:@"personal"]?@"":[chatWithUser userID];
            BOOL isThisGroupChat=false;//[chatType isEqual:@"group"]?true:false;
            NSString *recieversID=[NSString stringWithFormat:@"user_%@@%@",[selectedContacts objectAtIndex:i],jabberUrl];
           
            [[self appDelegate] storeMessageInDatabaseForBody:goodValue forMessageType:@"text" messageTo:recieversID groupId:groupID isGroup:isThisGroupChat forTimeInterval:timeInMiliseconds senderName:[[master_table1 objectAtIndex:0] objectForKey:@"DISPLAY_NAME"] postid:nil isRead:@"1" withImage:myImage];
            NSString *messageid=[[self appDelegate] CheckIfMessageExist:[goodValue stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:@"text"];
            // NSString *recieversID=[chatWithUser userID];
            //  if([chatType isEqual:@"group"])
            //     recieversID=groupID;
            //  else
            //      recieversID=[jid userID];
            NSString *referanceID=  [[self appDelegate] getLinkedIdOfMessageID:messageid forTimestamp:timeInMiliseconds senderID:[self appDelegate].myUserID recieversID:[recieversID userID] chattype:@"text"];
            [[self appDelegate] sendAcknoledgmentPacketId:referanceID isGroupAcknoledgment:isThisGroupChat];
            NSLog(@"%@",groupName);
            [sendInvitation sendMessageWithReceiversJid:[NSString stringWithFormat:@"user_%@@%@",[selectedContacts objectAtIndex:i],jabberUrl] message:[NSString stringWithFormat:@"You are invited to join the group %@. To join the group, just search for the group under Explore and select the group.$$$%@",groupName,groupId] type:@"text" groupId:@"" withReference:referanceID];
            
        }
        [selectedCells removeAllObjects];
        [selectedContacts removeAllObjects];
        [contactListTable reloadData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Invite have been sent."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        //[HUD hide:YES];
        //[self.navigationController popViewControllerAnimated:NO];
        
    }
    
    
    
}


-(void)openHomePage:(id)sender
{
    //FirstViewController *openHomePage = [[FirstViewController alloc]init];
    //[self.navigationController pushViewController:openHomePage animated:NO];
    AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegateObj setTabBar];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
}
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [contactId count];
    
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*static NSString *CellIdentifier = @"Cell Identifier";
     //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     
     
     if (cell == nil) {
     
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
     
     //cell.selectionStyle = UITableViewCellSelectionStyleNone;
     
     }*/
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    userContactCell *cell= (userContactCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[userContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    
    NSMutableDictionary *data =[[NSMutableDictionary alloc]init];
    [data setObject:[contactNames objectAtIndex:indexPath.row] forKey:@"name"];
    [data setObject:contactThumbnails[indexPath.row] forKey:@"image"];
    [data setObject:[contactLocation objectAtIndex:indexPath.row] forKey:@"location"];
    [cell drawCell:data withIndex:indexPath.row];
   
    
    if ( [selectedCells containsObject:[contactId objectAtIndex:indexPath.row]]  )
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSNumber *rowNsNum = [NSNumber numberWithUnsignedInt:indexPath.row];
    if ([CLtype isEqualToString:@"vcard"]){
        NSDictionary *userDetail=[[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select user_email,user_name,user_pic,user_status,user_location from contacts where user_id =%i",[[tempContactId objectAtIndex:indexPath.row] integerValue]]]objectAtIndex:0];
        [Instance sendVcardforUserID:[tempContactId objectAtIndex:indexPath.row] user_email:[userDetail objectForKey:@"USER_EMAIL"] userName:[userDetail objectForKey:@"USER_NAME"] user_pic:[userDetail objectForKey:@"USER_PIC"] user_status:[userDetail objectForKey:@"USER_STATUS"] user_location:[userDetail objectForKey:@"USER_LOCATION"]]  ;
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        if ([groupStatus isEqualToString:@"private#local"]||[groupStatus isEqualToString:@"private#global"] || [groupStatus isEqualToString:@"private"])
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell.accessoryType== UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                int index=[selectedContacts indexOfObject:[contactId objectAtIndex:indexPath.row]];
                NSLog(@"index %i",index);
                [selectedContacts removeObjectAtIndex:index];
                [selectedContactNames removeObjectAtIndex:index];
                [selectedCells removeObjectAtIndex:index];
                [selectedContactLocation removeObjectAtIndex:index];
                [selectedContactImage removeObjectAtIndex:index];
                [selectedType removeObjectAtIndex:index];
                [selectedRosterArray removeObject:[rosterArray objectAtIndex:indexPath.row]];
            }else{
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [selectedContacts addObject:[contactId objectAtIndex:indexPath.row]];
                [selectedContactNames addObject:[contactNames objectAtIndex:indexPath.row]];
                [selectedContactLocation addObject:[contactLocation objectAtIndex:indexPath.row]];
                [selectedCells addObject:[contactId objectAtIndex:indexPath.row]];
                [selectedContactImage addObject:[contactThumbnails objectAtIndex:indexPath.row]];
                [selectedType addObject:[type objectAtIndex:indexPath.row]];
                
                //NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
                //NSMutableArray *indexPaths = [[NSMutableArray alloc]init];
                //[indexPaths addObject:indexPath];
                //NSLog(@"indexPaths:%@",indexPaths);
            }
        }
        else
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell.accessoryType== UITableViewCellAccessoryCheckmark) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                int index=[selectedContacts indexOfObject:[contactId objectAtIndex:indexPath.row]];
                NSLog(@"index %i",index);
                [selectedContacts removeObjectAtIndex:index];
                [selectedContactNames removeObjectAtIndex:index];
                [selectedCells removeObjectAtIndex:index];
                [selectedContactLocation removeObjectAtIndex:index];
                [selectedContactImage removeObjectAtIndex:index];
                [selectedType removeObjectAtIndex:index];
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [selectedContacts addObject:[contactId objectAtIndex:indexPath.row]];
                [selectedContactNames addObject:[contactNames objectAtIndex:indexPath.row]];
                [selectedCells addObject:[contactId objectAtIndex:indexPath.row]];
                [selectedContactLocation addObject:[contactLocation objectAtIndex:indexPath.row]];
                [selectedContactImage addObject:[contactThumbnails objectAtIndex:indexPath.row]];
                [selectedType addObject:[type objectAtIndex:indexPath.row]];
            }
            
        }
        
        if (![hideUnhideSkipDoneButton isEqualToString:@"hide"] && selectedContacts.count>0) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:done];
            
            done.hidden =NO;
        }else if (![hideUnhideSkipDoneButton isEqualToString:@"hide"] && selectedContacts.count==0){
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:skip];
            
            done.hidden =YES;

        }
        //[selectedCells removeAllObjects];
        // [selectedCells addObjectsFromArray:tempSelectedCells];
        NSLog(@"selected contacts:%@",selectedContacts);
        NSLog(@"selected contacts name:%@",selectedContactNames);
        NSLog(@"selected contacts location:%@",selectedContactLocation);
        NSLog(@"slected celss:%@",selectedCells);
        NSLog(@"type slected celss:%@",selectedType);
    }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    
}


// search bar delegates


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchbartextdidbeginediting");
    searchBar.showsCancelButton=TRUE;
    
}
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"User searched for %@", searchText);
    
    if([searchBar.text length]==0)
    {
        
        isFiltered = FALSE;
        [contactId removeAllObjects];
        [contactNames removeAllObjects];
        [contactThumbnails removeAllObjects];
        [contactLocation removeAllObjects];
        [type removeAllObjects];
        // [selectedCells removeAllObjects];
        
        
        [contactId addObjectsFromArray:tempContactId];
        [contactNames addObjectsFromArray:tempContactName];
        [contactThumbnails addObjectsFromArray:tempContactsThumbnails];
        [contactLocation addObjectsFromArray:tempContactLocation];
        [type addObjectsFromArray:tempType];
        
        //[selectedCells addObjectsFromArray:tempSelectedCells];
        
    }
    else
    {
        isFiltered = TRUE;
        [contactId removeAllObjects];
        [contactNames removeAllObjects];
        [contactThumbnails removeAllObjects];
        [contactLocation removeAllObjects];
        [type removeAllObjects];
        //[selectedCells removeAllObjects];
        
        int i =0;
        for (NSString *string in tempContactName) {
            NSRange r=[string rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
            if(r.location!=NSNotFound)
            {
                //[displayItems addObject:string];
                [contactId addObject:[tempContactId objectAtIndex:i]];
                [contactNames addObject:[tempContactName objectAtIndex:i]];
                [contactThumbnails addObject:[tempContactsThumbnails objectAtIndex:i]];
                [contactLocation addObject:[tempContactLocation objectAtIndex:i]];
                [type addObject:[tempType objectAtIndex:i]];
                //[selectedCells addObject:[tempSelectedCells objectAtIndex:i]];
                
            }
            i++;
        }
    }
    if (contactId.count == 0)
    {
        NSLog(@"No results found.");
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Match not found."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alert show];*/
        
    }
    
    [contactListTable reloadData];
    
    
}



- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    searchBar.showsCancelButton=FALSE;
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
}

-(IBAction)skip:(id)sender
{
    ShareGroupInfo *shareGroupInfoPage = [[ShareGroupInfo alloc]init];
    shareGroupInfoPage.groupId = groupId;
    shareGroupInfoPage.groupName = groupName;
    shareGroupInfoPage.groupJID = _groupJID;
    shareGroupInfoPage.groupType=groupStatus;
    [self.navigationController pushViewController:shareGroupInfoPage animated:YES];

    
    
}
-(IBAction)done:(id)sender
{
    [self addMembersToGroup];
    
}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == addMembersConn) {
        
        [addMembersResponse setLength:0];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == addMembersConn) {
        
        [addMembersResponse appendData:data];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == addMembersConn) {
        NSString *str = [[NSMutableString alloc] initWithData:addMembersResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *response= res[@"response"];
        
        int status =[response[@"error"] integerValue];
        
        //NSString *statusMsg = response[@"error_mess"];
        
        if (status==1)
            
        {
            [HUD hide:YES];
            //[activityIndicator stopAnimating];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:response[@"error_mess"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            
        }else{
            
            if([hideUnhideSkipDoneButton isEqualToString:@"hide"])
                [memberID addObjectsFromArray:selectedContacts];
            else
                [memberID addObjectsFromArray:selectedContacts];
            NSLog(@"%@ count %i",selectedContacts,[selectedContacts count]);
            for (int j=0; j<[memberID count]; j++){
                NSLog(@"%@ %@",memberID,memberID[j]);
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[memberID objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                
                NSString *body=[NSString stringWithFormat:@"You have been added to the group %@ by %@",groupName,[[DatabaseManager getSharedInstance]getAppUserName]];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"show_notification"];
                [elementDic setValue:@"1" forKey:@"is_notify"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                
                [elementDic setValue:@"1" forKey:@"isgroup"];
                NSLog(@"gid %@",groupId);
                [elementDic setValue:groupId forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
            
            for (int k=0; k<selectedContacts.count; k++){
                
                NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@",groupId,selectedContacts[k]];
                BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                if (!memberExistOrNot) {
//                    NSString *subQuery=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%d','%@','%@','%@')",groupId,selectedContacts[k],0,[selectedContactNames[k] normalizeDatabaseElement],selectedContactLocation[k],selectedContactImage[k]];
                    
//                    NSLog(@"sub query %@",subQuery);
//                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:subQuery];
                    
                }
                else{
                    NSString *subQuery=[NSString stringWithFormat:@"update group_members set deleted = 0 where group_id=%@ and contact_id=%@" ,groupId,selectedContacts[k]];
                    
                    NSLog(@"sub query %@",subQuery);
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:subQuery];
                    
                }
                
                
            }
            [self inviteUserInGroup];
            int groupMembersCount=[[DatabaseManager getSharedInstance]countGroupMembers:groupId];
            NSString *updateQuery;
            if ([groupStatus isEqualToString:@"private#local"]||[groupStatus isEqualToString:@"private#global"] ||[groupStatus isEqualToString:@"private"]){
                
                updateQuery=[NSString stringWithFormat:@"update  groups_private set total_members = '%d' where group_server_id = '%@' ",groupMembersCount,groupId];
            }
            NSLog(@"update query %@",updateQuery);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateQuery];
            
            [HUD hide:YES];
            if ([hideUnhideSkipDoneButton isEqualToString:@"hide"]) {
                [self.navigationController popViewControllerAnimated:YES ];
            }else{
                ShareGroupInfo *shareGroupInfoPage = [[ShareGroupInfo alloc]init];
                shareGroupInfoPage.groupId = groupId;
                shareGroupInfoPage.groupName = groupName;
                shareGroupInfoPage.groupJID = _groupJID;
                shareGroupInfoPage.groupType=groupStatus;
                [self.navigationController pushViewController:shareGroupInfoPage animated:YES];
            }
        }
        
        
        addMembersConn=nil;
        
        [addMembersConn cancel];
        
    }
    
}

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(void)addMembersToGroup
{
    NSLog(@"selected contacts:%@",selectedContacts);
    NSLog(@"selected contacts name:%@",selectedContactNames);
    NSLog(@"selected contacts location:%@",selectedContactLocation);
    NSLog(@"slected celss:%@",selectedCells);
    NSLog(@"type slected celss:%@",selectedType);
    
    
    for (int m=0; m< selectedCells.count; m++) {
        if ([selectedType[m]isEqualToString:@"user"]) {
            
            [conId addObject:[selectedContacts objectAtIndex:m]];
            [conName addObject:[selectedContactNames objectAtIndex:m]];
            [conImage addObject:[selectedContactImage objectAtIndex:m]];
            [conLocation addObject:[selectedContactLocation objectAtIndex:m]];
            
        }
        else
        {
            [self getmemberDetails:[selectedCells objectAtIndex:m]];
        }
    }
    NSLog(@"selected contacts:%@",conId);
    NSLog(@"selected contacts name:%@",conName);
    NSLog(@"selected contacts location:%@",conLocation);
    NSLog(@"slected celss:%@",conImage);
    
    [selectedContacts removeAllObjects];
    [selectedContactNames removeAllObjects];
    [selectedContactLocation removeAllObjects];
    [selectedContactImage removeAllObjects];
    
    [selectedContacts addObjectsFromArray:conId];
    [selectedContactNames addObjectsFromArray: conName];
    [selectedContactLocation addObjectsFromArray:conLocation];
    [selectedContactImage addObjectsFromArray:conImage];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    if ([selectedContacts count] == 0) {
        NSLog(@"Please select users");
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please choose members."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
    }else{
        
        if ([groupStatus isEqualToString:@"private#local"]||[groupStatus isEqualToString:@"private#global"] ||[groupStatus isEqualToString:@"private"]) {
            NSString *selectedContactsString = [selectedContacts componentsJoinedByString:@","];
            //NSString *groupMembers = [NSString stringWithFormat:@"[%@]",selectedContactsString];
            
            NSLog(@"selectec string:%@",selectedContactsString);
            NSLog(@"Post variables %@%@",groupId,selectedContactsString);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"group_id=%@&mem_id=%@",groupId,selectedContactsString];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_mem1.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            addMembersConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [addMembersConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [addMembersConn start];
            addMembersResponse = [[NSMutableData alloc] init];
            
        }else{
            self.title = @"Invite Members";
            //send messages via chat
            NSLog(@"selcted contacts for public group:%@ msg %@ gid %@",selectedContacts,groupName,groupId);
            ChatScreen *sendInvitation=[[ChatScreen alloc]init];
            sendInvitation.chatType = @"personal";
            NSString *timeInMiliseconds=[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
            sendInvitation.timeInMiliseconds=timeInMiliseconds;
            //  [self appDelegate].isUSER=1;
            //  detailPage.chatTitle=[tempContactNames objectAtIndex:indexPath.row];
            //  NSLog(@"name %@",[tempContactNames objectAtIndex:indexPath.row]);
            //  id a=  [detailPage initWithUser:[[NSString stringWithFormat:@"user_%@@",[tempContactIds objectAtIndex:indexPath.row]] stringByAppendingString:(NSString*)jabberUrl ] ];
            
             NSArray *master_table1=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name,logged_in_user_id,chat_wall_paper from master_table"];
            for (int i=0;i<[selectedContacts count]; i++){
                
                NSLog(@"%@",groupName);
                NSString *msgToBesend=[NSString stringWithFormat:@"You are invited to join the group %@. To join the group, just search for the group under Explore and select the group.$$$%@",groupName,groupId];
                msgToBesend =[msgToBesend stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *goodValue=[msgToBesend UTFEncoded];
                NSString *groupID=@"";//[chatType isEqual:@"personal"]?@"":[chatWithUser userID];
                BOOL isThisGroupChat=false;//[chatType isEqual:@"group"]?true:false;
                NSString *recieversID=[NSString stringWithFormat:@"user_%@@%@",[selectedContacts objectAtIndex:i],jabberUrl];
                [[self appDelegate] storeMessageInDatabaseForBody:goodValue forMessageType:@"text" messageTo:recieversID groupId:groupID isGroup:isThisGroupChat forTimeInterval:timeInMiliseconds  senderName:[[master_table1 objectAtIndex:0] objectForKey:@"DISPLAY_NAME"] postid:nil isRead:@"1" withImage:myImage];
                NSString *messageid=[[self appDelegate] CheckIfMessageExist:[goodValue stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:@"text"];
                // NSString *recieversID=[chatWithUser userID];
                //  if([chatType isEqual:@"group"])
                //     recieversID=groupID;
                //  else
                //      recieversID=[jid userID];
                NSString *referanceID=  [[self appDelegate] getLinkedIdOfMessageID:messageid forTimestamp:timeInMiliseconds senderID:[self appDelegate].myUserID recieversID:[recieversID userID] chattype:@"text"];
                [[self appDelegate] sendAcknoledgmentPacketId:referanceID isGroupAcknoledgment:isThisGroupChat];
                NSLog(@"%@",groupName);
                
                [sendInvitation sendMessageWithReceiversJid:[NSString stringWithFormat:@"user_%@@%@",[selectedContacts objectAtIndex:i],jabberUrl] message:[NSString stringWithFormat:@"You are invited to join the group %@. To join the group, just search for the group under Explore and select the group.$$$%@",groupName,groupId] type:@"text" groupId:@"" withReference:referanceID];
                
                
            }
            [self inviteUserInGroup];
            [HUD hide:YES];
            ShareGroupInfo *shareGroupInfoPage = [[ShareGroupInfo alloc]init];
            shareGroupInfoPage.groupId = groupId;
            shareGroupInfoPage.groupName = groupName;
            shareGroupInfoPage.groupJID = _groupJID;
            shareGroupInfoPage.groupType=groupStatus;
            [self.navigationController pushViewController:shareGroupInfoPage animated:YES];
            NSLog(@"needs to be done");
        }
        
    }
    
}



-(void)inviteUserInGroup{
 
    for (int k=0; k<selectedContacts.count; k++){
        NSString *recieversID=[NSString stringWithFormat:@"user_%@@%@",[selectedContacts objectAtIndex:k],jabberUrl];
        [self.xmppRoom inviteUser:[XMPPJID jidWithString:recieversID] withMessage:@""];
    }

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
