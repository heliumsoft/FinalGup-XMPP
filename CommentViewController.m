//
//  ChatScreen.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/29/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "XMPPvCardTempModule.h"
#import "AFNetworking.h"
#import "CommentViewController.h"
#import "ViewContactProfile.h"
#import "XMPP.h"
#import "SMMessageViewTableCell.h"
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import <QuartzCore/QuartzCore.h>
#import "XMPPRoom.h"
#import "XMPPRoomCoreDataStorage.h"
#import "viewPrivateGroup.h"
#import "GroupInfo.h"
#import "DatabaseManager.h"
#import "ContactList.h"
#import "commentCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:.8]

@interface  CommentViewController(){
    NSArray *privateGroupList;
    NSString *roomType;
    XMPPRoom *xmppRoom;
    UILabel *unreadMessagelbl;
}

@end

@implementation CommentViewController
@synthesize chatType,chatTitle,groupType,chatTable,chatWithUser,messageField,vcardUserId,from,timeInMiliseconds,chatHistory,month,expandedMessageId,audioPlayersCurrentTime,audioPlayersAudioDuration;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        
        month=[NSArray arrayWithObjects:@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August", @"September",@"October",@"November",@"December", nil];
        
    }
    return self;
}

- (void)viewDidLoad{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newCommentAction:) name:@"commentNotification" object:nil];
//    NSLog(@"utc date %@",[NSDate date]);
    
    name=[[DatabaseManager getSharedInstance] getAppUserName];
    updater=   [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(update) userInfo:nil repeats:YES];
    myUserId=[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideEditMenu) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageReceived) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [super viewDidLoad];
    pinnedMessge=[[NSMutableArray alloc]init];
    expandedMessageId=[[NSMutableArray alloc]init];
    date.layer.cornerRadius=8;
    date.hidden = YES;
    [self appDelegate]._messageDelegate=self;
    [self appDelegate].chatTableUpdate = self;
    uploadprogress=[[UIProgressView alloc]initWithFrame:CGRectMake(20, 35, self.view.frame.size.width-100-40, 50)];
    [uploadprogress setProgressViewStyle:UIProgressViewStyleBar];//uploadFile,*reportSpam/*,*downloadFile*/,*fetchHistory ,*fetchRefresh
    [uploadprogress setProgress:0.5];
    CGSize deviceSize=[UIScreen mainScreen].bounds.size;
    //NSLog(@"size w=%f h=%f ",deviceSize.width,deviceSize.height);
    chatBubbleWidth=deviceSize.width*0.5625;
    freezer=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, deviceSize.width, deviceSize.height)];
    [freezer setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
    [freezer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    
    progressViewBackground=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-100, 50)];
    [progressViewBackground setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
    [progressViewBackground.layer setCornerRadius:5];
    [progressViewBackground setCenter:CGPointMake(freezer.center.x, freezer.center.y-25)];
    
    uploadlable=[[UILabel alloc]initWithFrame:CGRectMake(10, 5,self.view.frame.size.width-120 , 20)];
    [uploadlable setBackgroundColor:[UIColor clearColor]];
    [uploadlable setTextAlignment:NSTextAlignmentCenter];
    [uploadlable setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.f]];
    [uploadlable setText:@""];
    [progressViewBackground addSubview:uploadlable];
    
    [progressViewBackground addSubview:uploadprogress];
    [freezer addSubview:progressViewBackground];
    GroupId = [[[[_toJid componentsSeparatedByString:@"@"] firstObject] componentsSeparatedByString:@"_"] lastObject];
    NSArray  *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if([[ver objectAtIndex:0]integerValue ]>=7){
        record.image=[[UIImage imageNamed:@"recorder"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        gallery.image=[[UIImage imageNamed:@"gallery"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        camera.image=[[UIImage imageNamed:@"camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vcard.image=[[UIImage imageNamed:@"contact"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        accessoryTab.translucent = NO;
    } else {
        [record setFinishedSelectedImage:[UIImage imageNamed:@"recorder"] withFinishedUnselectedImage:[UIImage imageNamed:@"recorder"]];
        [gallery setFinishedSelectedImage:[UIImage imageNamed:@"gallery"] withFinishedUnselectedImage:[UIImage imageNamed:@"gallery"]];
        [camera setFinishedSelectedImage:[UIImage imageNamed:@"camera"] withFinishedUnselectedImage:[UIImage imageNamed:@"camera"]];
        [vcard setFinishedSelectedImage:[UIImage imageNamed:@"contact"] withFinishedUnselectedImage:[UIImage imageNamed:@"contact"]];
    }
    
    
    pullRfrs = [[UIRefreshControl alloc] init];
    pullRfrs.backgroundColor = [UIColor clearColor];
    pullRfrs.tintColor = [UIColor colorWithRed:196.0f/255.0 green:234.0f/255.0 blue:249.0f/255.0 alpha:0.9];
    [pullRfrs addTarget:self action:@selector(getOlderBtnClicked) forControlEvents:UIControlEventValueChanged];
    [self.chatTable addSubview:pullRfrs];
    isMoreAvailable = YES;
    
    menuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 80)];
    menuView.backgroundColor = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    menuView.clearsContextBeforeDrawing = NO;
    [self.view addSubview:menuView];
    
    userIcon =[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
    userIcon.layer.cornerRadius = 20;
    userIcon.clipsToBounds = YES;
    [menuView addSubview:userIcon];
    
     UIButton* _postButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
    [_postButton setTitle:@"Post" forState:UIControlStateNormal];
    [_postButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1] forState:UIControlStateNormal];
    [_postButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    _postButton.titleLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:20];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_postButton];
    
    [self getProfileData];
    // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[4]]];
    NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
    myImage =getData[4];
    NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
    UIImage *profilePic = [UIImage imageWithData:pngData];
    if (profilePic) {
        userIcon.image=profilePic;
    }
    else
    {
        userIcon.image=[UIImage imageNamed:@"defaultProfile"];
    }
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(60, 10, self.view.bounds.size.width-100, 50)];
    //textView.layer.borderWidth = 1.0f;
    //textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.text = @"Type your comment....";
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont fontWithName:@"Dosis-Regular" size:12];
    textView.textColor = [UIColor whiteColor];
    textView.delegate=self;
    [menuView addSubview:textView];
    
    submenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, 25)];
    submenuView.backgroundColor = [UIColor whiteColor];
    submenuView.clearsContextBeforeDrawing = NO;
    [menuView addSubview:submenuView];
    
    cameraButton =[[UIButton alloc] initWithFrame:CGRectMake(10, 0,30, 25.0f)];
    [cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    [submenuView addSubview:cameraButton];
    
    galleryButton = [[UIButton alloc] initWithFrame: CGRectMake(50, 0, 30, 25.0f)];
    [galleryButton setImage:[UIImage imageNamed:@"gallery"] forState:UIControlStateNormal];
    [galleryButton addTarget:self action:@selector(addGallery) forControlEvents:UIControlEventTouchUpInside];
    [submenuView addSubview:galleryButton];
    
    contactButton = [[UIButton alloc] initWithFrame:CGRectMake(90, 0, 30,25.0f)];
    [contactButton setImage:[UIImage imageNamed:@"contact"] forState:UIControlStateNormal];
    [contactButton addTarget:self action:@selector(addContact) forControlEvents:UIControlEventTouchUpInside];
    [submenuView addSubview:contactButton];
    
    recorderButton = [[UIButton alloc] initWithFrame: CGRectMake(130, 0, 30, 25.0f)];
    [recorderButton setImage:[UIImage imageNamed:@"recording"] forState:UIControlStateNormal];
    [recorderButton addTarget:self action:@selector(addRecording) forControlEvents:UIControlEventTouchUpInside];
    [submenuView addSubview:recorderButton];
    
    accessoryView.hidden = YES;
    [self getMembersList];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeue" size:10.0f],NSFontAttributeName, NSForegroundColorAttributeName , [UIColor whiteColor],[UIColor whiteColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    chatHistory = [[NSMutableArray alloc ] init];
    [chatTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [chatTable setBackgroundColor:[UIColor clearColor]];
    [mainScroll setBackgroundColor:[UIColor clearColor]];
    mainScroll.scrollEnabled=true;
    mainScroll.showsVerticalScrollIndicator=true;
    [mainScroll setContentSize:CGSizeMake(mainScroll.frame.size.width,mainScroll.frame.size.height-64)];
    
    UIImageView *Back=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, deviceSize.width, deviceSize.height)];
    [Back setImage:[UIImage imageWithContentsOfFile:[self CachesPath:chatWallpaper]]];
    [self.view addSubview:Back];
    [self.view sendSubviewToBack:Back];
    
    [_tabBarView setHidden:YES];
    [accessoryTab setDelegate:self];
    accessoryTab.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0];
    _tabBarView.frame = CGRectMake(0, accessoryView.frame.origin.y-49, self.view.frame.size.width, accessoryTab.frame.size.height);
    
    messageField.returnKeyType = UIReturnKeyDone;
    [messageField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [messageField.layer setBorderWidth:1.0];
    messageField.layer.cornerRadius = 4;
    messageField.clipsToBounds = YES;
    [messageField setDelegate:self];
    
//    UIButton  *ViewPinned = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 40.0f, 30.0f)];
//    [ViewPinned setImage:[UIImage imageNamed:@"Fpin"] forState:UIControlStateNormal];//[UIColor greenColor]];
//    [ViewPinned addTarget:self action:@selector(viewGroupInfo) forControlEvents:UIControlEventTouchUpInside];
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:ViewPinned];
    
    [self newMessageReceived];
    [self scrollDown];
    [self updateChatHistory];
    [self plotLatest];
    accessoryView.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0];
    if([from isEqual:@"explore"])
        accessoryView.hidden=true;
//    button=[[UIButton alloc]init ];
//    [button setTitle:@"Get Older Comments" forState:UIControlStateNormal];
//    [button setTitle:@"Recovering Please Wait" forState:UIControlStateSelected];
    
    unreadMessagelbl = [[UILabel alloc]init];
    unreadMessagelbl.text = @"Unread messages";
    [self.view addSubview:date];
    [self.view bringSubviewToFront:date];
    
}
-(void)getProfileData
{
    DatabaseManager *getProfile;   //Get Profile Data From DATABASEMANAGER
    getProfile = [[DatabaseManager alloc] init];
    getData = [[NSMutableArray alloc]init];
    getData=[getProfile getProfileData];
    NSLog(@"profile data: %@",getData);
    
}
-(void)openProfile{
    
      if ([self.groupType isEqualToString:@"private"]) {
            viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
            viewGroupAsAdmin.title = self.chatTitle;
            viewGroupAsAdmin.groupId = GroupId;
            viewGroupAsAdmin.groupType =self.groupType;
            [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
            
        }else{
            
            GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
            viewGroupPage.title = self.chatTitle;
            viewGroupPage.groupId = GroupId;
            viewGroupPage.groupType = self.groupType;
            [self.navigationController pushViewController:viewGroupPage animated:NO];
            
        }
        
    
}

-(void)viewWillAppear:(BOOL)animated{

//        [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT   chat_group set read=1 where post_id=%@ ",self.postId]];
  
    unreadMessage = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select messageStatus,chat_group.id,user_id,time_stamp,message_id,pinned,spam,message_type,message_text,message_filename,message_deleted,received_time,sendername,sender_image  from chat_group INNER  JOIN chat_message where read=0 AND post_id =%@ AND group_id=%@ AND message_type!='(null)' AND user_id!='(null)' AND message_id=chat_message.id  order by chat_group.received_time ASC ", self.postId,GroupId]];
    [chatTable reloadData];
    self.tabBarController.tabBar.hidden=YES;
    if ([self appDelegate].hasInet==true&&[[[NSUserDefaults standardUserDefaults] objectForKey:@"TimeDifferance"] isEqual:@" "]){
        [[self appDelegate] CurrentDate];
        [self freezerAnimate];
    }
    
}


-(void)viewDidAppear:(BOOL)animated{
    //NSLog(@"name %@",chatTitle);
    CGSize  textSize = {self.navigationController.navigationBar.frame.size.width-170, 30 };
    CGSize size = [chatTitle sizeWithFont:[UIFont fontWithName:@"Dosis-SemiBold" size:17.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    contactNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(15,5,size.width,30)];
    [contactNameLabel setBackgroundColor:[UIColor clearColor]];
    contactNameLabel.textAlignment =NSTextAlignmentCenter;
    contactNameLabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:17.f];
    contactNameLabel.textColor =[UIColor whiteColor];
    if (![chatType isEqual:@"group"]){
        imageViewForStatus= [[UIImageView alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.frame.size.width/2-size.width/2-20, 12, 20, 20)];
        imageViewForStatus.layer.cornerRadius=10;
    }
    //[self.navigationController.navigationBar addSubview:imageViewForStatus];
    //[self.navigationController.navigationBar addSubview:contactNameLabel];
    [contactNameLabel setCenter:CGPointMake(self.navigationController.navigationBar.frame.size.width/2,self.navigationController.navigationBar.frame.size.height/2)];
    contactNameLabel.text =chatTitle;
    self.navigationItem.title =@"Comment";
    contactNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *titletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openProfile)];
    [contactNameLabel addGestureRecognizer:titletap];
    [self updateTitleStatus ];
}

