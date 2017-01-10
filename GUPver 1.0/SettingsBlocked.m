//
//  SettingsBlocked.m
//  GUPver 1.0
//
//  Created by genora on 11/5/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "SettingsBlocked.h"
#import "NSString+Utils.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "JSON.h"

@interface SettingsBlocked ()

@end

@implementation SettingsBlocked

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Blocked Users";
    }
    return self;
}
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    UIBarButtonItem *unblockButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Unblock"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(unblockUsers:)];
    self.navigationItem.rightBarButtonItem = unblockButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:6.0/255.0 green:72.0/255.0 blue:64.0/255.0 alpha:1.0];
    blockedUserId=[[NSMutableArray alloc]init];
    blockedUserName=[[NSMutableArray alloc]init];
    blockedUserPic=[[NSMutableArray alloc]init];
    blockedUserLocation=[[NSMutableArray alloc]init];
    selectedUserId=[[NSMutableArray alloc]init];
    appUserId=[[DatabaseManager getSharedInstance]getAppUserID];
    //[self loadBlockedUsers];
    
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self loadBlockedUsers];
    
}
-(void)loadBlockedUsers
{
    //[self startActivityIndicator];
    [blockedUserId removeAllObjects];
    [blockedUserName removeAllObjects];
    [blockedUserPic removeAllObjects];
    [blockedUserLocation removeAllObjects];
    //[selectedUserId removeAllObjects];
    
    NSString *checkIfBlockedUsersExist;
    checkIfBlockedUsersExist=[NSString stringWithFormat:@"select * from contacts where blocked=1"];
    BOOL blockedUsersExist=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfBlockedUsersExist];
    if(blockedUsersExist)
    {
        NSMutableArray *getBlockedUsers = [[NSMutableArray alloc]init];
        getBlockedUsers = [[DatabaseManager getSharedInstance]getBlockedUsers];
        
        if([getBlockedUsers count]>0){
            for(int i=0;i<[getBlockedUsers count];i++)
            {
                
                NSMutableArray *blockedUsers = [getBlockedUsers objectAtIndex:i];
                [blockedUserId addObject:[blockedUsers objectAtIndex:0]];
                [blockedUserName addObject:[blockedUsers objectAtIndex:1]];
                [blockedUserPic addObject:[blockedUsers objectAtIndex:2]];
                [blockedUserLocation addObject:[blockedUsers objectAtIndex:3]];
                
            }
            [blockedTable reloadData];
        }
        else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There no Blocked Users."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
        }
        
    }
    else
    {
        [self startActivityIndicator];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSString *postData = [NSString stringWithFormat:@"user_id=%@",appUserId];
        NSLog(@"$[%@]",postData);
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/blocked_user_listing.php",gupappUrl]]];
        
        [request setHTTPMethod:@"POST"];
        
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        
        fetchBlockedUsersConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        
        [fetchBlockedUsersConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        [fetchBlockedUsersConn start];
        
        fetchBlockedUsersResponse = [[NSMutableData alloc] init];
        
    }
    

}

