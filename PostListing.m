//
//  PostListing.m
//  GUP
//
//  Created by Ram Krishna on 18/12/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import "PostListing.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "CreateNewPost.h"
#import "postCell.h"
#import <Social/Social.h>
#import "AFNetworking.h"
#import "ChatScreen.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "CommentViewController.h"
#import "LikeViewController.h"
#import "ShareGroupInfo.h"
#import "ViewContactProfile.h"
#import "viewPrivateGroup.h"
#include "GroupInfo.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:.8]
@implementation PostListing{
    UIRefreshControl *pullRfrs;
    UIActivityIndicatorView *indicator;
    UIImageView *fullSizeImage;
    UIActivityIndicatorView *spinner;
    UITapGestureRecognizer *fullImageTap;
    UISwipeGestureRecognizer *leftSwip;
    UISwipeGestureRecognizer *rightSwip;
    UIView *imageShowView;
    UIPageControl *pageControl;
    NSMutableDictionary *imageDataDictonary;
    BOOL isMoreAvailable;
    UIButton *report;
    NSIndexPath *cellIndexPath;
}

-(IBAction)dissmisal:(UITapGestureRecognizer*)sender1{
    
    [self.parentViewController.parentViewController.view setUserInteractionEnabled:YES];
    [sender1.view removeFromSuperview];
}
-(void)plistSpooler{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path]){
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        if (![[data objectForKey:@"CreateGroup"] boolValue]) {
            
            [data setObject:[NSNumber numberWithInt:true] forKey:@"CreateGroup"];
            CGSize deviceSize=[UIScreen mainScreen].bounds.size;
            UIImageView *Back=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            UIImage *backimage=[UIImage imageNamed:@"topic"];
            [Back setImage:[backimage stretchableImageWithLeftCapWidth:backimage.size.width topCapHeight:backimage.size.width/2]];
            [Back setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *titletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmisal:)];
            [Back addGestureRecognizer:titletap];

//            UIButton *dismiss=[[UIButton alloc]initWithFrame:CGRectMake(deviceSize.width-110, 32, 100, 30)];
//            [dismiss setTitle:@"Done" forState:UIControlStateNormal];
//            [dismiss setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:55.0/255.0 alpha:1 ]];
//            [dismiss setUserInteractionEnabled:YES];
//            [dismiss addTarget:self action:@selector(dissmisal:) forControlEvents:UIControlEventTouchUpInside];
//            [Back addSubview:dismiss];
            [self.parentViewController.parentViewController.view addSubview:Back];
            [self.parentViewController.parentViewController.view bringSubviewToFront:Back ];
            
        }
        [data writeToFile: path atomically:YES];
        
    }else{
        
        data = [[NSMutableDictionary alloc] init];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"HomeScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"CreateGroup"];
        [data writeToFile: path atomically:YES];
        
        
    }
    
}

-(void)viewDidLoad{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeUnlikeAction:) name:@"likeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentAction:) name:@"commentNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didfetchConfigForm:) name:@"configForm" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPostCome:) name:@"newpostnotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreceView) name:@"reloadPostList" object:nil];
    
    [self plistSpooler];
//    timeFlag = true;
    deleteFlag = true;
    self.view.frame = [[UIScreen mainScreen] bounds];
    _postTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width,  self.view.frame.size.height-120) style:UITableViewStyleGrouped];
    _postTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _postTable.backgroundColor = [UIColor whiteColor];
    _postTable.delegate = self;
//    _postTable.delaysContentTouches = YES;
    
    _postTable.dataSource = self;
