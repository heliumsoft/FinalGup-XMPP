//
//  FirstViewController.m
//  GUPver 1.0
//
//  Created by genora on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "FirstViewController.h"
#import "XMPPJID.h"
#import "ChatScreen.h"
#import "AppDelegate.h"
#import "CreateGroup.h"
#import "FPPopoverController.h"
#import "DatabaseManager.h"
#import "ViewContactProfile.h"
#import "GroupInfo.h"
#import "viewPrivateGroup.h"
#import "globleData.h"
#import "NSString+Utils.h"
#import "SBJSON.h"
#import "Haneke.h"
#import "CreateNewPost.h"
#import "PostListing.h"
#import "AFNetworking.h"
#import "UserGroupTableViewCell.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize type,messageToBeForwarded,msgType,appUserId,sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Home", @"Home");
        self.navigationItem.title = @"My 1 on 1 Chats";
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
//        self.tabBarItem.image = [UIImage imageNamed:@"contactTab"];
//        UIImage *selectedImage = [UIImage imageNamed:@"contactActive"];
//        UIImage *unselectedImage = [UIImage imageNamed:@"contactTab"];
//        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
//        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
    }
    return self;
}
- (void)buddyStatusUpdated{
    
//    [self fetchGroups];
    [self refreshChatList];
//    [self refreshGroupList];
    
}
- (AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}
- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}
- (XMPPRoster *)xmppRoster {
    return [[self appDelegate] xmppRoster];
}
-(void)freezerAnimate{
    if (HUD==nil ){
        [self setActivityIndicator];
    }
    [HUD setHidden:NO];
}
-(void)freezerRemove{
    if(HUD!=nil){
        [HUD setHidden:YES];
    }
}
-(void)initiateChat{
    
    NSArray *excutedOutput=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select id,logged_in_user_id,email,password, language,verified,display_name,display_pic,status,chat_wall_paper,social_login,social_login_type,social_login_id,location_id,location,profile_update,registered,about_us from master_table"];

    if ([excutedOutput count]==1){
        //[[self appDelegate] setXmpp];
        NSDictionary *rowElements=[excutedOutput objectAtIndex:0];
        [self appDelegate].MyUserName=[rowElements objectForKey:@"DISPLAY_NAME"];
        NSLog(@"USER NAME %@",[self appDelegate].MyUserName);
        
        [self appDelegate].myUserID=[rowElements objectForKey:@"LOGGED_IN_USER_ID"];
        NSString *username=[NSString stringWithFormat:@"user_%@",[rowElements objectForKey:@"LOGGED_IN_USER_ID"]];
        NSString *jid=[username stringByAppendingString:[NSString stringWithFormat:@"@%@",jabberUrl]];
        NSString *password=[NSString stringWithFormat:@"password_%@_user",[rowElements objectForKey:@"LOGGED_IN_USER_ID"]];
        NSString *userStatus=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"STATUS" ForRowIndex:0 givenOutput:excutedOutput];
        
        if ([userStatus isEqual:@"offline"]) {
//            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
            
//            [[self appDelegate] goOffline ];
            
            
            
        }else if([userStatus isEqual:@"away"]){
//            self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:240.0/255.0 blue:0.0/255.0 alpha:1.0];
            
//            [[self appDelegate]goAway];
        }else if([userStatus isEqual:@"online"]){
//            self.navigationItem.leftBarButtonItem.tintColor =[UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0] ;
            
//            [[self appDelegate] goOnline];
        }
        
        NSString *unifier=[[rowElements objectForKey:@"SOCIAL_LOGIN"] isEqualToString:@"1"]?@"":[rowElements objectForKey:@"EMAIL"];
        //NSLog(@"username %@ PASSWORD %@ UNIFIER %@",username,password,unifier);
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:jid forKey:@"Jid"];
        [defaults setObject:password forKey:@"Password"];
        NSString *chatWallpaper;
        if ([[rowElements objectForKey:@"CHAT_WALL_PAPER"] isEqual:[NSNull null] ])
        {chatWallpaper=@"wallpaper.jpg";
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"UPDATE master_table SET chat_wall_paper='%@' WHERE id=1 ",chatWallpaper ]];
            
        }else{
            chatWallpaper=[rowElements objectForKey:@"CHAT_WALL_PAPER"];
        }
        
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"UPDATE master_table SET registered=1 WHERE id=1 "];
        [defaults synchronize];
        if ([[rowElements objectForKey:@"REGISTERED"] isEqual:[NSNull null]]||[[rowElements objectForKey:@"REGISTERED"] isEqual:@"0"]){
            BOOL reply= [[self appDelegate]registrationWithUserName:username password:password name:[rowElements objectForKey:@"DISPLAY_NAME"] emailid:unifier];
            if (reply)
            NSLog(@"registratration process starts");
            else
            
            NSLog(@"you cannot interrupt registratration ");
        }else{
            [[self appDelegate] connect];
        }
        
    }
    ////NSLog(@"%@ ,pass %@  for %@ %@",[defaults objectForKey:@"Jid"], [defaults objectForKey:@"Password"],jid,password);
    
}