-(void)plotLatest{
    
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
    [data setValue:self.postId forKey:@"postId"];
    [data setValue:GroupId forKey:@"groupId"];
    if (chatHistory.count >0) {
        NSArray *minTime = [[DatabaseManager getSharedInstance] retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT max_time FROM Post WHERE post_id = %@",self.postId]];
        if([[[minTime firstObject] objectForKey:@"MAX_TIME"] intValue]!=0)
            [data setValue:[NSString stringWithFormat:@"%@",[[minTime firstObject] objectForKey:@"MAX_TIME"]] forKey:@"timeStamp"];
    }
    
    NSString *url =[NSString stringWithFormat:@"%@/scripts/post_new_comments.php",gupappUrl];
    [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData * data = (NSData*)responseObject;
        NSError *error = nil;
        NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        NSLog(@"error %@",JSON);
        _indecaterView.hidden = YES;
        indecater.hidden = YES;
        waitLbl.hidden = YES;
        if (JSON.count>0) {
            for(NSString *data in JSON){
                
                NSString *postId = [data stringBetweenString:@"(postid)" andString:@"(/postid)"];
                NSString *groupID= [data stringBetweenString:@"(groupID)" andString:@"(/groupID)"];
                NSString *message_type= [data stringBetweenString:@"(message_type)" andString:@"(/message_type)"];
                NSString *timeStamp= [data stringBetweenString:@"(TimeStamp)" andString:@"(/TimeStamp)"];
                NSString *from_user_name= [data stringBetweenString:@"(from_user_name)" andString:@"(/from_user_name)"];
                NSString *from_user_image= [data stringBetweenString:@"(from_user_image)" andString:@"(/from_user_image)"];
                NSString *from_user_id= [data stringBetweenString:@"(from_user_id)" andString:@"(/from_user_id)"];
                NSString *body= [data stringBetweenString:@"(body)" andString:@"(/body)"];
//                NSString *isPost= [data stringBetweenString:@"(ispost)" andString:@"(/ispost)"];
//                NSString *messageId = [data stringBetweenString:@"(referenceID)" andString:@"(/referenceID)"];
                BOOL messageExist=[[self appDelegate]CheckIfMessageIsDuplicateFrom:from_user_id ofMessageTime:timeStamp isGroupMsg:true];
                if(!messageExist){
                     NSString *messageid=[[self appDelegate] PutMessageInStorage:[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:message_type];
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_group (group_id,user_id,time_stamp,message_id,pinned,spam,deleted,read,messageStatus,received_time,sendername,sender_image,orignal_time,post_id)VALUES(%@,%@,'%@',%@,0,0,0,1,1,'%@','%@','%@','%@',%@)",groupID,from_user_id,timeStamp,messageid,timeStamp,from_user_name,from_user_image,timeStamp,postId]];

                }
            }
            
            NSString *maxTime = [[JSON firstObject] stringBetweenString:@"(TimeStamp)" andString:@"(/TimeStamp)"];
            NSString *minTime = [[JSON lastObject] stringBetweenString:@"(TimeStamp)" andString:@"(/TimeStamp)"];
            [[DatabaseManager getSharedInstance] executeQueryWithQuery:[NSString stringWithFormat:@"UPDATE Post set max_time = %@,min_time = %@ WHERE post_id = %@",maxTime,minTime, self.postId]];
            
            NSArray *arr= [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select messageStatus,chat_group.id,user_id,time_stamp,message_id,pinned,spam,read,message_type,message_text,message_filename,message_deleted,received_time,sendername,sender_image  from chat_group INNER JOIN chat_message where read=1 AND post_id =%@ AND group_id=%@ AND message_type!='(null)' AND user_id!='(null)' AND message_id=chat_message.id order by chat_group.time_stamp DESC LIMIT 50",self.postId,GroupId]];
            
            NSMutableArray *mutableArray = [NSMutableArray array];
            int arrlen = arr.count-1;
            for (int i = 0; i<arr.count ; i++) {
                [mutableArray addObject:[arr objectAtIndex:arrlen]];
                --arrlen;
            }
            chatHistory=nil;
            chatHistory = [NSArray array];
            chatHistory = [chatHistory arrayByAddingObjectsFromArray:mutableArray];
            [pinnedMessge removeAllObjects];
            for (int i=0; i<[chatHistory count];i++){
                BOOL ispinned=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"PINNED" ForRowIndex:i givenOutput:chatHistory] boolValue];
                if (ispinned) {
                    [pinnedMessge addObject:[NSString stringWithFormat:@"%i",i]];
                }
            }
            CurrentlyPinnedMessageRowIndex=-5;
            
            [chatTable reloadData];
//            if (unreadMessage.count) {
//                NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:unreadMessage.count-1 inSection:1];
//                [chatTable scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
//
//            }
            
            [self getOlderComments];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _indecaterView.hidden = YES;
        indecater.hidden = YES;
        waitLbl.hidden = YES;
        
    }];
    
}

-(void)getOlderComments{
    
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
    [data setValue:self.postId forKey:@"postId"];
     [data setValue:GroupId forKey:@"groupId"];
    NSArray *minTime = [[DatabaseManager getSharedInstance] retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT min_time FROM Post WHERE post_id = %@",self.postId]];
    [data setValue:[NSString stringWithFormat:@"%@",[[minTime firstObject] objectForKey:@"MIN_TIME"]] forKey:@"timeStamp"];
    
    NSString *url =[NSString stringWithFormat:@"%@/scripts/post_comment_history.php",gupappUrl];
    [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData * data = (NSData*)responseObject;
        NSError *error = nil;
        NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        NSLog(@"error %@",JSON);
        
        if (JSON.count>0) {
            for(NSString *data in JSON){
                
                NSString *postId = [data stringBetweenString:@"(postid)" andString:@"(/postid)"];
                NSString *groupID= [data stringBetweenString:@"(groupID)" andString:@"(/groupID)"];
                NSString *message_type= [data stringBetweenString:@"(message_type)" andString:@"(/message_type)"];
                NSString *timeStamp= [data stringBetweenString:@"(TimeStamp)" andString:@"(/TimeStamp)"];
                NSString *from_user_name= [data stringBetweenString:@"(from_user_name)" andString:@"(/from_user_name)"];
                NSString *from_user_id= [data stringBetweenString:@"(from_user_id)" andString:@"(/from_user_id)"];
                NSString *body= [data stringBetweenString:@"(body)" andString:@"(/body)"];
//                NSString *isPost= [data stringBetweenString:@"(ispost)" andString:@"(/ispost)"];
                BOOL messageExist=[[self appDelegate]CheckIfMessageIsDuplicateFrom:from_user_id ofMessageTime:timeStamp isGroupMsg:true];
                if(!messageExist){
                    NSString *messageid=[[self appDelegate] PutMessageInStorage:[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:message_type];
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_group (group_id,user_id,time_stamp,message_id,pinned,spam,deleted,read,messageStatus,received_time,sendername,orignal_time,post_id)VALUES(%@,%@,'%@',%@,0,0,0,1,1,'%@','%@','%@',%@)",groupID,from_user_id,timeStamp,messageid,timeStamp,from_user_name,timeStamp,postId]];
            }
                
           }
            
            NSString *minTime = [[JSON lastObject] stringBetweenString:@"(TimeStamp)" andString:@"(/TimeStamp)"];
            [[DatabaseManager getSharedInstance] executeQueryWithQuery:[NSString stringWithFormat:@"UPDATE Post set min_time = %@ WHERE post_id = %@",minTime,self.postId]];
            NSArray *dataOld = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select messageStatus,chat_group.id,user_id,time_stamp,message_id,pinned,spam,read,message_type,message_text,message_filename,message_deleted,received_time,sendername,sender_image from chat_group INNER  JOIN chat_message where read=1 AND post_id =%@ AND group_id=%@ AND message_type!='(null)' AND user_id!='(null)' AND time_stamp < %@ AND message_id=chat_message.id order by chat_group.time_stamp DESC LIMIT 50",self.postId,GroupId,[[chatHistory firstObject] objectForKey:@"TIME_STAMP"]]];
            
            NSMutableArray *mutableArray = [NSMutableArray array];
            int arrlen = dataOld.count-1;
            for (int i = 0; i<dataOld.count ; i++) {
                [mutableArray addObject:[dataOld objectAtIndex:arrlen]];
                --arrlen;
            }

            [mutableArray addObjectsFromArray:chatHistory];
            chatHistory = nil;
            chatHistory = mutableArray;
            
            [pinnedMessge removeAllObjects];
            for (int i=0; i<[chatHistory count];i++){
                BOOL ispinned=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"PINNED" ForRowIndex:i givenOutput:chatHistory] boolValue];
                if (ispinned) {
                    [pinnedMessge addObject:[NSString stringWithFormat:@"%i",i]];
                }
            }
            CurrentlyPinnedMessageRowIndex=-5;
//            if (unreadMessage.count) {
//                NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:unreadMessage.count-1 inSection:1];
//                [chatTable scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
//                
//            }
            
            
            [chatTable reloadData];
        }
        
        if(pullRfrs.isRefreshing)
            [pullRfrs endRefreshing];
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(pullRfrs.isRefreshing)
            [pullRfrs endRefreshing];
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:error.localizedDescription  message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        
    }];
}