-(void)unblockUsers:(id)sender
{
    
    NSLog(@"selected user id: %@",selectedUserId);
    if ([selectedUserId count] ==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Select Users."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];

        NSLog(@"please select users");
    }
    else{
    [self startActivityIndicator];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *selectedContacts= [selectedUserId componentsJoinedByString:@","];
    NSLog(@"selectec string:%@",selectedContacts);
    NSString *postData = [NSString stringWithFormat:@"user_id=%@&blocked=%@",appUserId,selectedContacts];
    NSLog(@"$[%@]",postData);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/delete_blocked_user.php",gupappUrl]]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    unblockUsersConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [unblockUsersConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [unblockUsersConn start];
    
    unblockUsersResponse = [[NSMutableData alloc] init];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [blockedUserId count];
    
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
          cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
      
    }
    cell.accessoryType=UITableViewCellAccessoryNone;
    // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",blockedUserPic[indexPath.row]]];
    NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
    NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
    UIImage *profilePic = [UIImage imageWithData:pngData];
    if (profilePic) {
        cell.imageView.image=profilePic;
    }
    else
    {
        cell.imageView.image=[UIImage imageNamed:@"defaultProfile"];
    }
    

    cell.textLabel.text = [blockedUserName objectAtIndex:indexPath.row];
    cell.detailTextLabel.text =[blockedUserLocation objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.f];
    cell.detailTextLabel.textColor =[UIColor lightGrayColor];
    if ( [selectedUserId containsObject:[blockedUserId objectAtIndex:indexPath.row]])
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
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType== UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedUserId removeObject:[blockedUserId objectAtIndex:indexPath.row]];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedUserId addObject:[blockedUserId objectAtIndex:indexPath.row]];
       
    }
    
    
}
//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == fetchBlockedUsersConn) {
        
        [fetchBlockedUsersResponse setLength:0];
        
    }
    if (connection == unblockUsersConn) {
        
        [unblockUsersResponse setLength:0];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == fetchBlockedUsersConn) {
        
        [fetchBlockedUsersResponse appendData:data];
        
    }
    if (connection == unblockUsersConn) {
        
        [unblockUsersResponse appendData:data];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == fetchBlockedUsersConn) {
        
        
        NSString *str = [[NSMutableString alloc] initWithData:fetchBlockedUsersResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"blocked_user_list"];
        NSDictionary *list=responce[@"list"];
        int status= [responce[@"status"] integerValue];
        if (status==0)
        {
            for (NSDictionary *result in list)
            {
                [blockedUserId addObject:result[@"user_id"]];
                [blockedUserName addObject:result[@"display_name"]];
                [blockedUserPic addObject:result[@"profile_pic"]];
                [blockedUserLocation addObject:result[@"location_name"]];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,result[@"profile_pic"]]]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //cell.imageView.image = [UIImage imageWithData:imgData];
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        NSLog(@"paths=%@",paths);
                        NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",result[@"profile_pic"]]];
                        [imgData writeToFile:contactPicPath atomically:YES];
                        
                        
                    });
                    
                });
                

                
            }
            
            [HUD hide:YES];
            [blockedTable reloadData];
        }
        
        else
        {
            [HUD hide:YES];
            /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No blocked users"   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];*/
            
        }
        
        
        fetchBlockedUsersConn=nil;
            
        [fetchBlockedUsersConn cancel];
        
    }
    if (connection == unblockUsersConn) {
        
        
        NSString *str = [[NSMutableString alloc] initWithData:unblockUsersResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"response"];
        int status= [responce[@"error"] integerValue];
        NSString *error=responce[@"error_mess"];
        if (status==0)
        {
            for (int k=0; k<[selectedUserId count]; k++) {
                NSString *updateContact=[NSString stringWithFormat:@"update  contacts set blocked = 0 where user_id = '%@' ",selectedUserId[k]];
                
                [[self appDelegate] addFriendWithJid:[selectedUserId[k] JID] nickName:@"ram"];
                NSLog(@"query %@",updateContact);
               NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[selectedUserId objectAtIndex:k] JID]forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"you are unblocked"];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"contactUpdate"];
                [elementDic setValue:@"0" forKey:@"is_notify"];
                [elementDic setValue:@"0" forKey:@"isgroup"];
                //  NSLog(@"gid %@",groupId);
                // [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];

                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateContact];
            }
            
            [blockedUserId removeAllObjects];
            [blockedUserName removeAllObjects];
            [blockedUserPic removeAllObjects];
            [blockedUserLocation removeAllObjects];
            NSMutableArray *getBlockedUsers = [[NSMutableArray alloc]init];
            getBlockedUsers = [[DatabaseManager getSharedInstance]getBlockedUsers];
            
            if([getBlockedUsers count]>0){
                for(int i=0;i<[getBlockedUsers count];i++)
                {
                    
                    NSMutableArray *blockedUsers = [getBlockedUsers objectAtIndex:i];
                    [blockedUserId addObject:[blockedUsers objectAtIndex:0]];
                    [blockedUserName addObject:[blockedUsers objectAtIndex:1]];
                    [blockedUserPic addObject:[blockedUsers objectAtIndex:2]];
                    [blockedUserLocation addObject:[blockedUsers objectAtIndex:3]];
                    
                }
                
            }
            else{
                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There are no Blocked Users."   delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                alert.tag=33;
                    [alert show];
            }
            [selectedUserId removeAllObjects];
            [blockedTable reloadData];
            [HUD hide:YES];
           
        }
        
        else
        {
            //[blockedTable reloadData];
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
            
        }
        
        
        unblockUsersConn=nil;
        
        [unblockUsersConn cancel];
        
    }

    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==33) {
        if (buttonIndex==0) {
            [self.navigationController popViewControllerAnimated:NO];
        }
        
    }
}

-(void)startActivityIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}



@end
