//
//  FirstViewController.m
//  GUPver 1.0
//
//  Created by genora on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "FirstViewController.h"
#import "ChatScreen.h"
#import "CreateGroup.h"
#import "FPPopoverController.h"
#import "DatabaseManager.h"
#import "ViewContactProfile.h"
#import "globleData.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Home", @"Home");
        self.navigationItem.title = @"Home";
        //self.tabBarItem.image = [UIImage imageNamed:@"home"];
        UIImage *selectedImage = [UIImage imageNamed:@"home_blue"];
        UIImage *unselectedImage = [UIImage imageNamed:@"home"];
        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
         self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    groupsChatList = [NSArray arrayWithObjects:@"Private Group Name", @"Private Group Name", @"Public Group Local", @"Private Group Name", @"Public Group Global", @"Public Group Local", @"Private Group Name", @"Public Group Global", nil];
    thumbnails = [NSArray arrayWithObjects:@"lock.png", @"lock.png", @"pin.png", @"lock.png", @"globe.png", @"pin.png", @"lock.png", @"globe.png", nil];
    
    contactNames = [[NSMutableArray alloc]init];
    contactPics = [[NSMutableArray alloc]init];
    contactStatus = [[NSMutableArray alloc]init];
    contactIds = [[NSMutableArray alloc]init];
    //lastMsgReceivedTime = [[NSMutableArray alloc]init];
    //unreadMsgsNo = [[NSMutableArray alloc]init];
    lastMsg = [[NSMutableArray alloc]init];

    tempContactNames = [[NSMutableArray alloc]init];
    tempContactPics = [[NSMutableArray alloc]init];
    tempContactStatus = [[NSMutableArray alloc]init];
    tempLastMsgReceivedTime = [[NSMutableArray alloc]init];
    tempUnreadMsgNo = [[NSMutableArray alloc]init];
    tempContactIds = [[NSMutableArray alloc]init];
    tempLastMsg = [[NSMutableArray alloc]init];
    
    

    //privateChatList = [NSArray arrayWithObjects:@"Peter Noronha", @"Messy Lourdes", @"Jacquelin Ferns", @"Larry Hans", @"Nihaal Jain", @"Freddy Gomes", @"Jessica Gomes", @"Irwin Lourdes",nil];
    //personalImages = [NSArray arrayWithObjects:@"profile1", @"profile2", @"profile3", @"profile4", @"profile2", @"profile4", @"profile3", @"profile1", nil];
    statusOptions = [NSArray arrayWithObjects:@"Available", @"Busy", @"Invisible", nil];
    statusOptionsThumbnails = [NSArray arrayWithObjects:@"online", @"busy", @"invisible", nil];
    lastMsgReceivedTime = [NSMutableArray arrayWithObjects:@"09.00",@"08.45",@"08.15", @"07.45", @"07.30", @"06.15", @"04.00", @"06.00", @"04.30", nil];
    unreadMsgsNo = [NSMutableArray arrayWithObjects:@"3",@"",@"", @"", @"", @"", @"", @"", @"", nil];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:UITextAttributeTextColor]];
    
    [self initialiseView];
    [self setupSegmentController];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        
        //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:100.0/255.0 green:234.0/255.0 blue:224.0/255.0 alpha:1.0];
        [segControl setTintColor:[UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0]];
        search.barTintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
        
        
    }else{
        
        //self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:100.0/255.0 green:234.0/255.0 blue:224.0/255.0 alpha:1.0];
        [segControl setTintColor:[UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0]];
        search.tintColor = [UIColor colorWithRed:255.0/255.0 green:179.0/255.0 blue:67.0/255.0 alpha:1.0];
        
        
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==66)
    {
        if (buttonIndex==1)
        {
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:@"http://198.154.98.11/~gup/Gup_demo/scripts/resend_verify.php"]];
            [request setHTTPMethod:@"POST"];
            NSMutableData *body = [NSMutableData data];
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            
            //  parameter username
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"%i",[globleData userID]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            // close form
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            // setting the body of the post to the reqeust
            [request setHTTPBody:body];
            
            
            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
             NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@" return %@",dict);
            NSLog(@"result %@",returnString);
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
        }
    }
    
    
    
}