//    readMoreIndexPath = nil;
    
    NSArray *privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT group_name FROM groups_private WHERE group_server_id = %@",self.groupId]];
    if (privateGroupList.count) {
        isPrivate = true;
    }else{
        isPrivate = false;
    }
    
    NSString *tojid = [NSString stringWithFormat:@"group_%@@%@",self.groupId,groupJabberUrl];
    XMPPRoomCoreDataStorage *roomMemoryStorage = [XMPPRoomCoreDataStorage sharedInstance];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage
                                                           jid:[XMPPJID jidWithString:tojid]
                                                 dispatchQueue:dispatch_get_main_queue()];
        
     [xmppRoom activate:[self appDelegate].xmppStream];
     [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
     [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"user_%@",[self appDelegate].myUserID] history:nil];
    
        readMoreIndexPath = nil;
    UIButton *createPost = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 30.0f, 30.0f)];
    [createPost setImage:[UIImage imageNamed:@"createPost"] forState:UIControlStateNormal];
    [createPost addTarget:self action:@selector(createPostAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:createPost];
    self.navigationItem.rightBarButtonItem = addButton;
    [self.view addSubview:_postTable];
    
    pullRfrs = [[UIRefreshControl alloc] init];
    pullRfrs.backgroundColor = [UIColor clearColor];
    pullRfrs.tintColor = [UIColor colorWithRed:196.0f/255.0 green:234.0f/255.0 blue:249.0f/255.0 alpha:0.9];
    [pullRfrs addTarget:self action:@selector(loadNewPost) forControlEvents:UIControlEventValueChanged];
    [self.postTable addSubview:pullRfrs];
    isMoreAvailable = YES;
    
    fullSizeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-100)];
    fullSizeImage.contentMode = UIViewContentModeScaleAspectFit;
    fullSizeImage.backgroundColor = [UIColor blackColor];
    imageShowView = [[UIView alloc] initWithFrame:fullSizeImage.frame];
    [imageShowView addSubview:fullSizeImage];
    fullSizeImage.userInteractionEnabled=YES;
    
    [self.view addSubview:imageShowView];
    imageShowView.hidden = YES;
    
    fullImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageView:)];
    fullImageTap.numberOfTapsRequired = 1;
    [fullSizeImage addGestureRecognizer:fullImageTap];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, imageShowView.frame.origin.y+imageShowView.frame.size.height-20, 100, 20)];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.center = CGPointMake(self.view.center.x, pageControl.frame.origin.y);
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    [imageShowView addSubview:pageControl];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = fullSizeImage.center;
    [spinner setHidesWhenStopped:YES];
    [fullSizeImage addSubview:spinner];
    
    leftSwip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftImageChangeAction:)];
    leftSwip.direction = UISwipeGestureRecognizerDirectionLeft;
    [fullSizeImage addGestureRecognizer:leftSwip];
    
    rightSwip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rigthImageChangeAction:)];
    rightSwip.direction = UISwipeGestureRecognizerDirectionRight;
    [fullSizeImage addGestureRecognizer:rightSwip];
    
    newPostNotificationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    newPostNotificationView.backgroundColor = UIColorFromRGB(0x87CEFA);
    notificationlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
    notificationlabel.text = @"You have new posts";
    notificationlabel.textColor = [UIColor whiteColor];
    notificationlabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    notificationlabel.center = CGPointMake(newPostNotificationView.center.x+30, newPostNotificationView.center.y);
    [newPostNotificationView addSubview:notificationlabel];
    [self.view addSubview:newPostNotificationView];
    
    UITapGestureRecognizer *gasture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadNewPost)];
    gasture.numberOfTapsRequired = 1;
    [newPostNotificationView addGestureRecognizer:gasture];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    requestFlag = TRUE;
    latest =false;
    [self appDelegate].listFlag = true;
    CGSize  textSize = {self.navigationController.navigationBar.frame.size.width-170, 30 };
    CGSize size = [self.chatTitle sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    contactNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(15,5,size.width,30)];
    [contactNameLabel setBackgroundColor:[UIColor clearColor]];
    contactNameLabel.textAlignment =NSTextAlignmentCenter;
    
    UITapGestureRecognizer *gasture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openProfile)];
    gasture1.numberOfTapsRequired = 1;
    [contactNameLabel addGestureRecognizer:gasture1];
     self.navigationController.navigationBar.userInteractionEnabled = YES;
    contactNameLabel.userInteractionEnabled = YES;
    
    
    contactNameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.f];
    if (![self.chatType isEqual:@"group"]){
        imageViewForStatus= [[UIImageView alloc] initWithFrame:CGRectMake(self.navigationController.navigationBar.frame.size.width/2-size.width/2-20, 12, 20, 20)];
        imageViewForStatus.layer.cornerRadius=10;
    }
    self.navigationItem.title =self.chatTitle;
    [contactNameLabel setCenter:CGPointMake(self.navigationController.navigationBar.frame.size.width/2,self.navigationController.navigationBar.frame.size.height/2)];
    contactNameLabel.text =self.chatTitle;
    [self updateTitleStatus ];
    
    NSString *tojid = [NSString stringWithFormat:@"group_%@@%@",self.groupId,groupJabberUrl];
    XMPPRoomCoreDataStorage *roomMemoryStorage = [XMPPRoomCoreDataStorage sharedInstance];
    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage
                                                           jid:[XMPPJID jidWithString:tojid]
                                                 dispatchQueue:dispatch_get_main_queue()];
    
    [xmppRoom activate:[self appDelegate].xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSLog(@"%hhd",[xmppRoom isJoined]);
    if(![xmppRoom isJoined])
        [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"user_%@",[self appDelegate].myUserID] history:nil];
    postListData = [NSMutableArray array];
    NSString *favQuery=[NSString stringWithFormat:@"SELECT post_id,is_report, description,user_id, user_name,user_image,created,updated,is_fav,total_likes,total_comments,imageCount,is_like from Post WHERE group_id = %@ AND is_fav=1 ORDER BY updated DESC",self.groupId];
    NSArray *favPostDataArray = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:favQuery];
    NSString *udfavQuery=[NSString stringWithFormat:@"SELECT post_id,is_report, description,user_id, user_name,user_image,created,updated,is_fav,total_likes,total_comments,imageCount,is_like from Post WHERE group_id = %@ AND is_fav=0 ORDER BY created DESC",self.groupId];
    NSArray *dataArray =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:udfavQuery];
    for (NSDictionary *post in favPostDataArray) {
        
        NSString *query=[NSString stringWithFormat:@"SELECT image_url from PostImageUrl WHERE post_id = %@ ",[post objectForKey:@"POST_ID"]];
        NSArray *postData =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:query];
        
        NSMutableDictionary *tampPostData = [NSMutableDictionary dictionary];
        [tampPostData setValue:[post objectForKey:@"USER_ID"] forKey:@"user_id"];
        [tampPostData setValue:[post objectForKey:@"USER_IMAGE"] forKey:@"user_image"];
        [tampPostData setValue:[post objectForKey:@"USER_NAME"] forKey:@"user_name"];
        [tampPostData setValue:[post objectForKey:@"POST_ID"] forKey:@"post_id"];
        [tampPostData setValue:[post objectForKey:@"DESCRIPTION"] forKey:@"description"];
        [tampPostData setValue:[post objectForKey:@"TOTAL_LIKES"] forKey:@"total_likes"];
        [tampPostData setValue:[post objectForKey:@"IS_REPORT"] forKey:@"is_report"];
        [tampPostData setValue:[post objectForKey:@"UPDATED"] forKey:@"time"];
        [tampPostData setValue:[post objectForKey:@"TOTAL_COMMENTS"] forKey:@"total_comments"];
        [tampPostData setValue:[post objectForKey:@"IMAGECOUNT"] forKey:@"imageCount"];
        [tampPostData setValue:[post objectForKey:@"IS_FAV"] forKey:@"is_fav"];
        [tampPostData setValue:[post objectForKey:@"IS_LIKE"] forKey:@"islike"];
        [tampPostData setValue:[NSString stringWithFormat:@"%d",1] forKey:@"index"];
        int i = 1;
        for (NSDictionary *imageData in postData) {
            NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
            [imageDic setValue:[imageData objectForKey:@"IMAGE_URL"] forKey:@"image_url"];
            [tampPostData setValue:imageDic forKey:[NSString stringWithFormat:@"image_%d",i++]];
        }
        
        [postListData addObject:tampPostData];
    }
    
    for (NSDictionary *post in dataArray) {
        
        NSString *query=[NSString stringWithFormat:@"SELECT image_url from PostImageUrl WHERE post_id = %@ ",[post objectForKey:@"POST_ID"]];
        NSArray *postData =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:query];
        
        NSMutableDictionary *tampPostData = [NSMutableDictionary dictionary];
        [tampPostData setValue:[post objectForKey:@"USER_ID"] forKey:@"user_id"];
        [tampPostData setValue:[post objectForKey:@"USER_IMAGE"] forKey:@"user_image"];
        [tampPostData setValue:[post objectForKey:@"USER_NAME"] forKey:@"user_name"];
        [tampPostData setValue:[post objectForKey:@"POST_ID"] forKey:@"post_id"];
        [tampPostData setValue:[post objectForKey:@"DESCRIPTION"] forKey:@"description"];
        [tampPostData setValue:[post objectForKey:@"TOTAL_LIKES"] forKey:@"total_likes"];
          [tampPostData setValue:[post objectForKey:@"IS_REPORT"] forKey:@"is_report"];
        [tampPostData setValue:[post objectForKey:@"CREATED"] forKey:@"time"];
        //        [tampPostData setValue:[post objectForKey:@"UPDATED"] forKey:@"updated"];
        //        [tampPostData setValue:[post objectForKey:@"CREATED"] forKey:@"created"];
        [tampPostData setValue:[post objectForKey:@"TOTAL_COMMENTS"] forKey:@"total_comments"];
        [tampPostData setValue:[post objectForKey:@"IMAGECOUNT"] forKey:@"imageCount"];
        [tampPostData setValue:[post objectForKey:@"IS_FAV"] forKey:@"is_fav"];
        [tampPostData setValue:[post objectForKey:@"IS_LIKE"] forKey:@"islike"];
        [tampPostData setValue:[NSString stringWithFormat:@"%d",1] forKey:@"index"];
        int i = 1;
        for (NSDictionary *imageData in postData) {
            NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
            [imageDic setValue:[imageData objectForKey:@"IMAGE_URL"] forKey:@"image_url"];
            [tampPostData setValue:imageDic forKey:[NSString stringWithFormat:@"image_%d",i++]];
        }
        
        [postListData addObject:tampPostData];
    }

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"time"  ascending:NO];
    NSArray *arr=[postListData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    postListData = [arr mutableCopy];
    [self.postTable reloadData];
    [self.postTable scrollsToTop];
    [self performSelectorInBackground:@selector(fetchLatest) withObject:nil];
//    if(postListData.count==0){
//        
//        HUD1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        HUD1.delegate = self;
//        HUD1.dimBackground = YES;
//        HUD1.labelText = @"Please Wait";
//        
//    }
    
}