-(void)getOlderBtnClicked{

    
    NSString *maxTime = [[chatHistory firstObject] objectForKey:@"TIME_STAMP"];
    NSArray *arr= [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select messageStatus,chat_group.id,user_id,time_stamp,message_id,pinned,spam,read,message_type,message_text,message_filename,message_deleted,received_time,sendername,sender_image  from chat_group INNER  JOIN chat_message where read=1 AND post_id =%@ AND group_id=%@ AND message_type!='(null)' AND user_id!='(null)' AND message_id=chat_message.id AND time_stamp < %@ order by chat_group.time_stamp DESC LIMIT 50",self.postId,GroupId,maxTime]];
    NSMutableArray *mutableArray = [NSMutableArray array];
//    for (int i= [arr count]-1; i==0; i--) {
//        [mutableArray addObject:[arr objectAtIndex:i]];
//    }
    int arrlen = arr.count-1;
    for (int i = 0; i<arr.count ; i++) {
        [mutableArray addObject:[arr objectAtIndex:arrlen]];
        --arrlen;
    }
    [mutableArray addObjectsFromArray:chatHistory];
    chatHistory = nil;
    chatHistory = mutableArray;
    
//    chatHistory =[chatHistory arrayByAddingObjectsFromArray:mutableArray];
    [chatTable reloadData];
    
    _indecaterView.hidden = NO;
    indecater.hidden = NO;
    waitLbl.hidden = NO;
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
    [data setValue:self.postId forKey:@"postId"];
    [data setValue:GroupId forKey:@"groupId"];
    NSArray *minTime = [[DatabaseManager getSharedInstance] retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT min_time FROM Post WHERE post_id = %@",self.postId]];
    [data setValue:[NSString stringWithFormat:@"%@",[[minTime firstObject] objectForKey:@"MIN_TIME"]] forKey:@"timeStamp"];
    
     NSString *url =[NSString stringWithFormat:@"%@/scripts/post_comment_history.php",gupappUrl];
    [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData * data = (NSData*)responseObject;
        NSError *error = nil;
        NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//        NSLog(@"error %@",JSON);
        _indecaterView.hidden = YES;
        indecater.hidden = YES;
        waitLbl.hidden = YES;
        if (JSON.count>0) {
            for(NSString *data in JSON){
                
                NSString *postId = [data stringBetweenString:@"(postid)" andString:@"(/postid)"];
                NSString *groupID= [data stringBetweenString:@"(groupID)" andString:@"(/groupID)"];
                NSString *message_type= [data stringBetweenString:@"(message_type)" andString:@"(/message_type)"];
                NSString *timeStamp= [data stringBetweenString:@"(TimeStamp)" andString:@"(/TimeStamp)"];
                NSString *from_user_name= [data stringBetweenString:@"(from_user_name)" andString:@"(/from_user_name)"];
                NSString *from_user_id= [data stringBetweenString:@"(from_user_id)" andString:@"(/from_user_id)"];
                NSString *body= [data stringBetweenString:@"(body)" andString:@"(/body)"];
//                NSString *isPost= [data stringBetweenString:@"(ispost)" andString:@"(/ispost)"];
                
                BOOL messageExist=[[self appDelegate]CheckIfMessageIsDuplicateFrom:from_user_id ofMessageTime:timeStamp isGroupMsg:true];
                if(!messageExist){
                    NSString *messageid=[[self appDelegate] PutMessageInStorage:[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:message_type];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_group (group_id,user_id,time_stamp,message_id,pinned,spam,deleted,read,messageStatus,received_time,sendername,orignal_time,post_id)VALUES(%@,%@,'%@',%@,0,0,0,1,1,'%@','%@','%@',%@)",groupID,from_user_id,timeStamp,messageid,timeStamp,from_user_name,timeStamp,postId]];
                    
                }
            }
        }
        
        NSString *minTime = [[JSON lastObject] stringBetweenString:@"(TimeStamp)" andString:@"(/TimeStamp)"];
        [[DatabaseManager getSharedInstance] executeQueryWithQuery:[NSString stringWithFormat:@"UPDATE Post set min_time = %@ WHERE post_id = %@",minTime,self.postId]];
        
        NSArray *dataOld = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select messageStatus,chat_group.id,user_id,time_stamp,message_id,pinned,spam,read,message_type,message_text,message_filename,message_deleted,received_time,sendername,sender_image  from chat_group INNER  JOIN chat_message where read=1 AND post_id =%@ AND group_id=%@ AND message_type!='(null)' AND user_id!='(null)' AND time_stamp < %@ AND message_id=chat_message.id order by chat_group.time_stamp DESC LIMIT 50",self.postId,GroupId,[[chatHistory firstObject] objectForKey:@"TIME_STAMP"]]];
        
        if(dataOld.count>0){
            NSMutableArray *mutableArray = [NSMutableArray array];
            int arrlen = dataOld.count-1;
            for (int i = 0; i<dataOld.count ; i++) {
                [mutableArray addObject:[dataOld objectAtIndex:arrlen]];
                --arrlen;
            }
            
            
            //            NSArray *array =[NSArray arrayWithArray:chatHistory];
            [mutableArray addObjectsFromArray:chatHistory];
            chatHistory = nil;
            chatHistory = mutableArray;
            [pinnedMessge removeAllObjects];
            for (int i=0; i<[chatHistory count];i++){
                BOOL ispinned=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"PINNED" ForRowIndex:i givenOutput:chatHistory] boolValue];
                if (ispinned) {
                    [pinnedMessge addObject:[NSString stringWithFormat:@"%i",i]];
                }
            }
            CurrentlyPinnedMessageRowIndex=-5;
            
            [chatTable reloadData];
            if(pullRfrs.isRefreshing)
                [pullRfrs endRefreshing];
            NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:JSON.count inSection:0];
            [chatTable scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(pullRfrs.isRefreshing)
            [pullRfrs endRefreshing];
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:error.localizedDescription  message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        
    }];
    
}

-(void)setActivityIndicator{
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    
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

#pragma mark- keyboard up down
- (void) keyboardWillShow:(NSNotification *)notification {
    
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float keyBdHeight;
    if (kbSize.height<kbSize.width){
        keyBdHeight=kbSize.height;
    }else{
        keyBdHeight=kbSize.width;
    }
    
    menuView.frame = CGRectMake(0, self.view.frame.size.height-keyBdHeight-85, self.view.frame.size.width, 80);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(00.0, 0.0, keyBdHeight, 0.0);
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;
    mainScroll.scrollEnabled=FALSE;
    
    CGRect aRect =[self convertView:mainScroll];
    aRect.size.height -= keyBdHeight;
    //[chatTable sizeToFit];
    //chatTable.layer.borderWidth=2;
    [self adjustHeightOfTableview];
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:chatHistory.count-1 inSection:0];
    if(chatHistory.count!=0){
        [chatTable scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        //        chatTable.frame = CGRectMake(0, 0, chatTable.frame.size.width, chatTable.frame.size.height-keyBdHeight);
        _tabBarView.frame = CGRectMake(0, accessoryView.frame.origin.y-49, self.view.frame.size.width, accessoryTab.frame.size.height);
    }
    if (!CGRectContainsPoint(aRect, TXFRAME.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, keyBdHeight);
        [mainScroll setContentOffset:scrollPoint animated:NO];
    }
    
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    //    [self adjustHeightOfTableview];
    [chatTable setFrame:CGRectMake(0,0 ,mainScroll.frame.size.width,mainScroll.frame.size.height-54)];
    
    menuView.frame = CGRectMake(0, self.view.frame.size.height-80, self.view.frame.size.width, 80);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 0.0);
    //    chatTable.frame = CGRectMake(chatTable.frame.origin.x, chatTable.frame.origin.y, chatTable.frame.size.width, chatTable.frame.size.height);
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;
    mainScroll.scrollEnabled=YES;
}

- (void)adjustHeightOfTableview{
    
    CGFloat height = chatTable.contentSize.height;
    CGFloat maxHeight = chatTable.superview.frame.size.height - chatTable.frame.origin.y;
    if (height > maxHeight)
        height = maxHeight;
    chatTable.frame = CGRectMake(0,0, chatTable.frame.size.width,chatTable.frame.size.height-mainScroll.contentInset.bottom) ;
    [chatTable setCenter:CGPointMake(chatTable.frame.size.width/2,mainScroll.frame.size.height-54-chatTable.frame.size.height/2 )];
}

- (CGRect)convertView:(UIView*)view{
    
    CGRect rect = view.frame;
    
    while(view.superview){
        view = view.superview;
        rect.origin.x += view.frame.origin.x;
        rect.origin.y += view.frame.origin.y;
    }
    
    return rect;
}

#pragma mark-textview delegates
//-(void)textViewDidBeginEditing:(UITextView *)textViews{
//    if(textViews==textView){
//        TXFRAME=[self convertView:textView];
//        TXFRAME=CGRectMake(TXFRAME.origin.x, TXFRAME.origin.y, TXFRAME.size.width,TXFRAME.size.height);
//        //NSLog(@"frame x=%f y=%f wi=%f he=%f",TXFRAME.origin.x,TXFRAME.origin.y,TXFRAME.size.width,TXFRAME.size.height);
//    }
//}
//
//-(void)textViewDidEndEditing:(UITextView *)textView{
//    
//    
//}

- (BOOL) textView: (UITextView*) textViews shouldChangeTextInRange: (NSRange) range replacementText: (NSString*) text{
    if(textViews==textView){
        if ([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
        //        NSUInteger newLength = [textView.text length] + [text length] - range.length;
        //NSLog(@"lenghth %i",newLength);
        //return (newLength > 100) ? NO : YES;
        return YES;
    }
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    return YES;
}
#pragma mark-referance object
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

#pragma mark-viewcontroller deleates

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)textViewDidBeginEditing:(UITextView *)textViews{
    if([textView.text isEqualToString:@"Type your comment...."])
        textView.text =@"";
}
- (void)textViewDidEndEditing:(UITextView *)textViews{
    if(textView.text.length==0)
        textView.text =@"Type your comment....";
}
-(IBAction)dissmisal:(UIButton*)sender{
    
    [self.parentViewController.parentViewController.view setUserInteractionEnabled:YES];
    [sender.superview removeFromSuperview];
}

-(void)didHideEditMenu{
    [UIMenuController sharedMenuController].menuItems=nil;
    menu=nil;
}

-(void)viewWillDisappear:(BOOL)animated{
    [updater invalidate];
    updater=nil;
    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_group set read=1 where post_id=%@ ",self.postId]];
    self.tabBarController.tabBar.hidden=NO;
    [audioLenght invalidate];
    audioLenght=Nil;
    [contactNameLabel setHidden:YES];
    [imageViewForStatus setHidden:YES];
    if (![[self.navigationController viewControllers] containsObject:self]) {
        //NSLog(@"stack %@",[self.navigationController viewControllers ]);
    }
    
}

#pragma mark-initial setup
-(void)getMembersList{
    NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and deleted!=1",[chatWithUser userID]]];
    membersID=[[NSMutableArray alloc]init];
    for (int i=0; i<[tempmembersID count];i++){
        [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
    }
    //NSLog(@"membersID %@",membersID);
}

-(void)viewGroupInfo{
    NSIndexPath *indexp;
    if ([pinnedMessge count]==0){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:Nil message:@"There are no pinned Messages" delegate:Nil cancelButtonTitle:Nil otherButtonTitles:@"OK", nil];
        [alert show];
        CurrentlyPinnedMessageRowIndex=-5;
    }else{
        if (CurrentlyPinnedMessage>[pinnedMessge count]){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:Nil message:@"No further pinned Messages" delegate:Nil cancelButtonTitle:Nil otherButtonTitles:@"OK", nil];
            [alert show];
            CurrentlyPinnedMessage=0;
            CurrentlyPinnedMessageRowIndex=-5;
            [chatTable reloadData];
        }else{
            indexp=[NSIndexPath indexPathForRow:[[pinnedMessge objectAtIndex:CurrentlyPinnedMessage] integerValue] inSection:0];
            CurrentlyPinnedMessageRowIndex=indexp.row;
            //  [chatTable scrollToRowAtIndexPath:indexp              atScrollPosition:UITableViewScrollPositionMiddle                               animated:YES];
            [UIView animateWithDuration:0.2 animations:^{
                [chatTable scrollToRowAtIndexPath:indexp atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            } completion:^(BOOL finished){
                SMMessageViewTableCell *cell =(SMMessageViewTableCell*) [chatTable cellForRowAtIndexPath:indexp];
                // [cell setBackgroundColor:[UIColor redColor]];
                [cell.contentView setBackgroundColor:[UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1]];
                [chatTable reloadData];
                
            }];
            CurrentlyPinnedMessage++;
            if (CurrentlyPinnedMessage>=[pinnedMessge count]){
                CurrentlyPinnedMessage=[pinnedMessge count]+5;
            }
        }
        
    }
  
}

-(IBAction)showAccessoryView:(id)sender{
    //    accessoryTab.frame=CGRectMake(0, chatTable.frame.size.height-49, accessoryTab.frame.size.width, accessoryTab.frame.size.height);
    [messageField resignFirstResponder];
    
    if (![_tabBarView isHidden]) {
        [_tabBarView setHidden:YES];
    }else{
        _tabBarView.frame = CGRectMake(0,self.view.bounds.size.height-(49+54), self.view.bounds.size.width, 49);
        [_tabBarView setHidden:NO];
    }
}

-(NSString *)documentsPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

-(NSString *)CachesPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

-(NSString *)getPresentDateTime{
    
    NSDateFormatter *dateTimeFormat = [[NSDateFormatter alloc] init];
    [dateTimeFormat setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSDate *now = [[NSDate alloc] init];
    NSString *theDateTime = [dateTimeFormat stringFromDate:now];
    dateTimeFormat = nil;
    now = nil;
    return theDateTime;
}

-(void)update{
    for (NSDictionary *rowElement in chatHistory){
        
        if ([[rowElement objectForKey:@"MESSAGESTATUS"]isEqual:@"0"]){
            
            double   timeI = [[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
            if ((timeI-[[rowElement objectForKey:@"TIME_STAMP"] doubleValue])<15000&&(timeI-[[rowElement objectForKey:@"TIME_STAMP"] doubleValue])>7700){
                
                [chatTable reloadData];
            }
        }
    }
}

#pragma mark-audio recording
-(void)recodingSetup{
    //audio
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"recordedAudio.aac",
                               nil];
    
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc]initWithURL:outputFileURL settings:recordSetting error:NULL];
    
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture{
    
    if (gesture.state == UIGestureRecognizerStateBegan){
        [sendButton setUserInteractionEnabled:NO];
        [cancelButton setUserInteractionEnabled:NO];
        [recorderButton setImage:[UIImage imageNamed:@"recorder_on.png"] forState:UIControlStateNormal];
        titleLabel.text =@"00.30";
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [self recodingSetup];
        // Start recording
        
        [recorder record];
        timerInseconds=29;
        milliseconds=99;
        timer = [NSTimer scheduledTimerWithTimeInterval:.01f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
        
        
    }else if ( gesture.state == UIGestureRecognizerStateEnded ) {
        [sendButton setUserInteractionEnabled:YES];
        [cancelButton setUserInteractionEnabled:YES];
        
        [self stopRecording];
    }
}

-(void)stopRecording{
    [sendButton setUserInteractionEnabled:YES];
    [cancelButton setUserInteractionEnabled:YES];
    [timer invalidate];
    [recorderButton setImage:[UIImage imageNamed:@"recorder_done.png"] forState:UIControlStateNormal];
    [recorderButton setUserInteractionEnabled:NO];
    [recorder stop];

}

- (void)updateCounter:(NSTimer *)theTimer {
    if(timerInseconds != 0 ){
        if (milliseconds==0){
            timerInseconds--;
            milliseconds=99;
        }else{
            milliseconds--;
        }
        
        titleLabel.text = [NSString stringWithFormat:@"%02d:%02d", timerInseconds,milliseconds];
    }else{
        [theTimer invalidate];
        titleLabel.text = [NSString stringWithFormat:@"%02d:%02d", 0,0];
        [self stopRecording];
    }
    
    
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [audioLenght invalidate];
    [playerstatus removeFromSuperview];
    [audioPlayersCurrentTime removeFromSuperview];
    [audioPlayersAudioDuration removeFromSuperview];
    playerstatus=nil;
    playingAudio=NO;
    [chatTable reloadData];
}

-(void)sendRecordedClip:(id)sender{
    
    [self uploadFileWithData:[NSData dataWithContentsOfFile:[self documentsPath:@"recordedAudio.aac"]] type:@"aac"];
    [frezzer removeFromSuperview];
    [vc setHidden:YES];
}

-(void)cancelRecording:(id)sender{
    
    [frezzer removeFromSuperview];
    [vc setHidden:YES];
}

-(void)holdToRecord:(id)sender{
    
}


#pragma mark-tabbar delegates
-(void)addImage{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = NO;
        
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Camera Unavailable"
                                                       message:@"Unable to Find a Camera on Your Device."
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }

}
-(void)addGallery{
    UIImagePickerController *Ipicker = [[UIImagePickerController alloc] init];
    [Ipicker setDelegate:self];
    Ipicker.allowsEditing = NO;
    Ipicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [Ipicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    [self presentViewController:Ipicker animated:YES completion:NULL];
}
-(void)addContact{
    ContactList *vcardOBJ=[[ContactList alloc]init];
    [vcardOBJ setBehaviourOfContactList:@"vcard" from:self];
    vcardOBJ.chatWithUserID=[chatWithUser userID];
    // [vcardOBJ setTitle:@"Contacts"];
    [self.navigationController pushViewController:vcardOBJ animated:YES ];
}
-(void)addRecording{
    [self.view endEditing:YES ];
    frezzer=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    [frezzer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    [self.view addSubview:frezzer];
    //NSLog(@"recording");
    vc=[[UIView alloc]initWithFrame:CGRectMake(35, 60,250, 200)];
    vc.backgroundColor=[UIColor whiteColor];
    //   [vc.layer setBorderWidth:4.0];
    [vc.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    //  vc.layer.cornerRadius=8.0;
    vc.layer.cornerRadius = 5.0f;
    vc.layer.masksToBounds = YES;
    [vc setCenter:chatTable.center];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 20, 195, 15)];
    [titleLabel setText:@"Hold and Talk"];
    //titleLabel.backgroundColor=[UIColor redColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.f]];
    titleLabel.textColor =[UIColor orangeColor];
    
    [vc addSubview:titleLabel];
    
    recorderButton=[UIButton buttonWithType:UIButtonTypeCustom];
    recorderButton.frame= CGRectMake(70, 40, 100, 100);
    [recorderButton setImage:[UIImage imageNamed:@"recorder1"] forState:UIControlStateNormal];
    //[recorderButton setImage:[UIImage imageNamed:@"recorder_on.png"] forState:UIControlStateHighlighted];
    //recorderButton.backgroundColor =[UIColor redColor];
    [recorderButton setUserInteractionEnabled:YES];
    [recorderButton addTarget:self action:@selector(holdToRecord:) forControlEvents:UIControlEventTouchUpInside];
    [vc addSubview:recorderButton];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [recorderButton addGestureRecognizer:longPress];
    
    cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame= CGRectMake(-2, 161, 127, 40);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    cancelButton.layer.borderWidth=.3f;
    cancelButton.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    [cancelButton addTarget:self action:@selector(cancelRecording:) forControlEvents:UIControlEventTouchUpInside];
    [vc addSubview:cancelButton];
    
    sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame= CGRectMake(125, 161, 127, 40);
    [sendButton setTitle:@"OK" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    sendButton.layer.borderWidth=0.3f;
    sendButton.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    [sendButton setUserInteractionEnabled:NO];
    [sendButton addTarget:self action:@selector(sendRecordedClip:) forControlEvents:UIControlEventTouchUpInside];
    [vc addSubview:sendButton];
    
    [self.view addSubview:vc];
}
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if (item.tag == 0) {
        
        
    }
    if (item.tag == 1){
            }
    if (item.tag == 2){
        
    
        
    }
    if (item.tag == 3){
        
    }
}

#pragma mark-imagepicker delegates
-(NSData*)compressedImage:(NSData*)imagedata{
    
    NSData *compressedImage;
    double compressionRatio = 1;
    int resizeAttempts = 5;
    UIImage *largeImage=[UIImage imageWithData:imagedata];
    while ([imagedata length] > 400000 && resizeAttempts > 0) {
        resizeAttempts -= 1;
        
//        NSLog(@"Image was bigger than 400000 Bytes. Resizing.");
//        NSLog(@"%i Attempts Remaining",resizeAttempts);
        
        //Increase the compression amount
        compressionRatio = compressionRatio*0.5;
//        NSLog(@"compressionRatio %f",compressionRatio);
        //Test size before compression
//        NSLog(@"Current Size: %i",[imagedata length]);
        compressedImage = UIImageJPEGRepresentation(largeImage,compressionRatio);
        
        //Test size after compression
        
    }
    return compressedImage;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSData *imgPngData;
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        imgPngData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage],0.1);
//        NSLog(@"edited image");
        
    }else{
        imgPngData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage],0.1);
//        NSLog(@"original image");
    }
    