-(void)handleUnsendFriendReuest{
    NSArray *userIDsData=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select user_id,user_name from contacts where blocked=0"];
    NSMutableArray *userIds=[[NSMutableArray alloc]init];
    NSMutableArray *userName=[[NSMutableArray alloc]init];
    for (int i=0; i<[userIDsData count]; i++){
        [userIds addObject:[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_ID" ForRowIndex:i givenOutput:userIDsData]];
        [userName addObject:[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_NAME" ForRowIndex:i givenOutput:userIDsData]];
        //[[[DatabaseManager  getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_ID" ForRowIndex:i givenOutput:userIDsData]]];
        //   [userName addObject:[[[DatabaseManager  getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"user_name" ForRowIndex:i givenOutput:userIDsData]]];
        
    }
    //NSLog(@"useerr_id %@ /n user_name %@ ",userIds,userName);
    for (int i=0; i<[userIds count]; i++){
        
        //NSLog(@"iq id %@ databade %@",[self appDelegate ].ArrayUsersIDs,[userIds objectAtIndex:i]);
        if (! [[self appDelegate ].ArrayUsersIDs containsObject:[userIds objectAtIndex:i]])
        {NSString *userId=[userIds objectAtIndex:i];
            NSString *user_name=[userName objectAtIndex:i];
            [[self appDelegate] addFriendWithJid:[[NSString stringWithFormat:@"user_%@@",userId] stringByAppendingString:(NSString*)jabberUrl ] nickName:user_name];
        }
    }
    
    //NSLog(@"array element %@\n ids %@",userIds,[self appDelegate].ArrayUsersIDs);
    
}
-(void)getProfileData
{
    DatabaseManager *getProfile;   //Get Profile Data From DATABASEMANAGER
    getProfile = [[DatabaseManager alloc] init];
    NSArray *ggetData = [[NSMutableArray alloc]init];
    ggetData=[getProfile getProfileData];
    myImage =ggetData[4];
    
}
- (void)viewDidLoad{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genetareNotification:) name:@"newCommentNotification" object:nil];
   //
    [super viewDidLoad];
//    
//    LandingPage *lp=[[LandingPage alloc]init];
//    lp.registrationID = [[DatabaseManager getSharedInstance]getAppUserID];
//    [self.navigationController pushViewController:lp animated:YES];
   // [self plistSpooler];
    [self initialiseView];
    if (![type isEqual:@"forward"]){
        [self appDelegate]._chatDelegate=self;
        [self initiateChat];
    }
    [self getProfileData];

    statusOptions = [NSArray arrayWithObjects:@"Available", @"Busy", @"Invisible", nil];
    statusOptionsThumbnails = [NSArray arrayWithObjects:@"online", @"away", @"invisible", nil];
    
    
    
    
    UITextField *txfSearchField = [search valueForKey:@"_searchField"];
    txfSearchField.layer.cornerRadius =10.0;
    txfSearchField.layer.borderWidth =1.0f;
    txfSearchField.layer.borderColor =  [[UIColor colorWithRed:138/255.0 green:155/255.0 blue:160/255.0 alpha:1] CGColor];
    //[self setActivityIndicator];
    //[self listCategories];
    
    txfSearchField.font = [UIFont fontWithName:@"Dosis-Regular" size:17.0f];
    
    
    appUserId = [[DatabaseManager getSharedInstance]getAppUserID];
    BOOL ifExists=[[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"select * from groups_private"]];
    
    BOOL ifPublicExists=[[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"select * from groups_public"]];
    if (!ifExists && !ifPublicExists) {
        
         [self setActivityIndicator];
         [self freezerAnimate];
    }else{
        [self freezerAnimate];
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:self
                                       selector:@selector(stopLoader)
                                       userInfo:nil
                                        repeats:NO];
    }
    [self fetchContacts];
//    [self setupSegmentController];
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


-(void)generateNotifications:(NSString*)notification{
    // Schedule the notification
    localNotification= [[UILocalNotification alloc] init];
    [localNotification setShouldGroupAccessibilityChildren:YES];
    [localNotification setIsAccessibilityElement:YES];
    
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = notification;
    
    localNotification.alertAction = @"Show me the item";
    NSMutableDictionary *dedew=[[NSMutableDictionary alloc]init];
    [dedew setValue:@"hi" forKey:@"deepesh"];
    
    [localNotification setUserInfo:dedew];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"vibration"] boolValue]){
        NSLog(@"1?>>>> vibration");
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"sound"] boolValue]){
        NSLog(@"1?>>>> sound");
        localNotification.soundName=UILocalNotificationDefaultSoundName;
    }
    int badgenumber;
    badgenumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    if(!badgenumber)
        badgenumber = 0;
    localNotification.applicationIconBadgeNumber = badgenumber + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}



-(void)stopLoader{
    
    [HUD hide:YES];
}



