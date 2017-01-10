//
//  ViewMembers.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 12/9/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ViewMembers.h"
#import "userContactCell.h"
#import "DatabaseManager.h"
#import "ViewContactProfile.h"
#import "JSON.h"
#import "ContactList.h"

@interface ViewMembers ()

@end

@implementation ViewMembers
@synthesize groupId,startLoading,groupType,groupName,viewType;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Members";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"gname:%@",groupName);
    
    expndRow =-1;
    // Do any additional setup after loading the view from its nib.
    selectedGroup  = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view from its nib.
   
   // membersList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSLog(@"grp id:%@",groupId);
    NSLog(@"viewType:%@",viewType);
    if ([viewType isEqualToString:@"Explore"]) {
        [membersList setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
    }
    else
    {
        [membersList setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
    }

    userId = [[NSMutableArray alloc]init];
    displayPic = [[NSMutableArray alloc]init];
    displayName = [[NSMutableArray alloc]init];
    displayLocation = [[NSMutableArray alloc]init];
    tempUserId = [[NSMutableArray alloc]init];
    tempDisplayName = [[NSMutableArray alloc]init];
    tempDisplayPic = [[NSMutableArray alloc]init];
    tempDisplayLocation = [[NSMutableArray alloc]init];
    if ([groupType isEqualToString:@"public#local"] || [groupType isEqualToString:@"public#global"] || [groupType isEqualToString:@"public"]) {
        
//        UIBarButtonItem *inviteMembersButton = [[UIBarButtonItem alloc]
//                                                initWithTitle:@"Invite"
//                                                style:UIBarButtonItemStylePlain
//                                                target:self
//                                                action:@selector(inviteMembers:)];
//        
//        self.navigationItem.rightBarButtonItem = inviteMembersButton;
//        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
        
    }
    
    
    UITextField *txfSearchField = [search valueForKey:@"_searchField"];
    txfSearchField.layer.cornerRadius =10.0;
    txfSearchField.layer.borderWidth =1.0f;
    txfSearchField.layer.borderColor =  [[UIColor colorWithRed:138/255.0 green:155/255.0 blue:160/255.0 alpha:1] CGColor];
    //[self setActivityIndicator];
    //[self listCategories];
    
    txfSearchField.font = [UIFont fontWithName:@"Dosis-Regular" size:17.0f];
    
    
    NSString *checkIfMembersExist;
    checkIfMembersExist=[NSString stringWithFormat:@"select * from group_members where group_id=%@",groupId];
    BOOL membersExist=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMembersExist];
    NSLog(@"bool added %d",membersExist);
    if (membersExist) {
        [tempUserId removeAllObjects];
        [tempDisplayName removeAllObjects];
        [tempDisplayPic removeAllObjects];
        [tempDisplayLocation removeAllObjects];
        
        getData = [[NSMutableArray alloc]init];
        getData = [[DatabaseManager getSharedInstance]getMembersOfGroup:groupId];
        NSLog(@"get data array:%@",getData);
        
        if([getData count]>0){
            for(int i=0;i<[getData count];i++)
            {
                
                NSMutableArray *members = [getData objectAtIndex:i];
                [tempUserId addObject:[members objectAtIndex:0]];
                [tempDisplayName addObject:[members objectAtIndex:1]];
                [tempDisplayPic addObject:[members objectAtIndex:2]];
                [tempDisplayLocation addObject:[members objectAtIndex:3]];
                NSLog(@"user id%@",tempUserId[i]);
                NSLog(@"display name%@",tempDisplayName[i]);
                NSLog(@"display pic%@",tempDisplayPic[i]);
                NSLog(@"display location%@",tempDisplayLocation[i]);
            }
            
        }
        if ([getData count]== 0) {
            NSLog(@"no members");
        }
        [userId removeAllObjects];
        [displayName removeAllObjects];
        [displayPic removeAllObjects];
        [displayLocation removeAllObjects];
        [userId addObjectsFromArray:tempUserId];
        [displayName addObjectsFromArray:tempDisplayName];
        [displayPic addObjectsFromArray:tempDisplayPic];
        [displayLocation addObjectsFromArray:tempDisplayLocation];
        
    }
    else{
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
        HUD.dimBackground = YES;
        HUD.labelText = @"Please Wait";
        [self loadMembersFromServer];
        
    }
    //ios 7
    for(UIView *subView in [search subviews]) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subView setReturnKeyType: UIReturnKeyDone];
        } else {
            for(UIView *subSubView in [subView subviews]) {
                if([subSubView conformsToProtocol:@protocol(UITextInputTraits)]) {
                    [(UITextField *)subSubView setReturnKeyType: UIReturnKeyDone];
                }
            }
        }
        
    }
}