//    NSLog(@"%.2f",(float)imgPngData.length/1024.0f/1024.0f);
    [self dismissViewControllerAnimated:YES completion:Nil];
    [self uploadFileWithData:imgPngData type:@"jpg"];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark-connecrion related
-(void)uploadFileWithData:(NSData *)data type:(NSString*)type{
    
    //NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"first.png"], 90);
    
    fileToBeUploaded=data;
    uploadprogress.progress =0;
    [uploadlable setText:[NSString stringWithFormat:@"Uploading..."]];
    NSString *urlString = [NSString stringWithFormat:@"%@/scripts/chat_upload.php",gupappUrl ]; // URL of upload script.
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSMutableData *body = [NSMutableData data];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"chat_file\"; filename=\"a.%@\"\r\n" ,type] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:data]];
    //NSLog(@"%.2f",(float)data.length/1024.0f/1024.0f);
    //NSLog(@"%@",[NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile]);
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //  parameter username
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@",[self appDelegate].myUserID] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // NSError *oo;
    uploadFile = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [uploadFile scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [uploadFile start];
    uploadFileResponce = [[NSMutableData alloc] init];
    /*
     NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&oo];
     NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
     //NSLog(@"returnString: %@ \n error=%@", returnString,oo);
     
     *///
    
    [self.view addSubview:freezer ];
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == uploadFile) {
        
        [uploadFileResponce setLength:0];
    }
    if (connection == reportSpam) {
        
        [reportSpamResponce setLength:0];
    }
    if (connection==fetchHistory)
    {
        
        [historyResponse setLength:0];
        
    }
    if(connection==fetchRefresh){
        [refreshResponse setLength:0];
    }
    /* if (connection == downloadFile) {
     
     [downloadFileResponce setLength:0];
     }
     */
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    //NSLog(@"did recieve data");
    
    if (connection == uploadFile) {
        
        
        [uploadFileResponce appendData:data];
    }
    if (connection == reportSpam) {
        
        
        [reportSpamResponce appendData:data];
    }
    if (connection ==fetchHistory) {
        [historyResponse appendData:data];
    }
    if(connection==fetchRefresh){
        [refreshResponse appendData:data];
    }
    /*  if (connection == downloadFile) {
     
     //NSLog(@"2");
     [downloadFileResponce appendData:data];
     }*/
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == uploadFile ||connection ==reportSpam||connection==fetchHistory) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        _indecaterView.hidden = YES;
        [indecater stopAnimating];
        indecater.hidden = YES;
        waitLbl.hidden = YES;
    }
    if (connection==fetchHistory){
        //        [fetchingPleaseWait setHidden:YES];
        //        [fetchingPleaseWait stopAnimating];
    }
    [freezer removeFromSuperview];
    /*   if (connection == downloadFile) {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[error localizedDescription]   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
     
     [alert show];
     }
     */
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (connection == uploadFile) {
        
        NSString *str = [[NSMutableString alloc] initWithData:uploadFileResponce encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSString *type;
        NSDictionary *responce= res[@"response"];
        if ([responce[@"status"] integerValue]){
            //NSLog(@"Response:%@\n",str);
            if ([[[(NSString*)responce[@"uploadedfile"]componentsSeparatedByString:@"."] objectAtIndex:1] isEqual:@"jpg"])
                type=@"image";
            else if ([[[(NSString*)responce[@"uploadedfile"]componentsSeparatedByString:@"."] objectAtIndex:1] isEqual:@"aac"]){
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                NSString *filePath = [self documentsPath:@"recordedAudio.aac"];
                NSError *error;
                BOOL success =[fileManager removeItemAtPath:filePath error:&error];
                if (success) {
                }else{
                    //NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
                }
                type=@"audio";
            }
            //send to server
            timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] ;
            NSString *msgToBesend=[responce objectForKey:@"uploadedfile"];
            msgToBesend =[msgToBesend stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//            NSString *groupID=[chatType isEqual:@"personal"]?@"":[chatWithUser userID];
//            BOOL isThisGroupChat=[chatType isEqual:@"group"]?true:false;
            [[self appDelegate] storeMessageInDatabaseForBody:msgToBesend forMessageType:type messageTo:chatWithUser groupId:GroupId isGroup:true forTimeInterval:timeInMiliseconds senderName:[self appDelegate].MyUserName postid:self.postId isRead:@"1" withImage:myImage];
             [self updateGroupTime:timeInMiliseconds];
            NSString *messageid=[[self appDelegate] CheckIfMessageExist:[msgToBesend stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:type];
            NSString *recieversID=[chatWithUser userID];
            
            NSString *referanceID=  [[self appDelegate] getLinkedIdOfMessageID:messageid forTimestamp:timeInMiliseconds senderID:myUserId recieversID:recieversID chattype:chatType];
            [[self appDelegate] sendAcknoledgmentPacketId:referanceID isGroupAcknoledgment:true];
//            if ([chatType isEqual:@"personal"]) {
//                [self sendMessageWithReceiversJid:chatWithUser message:[responce objectForKey:@"uploadedfile"] type:type groupId:@""];
//            }else{
            
//                NSDictionary *userDictonary = [master_table lastObject];
            
                NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_group.id from chat_group INNER  JOIN chat_message where user_id=%@ AND post_id = %@ AND messageStatus=0 AND  message_id=chat_message.id order by chat_group.time_stamp ASC",[self appDelegate].myUserID,self.postId]];
                XMPPMessage *msg = [XMPPMessage message];
                [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
                [msg addAttributeWithName:@"groupCounter" stringValue:[self appDelegate].groupCounter];
                [msg addAttributeWithName:@"to" stringValue:_toJid];
                
                [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ];
                [msg addAttributeWithName:@"isResend" boolValue:FALSE];
                
                msgToBesend=[self RadhaCompatiableEncodingForstring:[responce objectForKey:@"uploadedfile"]];
                
                NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
                NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[msgToBesend stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
                
                NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[self appDelegate].myUserID];
                NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:[self appDelegate].MyUserName];
                
                NSXMLElement *reference = [NSXMLElement elementWithName:@"referenceID" stringValue:[[groupUnsendMessages objectAtIndex:0] objectForKey:@"CHAT_GROUP.ID"]];

                NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:type];
                NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:timeInMiliseconds];
                NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:GroupId];
                NSXMLElement *post = [NSXMLElement elementWithName:@"postid" stringValue:self.postId];
                NSXMLElement *isgroup = [NSXMLElement elementWithName:@"ispost" stringValue:[NSString stringWithFormat:@"%i",true]];
                
                [gup addChild:body];
                [gup addChild:reference];
                [gup addChild:from_user_id];
                [gup addChild:from_user_name];
                [gup addChild:timeStamp];
                [gup addChild:message_type];
                [gup addChild:isgroup];
                [gup addChild:post];
                [gup addChild:groupIDs];
                [msg addChild:gup];
                
                
                NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:msgToBesend]];
                [msg addChild:body1];
                if ([self appDelegate].hasInet&&[[self xmppStream] isDisconnected])
                    [[self appDelegate] connect ];
                
                [[self xmppStream] sendElement:msg];
            
            if(unreadMessage.count){
                unreadMessage = nil;
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_group set read=1 where post_id=%@ ",self.postId]];
            }
            
            NSString *fileSavePath = [self CachesPath:[responce objectForKey:@"uploadedfile"]];
            [fileToBeUploaded writeToFile:fileSavePath atomically:YES];
            [self resignFirstResponder];
            [_tabBarView setHidden:YES];
        }else{
            UIAlertView *errormsg=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"%@",responce[@"error_mess"]] delegate:Nil cancelButtonTitle:@"Cancel" otherButtonTitles:Nil, nil];
            [errormsg show];
            
        }
        
    }else if (connection==reportSpam){
        
        NSString *str = [[NSMutableString alloc] initWithData:reportSpamResponce encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"response"];
        UIAlertView *reportSpamError=[[UIAlertView alloc]initWithTitle:nil message:responce[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [reportSpamError show];
    }
    [freezer removeFromSuperview];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    
    //NSLog(@"progress %ld",(long)bytesWritten);
    float progress = [[NSNumber numberWithInteger:totalBytesWritten] floatValue];
    float total = [[NSNumber numberWithInteger: totalBytesExpectedToWrite] floatValue];
    uploadprogress.progress = progress/total;
    [uploadlable setText:[[NSString stringWithFormat:@"Uploading %.0f",progress/total*100] stringByAppendingString:@"%"]];
}



#pragma mark -
#pragma mark Table view delegates
-(void)updateTitleStatus{
    
    NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select user_status from contacts where user_id=%i ", [[chatWithUser userID] integerValue]]];
    NSString *status;
    @try {
        status= (NSString*)[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_STATUS" ForRowIndex:0 givenOutput:output];
    }
    @catch (NSException *exception) {
        status=@"offline";
    }
    if([status isEqualToString:@"online"]){
        [imageViewForStatus setImage:[UIImage imageNamed:@"online"]];
    }else if([status isEqualToString:@"offline"]){
        [imageViewForStatus setImage:[UIImage imageNamed:@"offline"]];
    }else{
        [imageViewForStatus setImage:[UIImage imageNamed:@"away"]];
    }
    
}

-(void)UpdateScreen{
//    [self updateChatHistory];
    [self tableViewScrollToBottomAnimated:YES];
}

-(void)postUpdate:(NSString*)postID messageID:(NSString *)msgid groupID:(NSString *)group{
    NSArray *tempArray = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select messageStatus,chat_group.id,user_id,time_stamp,message_id,pinned,spam,read,message_type,message_text,message_filename,message_deleted,received_time,sendername,sender_image  from chat_group INNER  JOIN chat_message where post_id =%@ AND group_id=%@ AND message_id = %@ AND message_type!='(null)' AND user_id!='(null)' AND message_id=chat_message.id",postID,group,msgid]];
    
    chatHistory =[chatHistory arrayByAddingObjectsFromArray:tempArray];
    [chatTable reloadData];
    [self tableViewScrollToBottomAnimated:YES];

}

-(void)reloadTable:(NSString*)group_id{
    if([group_id isEqualToString:[[[[_toJid componentsSeparatedByString:@"@"] firstObject] componentsSeparatedByString:@"_"] lastObject]]){
        [chatTable reloadData];
        [self tableViewScrollToBottomAnimated:YES];
    }
    
}

- (void)tableViewScrollToBottomAnimated:(BOOL)animated {
    NSInteger numberOfRows = [chatTable numberOfRowsInSection:0];
    if (numberOfRows) {
        [chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

-(void)updateChatHistory{
    
    chatHistory= [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select messageStatus,chat_group.id,user_id,time_stamp,message_id,pinned,spam,read,message_type,message_text,message_filename,message_deleted,received_time,sendername,sender_image  from chat_group INNER  JOIN chat_message where post_id =%@ AND group_id=%@ AND message_type!='(null)' AND user_id!='(null)' AND message_id=chat_message.id order by chat_group.received_time ASC ",self.postId,GroupId]];
    
    [pinnedMessge removeAllObjects];
    for (int i=0; i<[chatHistory count];i++){
        BOOL ispinned=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"PINNED" ForRowIndex:i givenOutput:chatHistory] boolValue];
        if (ispinned) {
            [pinnedMessge addObject:[NSString stringWithFormat:@"%i",i]];
        }
    }
    CurrentlyPinnedMessageRowIndex=-5;
 }

static CGFloat padding = 20.0;
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if([chatHistory count]!=0){
        [date setAlpha:1];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [UIView animateWithDuration:0.8f
                     animations:^{
                         [date setAlpha:0];
                         
                     }];
    
    [UIView commitAnimations];
    
}



-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}

- (void)scrollingFinish {
    //enter code here
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{/*
  NSDictionary *msg = (NSDictionary *) [chatHistory objectAtIndex:indexPath.row];
  if ([chatType isEqual:@"personal"])
  {
  
  NSInteger msg_id = [[msg objectForKey:@"CHAT_PERSONAL.ID"] integerValue];
  BOOL msg_pinned=[[msg objectForKey:@"PINNED"] boolValue];
  //NSLog(@"pinned ori%i afte %i query %@",msg_pinned,!msg_pinned,[NSString stringWithFormat:@"update chat_personal set pinned=%i where id=%i",!msg_pinned,msg_id]);
  [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_personal set pinned=%i where id=%i",!msg_pinned,msg_id]];
  
  
  }
  else
  {
  NSInteger msg_id = [[msg objectForKey:@"CHAT_GROUP.ID"] integerValue];
  BOOL msg_pinned=[[msg objectForKey:@"PINNED"] boolValue];
  //NSLog(@"pinned ori%i afte %i query %@",msg_pinned,!msg_pinned,[NSString stringWithFormat:@"update CHAT_GROUP set pinned=%i where id=%i",!msg_pinned,msg_id]);
  [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update CHAT_GROUP set pinned=%i where id=%i",!msg_pinned,msg_id]];
  
  }
  [self updateChatHistory];
  [chatTable reloadData];*/
}

-(void)getPreviousTimeStampAtIndex:(NSInteger)index{
    @try{
        NSDictionary *msg = (NSDictionary *) [chatHistory objectAtIndex:index<0?0:index];
        NSString *time = [msg objectForKey:@"RECEIVED_TIME"];
        time=  [time getDateTimeFromUTCTimeInterval];
        NSArray *dateTime=[time componentsSeparatedByString:@" "];
        NSArray *dateComponents=[[dateTime objectAtIndex:0] componentsSeparatedByString:@"-"];
        
        prevMonth=[dateComponents objectAtIndex:1];
        prevYear=[dateComponents objectAtIndex:0];
        prevDay=[dateComponents objectAtIndex:2];
    }@catch (NSException *exception){
        prevMonth=0;
        prevYear=0;
        prevDay=0;
    }
    
}

-(IBAction)expandMessage:(UIButton*)sender{
    //NSLog(@"sender %@\n tagval %i \n ",sender,sender.tag);
    // NSString *tag=sender.tag;
    if(![expandedMessageId containsObject:[NSString stringWithFormat:@"%i",sender.tag]]){
        [expandedMessageId addObject:[NSString stringWithFormat:@"%i",sender.tag]];
    }else{
        [expandedMessageId removeObject:[NSString stringWithFormat:@"%i",sender.tag]];
    }
//    [self updateChatHistory];
    //NSLog(@"chat histoty %@",chatHistory);
    
    [chatTable reloadData];
}

-(NSString*)RadhaCompatiableEncodingForstring:(NSString*)str{
    
    return [str stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
}

-(NSString*)RadhaCompatiableDecodingForString:(NSString*)str{
    
    return  [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    commentCell *cell1 =(commentCell*)cell;
    
    NSDictionary *dic;
    
    if(indexPath.section ==0)
        dic = [chatHistory objectAtIndex:indexPath.row];
    else
        dic = [unreadMessage objectAtIndex:indexPath.row];
    
    cell1.commentObject = self;
    [cell1 drawCell:dic withIndexPath:indexPath];
        
  
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *msg;
    if(indexPath.section == 0){
        msg = (NSDictionary *) [chatHistory objectAtIndex:indexPath.row];
    }
    if(indexPath.section == 1){
        msg = (NSDictionary *) [unreadMessage objectAtIndex:indexPath.row];
    }
        NSString *CellIdentifier;
        
        if([[msg objectForKey:@"MESSAGE_TYPE"] isEqualToString:@"text"]){
            CellIdentifier = @"MessageCellIdentifier";
        }else if([[msg objectForKey:@"MESSAGE_TYPE"] isEqualToString:@"image"]){
            CellIdentifier = @"ImageCellIdentifier";
        }else if([[msg objectForKey:@"MESSAGE_TYPE"] isEqualToString:@"audio"]){
            CellIdentifier = @"AudioCellIdentifier";
        }else if([[msg objectForKey:@"MESSAGE_TYPE"] isEqualToString:@"vcard"]){
            CellIdentifier = @"VCardCellIdentifier";
        }
        
        commentCell *cell = (commentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[commentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
   
        return cell;

    
}

-(void)getSenderName:(NSString*)senderid{
    //    NSString *name;
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        
        XMPPvCardTempModule *vcardTEmpModel = [self appDelegate].xmppvCardTempModule
        ;
        
        [vcardTEmpModel fetchvCardTempForJID:[XMPPJID jidWithString:senderid]];
        //        XMPPvCardTemp *myVcardTemp = [[self appDelegate].xmppvCardTempModule myvCardTemp];
        
        
        
        //                    [myVcardTemp setPhoto:imageData];
        
        //        [[self appDelegate].xmppvCardTempModule updateMyvCardTemp:myVcardTemp];
        
    });
    
}


-(NSString*)getusernameforBody:(NSString*)str{
//NSLog(@"string %@",str);
    int noOfFoundcolon=0;
    
    for (int u=0; u<str.length; u++){
        //NSLog(@"chara %hhd",(char)[str characterAtIndex:u]);
        if ([str characterAtIndex:u]==':'){
            
            noOfFoundcolon++;
            if (noOfFoundcolon==5){
                //NSLog(@"str %@",[str substringFromIndex:u+1]);
                return [str substringFromIndex:u+1];
                
            }
        }
        
    }
    return @"";
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture{
    UIView *tappedView = [gesture.view hitTest:[gesture locationInView:gesture.view] withEvent:nil];
    //NSLog(@"tag val %i\n%@",tappedView.tag,tappedView);
    ImageViewerGup *iv=[[ImageViewerGup alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width,self.view.frame.size.height)];
    iv.tag=tappedView.tag;
    //  iv.layer.borderWidth=3;
    //  iv.layer.borderColor=[UIColor greenColor].CGColor;
    // [iv setCenter:self.view.center];
    
    [iv setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin];
    
    // [iv LoadImage:[tempArray objectAtIndex:index]];
    // iv.layer.borderColor=[UIColor greenColor].CGColor;
    //  iv.layer.borderWidth=2;
    iv.EnabledTapGeture=1;
    iv.EnablePan=0;
    iv.EnablePinchGesture=1;
    iv.EnableRotation=0;
    
    iv.dataSource=self;
    iv.delegate=self;
    
    //NSLog(@"tag %i",tappedView.tag);
    //  iv.ImagePan.layer.borderColor=[UIColor redColor].CGColor;
    //  iv.ImagePan.layer.borderWidth=2;
    [mainScroll addSubview:iv];
}

-(UIImageView *)ImageOfImageViewer:(ImageViewerGup *)imageView{
    //NSLog(@"tag %i",imageView.tag);
    UIImageView *image=[[UIImageView alloc]initWithFrame:imageView.frame];
    [image setBackgroundColor:[UIColor blackColor ]];
    [imageView.activeIndicator setColor:[[UIColor grayColor] colorWithAlphaComponent:0.5]];
    [imageView.activeIndicator startAnimating];
    NSString *Filepath;
    if(imageView.section==1)
        Filepath=[self CachesPath:[[unreadMessage objectAtIndex:imageView.tag] objectForKey:@"MESSAGE_FILENAME"]];
    else
        Filepath=[self CachesPath:[[chatHistory objectAtIndex:imageView.tag] objectForKey:@"MESSAGE_FILENAME"]];//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //  //NSLog(@"image path %@",[NSString stringWithFormat:@"http://gupapp.com/Gup_demo/scripts/media/images/chat_files/%@",[[chatHistory objectAtIndex:imageView.tag] objectForKey:@"MESSAGE_FILENAME"]]);
    //   NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://gupapp.com/Gup_demo/scripts/media/images/chat_files/%@",[[chatHistory objectAtIndex:imageView.tag] objectForKey:@"MESSAGE_FILENAME"]]]];
    
    
    //  dispatch_async(dispatch_get_main_queue(), ^{
    [imageView.activeIndicator stopAnimating];
    [imageView.activeIndicator removeFromSuperview];
    //    //NSLog(@"data %@",imgData);
    UIImage *downloadImage=[UIImage imageWithContentsOfFile:Filepath];
//    NSLog(@"width =%f  height =%f",downloadImage.size.width ,downloadImage.size.height);
    // [imageView.ImagePan setFrame:CGRectMake(0, 0, downloadImage.size.width, downloadImage.size.height)];
    //  [ImagePan setCenter:self.center];
    [image setImage:downloadImage] ;
    [image setBackgroundColor:[UIColor clearColor ]];
    //image.contentMode=UIViewContentModeScaleAspectFit;
    //  });
    
    // });
    [image setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    return image;
}

-(UIImageView *)imageViewBackground:(ImageViewerGup *)imageView{
    return Nil;
}

-(void)ImageViewerWillAppear:(ImageViewerGup*)imageView{
    
}

-(void)ImageViewerDidAppear:(ImageViewerGup*)imageView{
    
}
-(void)ImageViewerDidEnd:(ImageViewerGup*)imageView{
}


//- (BOOL)canBecomeFirstResponder {
//	return YES;
//}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:playerstatus]){
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

#pragma mark - Menu controller
-(void)PinUnpinAt{
    NSDictionary *msg = (NSDictionary *) [chatHistory objectAtIndex:[messageIndex integerValue]];
    if ([chatType isEqual:@"personal"]){
        
        NSInteger msg_id = [[msg objectForKey:@"CHAT_PERSONAL.ID"] integerValue];
        BOOL msg_pinned=[[msg objectForKey:@"PINNED"] boolValue];
        //NSLog(@"pinned ori%i afte %i query %@",msg_pinned,!msg_pinned,[NSString stringWithFormat:@"update chat_personal set pinned=%i where id=%i",!msg_pinned,msg_id]);
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_personal set pinned=%i where id=%i",!msg_pinned,msg_id]];
        
        
    }else{
        
        NSInteger msg_id = [[msg objectForKey:@"CHAT_GROUP.ID"] integerValue];
        BOOL msg_pinned=[[msg objectForKey:@"PINNED"] boolValue];
        //NSLog(@"pinned ori%i afte %i query %@",msg_pinned,!msg_pinned,[NSString stringWithFormat:@"update CHAT_GROUP set pinned=%i where id=%i",!msg_pinned,msg_id]);
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update CHAT_GROUP set pinned=%i where id=%i",!msg_pinned,msg_id]];
        
    }
//    [self updateChatHistory];
    [chatTable reloadData];
    
}

- (void)longPressw:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan){
        [sendButton setUserInteractionEnabled:YES];
        CGPoint location = [recognizer locationInView:chatTable];
        
        NSIndexPath *row = [chatTable indexPathForRowAtPoint:location];
        commentCell *cell = (commentCell *)[chatTable cellForRowAtIndexPath:row];
        
        NSDictionary *msg = (NSDictionary *) [chatHistory objectAtIndex:row.row];
        messageIndex=[NSString stringWithFormat:@"%i",row.row];
        messageType=[msg objectForKey:@"MESSAGE_TYPE"];
        messageSelected=[[msg objectForKey:@"MESSAGE_TYPE"] isEqualToString:@"text"]||[[msg objectForKey:@"MESSAGE_TYPE"] isEqualToString:@"vcard"]?[msg objectForKey:@"MESSAGE_TEXT"]:[msg objectForKey:@"MESSAGE_FILENAME"] ;
        //  messageSelected=[messageSelected stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        messageSentBy=[msg objectForKey:@"USER_ID"];
        messageIdDeleted=[[msg objectForKey:@"MESSAGE_ID"] integerValue];
        
        referencedMessageIdDeleted=[[msg objectForKey:@"CHAT_GROUP.ID"] integerValue];
        
        UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteMessage:)];
        BOOL msg_pinned=[[msg objectForKey:@"PINNED"] boolValue];
        NSString *pinUnpinTitle=msg_pinned?@"Unpin":@"Pin";
        
        UIMenuItem *pinUnpin = [[UIMenuItem alloc] initWithTitle:pinUnpinTitle action:@selector(PinUnpinAt)];
        UIMenuItem *forward = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(forward:)];
        UIMenuItem *reportspam = [[UIMenuItem alloc] initWithTitle:@"Report as Inappropriate" action:@selector(reportSpam:)];
        [cell becomeFirstResponder];
        menu = [UIMenuController sharedMenuController];
        if ([[msg objectForKey:@"MESSAGE_TYPE"] isEqualToString:@"text"]){
            if ([messageSentBy isEqualToString:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]){
                UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMessage:)];
                [menu setMenuItems:[NSArray arrayWithObjects:pinUnpin,copy,delete, forward, nil]];
            }else{
                UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyMessage:)];
                [menu setMenuItems:[NSArray arrayWithObjects:pinUnpin,copy,delete, forward,reportspam, nil]];
            }
            
            messageToBeCopied=[msg objectForKey:@"MESSAGE_TEXT"]  ;
            //  messageToBeCopied=[messageToBeCopied stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        }else{
            [menu setMenuItems:[NSArray arrayWithObjects:pinUnpin,delete, forward,reportspam, nil]];
        }
        [menu setTargetRect:cell.messageText.frame inView:cell];
        [menu setMenuVisible:YES animated:YES];
        
    }else if (recognizer.state == UIGestureRecognizerStateCancelled||recognizer.state == UIGestureRecognizerStateEnded||recognizer.state == UIGestureRecognizerStateFailed){
        //menu=nil;
        
    }
}