-(IBAction)dissmisal:(UIButton*)sender1{
    
    [self.parentViewController.parentViewController.view setUserInteractionEnabled:YES];
    [sender1.superview removeFromSuperview];
}
-(void)plistSpooler{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path]){
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        if (![[data objectForKey:@"HomeScreen"] boolValue]) {
            
            [data setObject:[NSNumber numberWithInt:true] forKey:@"HomeScreen"];
            CGSize deviceSize=[UIScreen mainScreen].bounds.size;
            UIImageView *Back=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            UIImage *backimage=[UIImage imageNamed:@"screens"];
            [Back setImage:[backimage stretchableImageWithLeftCapWidth:backimage.size.width topCapHeight:backimage.size.width/2]];
            [Back setUserInteractionEnabled:YES];
            UIButton *dismiss=[[UIButton alloc]initWithFrame:CGRectMake(deviceSize.width-110, 32, 100, 30)];
            [dismiss setTitle:@"Done" forState:UIControlStateNormal];
            [dismiss setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:55.0/255.0 alpha:1 ]];
            [dismiss setUserInteractionEnabled:YES];
            [dismiss addTarget:self action:@selector(dissmisal:) forControlEvents:UIControlEventTouchUpInside];
            [Back addSubview:dismiss];
            [self.parentViewController.parentViewController.view addSubview:Back];
            [self.parentViewController.parentViewController.view bringSubviewToFront:Back ];
            
        }
        [data writeToFile: path atomically:YES];
        
    }else{
        
        data = [[NSMutableDictionary alloc] init];
        [data setObject:[NSNumber numberWithInt:true] forKey:@"IsSuccesfullRun"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"HomeScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"CreateGroup"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"Location"];
        [data writeToFile: path atomically:YES];
        
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    if(recieveContactMsg==nil) {
        
//        recieveContactMsg=[[UIImageView alloc]initWithFrame:CGRectMake(segControl.frame.origin.x-12,segControl.frame.origin.y-12, 24,24)];
//        [recieveContactMsg setImage:[UIImage imageNamed:@"message"]];
//        [self.view addSubview:recieveContactMsg];
//        recieveGroupMsg=[[UIImageView alloc]initWithFrame:CGRectMake(segControl.frame.origin.x+225-12,segControl.frame.origin.y-12, 24,24)];
//        [recieveGroupMsg setImage:[UIImage imageNamed:@"message"]];
//        [self.view addSubview:recieveGroupMsg];
//        [recieveContactMsg setHidden:1];
//        [recieveGroupMsg setHidden:1];
        
    }
    if([self appDelegate].hasInet&&[[self xmppStream] isDisconnected]){
        
        [[self appDelegate]  connect];
        
    }
    
//    [self fetchGroups];
    [groupsTable reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    search.showsCancelButton = NO;
    [search resignFirstResponder];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        
        
//        search.barTintColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        
    }else{
        
//        search.tintColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        
        
    }
    
    if (![type isEqual:@"forward"] && type){
        [self refreshChatList];
        [self refreshGroupList];
        [self appDelegate].currentUser=@"";
    }
}

-(void)initialiseView{
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    if ([type isEqual:@"forward"]){
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];//[UIColor
        [cancelButton addTarget:self action:@selector(CancelForward) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIButton *forwardButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 70.0f, 30.0f)];
        [forwardButton setTitle:@"Forward" forState:UIControlStateNormal];//[UIColor
        [forwardButton addTarget:self action:@selector(forwardMessage) forControlEvents:UIControlEventTouchUpInside];
        [forwardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        forward = [[UIBarButtonItem alloc] initWithCustomView:forwardButton];
        
    }else{
        
//        statusButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 40.0f, 30.0f)];
//        [statusButton setImage:[UIImage imageNamed:@"online"] forState:UIControlStateNormal];//[UIColor greenColor]];
//        [statusButton addTarget:self action:@selector(setStatus:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:statusButton];
        UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
        [backButton setTitle:@"Create" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(addGroup) forControlEvents:UIControlEventTouchUpInside];
        addButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
    }
    
}
-(void)CancelForward
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)forwardThisMessageToReceiver:(NSString*)recievers_id isItGroup:(NSString*)isgroup group_id:(NSString *)GID group_counter:(NSString *)GC time:(NSString*)timeInMiliseconds
{
    
    
    
    //    NSMutableDictionary *arrayTobePassed=[[NSMutableDictionary alloc]init];
    //    [arrayTobePassed setValue:[messageToBeForwarded stringByReplacingOccurrencesOfString:@"'" withString:@"''"] forKey:@"message"];
    //    [arrayTobePassed setValue:msgType forKey:@"message_type"];
    //    [arrayTobePassed setValue:@"" forKey:@"message_Id"];
    //    [arrayTobePassed setValue:@"" forKey:@"referenceID"];
    //    [arrayTobePassed setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid" ] forKey:@"senders_id"];
    //    [arrayTobePassed setValue:recievers_id forKey:@"recievers_id"];
    //    [arrayTobePassed setValue:isgroup forKey:@"isGroup"];
    //    [arrayTobePassed setValue:GID forKey:@"groupID"];
    //    [arrayTobePassed setValue:GC forKey:@"groupCounter"];
    //    [arrayTobePassed setValue:timeInMiliseconds  forKey:@"time_stamp" ];
    //    [arrayTobePassed setValue:@"0" forKey:@"isResending"];
    //
    //    [[self appDelegate] sendMessageWithMessageData:arrayTobePassed];
    
}