-(void)initialiseView
{
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    // add status button to the bar
    
    statusButton = [[UIBarButtonItem alloc]
                                     initWithImage:[UIImage imageNamed:@"online"]
                                     style:UIBarButtonItemStyleDone
                                     target:self
                                     action:@selector(setStatus:)];
    self.navigationItem.leftBarButtonItem = statusButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
    
    // add add group button to the bar
    addButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Create"
                                  style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:@selector(addGroup)];
    
    
    
    
}
-(IBAction)setStatus:(id)sender
{
       //the view controller you want to present as popover
    UIViewController *controller = [[UIViewController alloc] init];
    statusTable = [[UITableView alloc]initWithFrame:CGRectMake(10, 40, 120, 120) style:UITableViewStylePlain];
    statusTable.delegate = self;
    statusTable.dataSource = self;
    controller.view=statusTable;
    controller.title = nil;
     //our popover
    popover = [[FPPopoverController alloc] initWithViewController:controller];
    popover.contentSize = CGSizeMake(200,182);
    
    popover.arrowDirection = FPPopoverNoArrow;
    popover.border = NO;
    [popover presentPopoverFromView:segControl];
}

-(void)addGroup
{
    CreateGroup *addGroupPage = [[CreateGroup alloc]init];
    [self.navigationController pushViewController:addGroupPage animated:YES];
}

-(void)setupSegmentController{
    //add viewcontrollers to the segment control
      [segControl addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    //[segControl setImage:[UIImage imageNamed:@"public"] forSegmentAtIndex:0];
    //[segControl setImage:[UIImage imageNamed:@"private"] forSegmentAtIndex:1];
    segControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segControl setTitle:@"Group" forSegmentAtIndex:0];
    [segControl setTitle:@"Contacts" forSegmentAtIndex:1];
    [segControl setSelectedSegmentIndex:0];
    [self didChangeSegmentControl:segControl];
}



#pragma mark -
#pragma mark Segment control

- (void)didChangeSegmentControl:(UISegmentedControl *)control {
    
    NSString * segmentTitle = [control titleForSegmentAtIndex:control.selectedSegmentIndex];
    self.navigationItem.backBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:segmentTitle style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (segControl.selectedSegmentIndex == 1)
    {
        self.navigationItem.rightBarButtonItem = nil;
       /* DatabaseManager *getContacts;   //Get Profile Data From DBMANAGER
        getContacts= [[DatabaseManager alloc] init];
        getData = [[NSMutableArray alloc]init];
        getData =[getContacts getUsersData];
        [contactNames removeAllObjects];
        [contactPics removeAllObjects];
        [contactStatus removeAllObjects];
        [contactIds removeAllObjects];

        
        NSLog(@"users count %d",[getData count]);
        if([getData count]>0){
            for(int i=0;i<[getData count];i++)
            {
                
                NSMutableArray *contacts = [getData objectAtIndex:i];
                [contactNames addObject:[contacts objectAtIndex:0]];
                [contactPics addObject:[contacts objectAtIndex:1]];
                [contactStatus addObject:[contacts objectAtIndex:2]];
                [contactIds addObject:[contacts objectAtIndex:3]];
            }
            
        }
        
        for (int i=0; i<contactIds.count; i++) {
            NSLog(@"Array element: %@",[contactIds objectAtIndex:i]);
        }
        [tempContactNames removeAllObjects];
        [tempContactPics removeAllObjects];
        [tempContactStatus removeAllObjects];
        [tempLastMsgReceivedTime removeAllObjects];
        [tempUnreadMsgNo removeAllObjects];
        [tempContactIds removeAllObjects];
        [tempContactNames addObjectsFromArray:contactNames];
        [tempContactPics addObjectsFromArray:contactPics];
        [tempContactStatus addObjectsFromArray:contactStatus];
        [tempLastMsgReceivedTime addObjectsFromArray:lastMsgReceivedTime];
        [tempUnreadMsgNo addObjectsFromArray:unreadMsgsNo];
        [tempContactIds addObjectsFromArray:contactIds];
        [groupsTable reloadData];*/
        [self refreshChatList];
    }
    else{
        self.navigationItem.rightBarButtonItem = addButton;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
        [groupsTable reloadData];
    }
    
}