-(void)copyMessage:(id)sender{
    [[UIPasteboard generalPasteboard] setString:[[messageToBeCopied UTFDecoded] stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]];
    //menu=nil;
}

- (void)deleteMessage:(id)sender{
    NSArray *outputPersonal=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_personal where message_id=%i ",messageIdDeleted]] ;
    NSArray *outputGroup=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_group where message_id=%i ",messageIdDeleted]];
    NSInteger  noOfMessagesUsedInChat_personal=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputPersonal] integerValue];
    NSInteger  noOfMessagesUsedInChat_Group=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputGroup] integerValue];
    NSInteger noOfMessagesUsed=noOfMessagesUsedInChat_Group+noOfMessagesUsedInChat_personal;
    //NSLog(@"noOfMessagesUsed =%i ",noOfMessagesUsed);
    if (noOfMessagesUsed ==1){
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_message where id=%i",messageIdDeleted]];
        if (![messageType isEqual:@"text"]){
            [self removeFileNamed:messageSelected];
        }
        
    }
    if ([chatType isEqualToString:@"personal"])
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_personal where id=%i",referencedMessageIdDeleted]];
    else
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_group where id=%i",referencedMessageIdDeleted]];
//    [self updateChatHistory];
    [chatTable reloadData];
    // menu=nil;
}