-(void)forwardMessage
{
    
    NSArray *master_table1=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name,logged_in_user_id,chat_wall_paper from master_table"];
    for(int i=0;i<[receiversUserId count];i++)
    {
        
        NSString *chatWithUser=[NSString stringWithFormat:@"%@",[receiversUserId objectAtIndex:i]];
        
        /*  NSLog(@"msg %@",messageToBeForwarded);
         //send to server
         XMPPMessage *msg = [XMPPMessage message];
         [msg addAttributeWithName:@"type" stringValue:msgType];
         [msg addAttributeWithName:@"to" stringValue:chatWithUser];
         [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ];
         //  NSData *data = [msgToSend dataUsingEncoding:NSNonLossyASCIIStringEncoding];
         
         //  NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         NSString *goodValue=[messageToBeForwarded UTFEncoded];
         NSLog(@"converted %@",goodValue);
         // NSString *dd =  [[NSString alloc] initWithData:[goodValue dataUsingEncoding:NSASCIIStringEncoding] encoding:NSNonLossyASCIIStringEncoding];
         
         NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:goodValue];
         
         goodValue =[goodValue UTFDecoded];
         NSLog(@"decoded %@",goodValue);
         [msg addChild:body];
         [[self xmppStream] sendElement:msg];
         
         */
        NSString *timeInMiliseconds = [[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
        NSString *msgToBesend=messageToBeForwarded;
        msgToBesend =[msgToBesend stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *goodValue=[msgToBesend UTFEncoded];
        NSString *groupID=@"";
        BOOL isThisGroupChat=false;
        NSString *recieversID=[NSString stringWithFormat:@"user_%@@%@",chatWithUser,jabberUrl];
        
        [[self appDelegate] storeMessageInDatabaseForBody:goodValue forMessageType:msgType messageTo:recieversID groupId:groupID isGroup:isThisGroupChat forTimeInterval:timeInMiliseconds senderName:[[master_table1 objectAtIndex:0] objectForKey:@"DISPLAY_NAME"] postid:nil isRead:nil withImage:myImage];
        NSString *messageid=[[self appDelegate] CheckIfMessageExist:[goodValue stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
        //  NSString *recieversID=[chatWithUser userID];
        //  if([chatType isEqual:@"group"])
        //     recieversID=groupID;
        //  else
        //      recieversID=[jid userID];
        NSString *referanceID=  [[self appDelegate] getLinkedIdOfMessageID:messageid forTimestamp:timeInMiliseconds senderID:[self appDelegate].myUserID recieversID:chatWithUser chattype:@"personal"];
        [[self appDelegate] sendAcknoledgmentPacketId:referanceID isGroupAcknoledgment:isThisGroupChat];
        [self forwardThisMessageToReceiver:chatWithUser isItGroup:@"0" group_id:@"" group_counter:@""time:timeInMiliseconds];
        //   [sender sendMessageWithReceiversJid:chatWithUser message:messageToBeForwarded type:msgType groupId:@""];
        
    }
    for (int i=0; i<[receiversGroupId count]; i++)
//    {
//        NSString *chatWithUser=[NSString stringWithFormat:@"%@",[receiversGroupId objectAtIndex:i]];
//        
//        NSString *timeInMiliseconds=    [[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
//        NSString *msgToBesend=messageToBeForwarded;
//        msgToBesend =[msgToBesend stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//        NSString *goodValue=[msgToBesend UTFEncoded];
//        NSString *groupID=chatWithUser;
//        BOOL isThisGroupChat=true;
//        NSString *recieversID=[NSString stringWithFormat:@"user_%@@%@",chatWithUser,jabberUrl];
//        [[self appDelegate] storeMessageInDatabaseForBody:goodValue forMessageType:msgType messageTo:recieversID groupId:groupID isGroup:isThisGroupChat forTimeInterval:timeInMiliseconds senderName:[[master_table1 objectAtIndex:0] objectForKey:@"DISPLAY_NAME"] postid:nil isRead:nil];
//        NSString *messageid=[[self appDelegate] CheckIfMessageExist:[goodValue stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
//        //  NSString *recieversID=[chatWithUser userID];
//        //  if([chatType isEqual:@"group"])
//        //     recieversID=groupID;
//        //  else
//        //      recieversID=[jid userID];
//        NSString *referanceID=  [[self appDelegate] getLinkedIdOfMessageID:messageid forTimestamp:timeInMiliseconds senderID:[self appDelegate].myUserID recieversID:chatWithUser chattype:@"group"];
//        [[self appDelegate] sendAcknoledgmentPacketId:referanceID isGroupAcknoledgment:isThisGroupChat];
//        
////        NSArray *members=[self getMembersListGroupId:[[receiversGroupId objectAtIndex:i] integerValue]];
//        NSArray *master_table=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name,logged_in_user_id,chat_wall_paper from master_table"];
//        NSDictionary *userDictonary = [master_table lastObject];
//        for (NSString *groupid in receiversGroupId){
//            
//             NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_group.id,user_id,time_stamp,message_id,message_type,message_text,message_filename from chat_group INNER  JOIN chat_message where user_id=%@ AND group_id = %@ AND messageStatus=0 AND  message_id=chat_message.id order by chat_group.time_stamp ASC",[self appDelegate].myUserID,groupid]];
////            XMPPMessage *msg = [XMPPMessage message];
////            [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
////            [msg addAttributeWithName:@"groupCounter" stringValue:[self appDelegate].groupCounter];
////            [msg addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"group_%@@%@",groupid,groupJabberUrl]];
////            [msg addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"user_%@@%@",[self appDelegate].myUserID,jabberUrl]];
////            [msg addAttributeWithName:@"isResend" boolValue:FALSE];
//////            msgToBesend=[self RadhaCompatiableEncodingForstring:msgToBesend];
////            NSString *goodValue1=[msgToBesend UTFEncoded];
////            NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
////            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[goodValue1 stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]];
////            
////            NSXMLElement *reference = [NSXMLElement elementWithName:@"referenceID" stringValue:[[groupUnsendMessages objectAtIndex:0] objectForKey:@"CHAT_GROUP.ID"]];
////            NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[userDictonary objectForKey:@"LOGGED_IN_USER_ID"]];
////            NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:[userDictonary objectForKey:@"DISPLAY_NAME"]];
////            NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:msgType];
////            NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[NSString stringWithFormat:@"%@",timeInMiliseconds]];
////            NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:groupID ];
////            NSXMLElement *isgroup= [NSXMLElement elementWithName:@"isgroup" stringValue:[NSString stringWithFormat:@"%i",true]];
////            
////            [gup addChild:body];
////            [gup addChild:reference];
////            [gup addChild:from_user_id];
////            [gup addChild:from_user_name];
////            [gup addChild:timeStamp];
////            [gup addChild:message_type];
////            [gup addChild:isgroup];
////            [gup addChild:groupIDs];
////            [msg addChild:gup];
////            
////            NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:[goodValue1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];
////            [msg addChild:body1];
////            if ([self appDelegate].hasInet&&[[self xmppStream] isDisconnected])
////                [[self appDelegate] connect ];
////            [[self xmppStream] sendElement:msg];
//            
////            XMPPMessage *msg = [XMPPMessage message];
////            [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
////            [msg addAttributeWithName:@"groupCounter" stringValue:[self appDelegate].groupCounter];
////            [msg addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"group_%@@%@",groupid,groupJabberUrl]];
////            [msg addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"user_%@@%@",[self appDelegate].myUserID,jabberUrl]];
////            [msg addAttributeWithName:@"isResend" boolValue:FALSE];
////            msgToBesend=[self RadhaCompatiableEncodingForstring:messageToBeForwarded];
////            NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
////            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue :[msgToBesend stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
////            timeInMiliseconds = [[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] ;
////            NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[userDictonary objectForKey:@"LOGGED_IN_USER_ID"]];
////            NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:[userDictonary objectForKey:@"DISPLAY_NAME"]];
////            NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:msgType ];
////            NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[NSString stringWithFormat:@"%@",timeInMiliseconds]];
////            NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:groupID ];
////            NSXMLElement *isgroup= [NSXMLElement elementWithName:@"isgroup" stringValue:[NSString stringWithFormat:@"%i",true]];
////            
////            [gup addChild:body];
////            [gup addChild:from_user_id];
////            [gup addChild:from_user_name];
////            [gup addChild:timeStamp];
////            [gup addChild:message_type];
////            [gup addChild:isgroup];
////            [gup addChild:groupIDs];
////            [msg addChild:gup];
////            NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:msgToBesend]];
////            [msg addChild:body1];
////            if ([self appDelegate].hasInet&&[[self xmppStream] isDisconnected])
////            [[self appDelegate] connect ];
////            [[self xmppStream] sendElement:msg];
////            NSString *chatWithUser=[NSString stringWithFormat:@"%@",[members objectAtIndex:j]];
////            [self forwardThisMessageToReceiver:chatWithUser isItGroup:@"1"  group_id:[receiversGroupId objectAtIndex:i] group_counter:[NSString stringWithFormat:@"%i",j] time:timeInMiliseconds] ;
////            [sender sendMessageWithReceiversJid:chatWithUser message:messageToBeForwarded type:msgType groupId:[[receiversGroupId objectAtIndex:i] userID]];
//        }
//    }
    //[sender newMessageReceived];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString*)RadhaCompatiableEncodingForstring:(NSString*)str{
    return [str stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
}

-(NSString*)getStringFromBody:(NSXMLElement*)gupElement andBody:(NSString*)body{
    
    NSString *returnString=[[NSString alloc]init];
    for (int i=0; i<[gupElement.children count]; i++){
        DDXMLNode *targetElement=[gupElement childAtIndex:i];
        returnString=[returnString stringByAppendingString:[NSString stringWithFormat:@"(%@)",targetElement.name]];
        if([targetElement.name isEqual:@"body"])
        returnString= [returnString stringByAppendingString:[NSString stringWithFormat:@"%@",body]];
        else
        returnString= [returnString stringByAppendingString:[NSString stringWithFormat:@"%@",targetElement.stringValue]];
        returnString= [returnString stringByAppendingString:[NSString stringWithFormat:@"(/%@)",targetElement.name]];
        
    }
    return[NSString stringWithFormat:@"(gup)%@(/gup)", returnString];
}

-(NSArray*)getMembersListGroupId:(int)GID{
    NSMutableArray *temparray;
    NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%i and deleted!=1",GID]];
    temparray=[[NSMutableArray alloc]init];
    for (int i=0; i<[tempmembersID count];i++){
        [temparray addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
    }
    return temparray;
}

-(IBAction)setStatus:(id)sender{
    
    
    
    
    [popover1 dismissPopoverAnimated:YES];
    //the view controller you want to present as popover
    UIViewController *controller = [[UIViewController alloc] init];
    statusTable = [[UITableView alloc]initWithFrame:CGRectMake(15, 52, 120, 120) style:UITableViewStyleGrouped];
    statusTable.backgroundColor=[UIColor clearColor];
    statusTable.delegate = self;
    statusTable.dataSource = self;
    controller.view=statusTable;
    controller.title = nil;
    //our popover
    popover1=[[UIPopoverController alloc] initWithContentViewController:controller];
    [popover1 setPopoverContentSize:CGSizeMake(self.view.frame.size.width-10, 150)];
    //[popover1 presentPopoverFromBarButtonItem:statusButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    CGRect rect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0);
    [popover1 presentPopoverFromRect:rect inView:self.view permittedArrowDirections:NO animated:NO];

}

-(void)addGroup{

    CreateGroup *addGroupPage = [[CreateGroup alloc]init];
//     CreateNewPost *addGroupPage = [[CreateNewPost alloc] init];
    [self.navigationController pushViewController:addGroupPage animated:YES];
}

#pragma mark Table View Data Source Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
    
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView == groupsTable)
    return 1.0;
    else
    return 25.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userData.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    UserGroupTableViewCell *userCell = (UserGroupTableViewCell*)cell;
    NSDictionary *data = [userData objectAtIndex:indexPath.row];
    [userCell plotCellData:data];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *Identifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UserGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILongPressGestureRecognizer *groupLpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    groupLpgr.minimumPressDuration = 0.5; //seconds
    [cell addGestureRecognizer:groupLpgr];;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == groupsTable) {
        [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                            style:UIBarButtonItemStyleBordered
                                            target:nil
                                            action:nil]];
        
            if ([type isEqualToString:@"forward"]){
                [groupsTable reloadData];
                
            }else{
                
                    ChatScreen *detailPage = [[ChatScreen alloc]init];
                    detailPage.chatType = @"personal";
                    [self appDelegate].isUSER=1;
                    detailPage.chatTitle=[[userData objectAtIndex:indexPath.row] objectForKey:@"user_name"];
                    [detailPage initWithUser:[[NSString stringWithFormat:@"user_%@@",[[userData objectAtIndex:indexPath.row] objectForKey:@"user_id"]] stringByAppendingString:(NSString*)jabberUrl ]];
                    [self.navigationController pushViewController:detailPage animated:YES];
                
            }
        
    }else{
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        NSXMLElement *queryElement = [NSXMLElement elementWithName: @"query" xmlns: @"jabber:iq:roster"];
        NSXMLElement *iqStanza = [NSXMLElement elementWithName: @"iq"];
        [iqStanza addAttributeWithName: @"type" stringValue: @"get"];
        [iqStanza addChild: queryElement];
        [[self xmppStream] sendElement: iqStanza];
        [self performSelector:@selector(handleUnsendFriendReuest) withObject:Nil afterDelay:3];
        //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *selectedcell=[tableView cellForRowAtIndexPath:indexPath];
        selectedcell.accessoryType = UITableViewCellAccessoryCheckmark;
        status=[statusOptions objectAtIndex:indexPath.row];
        if(indexPath.row == 0){
            [statusButton setImage:[UIImage imageNamed:@"online"] forState:UIControlStateNormal];
            // self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0];
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"update master_table set status='online' where id=1"];
            [[self appDelegate] goOnline ];
        }else if(indexPath.row == 1){
            [statusButton setImage:[UIImage imageNamed:@"away"] forState:UIControlStateNormal];
            //self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:240.0/255.0 blue:0.0/255.0 alpha:1.0];
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"update master_table set status='away' where id=1"];
            [[self appDelegate]goAway];
        }else{
            [statusButton setImage:[UIImage imageNamed:@"offline"] forState:UIControlStateNormal];
            //   self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"update master_table set status='offline' where id=1"];
            [[self appDelegate] goOffline];
        }
        [popover1 dismissPopoverAnimated:YES];
    }
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}


- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}
// Handle Long Press in the cell
-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture{
    
    CGPoint location = [gesture locationInView:groupsTable];
    selectedIndexPath = [groupsTable indexPathForRowAtPoint: location];
//    NSString *selectedIndividual = [[userData objectAtIndex:selectedIndexPath.row] objectForKey:@"user_name"];
    selectedContactId = [[userData objectAtIndex:selectedIndexPath.row] objectForKey:@"user_id"];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        DatabaseManager *getUserDetails;   //Get Profile Data From DATABASEMANAGER
        getUserDetails = [[DatabaseManager alloc] init];
        NSArray *getUserData = [[NSMutableArray alloc]init];
        getUserData = [getUserDetails getContactMuteAndBlockStatus:selectedContactId];
        NSString *other3=@"Delete User";
        other0 = @"View Profile";
        other2 = @"Block User";
        NSString *other5=@"Report User";
        cancelTitle = @"Cancel";
        
        if ([getUserData[1] isEqualToString:@"1"]){
            other1 = @"Unmute";
        }else{
            other1 = @"Mute";
        }
        
        contactActionSheet = [[UIActionSheet alloc]
                              initWithTitle:@""
                              delegate:self
                              cancelButtonTitle:cancelTitle
                              destructiveButtonTitle:Nil
                              otherButtonTitles:other0, other1, other2, other3,other5, nil];
        [contactActionSheet showFromTabBar:self.tabBarController.tabBar];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [actionSheet dismissWithClickedButtonIndex:0 animated:NO];

    if(actionSheet == contactActionSheet){
        
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:@"View Profile"]) {
            ViewContactProfile *viewContact = [[ViewContactProfile alloc]init];
            viewContact.userId=selectedContactId;
            [self.navigationController pushViewController:viewContact animated:YES];
            
        }
        if ([buttonTitle isEqualToString:@"Mute"]) {
            
            
            NSString *query=[NSString stringWithFormat:@"UPDATE contacts SET mute_notification=%d WHERE user_id=%@ ",1,selectedContactId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            UserGroupTableViewCell *selectedCell= (UserGroupTableViewCell *)[groupsTable cellForRowAtIndexPath:selectedIndexPath];
            selectedCell.muteImageView.image = [UIImage imageNamed:@"mute"];
            
        }
        if ([buttonTitle isEqualToString:@"Block User"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to block this user?"   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag=1;
            [alert show];
            
        }
        if ([buttonTitle isEqualToString:@"Unmute"]) {
            NSString *query=[NSString stringWithFormat:@"UPDATE contacts SET mute_notification=%d WHERE user_id=%@ ",0,selectedContactId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            UserGroupTableViewCell *selectedCell= (UserGroupTableViewCell *)[groupsTable cellForRowAtIndexPath:selectedIndexPath];
            selectedCell.muteImageView.image = [UIImage imageNamed:@""];
            
        }
        if ([buttonTitle isEqualToString:@"Delete User"]) {
            
            NSString *query=[NSString stringWithFormat:@"UPDATE contacts SET deleted=%d WHERE user_id=%@ ",1,selectedContactId];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            [self refreshChatList];
            
        }
//        if ([buttonTitle isEqualToString:@"Clear Chat History"]) {
//            
//            NSArray *messageIds=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select message_id,id  from  chat_personal where user_id=%@ or receivers_id=%@",selectedContactId,selectedContactId]] ;
//            
//            for (int i=0; i<[messageIds count]; i++) {
//                NSInteger  msgId=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_ID" ForRowIndex:i givenOutput:messageIds]integerValue ];
//                NSArray *outputPersonal=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_personal where message_id=%i and( user_id!=%@ or receivers_id!=%@ )",msgId,selectedContactId,selectedContactId]] ;
//                NSArray *outputGroup=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_group where message_id=%i ",msgId]];
//                NSInteger  noOfMessagesUsedInChat_Group=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputGroup] integerValue];
//                NSInteger  noOfMessagesUsedInChat_personal=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputPersonal] integerValue];
//                NSInteger noOfMessagesUsed=noOfMessagesUsedInChat_Group+noOfMessagesUsedInChat_personal;
//                if (noOfMessagesUsed ==1)
//                {
//                    NSArray *fileNames=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select message_filename from chat_message where id=%i",msgId]] ;
//                    NSString  *fileName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_FILENAME" ForRowIndex:0 givenOutput:fileNames];
//                    if (fileName != (id)[NSNull null]) {
//                        [self removeFileNamed:fileName];
//                    }
//                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_message where id=%i",msgId]];
//                    
//                }
//                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_personal where id=%@",[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"ID" ForRowIndex:i givenOutput:messageIds ]]];
//                
//                
//            }
//            
//            
//        }
        
        if ([buttonTitle isEqualToString:@"Report User"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Report this User as inappropriate ?"   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag=33;
            [alert show];
            
            
        }
        
        
        if ([buttonTitle isEqualToString:@"Cancel"]) {
        }
        
    }
    
}
- (void)removeFileNamed:(NSString*)filename{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *filePathRetrieve =[[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",filename]];
    
    NSError *error = nil;
    if(![fileManager removeItemAtPath: filePathRetrieve error:&error]) {
    } else {
    }
    
}



//uialertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==66){
        if (buttonIndex==1){
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/resend_verify.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            NSMutableData *body = [NSMutableData data];
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%i",[globleData userID]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:body];
            resendEmail = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [resendEmail scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [resendEmail start];
            resendEmailresponce = [[NSMutableData alloc] init];
            
        }
    }
    
    if (alertView.tag==1) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"user_id=%@&blocked_user_id=%@&block_status=%i",appUserId,selectedContactId,1];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/block_unblock_user.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            notifyBlockedUsersConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [notifyBlockedUsersConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [notifyBlockedUsersConn start];
            notifyBlockedUsersResponse = [[NSMutableData alloc] init];
        }
        
    }
    if (alertView.tag==2) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
//            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//            NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",selectedGroup,appUserId];
//            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/leave_group.php",gupappUrl]]];
//            [request setHTTPMethod:@"POST"];
//            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
//            leaveGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//            [leaveGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//            [leaveGroupConn start];
//            leaveGroupResponse = [[NSMutableData alloc] init];
        }
        
    }
    if (alertView.tag==3) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