-(void)openProfile{

    if (isPrivate) {
        viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
        viewGroupAsAdmin.title = self.chatTitle;
        viewGroupAsAdmin.groupId = self.groupId;
        viewGroupAsAdmin.groupType =self.groupType;
        [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
        
    }else{
        
        GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
        viewGroupPage.title = self.chatTitle;
        viewGroupPage.groupId = self.groupId;
        viewGroupPage.groupType = self.groupType;
        [self.navigationController pushViewController:viewGroupPage animated:NO];
        
    }
    
}


-(void)refreceView{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";

 [self performSelectorInBackground:@selector(fetchLatest) withObject:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [contactNameLabel setHidden:YES];
    [imageViewForStatus setHidden:YES];
    [self appDelegate].listFlag = false;
}

- (void) initWithUser:(NSString *) userjid {
    
    [self appDelegate].currentUser=userjid;
    self.chatWithUser = userjid;
}

-(void)createPostAction{
    
    CreateNewPost *addGroupPage = [[CreateNewPost alloc] initWithNibName:@"CreateNewPost" bundle:nil];
    addGroupPage.groupName = _groupName;
    addGroupPage.groupID = _groupId;
    [self.navigationController pushViewController:addGroupPage animated:YES];
    
}
#pragma mark-referance object
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)updateTitleStatus{
    
    NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select user_status from contacts where user_id=%i ", [[self.chatWithUser userID] integerValue]]];
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

#pragma mark- Uitableview methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (isMoreAvailable && [postListData count]>0 && [postListData count]>[[tableView visibleCells] count]){
        return [postListData count]+1;
    }
    return postListData.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section<postListData.count) {
        postCell *pcell = (postCell*)cell;
        pcell.imageDelegate = self;
        [pcell clearCell];
        [pcell drawCell:[postListData objectAtIndex:indexPath.section]];
    }
    
    
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (readMoreIndexPath && [readMoreIndexPath compare:indexPath]==NSOrderedSame) {
        readMoreIndexPath =nil;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier;
    if (indexPath.section==postListData.count) {
        identifier = @"loadIndicatorCell";
        UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            indicator.tag=100;
            [indicator setColor:[UIColor grayColor]];
            indicator.center=CGPointMake(cell.contentView.center.x, 33);
            [indicator startAnimating];
            [cell.contentView addSubview:indicator];
        } else{
            indicator = (UIActivityIndicatorView*)[cell.contentView viewWithTag:100];
            [indicator startAnimating];
        }if (requestFlag) {
            requestFlag=FALSE;
            [self performSelectorInBackground:@selector(fetchPostData) withObject:nil];
            
        }
        return cell;
        
    }else{
        BOOL isContains=NO;
//        for (NSIndexPath *moreIndex in readMoreIndexPath) {
            if (readMoreIndexPath && [readMoreIndexPath compare:indexPath]== NSOrderedSame) {
                isContains=YES;
            }
//        }
        if (isContains) {
            identifier = @"loadMoreCell";
        }else{
            identifier = @"PostCell";
        }
        
        postCell *pcell = (postCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if(pcell==nil){
            pcell = [[postCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        pcell.selectionStyle = UITableViewCellSelectionStyleNone;
        return pcell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==postListData.count) {
        return 66;
    }else{

        NSString *disString = [[postListData objectAtIndex:indexPath.section] objectForKey:@"description"];

        disString=[disString UTFDecoded];
        if(!disString){

            disString = [[postListData objectAtIndex:indexPath.section] objectForKey:@"description"];
        }
        
        disString=[self RadhaCompatiableDecodingForString:disString];
        disString=[disString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
               
        if([[disString componentsSeparatedByString:@"\n"] count]>5){
            disString = [self newLineStringFormat:[disString componentsSeparatedByString:@"\n"]];
            
        }
        
        CGSize size = [self calculateHeight:disString];
        NSString *str;
        float height;
        if ([[[postListData objectAtIndex:indexPath.section] objectForKey:@"imageCount"] intValue]==0) {
            if(disString.length>=210){
                str = [NSString stringWithFormat:@"%@...%@",[disString substringWithRange:NSMakeRange(0, (disString.length>220)?220:disString.length)],@"More"];
                CGSize cutTextSize = [self calculateHeight:str];
                height=100+(cutTextSize.height-10);
            }else{
                height=100+(size.height-10);
            }
        }else{
            if(disString.length>=210){
                str = [NSString stringWithFormat:@"%@...%@",[disString substringWithRange:NSMakeRange(0, (disString.length>220)?220:disString.length)],@"More"];
                CGSize cutTextSize = [self calculateHeight:str];
                height=310+(cutTextSize.height-10);
            }else{
                height=310+(size.height);
            }
            
        }
        
//        for (NSIndexPath *morePaths in readMoreIndexPath) {
            if(readMoreIndexPath && [indexPath compare:readMoreIndexPath] == NSOrderedSame){
                if ([[[postListData objectAtIndex:indexPath.section] objectForKey:@"imageCount"] intValue]==0) {
                    return (100 +([self calculateHeight: [[postListData objectAtIndex:indexPath.section] objectForKey:@"description"]].height));
                }else{
                    return (310 +([self calculateHeight: [[postListData objectAtIndex:indexPath.section] objectForKey:@"description"]].height));
                }
                
                
                
            }
            
//        }
        return height;
    }
}

//- (NSString *)UTFDecoded {
//    
//    
//    return [[NSString alloc] initWithData:[self dataUsingEncoding:NSASCIIStringEncoding] encoding:NSNonLossyASCIIStringEncoding];
//    
//}

-(NSString*)newLineStringFormat:(NSArray*)atrArray{
    NSString *cText =@"";
    int i=1;
    for (NSString *first in atrArray) {
        
        if(cText.length +first.length>210 || i == 5){
            cText = [NSString stringWithFormat:@"%@\n%@...%@",cText,[first substringWithRange:NSMakeRange(0, (first.length<40)?first.length:40)],@"More"];
            break;
        }else{
            i=i+first.length/47;
            if (first.length%47!=0 || first.length==0) {
                i=i+1;
            }
            cText = [NSString stringWithFormat:@"%@\n%@",cText,first];
            
        }
        
    }
    
    return cText;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    view.backgroundColor = [UIColor whiteColor];
    return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}

-(CGSize)calculateHeight:(NSString*)data{
    
    CGFloat width = 280;
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:data attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    size.width = size.width +25;
    size.height = size.height +25;
    return size;
}

-(void)leftImageAction:(UIImageView*)image{
    
    postCell *pcell;
    if ([[image superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[image superview];
    }
    else if ([[[image superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[image superview] superview];
    }
    NSIndexPath *indexPath = [self.postTable indexPathForCell:pcell];
    NSDictionary *dic = [postListData objectAtIndex:indexPath.section];
    int ind = [[dic valueForKey:@"index"] integerValue];
    if(ind == 0)
        ind +=2;
    else
        ind+=1;
    
    NSString *postImagePath = [[dic objectForKey:[NSString stringWithFormat:@"image_%d",ind]] objectForKey:@"image_url"];
    if(postImagePath){
        [dic setValue:[NSString stringWithFormat:@"%d",ind] forKey:@"index"];
        [postListData replaceObjectAtIndex:indexPath.section withObject:dic];
        UIActivityIndicatorView *spinner1 = (UIActivityIndicatorView*)[[image subviews]lastObject];
        [spinner1 startAnimating];
        [image sd_setImageWithURL:[NSURL URLWithString:postImagePath] placeholderImage:[UIImage imageNamed:@"imageplaceholder"] completed:^(UIImage *cImage , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (cImage) {
                image.image = cImage;
            }else{
                image.image = [UIImage imageNamed:@"imageplaceholder"];
            }
            [spinner1 stopAnimating];
            
        }];
        int i =  ind-1;
        UIPageControl *page = (UIPageControl*)[pcell viewWithTag:110];
        page.currentPage = i;
        
    }
    
}

-(void)rightImageAction:(UIImageView*)image{
    
    postCell *pcell;
    if ([[image superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[image superview];
    }
    else if ([[[image superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[image superview] superview];
    }
    NSIndexPath *indexPath = [self.postTable indexPathForCell:pcell];
    NSDictionary *dic = [postListData objectAtIndex:indexPath.section];
    int ind = [[dic valueForKey:@"index"] integerValue];
    ind -=1;
    
    NSString *postImagePath = [[dic objectForKey:[NSString stringWithFormat:@"image_%d",ind]] objectForKey:@"image_url"];
    if(postImagePath){
        [dic setValue:[NSString stringWithFormat:@"%d",ind] forKey:@"index"];
        [postListData replaceObjectAtIndex:indexPath.section withObject:dic];
        UIActivityIndicatorView *spinner1 = (UIActivityIndicatorView*)[[image subviews]lastObject];
        [spinner1 startAnimating];
        [image sd_setImageWithURL:[NSURL URLWithString:postImagePath] placeholderImage:[UIImage imageNamed:@"imageplaceholder"] completed:^(UIImage *cImage , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (cImage) {
                image.image = cImage;
            }else{
                image.image = [UIImage imageNamed:@"imageplaceholder"];
            }
            [spinner1 stopAnimating];
            
        }];
        UIPageControl *page = (UIPageControl*)[pcell viewWithTag:110];
        int i =  ind-1;
        page.currentPage = i;
    }
    
}

-(void)cellHeightChange:(TTTAttributedLabel*)lbl{
    postCell *pcell;
    if ([[lbl superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[lbl superview];
    }
    else if ([[[lbl superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[lbl superview] superview];
    }
    NSIndexPath *morePath =[self.postTable indexPathForCell:pcell];
    readMoreIndexPath =morePath;
    [self.postTable beginUpdates];
    [self.postTable reloadSections:[NSIndexSet indexSetWithIndex:morePath.section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:self.postTable heightForRowAtIndexPath:morePath];
    [self.postTable endUpdates];
}

-(void)readLessAction:(TTTAttributedLabel*)lbl{
    postCell *pcell;
    if ([[lbl superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[lbl superview];
    }
    else if ([[[lbl superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[lbl superview] superview];
    }
//    NSIndexPath *morePath =[self.postTable indexPathForCell:pcell];
    readMoreIndexPath =nil;
    [self.postTable beginUpdates];
    [self.postTable reloadSections:[NSIndexSet indexSetWithIndex:[self.postTable indexPathForCell:pcell].section] withRowAnimation:UITableViewRowAnimationNone];
    [self tableView:self.postTable heightForRowAtIndexPath:[self.postTable indexPathForCell:pcell]];
    [self.postTable endUpdates];
}

-(void)fetchLatest{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
    
    [requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    manager.requestSerializer.timeoutInterval = 60*4;
    
    NSMutableDictionary *postdata = [NSMutableDictionary dictionary];
    [postdata setObject:self.groupId forKey:@"group_id"];
    [postdata setObject:[self appDelegate].myUserID forKey:@"user_id"];
    
    NSString *url =[NSString stringWithFormat:@"%@/scripts/post_data.php",gupappUrl];
    [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:postdata success:^(AFHTTPRequestOperation *operation, id responseObject){
        requestFlag = TRUE;
        latest = true;
        NSData * data = (NSData *)responseObject;
        NSError *error = nil;
        NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"error %@",JSON);
        
        if(JSON.count){
            if(isPrivate) {
                NSString *query1=[NSString stringWithFormat:@"UPDATE groups_private SET max_time=%@,min_time=%@ WHERE group_server_id = %@",[[JSON firstObject] objectForKey:@"created"],[[JSON lastObject] objectForKey:@"created"],self.groupId];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query1];
            }else{
                NSString *query1=[NSString stringWithFormat:@"UPDATE groups_public SET max_time=%@,min_time=%@ WHERE group_server_id = %@",[[JSON firstObject] objectForKey:@"created"],[[JSON lastObject] objectForKey:@"created"],self.groupId];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query1];
            }
        }
        
        if(JSON.count<15){
            isMoreAvailable=false;
        }
        if(JSON.count>0){
            [self UpdateDataBase:JSON];
        }
        
        //[HUD1 removeFromSuperview];
        [HUD removeFromSuperview];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       // [HUD1 removeFromSuperview];
        [HUD removeFromSuperview];
    }];
    
}

-(void)fetchPostData{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
    
    [requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    manager.requestSerializer.timeoutInterval = 60*4;
    NSString *time = nil;

    if(isPrivate){
        NSArray *minTime = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT min_time FROM groups_private WHERE group_server_id = %@",self.groupId]];
        time = [[minTime lastObject] objectForKey:@"MIN_TIME"];
    }else{
        NSArray *minTime = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT min_time FROM groups_public WHERE group_server_id = %@",self.groupId]];
        time = [[minTime lastObject] objectForKey:@"MIN_TIME"];
        
    }
    
    NSMutableDictionary *postdata = [NSMutableDictionary dictionary];
    [postdata setObject:self.groupId forKey:@"group_id"];
    [postdata setObject:@"previous" forKey:@"post_fetch_from"];
    [postdata setObject:[self appDelegate].myUserID forKey:@"user_id"];
    if(time)
        [postdata setObject:time forKey:@"post_timestamp"];
    
    NSString *url =[NSString stringWithFormat:@"%@/scripts/post_data.php",gupappUrl];
    [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:postdata success:^(AFHTTPRequestOperation *operation, id responseObject) {
        requestFlag = TRUE;
        NSData * data = (NSData *)responseObject;
        NSError *error = nil;
        NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"error %@",JSON);
        if (JSON.count<15) {
            isMoreAvailable=false;
        }
        if(JSON.count){
            if(isPrivate) {
                NSString *query=[NSString stringWithFormat:@"UPDATE groups_private SET min_time=%@ WHERE group_server_id = %@",[[JSON firstObject] objectForKey:@"created"],self.groupId];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            }else{
                NSString *query=[NSString stringWithFormat:@"UPDATE groups_public SET min_time=%@ WHERE group_server_id = %@",[[JSON firstObject] objectForKey:@"created"],self.groupId];//created = 1422440570948;
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            }
            [self UpdateDataBase:JSON];

        }else{
            [_postTable reloadData];
        }
        [indicator stopAnimating];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Unable to retrieve posts at this time. Could not connect to the internet" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        requestFlag=true;
        [indicator stopAnimating];
    }];
    
}

-(void)loadNewPost{
    
    if(newPostNotificationView.frame.size.height!=0){
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(hideNotificationView)
                                                   object:nil];
        [UIView beginAnimations:@"FadeOut" context:nil];
        [UIView setAnimationDuration:0.5];
        newPostNotificationView.frame = CGRectMake(0, 0, newPostNotificationView.frame.size.width, 0);
        _postTable.frame = CGRectMake(_postTable.frame.origin.x, _postTable.frame.origin.y-40, _postTable.frame.size.width, _postTable.frame.size.height+40);
        notificationlabel.frame = CGRectMake(notificationlabel.frame.origin.x,notificationlabel.frame.origin.y,200, 0);
        [UIView commitAnimations];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
    
    [requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    manager.requestSerializer.timeoutInterval = 60*4;
    
    NSString *maxTimeStr = nil;
    if(isPrivate){
        NSArray *maxTime = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT max_time FROM groups_private WHERE group_server_id = %@",self.groupId]];
        maxTimeStr = [[maxTime lastObject] objectForKey:@"MAX_TIME"];
        
    }else{
        NSArray *maxTime = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT max_time FROM groups_public WHERE group_server_id = %@",self.groupId]];
        maxTimeStr = [[maxTime lastObject] objectForKey:@"MAX_TIME"];
        
    }
    
    NSMutableDictionary *postdata = [NSMutableDictionary dictionary];
    [postdata setObject:self.groupId forKey:@"group_id"];
    [postdata setObject:[self appDelegate].myUserID forKey:@"user_id"];
    if(maxTimeStr){
        [postdata setObject:maxTimeStr forKey:@"post_timestamp"];
        [postdata setObject:@"next" forKey:@"post_fetch_from"];
    }
    
    NSString *url =[NSString stringWithFormat:@"%@/scripts/post_data.php",gupappUrl];
    [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:postdata success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData * data = (NSData*)responseObject;
        NSError *error = nil;
        NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"error %@",JSON);
        if(JSON.count){
            if(isPrivate) {
                NSString *query1=[NSString stringWithFormat:@"UPDATE groups_private SET max_time=%@ WHERE group_server_id = %@",[[JSON lastObject] objectForKey:@"created"],self.groupId];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query1];
            }else{
                NSString *query1=[NSString stringWithFormat:@"UPDATE groups_public SET max_time=%@ WHERE group_server_id = %@",[[JSON lastObject] objectForKey:@"created"],self.groupId];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query1];
            }
            loadNew= true;
             [self UpdateDataBase:JSON];
        }

        if(pullRfrs.isRefreshing)
            [pullRfrs endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(pullRfrs.isRefreshing)
            [pullRfrs endRefreshing];
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Unable to retrieve posts at this time. Could not connect to the internet" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        [HUD removeFromSuperview];
    }];
}

-(void)UpdateDataBase:(NSArray*)JSON{
    
    NSArray *postData = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT post_id,is_fav,user_id,updated FROM Post WHERE group_id = %d",[self.groupId intValue]]];
    
    if(deleteFlag){
        deleteFlag = false;
        
        for (NSDictionary *dic in postData) {
            
            if([[dic objectForKey:@"IS_FAV"] intValue]!=1 ){
                
                [[DatabaseManager getSharedInstance]deleteDataWithQuery:[NSString stringWithFormat:@"DELETE FROM PostImageUrl WHERE post_id = %d",[[dic objectForKey:@"POST_ID"]intValue]]];
                [[DatabaseManager getSharedInstance]deleteDataWithQuery:[NSString stringWithFormat:@"DELETE FROM Post WHERE group_id = %d AND post_id = %d",[self.groupId intValue],[[dic objectForKey:@"POST_ID"]intValue]]];
                
            }else{
                NSString *likestatus;
                NSDate *now = [NSDate date];
                NSTimeInterval seconds =  [now timeIntervalSince1970];
                double currentDataMiliSecend = seconds*1000;
//                double currentDataMiliSecend  = [[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
                double updateTime = [[dic objectForKey:@"UPDATED"] doubleValue];
                int postid = [[dic objectForKey:@"POST_ID"] intValue];
                double timeDifference = currentDataMiliSecend - updateTime;
                if(timeDifference > 24*2*60*60*1000){
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:[NSString stringWithFormat:@"DELETE FROM PostImageUrl WHERE post_id = %d",postid]];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:[NSString stringWithFormat:@"DELETE FROM Post WHERE post_id = %d",postid]];
                    
                }
                
            }
        }
    }
    
    for (NSDictionary *post in JSON) {
        
        NSString *query=[NSString stringWithFormat:@"SELECT  description,user_id, user_name,user_image,created,updated,is_fav,total_likes,total_comments,imageCount from Post WHERE group_id = %@ AND post_id = %d  ",self.groupId,[[post objectForKey:@"post_id"] intValue]];
        NSArray *postDataArray =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:query];
        
        if(postDataArray.count == 0){
            int fav;
            if([post objectForKey:@"post_urls_data"]){
                NSArray *urls = [post objectForKey:@"post_urls_data"];
                if([[post objectForKey:@"user_id"] intValue] == [[self appDelegate].myUserID intValue] || [[post objectForKey:@"is_liked"] intValue]==1)
                    fav = 1;
                else
                    fav = 0;
                NSString *query=[NSString stringWithFormat:@"insert into Post (is_report,post_id, group_id, imageCount, description,user_id, user_name,user_image,created,updated,is_fav,total_likes,total_comments,is_like) values (%@,'%@','%@',%d,'%@','%@','%@','%@','%@','%@',%d,%@,%@,%@)",[post objectForKey:@"isReport"]?[post objectForKey:@"isReport"]:@"0",[post objectForKey:@"post_id"],self.groupId,[urls count],[[post objectForKey:@"post_text"] stringByReplacingOccurrencesOfString:@"'" withString:@"''" ],[post objectForKey:@"user_id"],[post objectForKey:@"display_name"],[post objectForKey:@"user_image"],[post objectForKey:@"created"],[post objectForKey:@"updated"],fav,[post objectForKey:@"total_likes"],[post objectForKey:@"total_comments"],[post objectForKey:@"is_liked"]];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
                for (NSString *urlDic in urls) {
                    NSString *query=[NSString stringWithFormat:@"insert into PostImageUrl (post_id,image_url) values ('%@','%@')",[post objectForKey:@"post_id"],urlDic];
                    NSLog(@"query %@",query);
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
                    
                }

            }
            
        }else{

            NSString *query=[NSString stringWithFormat:@"UPDATE Post SET is_report=%@,is_like = %@,user_image=\"%@\",total_likes=%d,user_name ='%@' WHERE post_id = %@",[post objectForKey:@"isReport"]?[post objectForKey:@"isReport"]:@"0",[post objectForKey:@"is_liked"],[post objectForKey:@"user_image"],[[post objectForKey:@"total_likes"] intValue],[post objectForKey:@"display_name"],[post objectForKey:@"post_id"]];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
            
            NSString *query1=[NSString stringWithFormat:@"UPDATE Post SET total_comments=%d WHERE post_id = %@ AND total_comments < %d", [[post objectForKey:@"total_comments"] intValue],[post objectForKey:@"post_id"],[[post objectForKey:@"total_comments"] intValue]];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query1];
            
        }
    }
    
    
    if(latest){
        [self reloadTable];
        latest = false;
    }else{
        
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic in JSON) {
            NSArray *imagearr = [dic objectForKey:@"post_urls_data"];
            NSMutableDictionary *postData = [NSMutableDictionary dictionary];
            [postData setValue:[dic objectForKey:@"post_text"] forKey:@"description"];
            [postData setValue:[NSString stringWithFormat:@"%d",[imagearr count]] forKey:@"imageCount"];
            [postData setValue:@"1" forKey:@"index"];
            int fav;
            if([[dic objectForKey:@"user_id"] intValue] == [[self appDelegate].myUserID intValue] || [[dic objectForKey:@"is_liked"] intValue]==1)
                fav = 1;
            else
                fav = 0;
            
            [postData setValue:[NSString stringWithFormat:@"%d",fav] forKey:@"is_fav"];
            [postData setValue:[dic objectForKey:@"isReport"] forKey:@"is_report"];
            [postData setValue:[dic objectForKey:@"is_liked"] forKey:@"islike"];
            [postData setValue:[dic objectForKey:@"post_id"] forKey:@"post_id"];
            if(fav ==1 )
                [postData setValue:[dic objectForKey:@"updated"] forKey:@"time"];
            if(fav ==0 )
                [postData setValue:[dic objectForKey:@"created"] forKey:@"time"];
            [postData setValue:[dic objectForKey:@"total_comments"] forKey:@"total_comments"];
            [postData setValue:[dic objectForKey:@"total_likes"] forKey:@"total_likes"];
            [postData setValue:[dic objectForKey:@"user_id"] forKey:@"user_id"];
            [postData setValue:[dic objectForKey:@"user_image"] forKey:@"user_image"];
            [postData setValue:[dic objectForKey:@"display_name"] forKey:@"user_name"];
            int i=1;
            for (NSString *imageData in imagearr) {
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
                [imageDic setValue:imageData forKey:@"image_url"];
                [postData setValue:imageDic forKey:[NSString stringWithFormat:@"image_%d",i++]];
            }
            
            [arr addObject:postData];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"time"  ascending:NO];
        NSMutableArray *sortedArray=[[arr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] mutableCopy];
        
        if(loadNew){
            postListData = [[sortedArray arrayByAddingObjectsFromArray:postListData] mutableCopy]; loadNew=false;
        }else
            postListData = [[postListData arrayByAddingObjectsFromArray:sortedArray] mutableCopy];
         [self.postTable reloadData];
    }
   
    
}


-(void)reloadTable{
    
    [postListData removeAllObjects];
    
    NSString *favQuery=[NSString stringWithFormat:@"SELECT post_id,is_report, description,user_id, user_name,user_image,created,updated,is_fav,total_likes,total_comments,imageCount,is_like from Post WHERE group_id = %@ AND is_fav=1 ORDER BY updated DESC",self.groupId];
    NSArray *favPostDataArray =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:favQuery];
    
    NSString *udfavQuery=[NSString stringWithFormat:@"SELECT post_id,is_report, description,user_id, user_name,user_image,created,updated,is_fav,total_likes,total_comments,imageCount,is_like from Post WHERE group_id = %@ AND is_fav=0 ORDER BY created DESC",self.groupId];
    NSArray *dataArray =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:udfavQuery];
    
    for (NSDictionary *post in favPostDataArray) {
        
        NSString *query=[NSString stringWithFormat:@"SELECT image_url from PostImageUrl WHERE post_id = %@ ",[post objectForKey:@"POST_ID"]];
        NSArray *postData =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:query];
        
        NSMutableDictionary *tampPostData = [NSMutableDictionary dictionary];
        [tampPostData setValue:[post objectForKey:@"USER_ID"] forKey:@"user_id"];
        [tampPostData setValue:[post objectForKey:@"USER_IMAGE"] forKey:@"user_image"];
        [tampPostData setValue:[post objectForKey:@"USER_NAME"] forKey:@"user_name"];
        [tampPostData setValue:[post objectForKey:@"POST_ID"] forKey:@"post_id"];
        [tampPostData setValue:[post objectForKey:@"DESCRIPTION"] forKey:@"description"];
        [tampPostData setValue:[post objectForKey:@"TOTAL_LIKES"] forKey:@"total_likes"];
        [tampPostData setValue:[post objectForKey:@"IS_REPORT"] forKey:@"is_report"];
        [tampPostData setValue:[post objectForKey:@"UPDATED"] forKey:@"time"];
        //        [tampPostData setValue:[post objectForKey:@"UPDATED"] forKey:@"updated"];
        //        [tampPostData setValue:[post objectForKey:@"CREATED"] forKey:@"created"];
        [tampPostData setValue:[post objectForKey:@"TOTAL_COMMENTS"] forKey:@"total_comments"];
        [tampPostData setValue:[post objectForKey:@"IMAGECOUNT"] forKey:@"imageCount"];
        [tampPostData setValue:[post objectForKey:@"IS_FAV"] forKey:@"is_fav"];
        [tampPostData setValue:[post objectForKey:@"IS_LIKE"] forKey:@"islike"];
        [tampPostData setValue:[NSString stringWithFormat:@"%d",1] forKey:@"index"];
        int i = 1;
        for (NSDictionary *imageData in postData) {
            NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
            [imageDic setValue:[imageData objectForKey:@"IMAGE_URL"] forKey:@"image_url"];
            [tampPostData setValue:imageDic forKey:[NSString stringWithFormat:@"image_%d",i++]];
        }
        
        [postListData addObject:tampPostData];
    }
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"time"  ascending:NO];
    NSArray *arr=[postListData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    postListData  = [arr mutableCopy];
    
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSDictionary *post in dataArray) {
        
        NSString *query=[NSString stringWithFormat:@"SELECT image_url from PostImageUrl WHERE post_id = %@ ",[post objectForKey:@"POST_ID"]];
        NSArray *postData =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:query];
        
        NSMutableDictionary *tampPostData = [NSMutableDictionary dictionary];
        [tampPostData setValue:[post objectForKey:@"USER_ID"] forKey:@"user_id"];
        [tampPostData setValue:[post objectForKey:@"USER_IMAGE"] forKey:@"user_image"];
        [tampPostData setValue:[post objectForKey:@"USER_NAME"] forKey:@"user_name"];
        [tampPostData setValue:[post objectForKey:@"POST_ID"] forKey:@"post_id"];
        [tampPostData setValue:[post objectForKey:@"DESCRIPTION"] forKey:@"description"];
        [tampPostData setValue:[post objectForKey:@"TOTAL_LIKES"] forKey:@"total_likes"];
        [tampPostData setValue:[post objectForKey:@"IS_REPORT"] forKey:@"is_report"];
        [tampPostData setValue:[post objectForKey:@"CREATED"] forKey:@"time"];
        //        [tampPostData setValue:[post objectForKey:@"UPDATED"] forKey:@"updated"];
        //        [tampPostData setValue:[post objectForKey:@"CREATED"] forKey:@"created"];
        [tampPostData setValue:[post objectForKey:@"TOTAL_COMMENTS"] forKey:@"total_comments"];
        [tampPostData setValue:[post objectForKey:@"IMAGECOUNT"] forKey:@"imageCount"];
        [tampPostData setValue:[post objectForKey:@"IS_FAV"] forKey:@"is_fav"];
        [tampPostData setValue:[post objectForKey:@"IS_LIKE"] forKey:@"islike"];
        [tampPostData setValue:[NSString stringWithFormat:@"%d",1] forKey:@"index"];
        int i = 1;
        for (NSDictionary *imageData in postData) {
            NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
            [imageDic setValue:[imageData objectForKey:@"IMAGE_URL"] forKey:@"image_url"];
            [tampPostData setValue:imageDic forKey:[NSString stringWithFormat:@"image_%d",i++]];
        }
        [postListData addObject:tampPostData];

    }
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"time"  ascending:NO];
    NSArray *arr1=[postListData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor1,nil]];
    postListData = [arr1 mutableCopy];
//    postListData = [[postListData arrayByAddingObjectsFromArray:arr1] mutableCopy];
    [self.postTable reloadData];

}

-(NSString*)RadhaCompatiableDecodingForString:(NSString*)str{
    
    return  [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
}

-(void)commentButtonClick:(UIButton*)btn{
    
    postCell *pcell;
    if ([[btn superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[btn superview];
    }else if ([[[btn superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[btn superview] superview];
    }else if ([[[[btn superview] superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[[btn superview] superview] superview];
    }
    NSIndexPath *cellIndexPath =[self.postTable indexPathForCell:pcell];
    NSDictionary *groupData = [postListData objectAtIndex:cellIndexPath.section];
    CommentViewController *detailPage = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    detailPage.chatType = @"group";
    detailPage.toJid = [NSString stringWithFormat:@"group_%@@%@",self.groupId,groupJabberUrl];
    detailPage.chatTitle=self.groupName;
    if(isPrivate)
        detailPage.groupType = @"private";
    else
        detailPage.groupType = @"public";
    detailPage.postId = [groupData objectForKey:@"post_id"];
    [self.navigationController pushViewController:detailPage animated:YES];
    
}


-(void)likePost:(UIButton*)btn{
    postCell *pcell;
    if ([[btn superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[btn superview];
    }else if ([[[btn superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[btn superview] superview];
    }
    else if ([[[[btn superview] superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[[btn superview] superview] superview];
    }
    NSIndexPath *cellIndexPath =[self.postTable indexPathForCell:pcell];
    NSMutableDictionary *groupData = [postListData objectAtIndex:cellIndexPath.section];
    
    UILabel *likelbl = (UILabel*)[[pcell viewWithTag:11] viewWithTag:2];
    
    NSArray *totalLike = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT total_likes FROM Post WHERE post_id = %@",[groupData objectForKey:@"post_id"]]];
    int total = [[[totalLike firstObject] objectForKey:@"TOTAL_LIKES"] intValue];
    
    NSString *likestatus;
    NSDate *now = [NSDate date];
    NSTimeInterval seconds =  [now timeIntervalSince1970];
    double time1 = seconds*1000;
    
//    double time1 =[[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
    if([[groupData objectForKey:@"islike"] intValue]==1){
        --total;
        likestatus = @"unlike";
        [groupData setValue:@"0" forKey:@"islike"];
        [groupData setValue:[NSNumber numberWithInt:total] forKey:@"total_likes"];
        [btn setBackgroundImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
        
        if(total == 0)
            likelbl.userInteractionEnabled = NO;
        else
            likelbl.userInteractionEnabled = YES;
        
        likelbl.text = [NSString stringWithFormat:@"%d Likes",total];
//        NSString *query=[NSString stringWithFormat:@"UPDATE Post SET is_like=0,total_likes = %d,updated = %.0f WHERE post_id = %@",total,time1,[groupData objectForKey:@"post_id"]];
        NSString *query=[NSString stringWithFormat:@"UPDATE Post SET is_like=0,total_likes = %d WHERE post_id = %@",total,[groupData objectForKey:@"post_id"]];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query];

       NSString *timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
       
        [self updateGroupTime:timeInMiliseconds];
        
         if([[groupData objectForKey:@"user_id"] intValue] == [[self appDelegate].myUserID intValue]){
            NSString *updateTime=[NSString stringWithFormat:@"UPDATE Post SET updated=%.0f WHERE post_id = %@",time1,[groupData objectForKey:@"post_id"]];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateTime];

        }else{
            
//            NSString *updateTime=[NSString stringWithFormat:@"UPDATE Post SET is_fav = 0 WHERE post_id = %@",[groupData objectForKey:@"post_id"]];
//            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateTime];
            NSString *commentque = [NSString stringWithFormat:@"SELECT count(message_id) FROM chat_group WHERE user_id = %@ AND post_id=%@",[self appDelegate].myUserID,[groupData objectForKey:@"post_id"]];
            NSArray *postData =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:commentque];
            int messageCount =[[[postData firstObject] objectForKey:@"COUNT(MESSAGE_ID)"] intValue];
            if(messageCount==0){
                NSString *query=[NSString stringWithFormat:@"UPDATE Post SET is_fav = 0 WHERE post_id = %@",[groupData objectForKey:@"post_id"]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:query];
                [groupData setValue:@"0" forKey:@"is_fav"];
            }
        }
        [postListData replaceObjectAtIndex:[postListData indexOfObject:[postListData objectAtIndex:cellIndexPath.section]] withObject:groupData];

    }else{
        
        ++total;
        likestatus = @"like";
        [groupData setValue:[NSNumber numberWithInt:total] forKey:@"total_likes"];
        [groupData setValue:@"1" forKey:@"islike"];
        [groupData setValue:@"1" forKey:@"is_fav"];
        [postListData replaceObjectAtIndex:[postListData indexOfObject:[postListData objectAtIndex:cellIndexPath.section]] withObject:groupData];
        [btn setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        if(total == 0)
            likelbl.userInteractionEnabled = NO;
        else
            likelbl.userInteractionEnabled = YES;
        likelbl.text = [NSString stringWithFormat:@"%d Likes",total];
         NSString *query=[NSString stringWithFormat:@"UPDATE Post SET is_like=1,total_likes = %d ,updated = %.0f WHERE post_id = %@",total,time1,[groupData objectForKey:@"post_id"]];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query];
        
        NSString *query1=[NSString stringWithFormat:@"UPDATE Post SET  is_fav = 1 WHERE post_id = %@ AND is_fav = 0 ",[groupData objectForKey:@"post_id"]];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query1];
        
        NSString *timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
        [self updateGroupTime:timeInMiliseconds];
        
      }
    
    
    NSString *query=[NSString stringWithFormat:@"insert into offlinelike (postid, groupid, likestatus, updatedTime) values (%@,%@,'%@',%@)",[groupData objectForKey:@"post_id"],self.groupId,likestatus,[NSString stringWithFormat:@"%.0f",time1]];
    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
    
    XMPPPresence *likeiq = [XMPPPresence elementWithName:@"presence"];
    [likeiq addAttributeWithName:@"to" stringValue:jabberUrl];
    [likeiq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"like_%.0f",time1]];
    NSXMLElement *likeuser = [NSXMLElement elementWithName:@"status" stringValue:@"like"];
    NSXMLElement *show = [NSXMLElement elementWithName:@"likedata" xmlns:@"urn:xmpp:guplike"];
    NSXMLElement *user = [NSXMLElement elementWithName:@"user" stringValue:[self appDelegate].MyUserName];
    NSXMLElement *userid = [NSXMLElement elementWithName:@"userid" stringValue:[self appDelegate].myUserID];
    NSXMLElement *status = [NSXMLElement elementWithName:@"likestatus" stringValue:likestatus];
    NSXMLElement *groupid = [NSXMLElement elementWithName:@"groupid" stringValue:self.groupId];
    NSXMLElement *postid = [NSXMLElement elementWithName:@"postid" stringValue:[groupData objectForKey:@"post_id"]];
    NSXMLElement *updatedTime = [NSXMLElement elementWithName:@"updatedTime" stringValue:[NSString stringWithFormat:@"%.0f",time1]];
    
    [show addChild:user];
    [show addChild:userid];
    [show addChild:status];
    [show addChild:groupid];
    [show addChild:postid];
    [show addChild:updatedTime];
    //    NSXMLElement *show = [NSXMLElement elementWithName:@"likedata" stringValue:nsJson];
    [likeiq addChild:likeuser];
    [likeiq addChild:show];
    NSLog(@"%@",likeiq);
    [[self appDelegate].xmppStream sendElement:likeiq];
    
}



-(void)likeLabelAction:(UIGestureRecognizer*)gesture{
    
    postCell *pcell;
    UILabel *lbl = (UILabel*)[gesture view];
    if ([[lbl superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[lbl superview];
    }else if ([[[lbl superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[lbl superview] superview];
    }else if ([[[[lbl superview] superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[[lbl superview] superview] superview];
    }
    NSIndexPath *cellIndexPath =[self.postTable indexPathForCell:pcell];
    LikeViewController *like = [[LikeViewController alloc] initWithNibName:@"LikeViewController" bundle:nil];
    like.postid = [[postListData objectAtIndex:cellIndexPath.section] objectForKey:@"post_id"];
    [self.navigationController pushViewController:like animated:YES];
}

-(void)commentLblAction:(UIGestureRecognizer*)gesture{
    postCell *pcell;
    UILabel *lbl = (UILabel*)[gesture view];
    if ([[lbl superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[lbl superview];
    }else if ([[[lbl superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[lbl superview] superview];
    }else if ([[[[lbl superview] superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[[lbl superview] superview]superview];
    }
    
    NSIndexPath *cellIndexPath =[self.postTable indexPathForCell:pcell];
    NSDictionary *groupData = [postListData objectAtIndex:cellIndexPath.section];
    CommentViewController *detailPage = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    detailPage.chatType = @"group";
    detailPage.toJid = [NSString stringWithFormat:@"group_%@@%@",self.groupId,groupJabberUrl];
    detailPage.chatTitle=self.groupName;
    if(isPrivate)
        detailPage.groupType = @"private";
    else
        detailPage.groupType = @"public";
    detailPage.postId = [groupData objectForKey:@"post_id"];
    [self.navigationController pushViewController:detailPage animated:YES];
    
}


-(void)likeUnlikeAction:(NSNotification*)notification{
    NSDictionary *notificationdata = [notification userInfo];
    int i = 0;
    for (NSDictionary *dic in postListData) {
        if([[dic objectForKey:@"post_id"] intValue] == [[notificationdata objectForKey:@"postid"] intValue]){
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:i];
            postCell *pCell = (postCell*)[_postTable cellForRowAtIndexPath:index];
            NSMutableDictionary *mutDic = [dic mutableCopy];
            int j = [[mutDic objectForKey:@"total_likes"] intValue];
            if([[notificationdata objectForKey:@"status"] caseInsensitiveCompare:@"like"] == NSOrderedSame)
                [mutDic setValue:[NSString stringWithFormat:@"%d",++j] forKey:@"total_likes"];
            else
                [mutDic setValue:[NSString stringWithFormat:@"%d",--j] forKey:@"total_likes"];
            
            [_postTable beginUpdates];
            NSMutableArray *tempArray = [postListData mutableCopy];
            [tempArray replaceObjectAtIndex:[postListData indexOfObject:dic] withObject:mutDic];
            postListData = [tempArray mutableCopy];
            UILabel *label = (UILabel*)[pCell viewWithTag:2];
            label.text = [NSString stringWithFormat:@"%d Likes",j];
            [_postTable endUpdates];
        }
        i++;
    }
}

-(void)commentAction:(NSNotification*)notification{
    
    NSDictionary *notificationdata = [notification userInfo];
    int i = 0;
    for (NSDictionary *dic in postListData) {
        if([[dic objectForKey:@"post_id"] intValue] == [[notificationdata objectForKey:@"postid"] intValue]){
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:i];
            postCell *pCell = (postCell*)[_postTable cellForRowAtIndexPath:index];
            NSMutableDictionary *mutDic = [dic mutableCopy];
            int j = [[mutDic objectForKey:@"total_comments"] intValue];
            [mutDic setValue:[NSString stringWithFormat:@"%d",++j] forKey:@"total_comments"];
            [_postTable beginUpdates];
            NSMutableArray *tempArray = [postListData mutableCopy];
            [tempArray replaceObjectAtIndex:[postListData indexOfObject:dic] withObject:mutDic];
            postListData = [tempArray mutableCopy];
            UILabel *label = (UILabel*)[pCell viewWithTag:4];
            label.text = [NSString stringWithFormat:@"%d Comments",j];
            [_postTable endUpdates];
        }
        i++;
    }
}

-(void)repostPost:(UIButton*)btn{
    postCell *pcell;
    if ([[btn superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[btn superview];
    }else if ([[[btn superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[btn superview] superview];
    }else if ([[[[btn superview] superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[[btn superview] superview] superview];
    }
    
    report = (UIButton*)[pcell viewWithTag:15];
    cellIndexPath =[self.postTable indexPathForCell:pcell];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you want to report this topic as inappropriate" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    alert.tag = cellIndexPath.section;
    [alert show];
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        [self sendReport:cellIndexPath button:report];
    }

}

-(void)openImageInFullSize:(UIImageView*)img currentImageUrl:(NSString*)url{
    
    postCell *pcell;
    if ([[img superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[img superview];
    }else if ([[[img superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[img superview] superview];
    }
    imageShowView.hidden = NO;
    NSIndexPath *cellIndexPath =[self.postTable indexPathForCell:pcell];
    [spinner startAnimating];
    [fullSizeImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"imageplaceholder"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        if (image) {
            fullSizeImage.image = image;
        }else{
            fullSizeImage.image = [UIImage imageNamed:@"imageplaceholder"];
        }
        [spinner stopAnimating];
        
    }];
    imageDataDictonary = [[postListData objectAtIndex:cellIndexPath.section] mutableCopy];
    pageControl.numberOfPages = [[imageDataDictonary objectForKey:@"imageCount"] intValue];
    int ind = [[imageDataDictonary objectForKey:@"index"] integerValue];
    pageControl.currentPage = ind-1;
    
}

-(void)hideImageView:(UIGestureRecognizer*)gesture{
    imageShowView.hidden = YES;
}
-(void)leftImageChangeAction:(UIGestureRecognizer*)gesture{
    
    int ind = [[imageDataDictonary valueForKey:@"index"] integerValue];
    if(ind == 0)
        ind +=2;
    else
        ind+=1;
    
    NSString *postImagePath = [[imageDataDictonary objectForKey:[NSString stringWithFormat:@"image_%d",ind]] objectForKey:@"image_url"];
    if(postImagePath){
        [imageDataDictonary setValue:[NSString stringWithFormat:@"%d",ind] forKey:@"index"];
        [spinner startAnimating];
        [fullSizeImage sd_setImageWithURL:[NSURL URLWithString:postImagePath] placeholderImage:[UIImage imageNamed:@"imageplaceholder"] completed:^(UIImage *cImage , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (cImage) {
                fullSizeImage.image = cImage;
            }else{
                fullSizeImage.image = [UIImage imageNamed:@"imageplaceholder"];
            }
            [spinner stopAnimating];
            
        }];
        int i =  ind-1;
        pageControl.currentPage = i;
        
    }
}

-(void)rigthImageChangeAction:(UIGestureRecognizer*)gesture{
    
    int ind = [[imageDataDictonary valueForKey:@"index"] integerValue];
    ind -=1;
    
    NSString *postImagePath = [[imageDataDictonary objectForKey:[NSString stringWithFormat:@"image_%d",ind]] objectForKey:@"image_url"];
    if(postImagePath){
        [imageDataDictonary setValue:[NSString stringWithFormat:@"%d",ind] forKey:@"index"];
        [spinner startAnimating];
        [fullSizeImage sd_setImageWithURL:[NSURL URLWithString:postImagePath] placeholderImage:[UIImage imageNamed:@"imageplaceholder"] completed:^(UIImage *cImage , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (cImage) {
                fullSizeImage.image = cImage;
            }else{
                fullSizeImage.image = [UIImage imageNamed:@"imageplaceholder"];
            }
            [spinner stopAnimating];
            
        }];
        
        int i =  ind-1;
        pageControl.currentPage = i;
    }
    
    
}

-(void)sharePost:(UIButton*)btn{
    postCell *pcell;
    if ([[btn superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[btn superview];
    }else if ([[[btn superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[btn superview] superview];
    }else if ([[[[btn superview] superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[[btn superview] superview] superview];
    }
    NSIndexPath *cellIndexPath =[self.postTable indexPathForCell:pcell];
    NSDictionary *groupData = [postListData objectAtIndex:cellIndexPath.section];
    ShareGroupInfo *share = [[ShareGroupInfo alloc] initWithNibName:@"ShareGroupInfo" bundle:nil];
    share.postText = [[groupData objectForKey:@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    share.groupName = self.groupName;
    share.noOfLikes = [groupData objectForKey:@"total_likes"];
    share.noOfComments = [groupData objectForKey:@"total_comments"];
    NSString *timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
    [self updateGroupTime:timeInMiliseconds];
    int i=1;
    share.imageURl=[NSMutableArray array];
    while (true){
        NSString *imageKey = [NSString stringWithFormat:@"image_%d",i++];
        if([groupData objectForKey:imageKey]){
            NSDictionary *data = [groupData objectForKey:imageKey];
            [share.imageURl addObject:[data objectForKey:@"image_url"]];
        }else
            break;
    }
    [self.navigationController pushViewController:share animated:YES];
    
}

-(void)openUserProfileImage:(UIImageView*)userImage{

    postCell *pcell;
    if ([[userImage superview] isKindOfClass:[postCell class]]) {
        pcell = (postCell *)[userImage superview];
    }else if ([[[userImage superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[userImage superview] superview];
    }else if ([[[[userImage superview] superview] superview] isKindOfClass:[postCell class]]){
        pcell = (postCell *)[[[userImage superview] superview] superview];
    }
    NSIndexPath *cellIndexPath =[self.postTable indexPathForCell:pcell];
    NSDictionary *groupData = [postListData objectAtIndex:cellIndexPath.section];
    
    ViewContactProfile *viewContact = [[ViewContactProfile alloc]init];
    viewContact.userId=[groupData objectForKey:@"user_id"];
    [self.navigationController pushViewController:viewContact animated:YES];
    
    
}



-(void)sendReport:(NSIndexPath*)indexPath button:(UIButton*)btn{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
    
    [requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    manager.requestSerializer.timeoutInterval = 60*4;
    
    //    NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT MIN(created) FROM Post WHERE group_id = %@",self.groupId]];
    NSDictionary *groupData = [postListData objectAtIndex:indexPath.section];
    NSMutableDictionary *postdata = [NSMutableDictionary dictionary];
    [postdata setObject:[groupData objectForKey:@"post_id"] forKey:@"post_id"];
    [postdata setObject:[self appDelegate].myUserID forKey:@"user_id"];
    
    NSString *url =[NSString stringWithFormat:@"%@/scripts/report_post.php",gupappUrl];
    [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:postdata success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData * data = (NSData *)responseObject;
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"error %@",JSON);
        if([[JSON objectForKey:@"message"] isEqualToString:@"Record Inserted"]){
            NSString *query=[NSString stringWithFormat:@"UPDATE Post SET is_report=1 WHERE post_id = %@",[groupData objectForKey:@"post_id"]];
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:query];
            [groupData setValue:@"1" forKey:@"is_report"];
            [postListData replaceObjectAtIndex:[postListData indexOfObject:[postListData objectAtIndex:indexPath.section]] withObject:groupData];
            [btn setBackgroundImage:[UIImage imageNamed:@"reported"] forState:UIControlStateNormal];
            NSString *timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
            [self updateGroupTime:timeInMiliseconds];
             btn.userInteractionEnabled = NO;
        }else{
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Unable to report posts at this time" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Unable to report posts at this time. Could not connect to the internet" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        requestFlag=true;
        [indicator stopAnimating];
        
        
    }];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    [HUD hide:YES];
    NSArray *master_table1=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name,logged_in_user_id,chat_wall_paper from master_table"];
    
    NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_group.id,user_id,time_stamp,message_id,message_type,message_text,message_filename,post_id from chat_group INNER  JOIN chat_message where user_id=%@ AND group_id = %@ AND messageStatus=0 AND  message_id=chat_message.id order by chat_group.time_stamp ASC",[self appDelegate].myUserID,_groupId]];
    if(groupUnsendMessages.count>0)
        for (int i=0; i<[groupUnsendMessages count]; i++)   {
            
            NSDictionary *row=   [[DatabaseManager getSharedInstance]DatabaseOutputParserRetrieveRowFromRowIndex:i FromOutput:groupUnsendMessages];
            NSDictionary *userDictonary = [master_table1 lastObject];
            
            XMPPMessage *msg = [XMPPMessage message];
            [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
            [msg addAttributeWithName:@"groupCounter" integerValue:[@"" integerValue]];
            [msg addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",sender.roomJID]];
            [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ];
            [msg addAttributeWithName:@"isResend" boolValue:[@"1" boolValue]];
            NSString *recieversID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"CHAT_GROUP.ID" givenRow:row];
            [msg addAttributeWithName:@"referenceID" integerValue:[recieversID integerValue]];
            
            NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[row objectForKey:@"MESSAGE_TEXT"]];
            NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[row objectForKey:@"USER_ID"]];
            NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:[userDictonary objectForKey:@"DISPLAY_NAME"]];
            NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:[row objectForKey:@"MESSAGE_TYPE"]];
            NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[row objectForKey:@"TIME_STAMP"]];
            NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:_groupId];
            NSXMLElement *isgroup =[NSXMLElement elementWithName:@"ispost" stringValue:@"0"];
            NSXMLElement *postid =[NSXMLElement elementWithName:@"postid" stringValue:[row objectForKey:@"POST_ID"]];
            NSXMLElement *referanceID = [NSXMLElement elementWithName:@"referenceID" stringValue:recieversID];
            
            
            [gup addChild:body];
            [gup addChild:from_user_id];
            [gup addChild:from_user_name];
            [gup addChild:timeStamp];
            [gup addChild:message_type];
            [gup addChild:referanceID];
            [gup addChild:isgroup];
            [gup addChild:groupIDs];
            [gup addChild:postid];
            [msg addChild:gup];
            NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:[row objectForKey:@"MESSAGE_TEXT"]]];
            [msg addChild:body1];
            [[self appDelegate].xmppStream sendElement:msg];
            
            
        }
    
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

-(void)newPostCome:(NSNotification*)notification{
    
    NSDictionary *notificationDic = [notification userInfo];
    if([[notificationDic objectForKey:@"groupid"] intValue] == [self.groupId intValue]){
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"post_id = %@",[notificationDic objectForKey:@"postid"]];
        NSArray *arr = [postListData filteredArrayUsingPredicate:pre];
        if(arr.count<=0){
            if(newPostNotificationView.frame.size.height==0){
                [UIView beginAnimations:@"FadeIn" context:nil];
                [UIView setAnimationDuration:0.5];
                newPostNotificationView.frame = CGRectMake(0, 0, newPostNotificationView.frame.size.width, 40);
                _postTable.frame = CGRectMake(_postTable.frame.origin.x, _postTable.frame.origin.y+40, _postTable.frame.size.width, _postTable.frame.size.height);
                notificationlabel.frame = CGRectMake(notificationlabel.frame.origin.x,notificationlabel.frame.origin.y,200, 15);
                notificationlabel.center = CGPointMake(newPostNotificationView.center.x+40, newPostNotificationView.center.y);
                [self performSelector:@selector(hideNotificationView) withObject:nil afterDelay:3];
                [UIView commitAnimations];
                
            }
        }
    }
}

-(void)hideNotificationView{
    [UIView beginAnimations:@"FadeOut" context:nil];
    [UIView setAnimationDuration:0.5];
    newPostNotificationView.frame = CGRectMake(0, 0, newPostNotificationView.frame.size.width, 0);
    _postTable.frame = CGRectMake(_postTable.frame.origin.x, _postTable.frame.origin.y-40, _postTable.frame.size.width, _postTable.frame.size.height);
    notificationlabel.frame = CGRectMake(notificationlabel.frame.origin.x,notificationlabel.frame.origin.y,200, 0);
    [UIView commitAnimations];
    
}


-(void)updateGroupTime:(NSString*)time{
    if (isPrivate) {
        NSString *query2=[NSString stringWithFormat:@"UPDATE groups_private SET updatetime=%@ WHERE group_server_id = %@",time,self.groupId];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query2];
    }else{
        NSString *query2=[NSString stringWithFormat:@"UPDATE groups_public SET updatetime=%@ WHERE group_server_id = %@",time,self.groupId];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query2];
    }
}
@end