- (void)removeFileNamed:(NSString*)filename{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePathRetrieve =[[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",filename]];
    NSError *error = nil;
    if(![fileManager removeItemAtPath: filePathRetrieve error:&error]) {
        //NSLog(@"Delete failed:%@", error);
    } else {
        //NSLog(@"image removed: %@", filePathRetrieve);
    }
}

- (void)forward:(id)sender{
    
    FirstViewController *forward=[[FirstViewController alloc] initWithNibName:@"FirstViewController_iPhone" bundle:nil];
    forward.type=@"forward";
    forward.msgType=messageType;
    //    NSString *goodValue=[messageSelected UTFEncoded];
    //    forward.messageToBeForwarded=[goodValue stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    forward.messageToBeForwarded=messageSelected;
    //NSLog(@"type %@ msg %@",messageType,messageSelected);
    forward.sender=self;
    [self.navigationController pushViewController:forward animated:YES];
    //  menu=nil;
}

- (void)reportSpam:(id)sender {
    // menu=nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData;
    if ([chatType isEqualToString:@"group"]) {
        postData = [NSString stringWithFormat:@"user_id=%@&spammed_user_id=%@&spam_msg=%@&group_id=%@",[self appDelegate].myUserID,messageSentBy,messageSelected,[chatWithUser userID]];
        //NSLog(@"post data %@",postData);
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/spam_user.php",gupappUrl]]];
    }    else    {
        postData = [NSString stringWithFormat:@"user_id=%@&spammed_user_id=%@&spam_msg=%@&group_id=0",[self appDelegate].myUserID,[chatWithUser userID],messageSelected];
        //NSLog(@"post data %@",postData);
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/spam_user.php",gupappUrl]]];
    }
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    reportSpam= [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [reportSpam scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [reportSpam start];
    reportSpamResponce = [[NSMutableData alloc] init];
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ( buttonIndex==1)
        [self InsertVcardDataTagValue:alertView.tag];
}

-(void)InsertVcardDataTagValue:(int)tag{
    // UIButton *button=(UIButton*)sender;
    NSDictionary *msg = (NSDictionary *) [chatHistory objectAtIndex:tag];
    NSArray *user_detail=[[msg objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ];
    //NSLog(@"you have tapped on a contact");
    NSString *query  = [NSString stringWithFormat:@"select * from contacts where user_id = '%@'",[user_detail objectAtIndex:0]];
    // NSString *query  = [NSString stringWithFormat:@"select * from contacts where user_id =12"];
    //NSLog(@"query : %@",query);
    BOOL recordExist = [[DatabaseManager getSharedInstance] recordExistOrNot:query];
    
    if (!recordExist) {
        // Insert data
        
        //NSLog(@"you can insert data");
        NSString *insertQuery=[NSString stringWithFormat:@"insert into contacts (user_id, user_email, user_name, user_pic, user_status,user_location) values ('%@','%@','%@','%@','%@','%@')",[user_detail objectAtIndex:0],[user_detail objectAtIndex:1],[self getusernameforBody:[msg objectForKey:@"MESSAGE_TEXT"]]/*[user_detail objectAtIndex:5]*/,[user_detail objectAtIndex:2],[user_detail objectAtIndex:3],[user_detail objectAtIndex:4]];
        
        //NSLog(@"query %@",insertQuery);
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
        [[self appDelegate]addFriendWithJid:[[NSString stringWithFormat:@"user_%@@",[user_detail objectAtIndex:0]] stringByAppendingString:(NSString*)jabberUrl ] nickName:[self getusernameforBody:[msg objectForKey:@"MESSAGE_TEXT"]]];
    }
    ViewContactProfile *viewProfile=[[ViewContactProfile alloc]init];
    viewProfile.userId=[[[msg objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ] objectAtIndex:0];
    viewProfile.triggeredFrom=@"explore";
    [self.navigationController pushViewController:viewProfile animated:YES];
}

-(IBAction)vcardClicked:(UIButton*)sender{
    
    // UIButton *button=(UIButton*)sender;
    NSDictionary *msg = (NSDictionary *) [chatHistory objectAtIndex:sender.tag];
    NSArray *user_detail=[[msg objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ];
    //NSLog(@"you have tapped on a contact");
    NSString *query  = [NSString stringWithFormat:@"select * from contacts where user_id = '%@'",[user_detail objectAtIndex:0]];
    // NSString *query  = [NSString stringWithFormat:@"select * from contacts where user_id =12"];
    //NSLog(@"query : %@",query);
    BOOL recordExist = [[DatabaseManager getSharedInstance] recordExistOrNot:query];
    
    if (!recordExist)    {
        UIAlertView *vcardAlert=[[UIAlertView alloc] initWithTitle:nil message:@"Do you want to add the user to your contact list?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [vcardAlert setTag:sender.tag];
        [vcardAlert show];
    }    else    {
        ViewContactProfile *viewProfile=[[ViewContactProfile alloc]init];
        viewProfile.userId=[[[msg objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ] objectAtIndex:0];
        viewProfile.triggeredFrom=@"explore";
        [self.navigationController pushViewController:viewProfile animated:YES];
    }
    
    
}

-(void)playNOW{
    
    [player setDelegate:self];
    [playerstatus setMinimumValue:0];
    [playerstatus setMaximumValue:[player duration]];
    [player play];
    //NSLog(@"time %@",[NSString stringWithFormat:@"%0.2f",[player duration]]);
    //NSLog(@"time \n %@",[NSString stringWithFormat:@"%02d:%02d", (int)((int)(player.duration)) / 60, (int)((int)(player.duration)) % 60]);
    if([player duration]>29)
        [audioPlayersAudioDuration setText:@"30:00"];
    else
        [audioPlayersAudioDuration setText:[NSString stringWithFormat:@"%0.2f",[player duration]]];
    [audioLenght invalidate];
    audioLenght=nil;
    audioLenght = [NSTimer scheduledTimerWithTimeInterval:.01f target:self selector:@selector(audioPlayerTimer:) userInfo:nil repeats:YES];
}

-(void)playAudio:(id)sender{
    UIButton *temp=sender;
    currentlyPlayedAudio=temp.tag;
    indexPath1 = [NSIndexPath indexPathForRow:temp.tag inSection:0];
    commentCell *cell =(commentCell*) [chatTable cellForRowAtIndexPath:indexPath1];
    
    
    // [chatTable scrollToRowAtIndexPath:indexPath1 atScrollPosition:UITableViewScrollPositionNone animated:NO];
    
    if (temp.selected==0){
        playingAudio=YES;
        temp.selected=1;
        if ([player currentTime]==0.0 ||temp.tag!=playerstatus.tag){
            //CGRect d= cell.bgImageView.frame;
            //  d.origin.x-=50;
            // [cell.bgImageView setFrame:d];
            
            
            //NSLog(@"cell  %@",cell);
            if (playerstatus==nil){
                playerstatus =[[UISlider alloc]initWithFrame:CGRectMake(110,50,0 , 34)];
                //   playerstatus.layer.borderWidth=1;
                audioPlayersCurrentTime=[[UILabel alloc]initWithFrame:CGRectMake(110, 66, 27, 34)];
                audioPlayersAudioDuration=[[UILabel alloc]initWithFrame:CGRectMake(180, 66, 27, 34)];
                [audioPlayersCurrentTime setFont:[UIFont fontWithName:@"Dosis-Regular" size:10.0f]];
                [audioPlayersCurrentTime setTextAlignment:NSTextAlignmentCenter];
                [audioPlayersAudioDuration setFont:[UIFont fontWithName:@"Dosis-Regular" size:10.0f]];
            }
            [audioPlayersAudioDuration setAlpha:0];
            [audioPlayersCurrentTime setAlpha:0];
            [playerstatus setAlpha:0];
            [playerstatus setTag:temp.tag];
            if([[[self appDelegate].ver objectAtIndex:0]integerValue ]>=7)
            [playerstatus setTintColor:[UIColor blueColor]];
            [playerstatus addTarget:self action:@selector(slideDidChange:) forControlEvents:UIControlEventValueChanged];
            [playerstatus removeFromSuperview];
            [audioPlayersAudioDuration removeFromSuperview];
            [audioPlayersCurrentTime removeFromSuperview];
            [cell addSubview:playerstatus];
            [audioPlayersCurrentTime setText:@"00.00"];
            [audioPlayersCurrentTime setBackgroundColor:[UIColor clearColor]];
            [audioPlayersAudioDuration setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:audioPlayersCurrentTime];
            
            [cell addSubview:audioPlayersAudioDuration];
            
            NSString *audioURL=[self CachesPath:[(NSDictionary*)[chatHistory objectAtIndex:temp.tag ] objectForKey:@"MESSAGE_FILENAME"]];
            NSFileManager *filemgr = [NSFileManager defaultManager];
            
            if ([filemgr fileExistsAtPath: audioURL ] == YES){
                
                NSURL *inputFileURL = [NSURL fileURLWithPath:audioURL];
                player = [[AVAudioPlayer alloc] initWithContentsOfURL:inputFileURL error:nil];
                //NSLog(@"duration %f current position %f ",[player duration],[player currentTime]);
                
                [self playNOW];
            }else{
                //[self downloadFileWithName:[(NSDictionary*)[chatHistory objectAtIndex:temp.tag ] objectForKey:@"MESSAGE_FILENAME"]];
                // [progressViewBackground setHidden:true];
                
                //  [self.view addSubview:freezer];
                
                // ai=[[UIActivityIndicatorView alloc]init];
                //  [ai setCenter:freezer.center];
                //  [ai startAnimating];
                // [freezer addSubview:ai];
                [self freezerAnimate];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/chat_files/%@",gupappUrl,[(NSDictionary*)[chatHistory objectAtIndex:temp.tag ] objectForKey:@"MESSAGE_FILENAME"]]]];
                    //freezer.superview.hidden=true;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[progressViewBackground setHidden:false];
                        // [ai removeFromSuperview];
                        // [ai stopAnimating];
                        //  [freezer removeFromSuperview];
                        [self freezerRemove];
                        //NSLog(@"data %@",fileData);
                        [fileData writeToFile:audioURL atomically:YES];
                        NSURL *inputFileURL = [NSURL fileURLWithPath:audioURL];
                        player = [[AVAudioPlayer alloc] initWithContentsOfURL:inputFileURL error:nil];
                        
                        [self playNOW];
                    });
                    
                });
                
            }
        }else{
            [self playNOW];
        }
        
        [UIView animateWithDuration:0.5f
                         animations:^{
                            
                              playerstatus.frame =CGRectMake(110,50,105 , 34);
                             [audioPlayersAudioDuration setAlpha:1];
                             [audioPlayersCurrentTime setAlpha:0];
                             [playerstatus setAlpha:1];
//                             [chatTable reloadData];
                             
                         }];
        [UIView commitAnimations];
        
        
    }else{
        [audioPlayersAudioDuration setAlpha:0];
        [audioPlayersCurrentTime setAlpha:0];
        [playerstatus setAlpha:0];
        [UIView animateWithDuration:0.5f
                         animations:^{
                             
//                             CGRect bgimageViewframe=cell.bgImage.frame;
//                             bgimageViewframe.size.width-=126;
//                             if(cell.bgImage.center.x>cell.contentView.frame.size.width/2)
//                                 bgimageViewframe.origin.x+=126;
//                             [cell.bgImage setFrame:bgimageViewframe];
                         }];
        
        [UIView commitAnimations];
        playingAudio=NO;
        temp.selected=0;
        //NSLog(@"tags player=%i button=%i",temp.tag,playerstatus.tag);
        if([player play] &&temp.tag==playerstatus.tag){
            [player pause];
            [audioLenght invalidate];
            audioLenght=nil;
            
        }
        
    }
    
}

- (void)audioPlayerTimer:(NSTimer *)theTimer{
    
    [audioPlayersCurrentTime setText:[NSString stringWithFormat:@"%0.2f",[player currentTime]]];
    playerstatus.value=[player currentTime];//[player duration];
}

-(IBAction)slideDidChange:(id)sender{
    [audioPlayersCurrentTime setText:[NSString stringWithFormat:@"%0.2f",playerstatus.value]];
    [player setCurrentTime:playerstatus.value];
}

-(IBAction)pauseAudio:(id)sender{
    UIButton *temp=sender;
    //NSLog(@"tags player=%i button=%i",temp.tag,playerstatus.tag);
    if([player play] &&temp.tag==playerstatus.tag){
        
        [player pause];
        [audioLenght invalidate];
        audioLenght=nil;
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section==0)
        return 0;
    else
        return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==1){
//
       UIView* border = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.chatTable.bounds.size.width-20, 20)];
        border.backgroundColor = [UIColor colorWithRed:242.0f/255.0 green:248.0f/255.0 blue:249.0f/255.0 alpha:1];
        border.opaque = YES;
        border.layer.borderWidth = 0.5;
        border.layer.borderColor = [UIColor colorWithRed:58.0/255.0 green:56.0/255.0 blue:48.0/255.0 alpha:1].CGColor;
        border.clearsContextBeforeDrawing = NO;
        unreadMessagelbl.frame = CGRectMake(10, 5, self.chatTable.bounds.size.width-40, 15);
        unreadMessagelbl.font = [UIFont fontWithName:@"Dosis-Regualr" size:15];
        unreadMessagelbl.textAlignment = NSTextAlignmentCenter;
        unreadMessagelbl.textColor = [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
        unreadMessagelbl.backgroundColor = [UIColor clearColor];
        [border addSubview:unreadMessagelbl];
        UIView* border1 = [[UIView alloc] initWithFrame:CGRectMake(10, 19, self.chatTable.bounds.size.width-20, 1)];
        border1.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:56.0/255.0 blue:48.0/255.0 alpha:1];
        border1.opaque = YES;
        border1.clearsContextBeforeDrawing = NO;
        [border addSubview:border1];

        return border;
    }
    
    return [UIView new];
}

-(CGSize)getSizeOfLableForText:(NSString*)text withfont:(UIFont*)fontStyle constrainedToSize:(CGSize)size{
    
    CGSize textsize = [text
                       boundingRectWithSize:size
                       options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                       attributes:@{NSFontAttributeName:fontStyle}
                       context:nil].size;
    return textsize;
}
-(CGSize)calculateHeight:(NSString*)data{
    
    CGFloat width = self.view.bounds.size.width-40;
    UIFont *font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f];
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:data attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    if([data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0){
        size.width = size.width +25;
        size.height = size.height +15;
    }
    return size;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dict;
    if(indexPath.section == 0)
        dict= (NSDictionary *)[chatHistory objectAtIndex:indexPath.row];
    else
        dict= (NSDictionary *)[unreadMessage objectAtIndex:indexPath.row];
    NSString *msg = [dict objectForKey:@"MESSAGE_TEXT"];
    
    if ([[dict objectForKey:@"MESSAGE_TYPE"] isEqual:@"text"]){
        msg=[msg UTFDecoded];
        
        CGSize textSize = [self calculateHeight:msg];
        
        CGFloat height = textSize.height;
       height += 50;
        return height;
        
    }else if([[dict objectForKey:@"MESSAGE_TYPE"] isEqual:@"audio"]){
        
        CGFloat heightImage=54;
       heightImage += 50;
        return heightImage;
        
    }else if([[dict objectForKey:@"MESSAGE_TYPE"] isEqual:@"image"]){
        CGFloat heightImage=self.view.bounds.size.width-90;
        
        heightImage += 50;
        
        return heightImage;
    }else{
        CGFloat heightImage=54;
        heightImage += 50;
        return heightImage;
        
    }
    
    
}


-(BOOL)checkForDate:(NSIndexPath*)indexPath timeinMilisecend:(NSString*)secends{

//    if (indexPath.row>0){
        @try{
            NSDictionary *msg = (NSDictionary *) [chatHistory objectAtIndex:indexPath.row-1<0?0:indexPath.row-1];
            NSString *time = [msg objectForKey:@"TIME_STAMP"];
            time=  [time getDateTimeFromUTCTimeInterval];
            NSArray *dateTime=[time componentsSeparatedByString:@" "];
            NSArray *dateComponents=[[dateTime objectAtIndex:0] componentsSeparatedByString:@"-"];
            
            prevMonth=[dateComponents objectAtIndex:1];
            prevYear=[dateComponents objectAtIndex:0];
            prevDay=[dateComponents objectAtIndex:2];
        }@catch (NSException *exception){
            prevMonth=0;
            prevYear=0;
            prevDay=0;
        }
        

//    }
    NSString *time = secends;
    time=  [time getDateTimeFromUTCTimeInterval];
    if ([time componentsSeparatedByString:@" "].count!=2){
        time=[NSString DateTime];
    }

    NSArray *dateTime=[time componentsSeparatedByString:@" "];
    NSArray *dateComponents=[[dateTime objectAtIndex:0] componentsSeparatedByString:@"-"];
    
    NSString *dateValue=@"";
    
    dateValue=[dateValue stringByAppendingString:[dateComponents objectAtIndex:2]];
    dateValue=[dateValue stringByAppendingString:[NSString stringWithFormat:@"-%@",[month objectAtIndex:[[dateComponents objectAtIndex:1] integerValue]-1]]];
    if (![prevDay isEqual:[dateComponents objectAtIndex:2]]||![prevMonth isEqual:[dateComponents objectAtIndex:1]]||![prevYear isEqual:[dateComponents objectAtIndex:0]])
        return true;
    else
        return false;
        
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"count %lu",(unsigned long)[chatHistory count]);
    
    prevYear=@"";
    prevMonth=@"";
    prevDay=@"";
    if(section ==0)
        return [chatHistory count];
    else
        return [unreadMessage count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (unreadMessage.count) {
        return 2;
    }
    return 1;
}


#pragma mark - Overriden UIViewController methods
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}
#pragma mark -
#pragma mark Chat delegates
-(void)scrollDown{
    
    //  [self updateChatHistory];
    
    
    //[chatTable reloadData];
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:chatHistory.count-1 inSection:0];
    if(chatHistory.count!=0){
        if(mainScroll.scrollEnabled)
        [self adjustHeightOfTableview];
        [chatTable scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
    }
    
}

- (void)newMessageReceived {
    
    [self updateChatHistory];
    [chatTable reloadData];
    if(chatHistory.count!=0){
        
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:chatHistory.count-1 inSection:0];
        NSArray *visible = [chatTable indexPathsForVisibleRows];
        
        NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:[visible count]-1];
        @try {
            
            if (indexpath.row>([chatTable numberOfRowsInSection:0]-[visible count]==1?2:[visible count])){
                if(mainScroll.scrollEnabled)
                    [self adjustHeightOfTableview];
                [chatTable scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];
                
                
            } else {
                
            }
        }
        @catch (NSException *exception) {
            
        }
    }
    
}