#pragma mark Table View Data Source Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    
    NSLog(@"Table  initialized ");
    return 1;
    
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == groupsTable)
        return 1.0;
    else
        return 20.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    if(tableView == groupsTable)
    {
        if (segControl.selectedSegmentIndex == 0) {
            return [groupsChatList count];
        }
        else
        {            NSLog(@"count %i",[tempContactNames count]);

            return [tempContactNames count];
        }
    }
    else
    {
        return 3;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(tableView == groupsTable)
        return @"";
    else
        return @"Status";
    

    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (tableView == groupsTable) {
        static NSString *simpleTableIdentifier = @"SimpleTableItem";
        HomeTableCell *cell= (HomeTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        

        if (segControl.selectedSegmentIndex == 0) {
            cell.nameLabel.text = [groupsChatList objectAtIndex:indexPath.row];
            cell.profileImageView.image = [UIImage imageNamed:[thumbnails objectAtIndex:indexPath.row]];
            //cell.badgeImageView.image = [unreadMsgsNo objectAtIndex:indexPath.row];
            cell.timeLabel.text = [lastMsgReceivedTime objectAtIndex:indexPath.row];
           
            if (![[unreadMsgsNo objectAtIndex:indexPath.row] isEqualToString:@""]) {
                
                //cell.badgeLabel.layer.borderColor = [UIColor redColor].CGColor;
                //cell.badgeLabel.layer.backgroundColor = [UIColor redColor].CGColor;
                //cell.badgeLabel.layer.borderWidth = 1.0;
                //cell.badgeLabel.layer.cornerRadius = 11;
                cell.badgeImageView.image = [UIImage imageNamed:@"unread"];
            }
        
            
        } else if (segControl.selectedSegmentIndex == 1)
        {
            NSLog(@"name %@",tempContactNames);
            cell.nameLabel.text = [tempContactNames objectAtIndex:indexPath.row];
            NSLog(@"contact pic %@",tempContactPics);
            cell.profileImageView.image = [UIImage imageNamed:[tempContactPics objectAtIndex:indexPath.row]];
            //cell.badgeLabel.text = [tempUnreadMsgNo objectAtIndex:indexPath.row];
            cell.timeLabel.text = [tempLastMsgReceivedTime objectAtIndex:indexPath.row];
            cell.status.image =[UIImage imageNamed:[tempContactStatus objectAtIndex:indexPath.row]];
            if (![[unreadMsgsNo objectAtIndex:indexPath.row] isEqualToString:@""]) {
                //cell.badgeLabel.layer.borderColor = [UIColor redColor].CGColor;
                //cell.badgeLabel.layer.backgroundColor = [UIColor redColor].CGColor;
                //cell.badgeLabel.layer.borderWidth = 1.0;
                //cell.badgeLabel.layer.cornerRadius = 11;
                cell.badgeImageView.image = [UIImage imageNamed:@"unread"];
            }
        }
        
        
        return cell;
    } else {
        static NSString *Identifier2 = @"CellType2";
        // cell type 2
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier2];
        }
        cell.imageView.image = [UIImage imageNamed:[statusOptionsThumbnails objectAtIndex:indexPath.row]];
        cell.textLabel.text = [statusOptions objectAtIndex:indexPath.row];
        //cell.backgroundColor=[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
        
        // set cell properties
        
        return cell;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == groupsTable)
        return 61;
    else
        return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == groupsTable) {
        
        NSLog(@"long press gesture");
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.5; //seconds
        
        

        //NSLog(@"selected news at %d",indexPath.row);
        if (segControl.selectedSegmentIndex == 0) {
            
            ChatScreen *detailPage = [[ChatScreen alloc]init];
            detailPage.chatStatus = @"group";
            if (indexPath.row==0||indexPath.row==1||indexPath.row==3||indexPath.row==6) {
                detailPage.groupType=@"private";
            }
            else
            {detailPage.groupType=@"public";
            }
            [self.navigationController pushViewController:detailPage animated:YES];
        } else if (segControl.selectedSegmentIndex == 1)
        {
            UITableViewCell *longPressedCell=[tableView cellForRowAtIndexPath:indexPath];
            //int selectedCell = indexPath.row;
            [longPressedCell addGestureRecognizer:lpgr];
            
            ChatScreen *detailPage = [[ChatScreen alloc]init];
            detailPage.chatStatus = @"personal";
            [self.navigationController pushViewController:detailPage animated:YES];

        }

}
    else
    {
        //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *selectedcell=[tableView cellForRowAtIndexPath:indexPath];
        selectedcell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSLog(@"Selected index=%d",indexPath.row);
        status=[statusOptions objectAtIndex:indexPath.row];
        NSLog(@"status %@",status);
        if(indexPath.row == 0)
        {
          self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
        }
        else if(indexPath.row == 1)
        {
            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:240.0/255.0 blue:0.0/255.0 alpha:1.0];
        }
        else
        {
            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
        }
        [popover dismissPopoverAnimated:YES];
    }
  
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// Handle Long Press in the cell
-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:groupsTable];
    NSIndexPath *indexPath = [groupsTable indexPathForRowAtPoint: location];
    NSString *selectedIndividual = [tempContactNames objectAtIndex:indexPath.row];
    selectedContactId = [tempContactIds objectAtIndex:indexPath.row];
    NSLog(@"Selected index = %d and selected person = %@ and selected id = %@",indexPath.row,selectedIndividual,selectedContactId);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        DatabaseManager *getUserDetails;   //Get Profile Data From DATABASEMANAGER
        getUserDetails = [[DatabaseManager alloc] init];
        NSArray *getUserData = [[NSMutableArray alloc]init];
        getUserData = [getUserDetails getContactMuteAndBlockStatus:selectedContactId];
        NSLog(@"block=%@ and mute=%@",getUserData[0],getUserData[1]);
        
        other0 = @"View Profile";
        other2 = @"Block User";
        cancelTitle = @"Cancel";
        
        if ([getUserData[1] isEqualToString:@"1"])
        {
            other1 = @"Unmute Chat";
        }
        else
        {
            other1 = @"Mute Chat";
        }
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:@""
                                          delegate:self
                                          cancelButtonTitle:cancelTitle
                                          destructiveButtonTitle:Nil
                                          otherButtonTitles:other0, other1, other2, nil];
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
      
        
      
        

    }
}