-(void)inviteMembers:(id)sender
{
    ContactList *openContactList = [[ContactList alloc]init];
    //openContactList.memberID=memberId;
    openContactList.hideUnhideSkipDoneButton=@"hide";
    openContactList.groupStatus = groupType;
    openContactList.groupId = groupId;
    openContactList.groupName = groupName;
    openContactList.viewType=viewType;
    [self.navigationController pushViewController:openContactList animated:NO];
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [search resignFirstResponder];
}

#pragma mark Table View Data Source Metho

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [userId count];
    
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    newGroupCell *cell= (newGroupCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[newGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.groupDelegate = self;
    
    
    NSMutableDictionary *data =[[NSMutableDictionary alloc]init];
    [data setObject:[displayName objectAtIndex:indexPath.row] forKey:@"name"];
    [data setObject:displayPic[indexPath.row] forKey:@"thumbnail"];
    [data setObject:[displayLocation objectAtIndex:indexPath.row] forKey:@"bottom_display"];
    [data setObject:@" " forKey:@"description"];
    [data setObject:@"contact" forKey:@"cell_type"];
    NSString *query  = [NSString stringWithFormat:@"select * from contacts where user_id = '%@'",[userId objectAtIndex:indexPath.row]];
    
    BOOL recordExist = [[DatabaseManager getSharedInstance] recordExistOrNot:query];
    
    if (!recordExist) {
        
        [data setObject:@"0" forKey:@"is_exist"];
        
    }else{
        
        [data setObject:@"1" forKey:@"is_exist"];
    }
    
    [cell drawCell:data withIndex:indexPath.row];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    /*ViewContactProfile *viewContact = [[ViewContactProfile alloc]init];
    viewContact.userId=[userId objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewContact animated:YES];*/
    
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
            [userId removeAllObjects];
            [displayName removeAllObjects];
            [displayPic removeAllObjects];
            [displayLocation removeAllObjects];
            
            
            [userId addObjectsFromArray:tempUserId];
            [displayName addObjectsFromArray:tempDisplayName];
            [displayPic addObjectsFromArray:tempDisplayPic];
            [displayLocation addObjectsFromArray:tempDisplayLocation];
           
        }
        else
        {
            isFiltered = TRUE;
            [userId removeAllObjects];
            [displayName removeAllObjects];
            [displayPic removeAllObjects];
            [displayLocation removeAllObjects];
            
            
            int i =0;
            for (NSString *string in tempDisplayName) {
                NSRange r=[string rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if(r.location!=NSNotFound)
                {
                    //[displayItems addObject:string];
                    [userId addObject:[tempUserId objectAtIndex:i]];
                    [displayName addObject:[tempDisplayName objectAtIndex:i]];
                    [displayPic addObject:[tempDisplayPic objectAtIndex:i]];
                    [displayLocation addObject:[tempDisplayLocation objectAtIndex:i]];
                    
                }
                i++;
            }
        }
        if (userId.count == 0)
        {
            NSLog(@"No results found.");
            /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Match not found."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];*/
            
        }
        
        [membersList reloadData];
    
    
}



- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    searchBar.showsCancelButton=FALSE;
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
}