- (void)sendMessage{
    
    NSString *msgCheck=[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    chatMessageType = @"text";
    if([msgCheck length]!=0){
        
        NSString *msgToBesend=textView.text;
        msgToBesend =[msgToBesend stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *goodValue=[msgToBesend UTFEncoded];
        
        timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
        [[self appDelegate] storeMessageInDatabaseForBody:goodValue forMessageType:@"text" messageTo:chatWithUser groupId:GroupId isGroup:true forTimeInterval:timeInMiliseconds senderName:[self appDelegate].MyUserName postid:[NSString stringWithFormat:@"%@",self.postId] isRead:@"1" withImage:myImage];
         [self updateGroupTime:timeInMiliseconds];
        NSString *messageid=[[self appDelegate] CheckIfMessageExist:[[goodValue stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\"" ] ofMessageType:@"text"];
        NSString *recieversID=[chatWithUser userID];
        NSString *referanceID=  [[self appDelegate] getLinkedIdOfMessageID:messageid forTimestamp:timeInMiliseconds senderID:myUserId recieversID:recieversID chattype:chatType];
        [[self appDelegate] sendAcknoledgmentPacketId:referanceID isGroupAcknoledgment:true];
        
        NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_group.id,user_id,time_stamp,message_id,message_type,message_text,message_filename from chat_group INNER  JOIN chat_message where user_id=%@ AND post_id = %@ AND messageStatus=0 AND  message_id=chat_message.id order by chat_group.time_stamp ASC",[self appDelegate].myUserID,self.postId]];
            XMPPMessage *msg = [XMPPMessage message];
            [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
            [msg addAttributeWithName:@"groupCounter" stringValue:[self appDelegate].groupCounter];
            [msg addAttributeWithName:@"to" stringValue:_toJid];
            [msg addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"user_%@@%@",[self appDelegate].myUserID,jabberUrl]];
        
            [msg addAttributeWithName:@"isResend" boolValue:FALSE];
            
            msgToBesend=[self RadhaCompatiableEncodingForstring:msgToBesend];
            NSString *goodValue1=[msgToBesend UTFEncoded];
            NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[goodValue1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
            
            NSXMLElement *reference = [NSXMLElement elementWithName:@"referenceID" stringValue:[[groupUnsendMessages objectAtIndex:0] objectForKey:@"CHAT_GROUP.ID"]];
            
            NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[self appDelegate].myUserID];
            NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:[self appDelegate].MyUserName];
            NSXMLElement *from_user_image = [NSXMLElement elementWithName:@"from_user_image" stringValue:myImage];
            NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:chatMessageType];
            NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[NSString stringWithFormat:@"%@",timeInMiliseconds]];
            NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:GroupId ];
            NSXMLElement *isgroup= [NSXMLElement elementWithName:@"ispost" stringValue:[NSString stringWithFormat:@"%i",true]];
            NSXMLElement *postid= [NSXMLElement elementWithName:@"postid" stringValue:self.postId];
            
            [gup addChild:body];
            [gup addChild:reference];
            [gup addChild:from_user_id];
            [gup addChild:from_user_name];
            [gup addChild:from_user_image];
            [gup addChild:timeStamp];
            [gup addChild:postid];
            [gup addChild:message_type];
            [gup addChild:isgroup];
            [gup addChild:groupIDs];
            [msg addChild:gup];
        
            NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:[goodValue1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];
            [msg addChild:body1];
            if ([self appDelegate].hasInet&&[[self xmppStream] isDisconnected])
                [[self appDelegate] connect];
            [[self xmppStream] sendElement:msg];
        
        if(unreadMessage.count){
            unreadMessage = nil;
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_group set read=1 where post_id=%@ ",self.postId]];
        }
            
        }