// action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"button title:%i,%@",buttonIndex ,buttonTitle);
    if ([buttonTitle isEqualToString:@"View Profile"]) {
        NSLog(@"View Profile");
        ViewContactProfile *viewContact = [[ViewContactProfile alloc]init];
        viewContact.userId=selectedContactId;
        [self.navigationController pushViewController:viewContact animated:YES];

    }
    if ([buttonTitle isEqualToString:@"Mute Chat"]) {
         //[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO];
        NSLog(@"mute pressed id =%@",selectedContactId);
        NSString *query=[NSString stringWithFormat:@"UPDATE contacts SET mute_notification=%d WHERE user_id=%@ ",1,selectedContactId];
        
        NSLog(@"query %@",query);
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
        
    }
    if ([buttonTitle isEqualToString:@"Block User"]) {
        NSLog(@"block pressed id =%@",selectedContactId);
        NSString *updateQuery=[NSString stringWithFormat:@"UPDATE contacts SET blocked=%d WHERE user_id=%@ ",1,selectedContactId];
        NSLog(@"query %@",updateQuery);
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateQuery];

        NSString *query=[NSString stringWithFormat:@"delete from contacts where user_id=%@",selectedContactId];
        NSLog(@"query %@",query);
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
        [self refreshChatList];
        //[groupsTable reloadData];
        
        
    }
    if ([buttonTitle isEqualToString:@"Unmute Chat"]) {
        //[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO];
        NSLog(@"unmute pressed id =%@",selectedContactId);
        NSString *query=[NSString stringWithFormat:@"UPDATE contacts SET mute_notification=%d WHERE user_id=%@ ",0,selectedContactId];
        NSLog(@"query %@",query);
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
        
    }


    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    }
    

}