//            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//            NSString *postData = [NSString stringWithFormat:@"user_id=%@&spammed_group_id=%@",appUserId,selectedGroup];
//            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/spam_group.php",gupappUrl]]];
//            [request setHTTPMethod:@"POST"];
//            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
//            reportGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
//            [reportGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//            [reportGroupConn start];
//            reportGroupResponse = [[NSMutableData alloc] init];
        }
        
    }
    
    if (alertView.tag==77){
        
        [[self appDelegate] disconnect];
        [notifyBlockedUsersConn cancel];
        [reportGroupConn cancel];
        [leaveGroupConn cancel];
        [fetchContactsConn cancel];
        [fetchGroupsConn cancel];
        [[self appDelegate]pushLoginScreen];
    }
    if (alertView.tag==33) {
        if (buttonIndex == 1) {
            [self setActivityIndicator];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData;
            postData = [NSString stringWithFormat:@"user_id=%@&spammed_user_id=%@",appUserId,selectedContactId];
            //NSLog(@"post data %@",postData);
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/spam_user.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            reportSpamConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [reportSpamConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [reportSpamConn start];
            reportSpamResponse = [[NSMutableData alloc] init];
        }
    }
}

-(void)setActivityIndicator{
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}



- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    searchBar.showsCancelButton=TRUE;
    
}