//    }
    textView.text = @"";
    [textView resignFirstResponder];
//    [self updateChatHistory];
//    [chatTable reloadData];
//    [messageField resignFirstResponder];
    
}



-(void)sendVcardforUserID:(NSString*)userid user_email:(NSString*)user_email userName:(NSString*)user_name user_pic:(NSString*)user_pic user_status:(NSString*)user_status user_location:(NSString*)user_location{
    
    NSString *msgToSend = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",userid,user_email,user_pic,user_status,user_location,user_name];
    timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
    msgToSend =[msgToSend stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    [[self appDelegate] storeMessageInDatabaseForBody:msgToSend forMessageType:@"vcard" messageTo:chatWithUser groupId:GroupId isGroup:true forTimeInterval:timeInMiliseconds senderName:[self appDelegate].MyUserName postid:[NSString stringWithFormat:@"%@",self.postId] isRead:@"1" withImage:myImage];
    [self updateGroupTime:timeInMiliseconds];
    NSString *messageid=[[self appDelegate] CheckIfMessageExist:[msgToSend stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:@"vcard"];
    NSString *recieversID=[chatWithUser userID];
    NSString *referanceID=  [[self appDelegate] getLinkedIdOfMessageID:messageid forTimestamp:timeInMiliseconds senderID:myUserId recieversID:recieversID chattype:chatType];
    [[self appDelegate] sendAcknoledgmentPacketId:referanceID isGroupAcknoledgment:true];
    
        XMPPMessage *msg = [XMPPMessage message];
        [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
        [msg addAttributeWithName:@"groupCounter" stringValue:[self appDelegate].groupCounter];
        [msg addAttributeWithName:@"to" stringValue:_toJid];
        [msg addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"user_%@@%@",[self appDelegate].myUserID,jabberUrl]];
        [msg addAttributeWithName:@"isResend" boolValue:FALSE];
        
        msgToSend=[self RadhaCompatiableEncodingForstring:msgToSend];
        NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[msgToSend stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
        
        
        NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_group.id,user_id,time_stamp,message_id,message_type,message_text,message_filename from chat_group INNER  JOIN chat_message where user_id=%@ AND post_id = %@ AND messageStatus=0 AND  message_id=chat_message.id order by chat_group.time_stamp ASC",[self appDelegate].myUserID,self.postId]];
        NSXMLElement *reference = [NSXMLElement elementWithName:@"referenceID" stringValue:[[groupUnsendMessages objectAtIndex:0] objectForKey:@"CHAT_GROUP.ID"]];
        [gup addChild:reference];
        
        timeInMiliseconds = [[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] ;
        NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[self appDelegate].myUserID];
        NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:[self appDelegate].MyUserName];
        NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:@"vcard"];
        NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[NSString stringWithFormat:@"%@",timeInMiliseconds]];
        NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:GroupId];
        NSXMLElement *postid = [NSXMLElement elementWithName:@"postid" stringValue:self.postId];
        NSXMLElement *isgroup= [NSXMLElement elementWithName:@"ispost" stringValue:[NSString stringWithFormat:@"%i",true]];
        
        [gup addChild:body];
        [gup addChild:from_user_id];
        [gup addChild:from_user_name];
        [gup addChild:timeStamp];
        [gup addChild:postid];
        [gup addChild:message_type];
        [gup addChild:isgroup];
        [gup addChild:groupIDs];
        [msg addChild:gup];
        
        
        NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:msgToSend]];
        [msg addChild:body1];
        if ([self appDelegate].hasInet&&[[self xmppStream] isDisconnected])
            [[self appDelegate] connect ];
        
        [[self xmppStream] sendElement:msg];
    if(unreadMessage.count){
        unreadMessage = nil;
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_group set read=1 where post_id=%@ ",self.postId]];
    }

    [self resignFirstResponder];
    
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

-(BOOL)resignFirstResponder{
    return YES;
}

-(void)updateGroupTime:(NSString*)time{
    if ([self.groupType isEqualToString:@"private"]) {
        NSString *query2=[NSString stringWithFormat:@"UPDATE groups_private SET updatetime=%@ WHERE group_server_id = %@",time,GroupId];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query2];
    }else{
        NSString *query2=[NSString stringWithFormat:@"UPDATE groups_public SET updatetime=%@ WHERE group_server_id = %@",time,GroupId];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query2];
    }
}
-(void)newCommentAction:(NSNotification*)notification{
    NSDictionary *dic = [notification userInfo];
    if([GroupId intValue]!= [[dic objectForKey:@"groupid"]intValue])
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newCommentNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"You have received a message from the group %@",[dic objectForKey:@"groupName"]] forKey:@"notificationData"]];
}

@end