-(void)loadMembersFromServer
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_members.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    viewMembersConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [viewMembersConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [viewMembersConn start];
    viewMembersResponse = [[NSMutableData alloc] init];

}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == viewMembersConn) {
        
        [viewMembersResponse setLength:0];
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == viewMembersConn) {
        
        [viewMembersResponse appendData:data];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == viewMembersConn) {
        
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == viewMembersConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:viewMembersResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        NSDictionary *members=results[@"users"];
        
        NSLog(@"members count %i",[members count]);
        if ([members count]==0 )
        {
            [HUD hide:YES];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                   
                                                             message:@"No members."
                                   
                                                            delegate:nil
                                   
                                                   cancelButtonTitle:@"OK"
                                   
                                                   otherButtonTitles:nil];
            [alert show];
        }
        
        NSLog(@"====EVENTS==3 %@",res);
        [tempUserId removeAllObjects];
        [tempDisplayName removeAllObjects];
        [tempDisplayPic removeAllObjects];
        [tempDisplayLocation removeAllObjects];
        
        for (NSDictionary *result in members)
        {
        NSString *memberId = result[@"user_id"];
        NSString *name = result[@"display_name"];
        NSString *location = result[@"location_name"];
        NSString *memberPic = result[@"profile_pic"];
        
        NSLog(@"member id: %@",memberId);
        NSLog(@"name: %@",name);
        NSLog(@"location: %@",location);
        NSLog(@"display pic: %@",memberPic);
            
        [tempUserId addObject:memberId];
        [tempDisplayName addObject:name];
        [tempDisplayPic addObject:memberPic];
        [tempDisplayLocation addObject:location];
            
        }
        [userId removeAllObjects];
        [displayName removeAllObjects];
        [displayPic removeAllObjects];
        [displayLocation removeAllObjects];
        [userId addObjectsFromArray:tempUserId];
        [displayName addObjectsFromArray:tempDisplayName];
        [displayPic addObjectsFromArray:tempDisplayPic];
        [displayLocation addObjectsFromArray:tempDisplayLocation];
        
        //load images
        for (int k=0; k<displayPic.count; k++) {
            
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,displayPic[k]]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
               // categoryImageView.image = [UIImage imageWithData:imgData];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSLog(@"paths=%@",paths);
                NSString *profilePicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",displayPic[k]]];
                NSLog(@"profile pic path=%@",profilePicPath);

                //Writing the image file
                [imgData writeToFile:profilePicPath atomically:YES];
                
                
            });
            
        });
        }
        
        [HUD hide:YES];
        [membersList reloadData];
        
     }
     viewMembersConn=nil;
    
    [viewMembersConn cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSIndexPath *morePath =[membersList indexPathForCell:pcell];
    [membersList beginUpdates];
    [membersList reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:membersList heightForRowAtIndexPath:morePath];
    [membersList endUpdates];
}
/*
-(void)joinAllGroup{
    
   // [self setActivityIndicator];
    
    NSMutableArray *users= [[NSMutableArray alloc] init];
    
    NSMutableArray *privateg= [[NSMutableArray alloc] init];
    
    NSMutableArray *publicg= [[NSMutableArray alloc] init];
    
    [selectedGroup enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSInteger row = [obj integerValue];
        
     
        if([[[searchData objectAtIndex:row] objectForKey:@"type"] isEqualToString:@"public#local"]||[[[searchData objectAtIndex:row] objectForKey:@"type"] isEqualToString:@"public#global"]){
            
            [publicg addObject:[searchData objectAtIndex:row][@"id"]];
            
        }else if ([[searchData objectAtIndex:row][@"type"] isEqual:@"private#local"]||[[searchData objectAtIndex:row][@"type"] isEqual:@"private#global"])
        {
            [privateg addObject:[searchData objectAtIndex:row][@"id"]];
        }else{
            
            [users addObject:[searchData objectAtIndex:row][@"id"]];
            
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
            [data setValue:appUserId forKey:@"user_id"];
            
            NSString *url =[NSString stringWithFormat:@"%@/scripts/multi_group_user_join.php",gupappUrl];
            [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [HUD hide:YES];
                NSData * data = (NSData*)responseObject;
                NSError *error = nil;
                NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                
                [selectedGroup enumerateObjectsUsingBlock:^(id objs, NSUInteger idx, BOOL *stop) {
                    
                    NSInteger rows = [objs integerValue];
                    
                    
                        NSString *insertQuery=[NSString stringWithFormat:@"insert into contacts (user_id, user_email, user_name, user_pic, user_status,user_location) values ('%@','%@','%@','%@','%@','%@')",[searchData objectAtIndex:rows][@"id"],[searchData objectAtIndex:rows][@"email"],[searchData objectAtIndex:rows][@"name"],[searchData objectAtIndex:rows][@"display_pic"],[searchData objectAtIndex:rows][@"status"],[searchData objectAtIndex:rows][@"bottom_display"]];
                        [[self appDelegate]addFriendWithJid:[[NSString stringWithFormat:@"user_%@@",selectedContactId] stringByAppendingString:(NSString*)jabberUrl ] nickName:selectedContactName];
                        
                        NSLog(@"query %@",insertQuery);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
                        //[[self appDelegate]._chatDelegate buddyStatusUpdated];
                        
                    
                }];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Groups has been added to your profile."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                [[self appDelegate]._chatDelegate buddyStatusUpdated];
                
                [selectedGroup removeAllObjects];
                
                expndRow =-1;
                
                [ExploreTableView reloadData];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [HUD hide:YES];
                
            }];
            
            
        }
        
    }];
    
}*/


-(void)groupSelected:(UIButton*)btn withIndex:(NSInteger)row{
    
    if([selectedGroup  containsObject:[NSString stringWithFormat:@"%ld",(long)row]]){
        
        [selectedGroup removeObject:[NSString stringWithFormat:@"%ld",(long)row]];
        
    }else{
        
        [selectedGroup addObject:[NSString stringWithFormat:@"%ld",(long)row]];
    }
    
    newGroupCell *pcell;
    if ([[btn superview] isKindOfClass:[newGroupCell class]]) {
        pcell = (newGroupCell *)[btn superview];
    }
    else if ([[[btn superview] superview] isKindOfClass:[newGroupCell class]]){
        pcell = (newGroupCell *)[[btn superview] superview];
    }
    NSIndexPath *morePath =[membersList indexPathForCell:pcell];
    [membersList beginUpdates];
    [membersList reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:membersList heightForRowAtIndexPath:morePath];
    [membersList endUpdates];
}

@end