-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    if([searchBar.text length]==0){
        isFiltered = FALSE;
        [userData removeAllObjects];
        [userData addObjectsFromArray:userSearchList];
        
    }else{
        
        isFiltered = TRUE;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_name CONTAINS[c] %@",searchBar.text];
        NSMutableArray *arr = [[userSearchList filteredArrayUsingPredicate:predicate] mutableCopy];
        [userData removeAllObjects];
        [userData addObjectsFromArray:arr];
    }
    [groupsTable reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    searchBar.showsCancelButton=FALSE;
    [searchBar resignFirstResponder];
}

-(void)refreshChatList{
    
    DatabaseManager *getContacts;
    getContacts= [[DatabaseManager alloc] init];
    getData = [[NSMutableArray alloc]init];
    getData = [getContacts getUsersData];
    userData = [NSMutableArray array];

    if(userData.count)
        [userData removeAllObjects];
    
    for (NSArray *data in getData) {
        NSMutableDictionary *singleUser = [NSMutableDictionary dictionary];
        [singleUser setValue:[data objectAtIndex:0] forKey:@"user_name"];
        [singleUser setValue:[data objectAtIndex:1] forKey:@"user_pic"];
        [singleUser setValue:[data objectAtIndex:2] forKey:@"user_status"];
        [singleUser setValue:[data objectAtIndex:3] forKey:@"user_id"];
        [singleUser setValue:[data objectAtIndex:4] forKey:@"time_stamp"];
        [singleUser setValue:[data objectAtIndex:5] forKey:@"message_type"];
        [singleUser setValue:[data objectAtIndex:6] forKey:@"message_text"];
        [singleUser setValue:[data objectAtIndex:7] forKey:@"read"];
        [singleUser setValue:[data objectAtIndex:8] forKey:@"mute"];
        [singleUser setValue:[data objectAtIndex:9] forKey:@"location"];


        [userData addObject:singleUser];
    }
    userSearchList = [NSMutableArray arrayWithArray:userData];
    [groupsTable reloadData];
    
}