// search bar delegates


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchbartextdidbeginediting");
    searchBar.showsCancelButton=TRUE;
    
}
/*- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
     NSLog(@"searchbartextdidendediting");
    //[groupsTable reloadData];
    // [self handleSearch:searchBar];
    
}*/

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
        NSLog(@"User searched for %@", searchText);
    
    
    if (segControl.selectedSegmentIndex == 1)
    {
        NSLog(@"segment control");
        if([searchBar.text length]==0)
        {
            
            isFiltered = FALSE;
            [tempContactNames removeAllObjects];
            [tempContactPics removeAllObjects];
            [tempContactStatus removeAllObjects];
            [tempLastMsgReceivedTime removeAllObjects];
            [tempUnreadMsgNo removeAllObjects];
            [tempContactIds removeAllObjects];
            
            [tempContactNames addObjectsFromArray:contactNames];
            [tempContactPics addObjectsFromArray:contactPics];
            [tempContactStatus addObjectsFromArray:contactStatus];
            [tempLastMsgReceivedTime addObjectsFromArray:lastMsgReceivedTime];
            [tempUnreadMsgNo addObjectsFromArray:unreadMsgsNo];
            [tempContactIds addObjectsFromArray:contactIds];
        }
        else
        {
            isFiltered = TRUE;
            [tempContactNames removeAllObjects];
            [tempContactPics removeAllObjects];
            [tempContactStatus removeAllObjects];
            [tempLastMsgReceivedTime removeAllObjects];
            [tempUnreadMsgNo removeAllObjects];
            [tempContactIds removeAllObjects];
            
            int i =0;
            for (NSString *string in contactNames) {
                NSRange r=[string rangeOfString:searchBar.text options:NSCaseInsensitiveSearch];
                if(r.location!=NSNotFound)
                {
                    //[displayItems addObject:string];
                    [tempContactNames addObject:[contactNames objectAtIndex:i]];
                    [tempContactPics addObject:[contactPics objectAtIndex:i]];
                    [tempContactStatus addObject:[contactStatus objectAtIndex:i]];
                    [tempLastMsgReceivedTime addObject:[lastMsgReceivedTime objectAtIndex:i]];
                    [tempUnreadMsgNo addObject:[unreadMsgsNo objectAtIndex:i]];
                    [tempContactIds addObject:[contactIds objectAtIndex:i]];
                }
                i++;
            }
        }
        if (tempContactNames.count == 0)
        {      
            NSLog(@"No results found.");
            /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Match not found."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];*/

        }
        
        [groupsTable reloadData];
    }
    
}



- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    searchBar.showsCancelButton=FALSE;
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
}

-(void)refreshChatList
{
    
    DatabaseManager *getContacts;   //Get Profile Data From DBMANAGER
    getContacts= [[DatabaseManager alloc] init];
    getData = [[NSMutableArray alloc]init];
    getData =[getContacts getUsersData];
    [contactNames removeAllObjects];
    [contactPics removeAllObjects];
    [contactStatus removeAllObjects];
    [contactIds removeAllObjects];
    
    
    NSLog(@"users count %d",[getData count]);
    if([getData count]>0){
        for(int i=0;i<[getData count];i++)
        {
            
            NSMutableArray *contacts = [getData objectAtIndex:i];
            [contactNames addObject:[contacts objectAtIndex:0]];
            [contactPics addObject:[contacts objectAtIndex:1]];
            [contactStatus addObject:[contacts objectAtIndex:2]];
            [contactIds addObject:[contacts objectAtIndex:3]];
        }
        
    }
    
    for (int i=0; i<contactIds.count; i++) {
        NSLog(@"Array element: %@",[contactIds objectAtIndex:i]);
        
    }
    [tempContactNames removeAllObjects];
    [tempContactPics removeAllObjects];
    [tempContactStatus removeAllObjects];
    [tempLastMsgReceivedTime removeAllObjects];
    [tempUnreadMsgNo removeAllObjects];
    [tempContactIds removeAllObjects];
    [tempContactNames addObjectsFromArray:contactNames];
    [tempContactPics addObjectsFromArray:contactPics];
    [tempContactStatus addObjectsFromArray:contactStatus];
    [tempLastMsgReceivedTime addObjectsFromArray:lastMsgReceivedTime];
    [tempUnreadMsgNo addObjectsFromArray:unreadMsgsNo];
    [tempContactIds addObjectsFromArray:contactIds];
    [groupsTable reloadData];
}
@end