-(void)newContactMessageRe{
    
        [self buddyStatusUpdated];
}

-(void)newGroupMessageRe{
    
    [self refreshChatList];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == notifyBlockedUsersConn) {
        
        [notifyBlockedUsersResponse setLength:0];
        
    }
//    if (connection == reportGroupConn) {
//        
//        [reportGroupResponse setLength:0];
//        
//    }
    
//    if (connection == leaveGroupConn) {
//        
//        [leaveGroupResponse setLength:0];
//        
//    }
    if (connection == fetchContactsConn) {
        
        [fetchContactsResponse setLength:0];
        
    }
//    if (connection == fetchGroupsConn) {
//        
//        [fetchGroupsResponse setLength:0];
//        
//    }
    if (connection == reportSpamConn) {
        
        [reportSpamResponse setLength:0];
    }
    if (connection == LOGOUT) {
        [LOGOUTRESPONSE setLength:0];
    }
    if (connection==resendEmail) {
        [resendEmailresponce setLength:0];
    }
    if (connection==muteConnection) {
        [muteData setLength:0];
    }
    if (connection==unmuteConnection) {
        [unmuteData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    //NSLog(@"did recieve data");
    if (connection==resendEmail){
        [resendEmailresponce appendData:data];
    }
    if (connection == notifyBlockedUsersConn) {
        
        [notifyBlockedUsersResponse appendData:data];
        
    }
//    if (connection == reportGroupConn) {
//        
//        [reportGroupResponse appendData:data];
//        
//    }
//    if (connection == leaveGroupConn) {
//        
//        [leaveGroupResponse appendData:data];
//        
//    }
    if (connection == fetchContactsConn) {
        
        [fetchContactsResponse appendData:data];
        
    }
    if (connection == fetchGroupsConn) {
        
        [fetchGroupsResponse appendData:data];
        
    }
    if (connection == reportSpamConn) {
        
        
        [reportSpamResponse appendData:data];
    }
    //NSLog(@"did recieve data");
    if (connection == LOGOUT) {
        [LOGOUTRESPONSE appendData:data];
    }
    if (connection == muteConnection) {
        [muteData appendData:data];
    }
    if (connection == unmuteConnection) {
        [unmuteData appendData:data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"%@",[error localizedDescription]);
    [HUD hide:YES];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //
    //    [alert show];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection==resendEmail){
        NSString *str = [[NSMutableString alloc] initWithData:resendEmailresponce encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
//        NSDictionary *responce= res[@"response"];
    }
    if (connection == LOGOUT){
        NSString *str = [[NSMutableString alloc] initWithData:LOGOUTRESPONSE encoding:NSASCIIStringEncoding];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"response"];
        
        BOOL   statusLogout= [responce[@"status"] boolValue];
        if (statusLogout){
            AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegateObj setLoginView];
        }
        [HUD hide:YES];
    }
    if (connection == notifyBlockedUsersConn) {
        
        NSString *str = [[NSMutableString alloc] initWithData:notifyBlockedUsersResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *result = res[@"response"];
        NSString *blockStatus = result[@"status"];
        NSString *error=result[@"error"];
        [HUD hide:YES];
        if ([blockStatus isEqualToString:@"1"]){
            
            NSString *updateQuery=[NSString stringWithFormat:@"UPDATE contacts SET blocked=%d WHERE user_id=%@ ",1,selectedContactId];
            [[self appDelegate] removeFriendWithJid:[selectedContactId JID]];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateQuery];
            // [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            [self refreshChatList];
            NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
            [attributeDic setValue:@"chat" forKey:@"type"];
            [attributeDic setValue:[selectedContactId JID]forKey:@"to"];
            [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
            [attributeDic setValue:@"0" forKey:@"isResend"];
            NSString *body=[NSString stringWithFormat:@"you are blocked"];
            NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
            [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
            [elementDic setValue:@"0" forKey:@"is_notify"];
            [elementDic setValue:@"text" forKey:@"message_type"];
            [elementDic setValue:@"1" forKey:@"contactDelete"];
            [elementDic setValue:@"0" forKey:@"contactUpdate"];
            [elementDic setValue:@"0" forKey:@"isgroup"];
            // [elementDic setValue:[NSString stringWithFormat:@"%@",selectedContactId ] forKey:@"contactID"];
            [elementDic setValue:body forKey:@"body"];
            
            [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];            //[groupsTable reloadData];
            // [[self xmppRoster]removeUser:[XMPPJID jidWithString:[selectedContactId JID]]];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }

    if(connection==reportSpamConn){
        NSString *str = [[NSMutableString alloc] initWithData:reportSpamResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"response"];
        NSString *reportStatus = responce[@"status"];
        NSString *error=responce[@"error"];
        [HUD hide:YES];
        if ([reportStatus isEqualToString:@"1"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
    
    if (connection == fetchContactsConn) {
        
        NSString *str = [[NSMutableString alloc] initWithData:fetchContactsResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *response=res[@"response"];
        NSDictionary *contacts = response[@"users"];
        //[HUD hide:YES];
        NSLog(@"all contacts: %@", res);
        if ([contacts count]==0 ){
            
        }else{
            for (NSDictionary *result in contacts) {
                
                NSString *checkIfExists=[NSString stringWithFormat:@"select * from contacts where user_id=%@",result[@"user_id"]];
                BOOL existOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfExists];
                if (existOrNot) {
                    NSString *updateContact=[NSString stringWithFormat:@"update  contacts set user_id = '%@', user_email = '%@', blocked = '%@', user_name ='%@', user_pic ='%@', user_location='%@' where user_id = '%@' ",result[@"user_id"],result[@"email"],result[@"blocked"],[result[@"user_name"] normalizeDatabaseElement],result[@"profile_pic"],result[@"location_name"],result[@"user_id"]];
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateContact];
                }else{
                    NSString *insertContact=[NSString stringWithFormat:@"insert into contacts (user_id, user_email, blocked, user_name, user_pic,user_location) values ('%@','%@','%@','%@','%@','%@')",result[@"user_id"],result[@"email"],result[@"blocked"],[result[@"user_name"] normalizeDatabaseElement],result[@"profile_pic"],result[@"location_name"]];
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertContact];
                }
                
                //download image and save in the cache
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,result[@"profile_pic"]]]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //cell.imageView.image = [UIImage imageWithData:imgData];
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",result[@"profile_pic"]]];
                        //Writing the image file
                        [imgData writeToFile:contactPicPath atomically:YES];
                    });
                });
            }
        }
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update master_table set contact_timestamp='%@'",response[@"timestamp"]]];
        
        [self refreshChatList];
        fetchContactsConn=nil;
        [fetchContactsConn cancel];
        if(fetchGroupsConn==nil){
            [self freezerRemove];
        }
    }
    if(connection == muteConnection){
        NSString *str = [[NSMutableString alloc] initWithData:muteData encoding:NSASCIIStringEncoding];
        NSLog(@"fetch groups Response:%@",str);
        //
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSString *status1 = [[res objectForKey:@"response"] objectForKey:@"status"];
        if([status1 intValue] == 1){
            NSLog(@"all groups: %@", res);
            NSLog(@"%.2f",(float)fetchGroupsResponse.length/1024.0f/1024.0f);
            [HUD hide:YES];
            
        }else{
            
        }
    }
    if(connection == unmuteConnection){
        NSString *str = [[NSMutableString alloc] initWithData:unmuteData encoding:NSASCIIStringEncoding];
        NSLog(@"fetch groups Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSString *status1 = [[res objectForKey:@"response"] objectForKey:@"status"];
        if([status1 intValue] == 1){
            NSLog(@"all groups: %@", res);
            NSLog(@"%.2f",(float)fetchGroupsResponse.length/1024.0f/1024.0f);
            [HUD hide:YES];
            
        }else{
            
        }
    }
    
}
// to fetch all the contacts and groups of the app user
-(void)fetchContacts{
    
    //    [self freezerAnimate];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSArray *groupArray = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_timestamp from master_table"]];
    NSString *contactTimeStampValue = [[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"CONTACT_TIMESTAMP" ForRowIndex:0 givenOutput:groupArray];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@&contact_timestamp=%@",appUserId,contactTimeStampValue];
    NSLog(@"$[contacts%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/contact_list.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    fetchContactsConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [fetchContactsConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [fetchContactsConn start];
    fetchContactsResponse = [[NSMutableData alloc] init];
}

-(void)genetareNotification:(NSNotification*)notification{
}



@end
