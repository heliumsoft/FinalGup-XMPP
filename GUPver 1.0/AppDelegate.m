//
//  AppDelegate.m
//  GUPver 1.0
//4552
//  Created by genora on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "AppDelegate.h"
//#import <CoreFoundation/CoreFoundation.h>
//#include <sys/socket.h>
#include <netinet/in.h>
#import "XMPPRoomMemoryStorage.h"
#import "ChatScreen.h"
#import "AudioToolbox/AudioToolbox.h"
#import "FirstViewController.h"
#import "ExploreViewController.h"
#import "ShareViewController.h"
#import "GroupViewController.h"
#import "SettingViewController.h"
#import "LandingPage.h"
#import "Login.h"
#import "globleData.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "DatabaseManager.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CFNetwork/CFNetwork.h>
#import "NSString+Utils.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
@interface AppDelegate(){
    NSString *val;
}

- (void)setupStream;
- (void)teardownStream;



@end

@implementation AppDelegate
@synthesize xmppping,userStatus;
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppAutoPing;
@synthesize _chatDelegate;
@synthesize _messageDelegate;
@synthesize currentUser,myUserID,ver,gpError;
@synthesize hasInet;
@synthesize session = _session,viewController1,rootViewControllerL;
@synthesize groupCounter,isUSER,localNotification,ArrayUsersIDs,MyUserName;
@synthesize reachability,gupappReachability,ipReachability,localWifiReachability,user_name;
//Shree shantadurga vijayte
//FBSample logic
// The native facebook application transitions back to an authenticating application when the user
// chooses to either log in, or cancel. The url passed to this method contains the token in the
// case of a successful login. By passing the url to the handleOpenURL method of FBAppCall the provided
// session object can parse the URL, and capture the token for use by the rest of the authenticating
// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
// session object, and does not reflect whether or not the login was successful; the session object's
// state, as well as its arguments passed to the state completion handler indicate whether the login
// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
// will be boolean NO, meaning the URL was not handled by the authenticating application
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    //NSLog(@"ver at start %@",ver);
    //NSLog(@"source app %@\n url %@ annotation %@",sourceApplication,url,annotation);
    //NSLog(@"%i",[FBAppCall handleOpenURL:url                  sourceApplication:sourceApplication                        withSession:self.session]);
    
    // attempt to extract a token from the url
    // return [FBAppCall handleOpenURL:url                  sourceApplication:sourceApplication                        withSession:self.session];
    
    if ((
         [GPPURLHandler handleURL:url
                sourceApplication:sourceApplication
                       annotation:annotation])&&rootViewControllerL!=nil)
    {
        if (!gpError)
            [rootViewControllerL freezerAnimate];
        gpError=nil;
        return 1;
    }
    if([FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:self.session]&&rootViewControllerL!=nil)
    {
        [rootViewControllerL freezerAnimate];
        return 1;
    }
    return 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session if it is open
    // this is a good idea because things may be hanging off the session, that need
    // releasing (completion block, etc.) and other components in the app may be awaiting
    // close notification in order to do cleanup
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
    DDLogError(@"The iPhone simulator does not process background network traffic. "
               @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
    if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
    {
        [application setKeepAliveTimeout:600 handler:^{
            
            DDLogVerbose(@"KeepAliveHandler");
            
            // Do other keep alive stuff here.
        }];
    }
    
    [self.session close];
}

// FBSample logic
// It is possible for the user to switch back to your application, from the native Facebook application,
// when the user is part-way through a login; You can check for the FBSessionStateCreatedOpenening
// state in applicationDidBecomeActive, to identify this situation and close the session; a more sophisticated
// application may choose to notify the user that they switched away from the Facebook application without
// completely logging in

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //shan4552
    //NSLog(@"cuurent time %@",[NSString getCurrentUTCFormateDate ]);
    if(_backgroundFlag){
        _backgroundFlag=false;
        NSArray *excutedOutput=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select status from master_table"];
        //NSLog(@"output=%@",excutedOutput);
        if ([excutedOutput count]==1)//&&![userStatus isEqual:@"tempUnailable"])
        {
            /*if(![xmppStream isConnected])
             {
             NSArray *output=   [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select social_login_type,password from master_table"];
             NSString *socialLoginType=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ;
             NSString *passwordFetched=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output];
             if (![socialLoginType isEqualToString:@" "]||![passwordFetched isEqualToString:@" "])
             {
             
             [self connect];
             }
             }*/
            NSString *UserStatus=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"STATUS" ForRowIndex:0 givenOutput:excutedOutput];
            
            if ([UserStatus isEqual:@"offline"]) {
                [self goOffline];
                
            }else if([UserStatus isEqual:@"away"]){
                [self goAway];
            }else if([UserStatus isEqual:@"online"]){
                [self goOnline];
                
                
            }
        }
        [triggerer invalidate];
        
        triggerer=nil;
        [FBAppEvents activateApp];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"MyNotification" object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSString *_string = note.object;
            
        }];
        
        [FBAppCall handleDidBecomeActiveWithSession:self.session];
    }
    //[self connect];
}


/*
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
 UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
 
 if (notification) {
 // launched from notification
 } else {
 // from the springboard
 }
 }*/
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

-(void)clearChatHistoryForGroup:(NSString*)selectedGroup{
    NSArray *messageIds=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select message_id,id  from  chat_group where group_id=%@",selectedGroup]] ;
    
    for (int i=0;i<[messageIds count];i++) {
        NSInteger  msgId=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_ID" ForRowIndex:i givenOutput:messageIds]integerValue ];
        NSArray *outputGroup=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_group where message_id=%i and group_id!=%@",msgId,selectedGroup]] ;
        //NSLog(@"count=%@",outputGroup);
        NSInteger  noOfMessagesUsedInChat_group=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputGroup] integerValue];
        NSArray *outputPersonal=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select COUNT(id)  from  chat_personal where message_id=%i ",msgId]];
        NSInteger  noOfMessagesUsedInChat_personal=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"COUNT(ID)" ForRowIndex:0 givenOutput:outputPersonal] integerValue];
        NSInteger noOfMessagesUsed=noOfMessagesUsedInChat_group+noOfMessagesUsedInChat_personal;
        //NSLog(@"noOfMessagesUsed =%i ",noOfMessagesUsed);
        if (noOfMessagesUsed ==0)
        {
            NSArray *fileNames=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select message_filename from chat_message where id=%i",msgId]] ;
            NSString  *fileName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_FILENAME" ForRowIndex:0 givenOutput:fileNames];
            //NSLog(@"filename%@",fileName);
            if (fileName != (id)[NSNull null]) {
                //NSLog(@" delete the file");
                [self removeFileNamed:fileName];
            }
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_message where id=%i",msgId]];
            
        }
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_group where id=%@",[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"ID" ForRowIndex:i givenOutput:messageIds ]]];
        
        
    }
    
    
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
    
    /*   NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];*/
    /*   //NSLog(@"Directory Contents:\n%@", [fileManager directoryContentsAtPath: appFolderPath]);*/
}

-(void)GetdeviceToken{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //NSLog(@"d i %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
    NSString *postData = [NSString stringWithFormat:@"user_id=%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"Jid"] userID]];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/device_check.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    getdeviceToken = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [getdeviceToken scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [getdeviceToken start];
    getDeviceTokenResponc = [[NSMutableData alloc] init];
}

-(void)checkAuthenticityOfCurrentUser{
    NSArray *output=   [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select logged_in_user_id,social_login,social_login_type,social_login_id,email,password from master_table"];
    //NSLog(@"output =%@",output);
    
    NSDictionary *ROW=[output objectAtIndex:0];
    NSString *email= [[ROW objectForKey:@"EMAIL"] isEqual:[NSNull null]]?@"":[ROW objectForKey:@"EMAIL"];
    NSString *passwordG=[[ROW objectForKey:@"PASSWORD"]isEqual:[NSNull null]]?@"":[ROW objectForKey:@"PASSWORD"];
    NSString *social_login=[[ROW objectForKey:@"SOCIAL_LOGIN"]isEqual:[NSNull null]]?@"":[ROW objectForKey:@"SOCIAL_LOGIN"];
    NSString *social_login_type=[[ROW objectForKey:@"SOCIAL_LOGIN_TYPE"]isEqual:[NSNull null]]?@"":[ROW objectForKey:@"SOCIAL_LOGIN_TYPE"];
    NSString *social_login_id=[[ROW objectForKey:@"SOCIAL_LOGIN_ID"]isEqual:[NSNull null]]?@"":[ROW objectForKey:@"SOCIAL_LOGIN_ID"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *appVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *postData = [NSString stringWithFormat:@"email=%@&password=%@&social_login=%i&social_login_type=%@&social_login_id=%@&deviceToken=%@&deviceType=2&versionCode=%@",email,passwordG,[social_login integerValue],social_login_type,social_login_id,[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"],appVer];
    //NSLog(@"post data %@",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/login_user.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    loginDetailsConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [loginDetailsConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [loginDetailsConn start];
    loginDetails = [[NSMutableData alloc] init];
    
}

-(void)pushLoginScreen{
       viewController1 = [[FirstViewController alloc] initWithNibName:@"FirstViewController_iPhone" bundle:nil];
    // Initialize Navigation Controller
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewControllerL];
    //NSLog(@"version %@",ver);
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:36/255.0 green:178/255.0 blue:178/255.0 alpha:1]];
    }else{
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:36/255.0 green:178/255.0 blue:178/255.0 alpha:1]];
    }
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor,
                                               [UIFont fontWithName:@"Dosis-Bold" size:17.0], UITextAttributeFont
                                               , nil];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{UITextAttributeTextColor:[UIColor whiteColor],
       UITextAttributeFont:[UIFont fontWithName:@"Dosis-Regular" size:15.0]
       }
                                                                                            forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
   
    
    //[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    navigationController.navigationBar.translucent = NO;
    [navigationController.navigationBar setHidden:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Configure Window
    [self.window setRootViewController:navigationController];
    [self.window setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]];
    //[self.window setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    [self.window makeKeyAndVisible];
}

-(void)setLoginView{
    
    NSArray *output=   [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name, logged_in_user_id,social_login,social_login_type,social_login_id,email,password,version_no from master_table"];
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *fetchedAppVer=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"VERSION_NO" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"VERSION_NO" ForRowIndex:0 givenOutput:output];
    //NSLog(@"output =%@",output);
    if ([output count]==0){
        rootViewControllerL = [[Login alloc] init];
        [self pushLoginScreen];
    }else{
        MyUserName=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"DISPLAY_NAME" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"DISPLAY_NAME" ForRowIndex:0 givenOutput:output];
        // MyUserName=@"FDF";
        
        NSString *socialLoginType=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ;
        NSString *emailID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"EMAIL" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"EMAIL" ForRowIndex:0 givenOutput:output] ;
        NSString *passwordFetched=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output];
        if ([socialLoginType isEqualToString:@" "]||[passwordFetched isEqualToString:@" "]||[appVersionString doubleValue]>[fetchedAppVer doubleValue]) {
            rootViewControllerL = [[Login alloc] init];
            rootViewControllerL.emailId.text=emailID;
            [self pushLoginScreen];
        }else{
            
          
            viewController1 = [[FirstViewController alloc] initWithNibName:@"FirstViewController_iPhone" bundle:nil];
            
            [self GetdeviceToken];
            AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegateObj setTabBar];
            
        }
        
        
    }
}
//run background task
-(void)runBackgroundTask: (int) time{
    //check if application is in background mode
    //  NSLog(@"state %d",[UIApplication sharedApplication].applicationState);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        //create UIBackgroundTaskIdentifier and create tackground task, which starts after time
        __block UIBackgroundTaskIdentifier bgTask=0;
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(startTrackingBg) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
            
        });
    }
}

-(void)startTrackingBg{
    //    NSTimeInterval timeInterval = [[UIApplication sharedApplication] backgroundTimeRemaining];
    
    
    //  NSLog(@" time remaining in background = %f",timeInterval);
    //write background time remaining
    if (timeInBACKGROUND>250) {
        [self goAway];
    }
    timeInBACKGROUND+=20;
    [self runBackgroundTask:20];
}

- (void)applicationWillResignActive:(UIApplication *)application{
    //create new uiBackgroundTask
    
    _backgroundFlag = true;
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]){
        //NSLog(@"Multitasking Supported");
    }else{
        //NSLog(@"Multitasking Not Supported");
    }
    __block UIBackgroundTaskIdentifier  bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        // [self runBackgroundTask:10];
    }];
    
    //and create new timer with async call:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //run function methodRunAfterBackground
        //        triggerer = [NSTimer scheduledTimerWithTimeInterval:170.0 target:self  selector:@selector(goAway) userInfo:nil repeats:NO];
        //        [[NSRunLoop currentRunLoop] addTimer:triggerer forMode:NSDefaultRunLoopMode];
        //        [[NSRunLoop currentRunLoop] run];
    });
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    //  [self goActualOffline];
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
    DDLogError(@"The iPhone simulator does not process background network traffic. "
               @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
    if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]){
        
        [application setKeepAliveTimeout:600 handler:^{
            
            DDLogVerbose(@"KeepAliveHandler");
            
            // Do other keep alive stuff here.
        }];
    }
    timeInBACKGROUND=0;
    
    //[self runBackgroundTask:20];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    //   [self goOnline];
    // [self get_UTC_Time];
    [self CurrentDate];
    timeInBACKGROUND=0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if (rootViewControllerL!=nil){
        [rootViewControllerL freezerRemove];
    }
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSArray *outputARR=   [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select last_logged_in,version_no from master_table where id=1"];
    NSLog(@"current date %@",[NSString CurrentDate]);
    
    if ([outputARR count]!=0&&![[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"LAST_LOGGED_IN" ForRowIndex:0 givenOutput:outputARR]isEqual:[NSString CurrentDate]]){
        NSString * appVersionString  = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *fetchedAppVer=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"VERSION_NO" ForRowIndex:0 givenOutput:outputARR] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"VERSION_NO" ForRowIndex:0 givenOutput:outputARR];
        if ([appVersionString doubleValue]>[fetchedAppVer doubleValue])
            [self pushLoginScreen];
        else
            [self GetdeviceToken];
    }
    
    if(self.listFlag){
        //        [_messageDelegate reloadPost];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPostList" object:nil];
    }
}

-(void)setTabBar{
    
    UIViewController  *viewController2, *viewController3, *viewController4, *viewController5;
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        
//        viewController2 = [[ExploreViewController alloc] initWithNibName:@"ExploreViewController" bundle:nil];
//        viewController3 = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
//        viewController4 = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
//        viewController5 = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
//    } else {
    
        viewController3 = [[GroupViewController alloc] initWithNibName:@"GroupViewController_iPhone" bundle:nil];
        viewController2 = [[ExploreViewController alloc] initWithNibName:@"ExploreViewController" bundle:nil];
        viewController4 = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
        viewController5 = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
//    }
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
        
    }else{
        
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
        
    }
    
    UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    UINavigationController *navigationController2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UINavigationController *navigationController3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    UINavigationController *navigationController4 = [[UINavigationController alloc] initWithRootViewController:viewController4];
    UINavigationController *navigationController5 = [[UINavigationController alloc] initWithRootViewController:viewController5];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    
    self.tabBarController.viewControllers = @[navigationController3,navigationController1, navigationController2,  navigationController4, navigationController5];
    
    
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:36/255.0 green:178/255.0 blue:178/255.0 alpha:1]];
        
//         self.tabBarController.tabBar.translucent = NO;
    }else{
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:36/255.0 green:178/255.0 blue:178/255.0 alpha:1]];
    }
    
    navigationController1.navigationBar.translucent = NO;
    navigationController2.navigationBar.translucent = NO;
    navigationController3.navigationBar.translucent = NO;
    navigationController4.navigationBar.translucent = NO;
    navigationController5.navigationBar.translucent = NO;
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor,
                                               [UIFont fontWithName:@"Dosis-SemiBold" size:20.0], UITextAttributeFont
                                               , nil];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{UITextAttributeTextColor:[UIColor whiteColor],
       UITextAttributeFont:[UIFont fontWithName:@"Dosis-Regular" size:15.0]
       }
                                                                                            forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
//    navigationController2.b
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:36/255.0 green:178/255.0 blue:178/255.0 alpha:1]];
    
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    
    
    imgTab = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,self.viewController1.view.bounds.size.width,50)];
    [self.tabBarController.tabBar addSubview:imgTab];
    self.tabBarController.delegate = self;
    
    float width1= (self.viewController1.view.bounds.size.width-150)/6;
    
    float width = 30;
    
    imghome=[[UIImageView alloc]initWithFrame:CGRectMake(width1,10.0,width,30.0)];
    imghome.image=[UIImage imageNamed:@"groupTab"];
    [imgTab addSubview:imghome];
    
    imgContact=[[UIImageView alloc]initWithFrame:CGRectMake(width1*2+width,10.0,width,30.0)];
    imgContact.image=[UIImage imageNamed:@"ContactTab"];
    [imgTab addSubview:imgContact];
    
    imgtTW=[[UIImageView alloc]initWithFrame:CGRectMake(((width1*3)+(width*2)),10.0,width,30.0)];
    imgtTW.image=[UIImage imageNamed:@"searchTab"];
    [imgTab addSubview:imgtTW];
    
    imgShare=[[UIImageView alloc]initWithFrame:CGRectMake(((width1*4)+(width*3)),10.0,width,30.0)];
    imgShare.image=[UIImage imageNamed:@"shareTab"];
    [imgTab addSubview:imgShare];
    
    imgSettings=[[UIImageView alloc]initWithFrame:CGRectMake(((width1*5)+(width*4)),10.0,width,30.0)];
    imgSettings.image=[UIImage imageNamed:@"settingTab"];
    [imgTab addSubview:imgSettings];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self.window setRootViewController:self.tabBarController];
//    [self.window setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]];
    
    [self.window makeKeyAndVisible];
    
}
- (void)tabBarController:(UITabBarController *)tabBarControllers didSelectViewController:(UIViewController *)viewController
{
    
    NSLog(@"%i",tabBarControllers.selectedIndex);
    if (tabBarControllers.selectedIndex == 0)
    {
        
        imghome.image=[UIImage imageNamed:@"groupActive"];
        imgContact.image=[UIImage imageNamed:@"ContactTab"];
        imgtTW.image=[UIImage imageNamed:@"searchTab"];
        imgShare.image=[UIImage imageNamed:@"shareTab"];
        imgSettings.image=[UIImage imageNamed:@"settingTab"];
    }
    else if (tabBarControllers.selectedIndex == 1)
    {
        
        imghome.image=[UIImage imageNamed:@"groupTab"];
        imgContact.image=[UIImage imageNamed:@"ContactActive"];
        imgtTW.image=[UIImage imageNamed:@"searchTab"];
        imgShare.image=[UIImage imageNamed:@"shareTab"];
        imgSettings.image=[UIImage imageNamed:@"settingTab"];
        
    }
    else if (tabBarControllers.selectedIndex == 2)
    {
        imghome.image=[UIImage imageNamed:@"groupTab"];
        imgContact.image=[UIImage imageNamed:@"ContactTab"];
        imgtTW.image=[UIImage imageNamed:@"searchActive"];
        imgShare.image=[UIImage imageNamed:@"shareTab"];
        imgSettings.image=[UIImage imageNamed:@"settingTab"];
        
    } else if (tabBarControllers.selectedIndex == 3)
    {
        imghome.image=[UIImage imageNamed:@"groupTab"];
        imgContact.image=[UIImage imageNamed:@"ContactTab"];
        imgtTW.image=[UIImage imageNamed:@"searchTab"];
        imgShare.image=[UIImage imageNamed:@"shareActive"];
        imgSettings.image=[UIImage imageNamed:@"settingTab"];
    }else if (tabBarControllers.selectedIndex == 4)
    {
        imghome.image=[UIImage imageNamed:@"groupTab"];
        imgContact.image=[UIImage imageNamed:@"ContactTab"];
        imgtTW.image=[UIImage imageNamed:@"searchTab"];
        imgShare.image=[UIImage imageNamed:@"shareTab"];
        imgSettings.image=[UIImage imageNamed:@"settingActive"];
    }
    
    
    
}

//project SHAN4552
-(void)setXmpp
{
    // Configure logging framework
    
    //[DDLog addLogger:[DDTTYLogger sharedInstance]];
    // Setup the XMPP stream
    ArrayUsersIDs=[[NSMutableArray alloc]init];
    
    [self setupStream];
    
    // [self connect];
    
}
#pragma chat service
-(void)sendAcknoledgmentPacketId:(NSString*)messageId isGroupAcknoledgment:(BOOL)grpAck
{
    XMPPMessage *msg = [XMPPMessage message];
    [msg addAttributeWithName:@"type" stringValue:@"chat"];
    [msg addAttributeWithName:@"message_id" stringValue:messageId];
    [msg addAttributeWithName:@"isGroupAcknolegment" boolValue:grpAck];
    [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ];
    [msg addAttributeWithName:@"to" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ];
    NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:@"ack"];
    [msg addChild:body1];
    [xmppStream sendElement:msg];
}
-(void)storeMessageInDatabaseForBody:(NSString*)body forMessageType:(NSString*)msgType messageTo:(NSString*)to groupId:(NSString*)groupID isGroup:(BOOL)isGroup forTimeInterval:(NSString*)timeInMiliseconds senderName:(NSString*)Sname postid:(NSString*)idpost isRead:(NSString*)read withImage:(NSString*)senderimage{
        body=[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSLog(@"message %@",[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]);
    NSString *messageid=[self CheckIfMessageExist:[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
    if (messageid==nil)
        messageid=[self PutMessageInStorage:[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
    NSMutableDictionary *ComposedMessaage=[[NSMutableDictionary alloc]init];
    [ComposedMessaage setValue:myUserID forKey:@"sendersUserID"];
    [ComposedMessaage setValue:[to userID] forKey:@"receiveruserID"];
    [ComposedMessaage setValue:groupID  forKey:@"groupID"];
    [ComposedMessaage setValue:timeInMiliseconds forKey:@"orignal_time"];
    [ComposedMessaage setValue:timeInMiliseconds forKey:@"timestamp"];
    [ComposedMessaage setValue:messageid forKey:@"messageid"];
    [ComposedMessaage setValue:@"0" forKey:@"messageStatus"];
    [ComposedMessaage setValue:@"0" forKey:@"pinned"];
    [ComposedMessaage setValue:Sname forKey:@"sendername"];
    [ComposedMessaage setValue:senderimage forKey:@"senderimage"];
    if(read){
        [ComposedMessaage setValue:read forKey:@"read"];
        
    }
    if (idpost) {
        [ComposedMessaage setValue:idpost forKey:@"postid"];
    }
    
    if (isGroup)
    {
        //        [ComposedMessaage setValue:[to userID] forKey:@"sendersUserID"];
        //        [ComposedMessaage setValue:myUserID forKey:@"receiveruserID"];
        [self PutLinkOfMessageInStorageForType:@"group" withMessageData:ComposedMessaage];
    }
    else
    {
        [self PutLinkOfMessageInStorageForType:@"personal" withMessageData:ComposedMessaage];
    }
    if (  ![currentUser isEqual:@""] && _messageDelegate!=nil)
    {
        [_messageDelegate newMessageReceived ];
        [_messageDelegate scrollDown];
    }
    
    
}


-(NSString*)getLinkedIdOfMessageID:(NSString*)messageID forTimestamp:(NSString*)timestamp senderID:(NSString*)senderID recieversID:(NSString*)recieversid chattype:(NSString*)chatType
{
    NSArray *output;
    if([chatType isEqual:@"group"])
        output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT id from chat_group where time_stamp ='%@' AND message_id=%@ AND user_id=%@ AND group_id=%@ ",timestamp,messageID,senderID,recieversid]];
    
    else
        output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT id from chat_personal where time_stamp ='%@' AND message_id=%@ AND user_id=%@ AND receivers_id=%@ ",timestamp,messageID,senderID,recieversid]];
    
    if ([output count]==0)
    {
        return nil;
    }
    else
    {
        return [[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"ID" ForRowIndex:0 givenOutput:output];
        
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//-(XMPPAutoPing *)xmppAutoPing
///{
//    return xmppAutoPing;
//}
-(void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender{
    DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
    NSLog(@"\n sender \n %@ \n",sender);
    if (isnetFluctuating)
    {
        if ([userStatus isEqual:@"offline"])
        {
            [self goOffline];
        }
        else if([userStatus isEqual:@"away"]){
            [self goAway];
        }
        else if([userStatus isEqual:@"online"])
        {
            [self goOnline];
            //            [self joinGroup];
        }
        isnetFluctuating=false;
    }
    
    
    
}
-(void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
{DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
    NSLog(@"\n sender \n %@ \n",sender);
}
-(void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
{DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
    NSLog(@"\n sender \n %@ \n",sender);
    //   if (!isnetFluctuating) {
    [self goActualOffline];
    //  }
    
    isnetFluctuating=true;
    
    
}
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags
{
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags
{
    return YES;
}
- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    //  self.xmppping=[[XMPPPing alloc]initWithDispatchQueue:dispatch_get_main_queue()];
    //
    //   [self.xmppping addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //
    //
    // [self.xmppping activate:xmppStream];
    xmppAutoTime = [[XMPPAutoTime alloc] init];
    xmppAutoTime.recalibrationInterval = 90;
    xmppAutoTime.targetJID = nil;
    [xmppAutoTime addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppAutoTime activate:xmppStream];
    //
    xmppAutoPing = [[XMPPAutoPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    self.xmppAutoPing.pingInterval = 60.0f; // default is 60
    self.xmppAutoPing.pingTimeout = 10; // default is 10
    [self.xmppAutoPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppAutoPing activate:self.xmppStream];
    [xmppReconnect setAutoReconnect:YES];
    
    [xmppReconnect setReconnectTimerInterval:20];
    [xmppReconnect setReconnectDelay:20];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    //	  XMPPRoom *room = [[XMPPRoom alloc] init];
    //    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    xmppRoster.autoFetchRoster = YES;
    
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    //    xmppCapabilities.autoFetchHashedCapabilities = YES;
    //    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];
    
    [xmppStream setHostName:gupHostName/*@"127.0.0.1"*/];
    [xmppStream setHostPort:5222];
    
    // You may need to alter these settings depending on the server you're connecting to
    allowSelfSignedCertificates = NO;
    allowSSLHostNameMismatch = NO;
}
- (void)changeAutoTimeInterval:(NSTimer *)aTimer
{
    DDLogVerbose(@"%@: %@", [self class], THIS_METHOD);
    
    xmppAutoTime.recalibrationInterval = 30;
}
- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
    
    
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements
-(void)updateProfile
{//NSLog(@"jid %@",xmppStream.myJID);
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"]; // type="available" is implicit
    /*
     NSString *domain = [xmppStream.myJID domain];
     
     //Google set their presence priority to 24, so we do the same to be compatible.
     
     if([domain isEqualToString:@"gmail.com"]
     || [domain isEqualToString:@"gtalk.com"]
     || [domain isEqualToString:@"talk.google.com"])
     {
     NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
     [presence addChild:priority];
     }
     */
    NSXMLElement *status=[NSXMLElement elementWithName:@"status" stringValue:@"update"];
    [presence addChild:status];
    [[self xmppStream] sendElement:presence];
    //NSLog(@"presence %@",presence);
    
    
}
- (void)goOnline
{//NSLog(@"jid %@",xmppStream.myJID);
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"]; // type="available" is implicit
    /*
     NSString *domain = [xmppStream.myJID domain];
     
     //Google set their presence priority to 24, so we do the same to be compatible.
     
     if([domain isEqualToString:@"gmail.com"]
     || [domain isEqualToString:@"gtalk.com"]
     || [domain isEqualToString:@"talk.google.com"])
     {
     NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
     [presence addChild:priority];
     }
     */
    NSXMLElement *status=[NSXMLElement elementWithName:@"status" stringValue:@"online"];
    [presence addChild:status];
    [[self xmppStream] sendElement:presence];
    userStatus=@"online";
    //     [self joinGroup];
    //NSLog(@"presence %@",presence);
}
- (void)goActualOffline{
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    NSXMLElement *status=[NSXMLElement elementWithName:@"status" stringValue:@"temporary"];
    [presence addChild:status];
    // userStatus=@"tempUnailable";
    [[self xmppStream] sendElement:presence];
}
- (void)goOffline{
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    NSXMLElement *status=[NSXMLElement elementWithName:@"status" stringValue:@"offline"];
    [presence addChild:status];
    [[self xmppStream] sendElement:presence];
    userStatus=@"offline";
}
-(void)goAway{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    NSXMLElement *status=[NSXMLElement elementWithName:@"status" stringValue:@"away"];
    [presence addChild:status];
    [[self xmppStream] sendElement:presence];
    
    userStatus=@"away";
}
-(void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    DDLogError(@"Error connecting: %@", error);
}
-(void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if([[[presence elementForName:@"status"] stringValue] isEqualToString:@"like"]){
        NSString *postid = [[[presence elementForName:@"likedata"] elementForName:@"postid"] stringValue];
        NSString *que= [NSString stringWithFormat:@"DELETE FROM offlinelike WHERE postid = %@",postid];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:que];
    }
    
    
}

-(void)xmppPing:(XMPPPing *)sender didNotReceivePong:(NSString *)pingID dueToTimeout:(NSTimeInterval)timeout{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self goActualOffline];
    isnetFluctuating=true;
}

-(void)xmppPing:(XMPPPing *)sender didReceivePong:(XMPPIQ *)pong withRTT:(NSTimeInterval)rtt{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self tryResendingMessages];
    //  });
    //NSLog(@"pong %@ pong %@ timeinterval %f",sender,pong,rtt);
    if (isnetFluctuating){
        if ([userStatus isEqual:@"offline"]){
            [self goOffline];
        }
        else if([userStatus isEqual:@"away"]){
            [self goAway];
        }
        else if([userStatus isEqual:@"online"]){
            
            [self goOnline];
            
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //            [self joinGroup];
            //            });
            
            
        }
        isnetFluctuating=false;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect{
    if ([xmppStream isConnected]) {
        //NSLog(@"narayan");
        //UIAlertView *alert =[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"You r allready logged-in as %@",[xmppStream myJID] ]delegate:Nil cancelButtonTitle:@"Cancle" otherButtonTitles:nil, nil];
        //   [alert show];
        return YES;
        //  [self disconnect];
    }
    
    NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
    self.myjid = myJID;
    //NSLog(@"jid %@ password %@",myJID,myPassword);
    //
    // myJID=@"admin@127.0.0.1";
    // myPassword=@"admin";
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        //	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"                                                  message:@"See console for error details."		                                                  delegate:nil		                                          cancelButtonTitle:@"Ok"		                                          otherButtonTitles:nil];
        //	[alertView show];
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    return YES;
    
    // return [self registration];
}

-(BOOL)registrationWithUserName:(NSString*)usernameR password:(NSString*)passwordR name:(NSString*)nameR emailid:(NSString*)emailIdR{
    if (isThisRegistration==false){
        username=[[NSString alloc]init];
        username=usernameR;
        Rpassword=[[NSString alloc]init];
        Rpassword=passwordR;
        name=[[NSString alloc]init];
        name=nameR;
        emailid=[[NSString alloc]init];
        emailid=emailIdR;
        accountType=[[NSString alloc]init];
        accountType=@"3";
        
        
        isThisRegistration=true;
        if (![xmppStream isDisconnected]) {
            //NSLog(@"narayan");
            //UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"You r allready logged-in as %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ]delegate:Nil cancelButtonTitle:@"Cancle" otherButtonTitles:nil, nil];
            //  [alert show];
            isThisRegistration=false;
            return YES;
            //  [self disconnect];
        }
        
        NSString *myJID = username;
        myJID=[myJID stringByAppendingString:[NSString stringWithFormat:@"@%@",jabberUrl]];
        //NSLog(@"url %@",myJID);
        if (myJID == nil ) {
            isThisRegistration=false;
            return NO;
        }
        
        [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
        
        NSError *error = nil;
        if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
        {
            //	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"		                                                    message:@"See console for error details."		                                                   delegate:nil		                                          cancelButtonTitle:@"Ok"		                                          otherButtonTitles:nil];
            //[alertView show];
            
            DDLogError(@"Error connecting: %@", error);
            isThisRegistration=false;
            return NO;
        }
        
        return YES;
    }
    else
    {
        return NO;
    }
}
- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
    isThisRegistration=false;
    [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"UPDATE master_table SET registered=1 WHERE id=1 "];
    //  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Registration Successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //  [alert show];
    NSError *error;
    [[self xmppStream] authenticateWithPassword:Rpassword error:&error];
    //NSLog(@"error %@",error);
    
}


- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    isThisRegistration=false;
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    
    //  NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
    // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    if([errorCode isEqualToString:@"409"]){
        
        //  [alert setMessage:@"Username Already Exists!"];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"UPDATE master_table SET registered=1 WHERE id=1 "];
        
        
        NSError *error;
        [[self xmppStream] authenticateWithPassword:Rpassword error:&error];
        //NSLog(@"error %@",error);
        
    }
    // [alert show];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender socketWillConnect:(GCDAsyncSocket *)socket
{
    // Tell the socket to stay around if the app goes to the background (only works on apps with the VoIP background flag set)
    [socket performBlock:^{
        [socket enableBackgroundingOnSocket];
    }];
}


/*-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
 {
 
 //Tell the system that you ar done.
 completionHandler(UIBackgroundFetchResultNewData);
 //NSLog(@"ch %@",completionHandler);
 }
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler{
    
    NSDictionary *dictionary=[userInfo objectForKey:@"aps"];
    NSLog(@"apns %@",dictionary);
    if (dictionary!=nil){
        NSInteger notificationType=[[dictionary objectForKey:@"notification_id"]isEqual:[NSNull null]]?0:[[dictionary objectForKey:@"notification_id"] integerValue];
        if (notificationType==1){
            
            if (application.applicationState == UIApplicationStateActive){
                
                [self goOffline ];
                [self disconnect];
                [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
                [self setLoginView];
                
            }else{
                
                [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
                [self setLoginView];
            }
            
        }
        if (notificationType==3||notificationType==6){
            NSString *groupid=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            if (![groupid isEqual:@" "]){
                
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from groups_public where group_server_id=%@",groupid]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from groups_private where group_server_id=%@",groupid]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from group_invitations where group_id=%@",groupid]];
                
                [_chatDelegate buddyStatusUpdated];
            }
            
        }
        if (notificationType==11||notificationType==12){
            
            NSString *groupContactsid=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            NSString *groupid=[[groupContactsid componentsSeparatedByString:@","] objectAtIndex:0];
            NSString *userID=[[groupContactsid componentsSeparatedByString:@","] objectAtIndex:1];
            if (![groupid isEqual:@" "]){
                
                [self groupUpdate:groupid];
                [[DatabaseManager getSharedInstance] executeQueryWithQuery:[NSString stringWithFormat:@"delete from group_join_request where group_id=%@ AND user_id=%@ ",groupid,userID ]];
            }
            
        }
        if (notificationType==4||notificationType==5||notificationType==7||notificationType==8||notificationType==9||notificationType==10||notificationType==2||notificationType==20){
            
            NSString *groupid=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            if (![groupid isEqual:@" "]){
                
                [self groupUpdate:groupid];
            }
            
        }
        if(notificationType==13||notificationType==15){
            NSString *contactID=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            [self getContactInfoWhereUserId:[contactID integerValue]];
        }
        if (notificationType==14) {
            NSString *contactID=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update contacts set deleted=1 where user_id=%@",contactID]];
            [_chatDelegate buddyStatusUpdated];
            
            
        }
        if(notificationType==18){
            NSString *userid=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            if (![userid isEqual:@" "]){
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat: @"delete from contacts where user_id =%@",userid ]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat: @"delete from group_members where contact_id =%@",userid ]];
                if(viewController1!=nil)
                    [_chatDelegate buddyStatusUpdated];
            }
        }
        if(notificationType==19){
            NSString *userid=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            if (![userid isEqual:@" "]){
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat: @"delete from groups_private where group_server_id =%@",userid ]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat: @"delete from groups_public where group_server_id =%@",userid ]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat: @"delete from group_invitations where group_id =%@",userid]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat: @"delete from group_members where group_id =%@",userid ]];
                if(viewController1!=nil)
                    [_chatDelegate buddyStatusUpdated];
            }
        }
        
    }
    
    
}
/*-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
 { application.applicationIconBadgeNumber = 0;
 application.applicationIconBadgeNumber=45;
 NSLog(@"userinfo %@",userInfo);
 NSDictionary *dictionary=[userInfo objectForKey:@"aps"];
 NSLog(@"diction %@",dictionary);
 
 }*/

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    //application.applicationIconBadgeNumber = 0;
    //application.applicationIconBadgeNumber=45;
    //NSLog(@"userinfo %@",userInfo);
    NSDictionary *dictionary=[userInfo objectForKey:@"aps"];
    //NSLog(@"diction %@",dictionary);
    NSLog(@"apns %@",dictionary);
    if (dictionary!=nil){
        NSInteger notificationType=[[dictionary objectForKey:@"notification_id"]isEqual:[NSNull null]]?0:[[dictionary objectForKey:@"notification_id"] integerValue];
        if (notificationType==1){
            //NSLog(@"state %d\n state %i %i %i",application.applicationState,UIApplicationStateActive,UIApplicationStateInactive,UIApplicationStateBackground);
            if (application.applicationState == UIApplicationStateActive){
                [self goOffline ];
                [self disconnect];
                [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
                [self setLoginView];
                // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
                //   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Your App name received this notification while it was running:\n%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alertView show];
                
            }else{
                [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
                [self setLoginView];
            }
            
        }
        if (notificationType==3||notificationType==6){
            //NSLog(@"state %d\n state %i %i %i",application.applicationState,UIApplicationStateActive,UIApplicationStateInactive,UIApplicationStateBackground);
            NSString *groupid=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            if (![groupid isEqual:@" "]){
                if (application.applicationState == UIApplicationStateActive){
                    //   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Your App name received this notification while it was running:\n%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    //  [alertView show];
                }
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from groups_public where group_server_id=%@",groupid]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from groups_private where group_server_id=%@",groupid]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from group_invitations where group_id=%@",groupid]];
                [_chatDelegate buddyStatusUpdated];
            }
            
        }
        if (notificationType==11||notificationType==12){
            //NSLog(@"state %d\n state %i %i %i",application.applicationState,UIApplicationStateActive,UIApplicationStateInactive,UIApplicationStateBackground);
            NSString *groupContactsid=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            NSString *groupid=[[groupContactsid componentsSeparatedByString:@","] objectAtIndex:0];
            NSString *userID=[[groupContactsid componentsSeparatedByString:@","] objectAtIndex:1];
            if (![groupid isEqual:@" "]){
                if (application.applicationState == UIApplicationStateActive){
                    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Your App name received this notification while it was running:\n%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    // [alertView show];
                    
                    
                }
                [self groupUpdate:groupid];
                [[DatabaseManager getSharedInstance] executeQueryWithQuery:[NSString stringWithFormat:@"delete from group_join_request where group_id=%@ AND user_id=%@ ",groupid,userID ]];
            }
            
        }
        if (notificationType==4||notificationType==5||notificationType==7||notificationType==8||notificationType==9||notificationType==10||notificationType==2){
            //NSLog(@"state %d\n state %i %i %i",application.applicationState,UIApplicationStateActive,UIApplicationStateInactive,UIApplicationStateBackground);
            NSString *groupid=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            if (![groupid isEqual:@" "]){
                if (application.applicationState == UIApplicationStateActive){
                    //   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Your App name received this notification while it was running:\n%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    //  [alertView show];
                }
                [self groupUpdate:groupid];
            }
            
        }
        if(notificationType==13||notificationType==15){
            NSString *contactID=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            [self getContactInfoWhereUserId:[contactID integerValue]];
        }
        if (notificationType==14){
            NSString *contactID=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update contacts set deleted=1 where user_id=%@",contactID]];
            [_chatDelegate buddyStatusUpdated];
            
            
        }
        if(notificationType==18){
            NSString *userid=[[dictionary objectForKey:@"data_id"]isEqual:[NSNull null]]?@" ":[dictionary objectForKey:@"data_id"];
            if (![userid isEqual:@" "]){
                
            }
        }
    }
}
-(void)groupUpdate:(NSString*)groupId
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *myID=[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",groupId,[myID userID]];
    //NSLog(@"$[%@]",postData);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_detail_user.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    groupInfoConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [groupInfoConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [groupInfoConn start];
    groupInfoResponse = [[NSMutableData alloc] init];
    
}
- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (allowSelfSignedCertificates)
    {
        [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
    }
    
    if (allowSSLHostNameMismatch)
    {
        [settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
    }
    else
    {
        // Google does things incorrectly (does not conform to RFC).
        // Because so many people ask questions about this (assume xmpp framework is broken),
        // I've explicitly added code that shows how other xmpp clients "do the right thing"
        // when connecting to a google server (gmail, or google apps for domains).
        
        NSString *expectedCertName = nil;
        
        NSString *serverDomain = xmppStream.hostName;
        NSString *virtualDomain = [xmppStream.myJID domain];
        
        if ([serverDomain isEqualToString:@"talk.google.com"])
        {
            if ([virtualDomain isEqualToString:@"gmail.com"])
            {
                expectedCertName = virtualDomain;
            }
            else
            {
                expectedCertName = serverDomain;
            }
        }
        else if (serverDomain == nil)
        {
            expectedCertName = virtualDomain;
        }
        else
        {
            expectedCertName = serverDomain;
        }
        
        if (expectedCertName)
        {
            [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
        }
    }
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //XMPPIQ *ss=[[XMPPIQ alloc]init];
    
    isXmppConnected = YES;
    
    if (isThisRegistration)
    {
        NSMutableArray *elements = [NSMutableArray array];
        [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:username]];
        [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:Rpassword]];
        [elements addObject:[NSXMLElement elementWithName:@"name" stringValue:name]];
        
        
        //  [elements addObject:[NSXMLElement elementWithName:@"accountType" stringValue:accountType]];
        [elements addObject:[NSXMLElement elementWithName:@"deviceToken" stringValue:DeviceToken]];
        
        [elements addObject:[NSXMLElement elementWithName:@"email" stringValue:emailid]];
        [xmppStream registerWithElements:elements error:nil];
        
        NSError * err = nil;
        
        if(![[self xmppStream] registerWithElements:elements error:&err])
        {
            //NSLog(@"Error registering: %@", err);
        }
        
        
    }else{
        NSError *error = nil;
        
        if (![[self xmppStream] authenticateWithPassword:password error:&error]){
            DDLogError(@"Error authenticating: %@", error);
        }
    }
    user_name=[[DatabaseManager getSharedInstance] getAppUserName];
    
    //    [self joinGroup];
}
-(BOOL)checkNetworkConnection
{
    Reachability *aa=[Reachability reachabilityWithHostName:@"www.google.com"];
    if([aa currentReachabilityStatus]==NotReachable)
        return NO;
    else
        return YES;
}


-(void)setUpRechability{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    //   gupappReachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    //   [gupappReachability startNotifier];
    //   localWifiReachability = [Reachability reachabilityForLocalWiFi];
    //   [localWifiReachability startNotifier];
    //  struct sockaddr_in callAddress;
    //  callAddress.sin_len = sizeof(callAddress);
    //   callAddress.sin_family = AF_INET;
    //   callAddress.sin_port = htons(9090);
    //  callAddress.sin_addr.s_addr = inet_addr("198.154.98.11");
    //  //  ipReachability = [Reachability reachabilityWithAddress:&callAddress];
    // [ipReachability startNotifier];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable){
        NSLog(@"no");
        self.hasInet=NO;
    }else if (remoteHostStatus == ReachableViaWiFi){
        NSLog(@"wifi");
        self.hasInet=YES;
    }else if(remoteHostStatus == ReachableViaWWAN)
    {
        NSLog(@"cell");
        self.hasInet=YES;
    }
    NSLog(@"network status %i",self.hasInet);
}

- (void) handleNetworkChange:(NSNotification *)notice
{
    //    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    //
    //    if          (remoteHostStatus == NotReachable)
    //    {
    //        NSLog(@"no");        self.hasInet=NO;
    //
    //    }
    //    else if     (remoteHostStatus == ReachableViaWiFi)
    //    {
    //        NSLog(@"wifi");    self.hasInet=YES;
    //    }
    //    else if     (remoteHostStatus == ReachableViaWWAN)
    //    {
    //        NSLog(@"cell");    self.hasInet=YES;
    //    }
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.hasInet=NO;
            if(self.xmppStream.isConnected)
                [self.xmppStream disconnect];
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.hasInet=YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.hasInet=YES;
            
            break;
        }
    }
    //    NetworkStatus gupStatus = [gupappReachability currentReachabilityStatus];
    //    switch (gupStatus)
    //    {
    //        case NotReachable:
    //        {
    //            NSLog(@"The internet is down.");
    //            self.hasInet=NO;
    //
    //            break;
    //        }
    //        case ReachableViaWiFi:
    //        {
    //            NSLog(@"The internet is working via WIFI.");
    //            self.hasInet=YES;
    //
    //            break;
    //        }
    //        case ReachableViaWWAN:
    //        {
    //            NSLog(@"The internet is working via WWAN.");
    //            self.hasInet=YES;
    //
    //            break;
    //        }
    //    }
    //    NetworkStatus localswitchingStatus = [localWifiReachability currentReachabilityStatus];
    //    switch (localswitchingStatus)
    //    {
    //        case NotReachable:
    //        {
    //            NSLog(@"The internet is down.");
    //            self.hasInet=NO;
    //
    //            break;
    //        }
    //        case ReachableViaWiFi:
    //        {
    //            NSLog(@"The internet is working via WIFI.");
    //            self.hasInet=YES;
    //
    //            break;
    //        }
    //        case ReachableViaWWAN:
    //        {
    //            NSLog(@"The internet is working via WWAN.");
    //            self.hasInet=YES;
    //
    //            break;
    //        }
    //    }
    //    NetworkStatus ipStatus = [ipReachability currentReachabilityStatus];
    //    switch (ipStatus)
    //    {
    //        case NotReachable:
    //        {
    //            NSLog(@"The internet is down.");
    //            self.hasInet=NO;
    //
    //            break;
    //        }
    //        case ReachableViaWiFi:
    //        {
    //            NSLog(@"The internet is working via WIFI.");
    //            self.hasInet=YES;
    //
    //            break;
    //        }
    //        case ReachableViaWWAN:
    //        {
    //            NSLog(@"The internet is working via WWAN.");
    //            self.hasInet=YES;
    //
    //            break;
    //        }
    //    }
    //
    //
    NSLog(@"has net %hhd",self.hasInet);
    if (self.hasInet&&[[[NSUserDefaults standardUserDefaults] objectForKey:@"TimeDifferance"] isEqual:@" "])
    {
        [self CurrentDate];
    }
    // [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",timeDifferance] forKey:@"TimeDifferance"];
    if (self.hasInet&&![xmppStream isConnecting])
    {
        
        if ([xmppStream isConnected])
        {
            [self disconnect];
        }
        if([xmppStream isDisconnected])
        {
            NSArray *output=   [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select social_login_type,password from master_table"];
            
            //NSLog(@"output =%@",output);
            if ([output count]!=0)
            {
                NSString *socialLoginType=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ;
                NSString *passwordFetched=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output];
                if (![socialLoginType isEqualToString:@" "]||![passwordFetched isEqualToString:@" "]){
                    [self connect];
                }
                
            }
        }
    }
    //NSLog(@"network status %i",self.hasInet);
    //    if (self.hasInet) {
    //        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Net avail" message:@"" delegate:self cancelButtonTitle:OK_EN otherButtonTitles:nil, nil];
    //        [alert show];
    //    }
}
//- (NSDate *) GMTNow
//{
//    NSDate *sourceDate = [NSDate date];
//    NSTimeZone* currentTimeZone = [NSTimeZone  localTimeZone];
//    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMT];
//
//    [sourceDate addTimeInterval:currentGMTOffset];
//
//    return sourceDate;
//}
-(void)get_UTC_Time
{
    if ( getUTCtime==nil)
    {
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"TimeDifferance"])
            previousTimeDifferance=[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue]==0.000?previousTimeDifferance:[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue];
        [[NSUserDefaults standardUserDefaults]setObject:@" " forKey:@"TimeDifferance"];
        if (  ![currentUser isEqual:@""]&&_messageDelegate!=nil)
        {
            [_messageDelegate freezerAnimate];
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSString *url= [NSString stringWithFormat:@"http://85.159.208.146/Gup_demo/scripts/utc_time.php"];
        
        [request setURL:[NSURL URLWithString:url]];
        //  [request setHTTPMethod:@"GET"];
        
        getUTCtime = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [getUTCtime scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [getUTCtime start];
        getUTCtimeResponce = [[NSMutableData alloc] init];
    }
    
}
-(void) CurrentDate{
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"TimeDifferance"])
        previousTimeDifferance=[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue]==0.000?previousTimeDifferance:[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue];
    [[NSUserDefaults standardUserDefaults]setObject:@" " forKey:@"TimeDifferance"];
    
    if (  ![currentUser isEqual:@""]&&_messageDelegate!=nil)
    {
        [_messageDelegate freezerAnimate];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSURL * scriptUrl = [NSURL URLWithString: @"http://gupapp.com/Gup_demo/scripts/utc_time.php"/*@"http://api.timezonedb.com/?zone=America/St_Barthelemy&format=json&key=RFBQVAXKTDQ2"*/];
        
        NSData * data = [NSData dataWithContentsOfURL: scriptUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil)
            {
                NSDictionary *dict;
                @try {
                    dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    NSDictionary *res=[dict objectForKey:@"final_array"];
                    double timestamp=[[res objectForKey:@"timestamp"] doubleValue];
                    double offset=0.00000;//[[res objectForKey:@"gmtOffset"] doubleValue];
                    
                    NSLog(@"utc time %f",(timestamp-offset)*1000 );
                    double ServerTimeStamp=(timestamp-offset)*1000;
                    NSLog(@"get utc forma%@",[NSString getCurrentUTCFormateDate]);
                    NSLog(@"get utc forma%@",[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate]);
                    double AppTimeStamp= [[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
                    double timeDifferance=AppTimeStamp-ServerTimeStamp;
                    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",timeDifferance] forKey:@"TimeDifferance"];
                    NSLog(@"time %f mimn %f",fabs(ServerTimeStamp-AppTimeStamp),fabs(ServerTimeStamp-AppTimeStamp)*0.001);
                    NSLog(@"get utc forma%@",[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate]);
                    if(fabs(AppTimeStamp -ServerTimeStamp )>903333)
                    {
                        //   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please set the correct device time"   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        
                        //  [alert show];
                    }
                    if (  ![currentUser isEqual:@""]&&_messageDelegate!=nil)
                    {
                        [_messageDelegate freezerRemove];
                    }
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"try again");
                    NSLog(@"try again");
                    [self CurrentDate];
                }
                
            }
            else {
                NSLog (@ "nsdata download failed");
                NSLog(@"try again");
                //[self CurrentDate];
                [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%.0f",previousTimeDifferance]  forKey:@"TimeDifferance"];
                if (  ![currentUser isEqual:@""]&&_messageDelegate!=nil)
                {
                    [_messageDelegate freezerRemove];
                }
            }
        });
        
    });
    
}
//- (NSDate *) CurrentDate
//{
//
//    NSURL * scriptUrl = [NSURL URLWithString: @"http://gupapp.com/Gup_demo/scripts/utc_time.php"/*@"http://api.timezonedb.com/?zone=America/St_Barthelemy&format=json&key=RFBQVAXKTDQ2"*/];
//    NSData * data = [NSData dataWithContentsOfURL: scriptUrl];
//
//    if (data != nil)
//    {
//        NSDictionary *dict;
//        @try {
//            dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//            double timestamp=[[dict objectForKey:@"timestamp"] doubleValue];
//            double offset=[[dict objectForKey:@"gmtOffset"] doubleValue];
//            NSLog(@"utc time %f",timestamp+offset );
//            NSLog(@"utc time %f",(timestamp-offset)*1000 );
//            NSDate * currDate = [NSDate dateWithTimeIntervalSince1970: timestamp+offset];
//            NSLog (@ " date is:%@", [currDate description]);
//            NSLog(@"current date %@",[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate]);
//            return currDate;
//        }
//        @catch (NSException *exception) {
//            NSLog(@"try again");
//        }
//
//        NSString * tempString = [NSString stringWithUTF8String: [data bytes]];
//        NSDate * currDate = [NSDate dateWithTimeIntervalSince1970: [tempString doubleValue]];
//        NSLog (@ "String returned from the site is:%@ and date is:%@", tempString, [currDate description]);
//        return currDate;
//    }
//    else {
//        NSLog (@ "nsdata download failed");
//        return [NSDate date];
//    }
//
//
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    previousTimeDifferance=0.000;
    [UIApplication sharedApplication].statusBarHidden = NO;
    //     [self get_UTC_Time];
    _backgroundFlag = false;
    [self CurrentDate];
    // NSLog(@"time %@",[self CurrentDate]);
    NSLog(@"time %@",[NSDate date]);
    //NSLog(@"cuurent time option %@",[NSString getCurrentUTCFormateDate ]);
    MyUserName=[[NSString alloc]init];
    app = [UIApplication sharedApplication];
    //NSLog(@"utc %f",[[NSDate date] timeIntervalSince1970] * 1000);
    [self setUpRechability];
    
    //[self getContactDataWithNotificationForUserId:@"11"];
    /* NSLog(@"array elements %@" ,   [[DatabaseManager getSharedInstance] retrieveDataFromTableWithQuery:@"select id,group_id,contact_id,is_admin,deleted from group_members"]);*/
    /* Login *rootViewController = [[Login alloc] init];
     // Initialize Navigation Controller
     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
     NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
     if ([[ver objectAtIndex:0] intValue] >= 7) {
     
     [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
     
     }else{
     
     [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1]];
     
     }
     //[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
     
     navigationController.navigationBar.translucent = NO;
     [navigationController.navigationBar setHidden:YES];
     self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
     // Configure Window
     [self.window setRootViewController:navigationController];
     [self.window setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]];
     //[self.window setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
     [self.window makeKeyAndVisible];*/
    //NSLog(@"dtv %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
    // if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] stringByReplacingOccurrencesOfString:@" " withString:@""].length==0||[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]==nil)
    //  {
    //   NSLog(@"Registering for push notifications...");
    //    [[UIApplication sharedApplication]unregisterForRemoteNotifications];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge)];
    //}
    //  else
    //  {
    
    // [[NSNotificationCenter defaultCenter] addObserver:self                                            selector:@selector(notifyForPN)                                                name:UIRemoteNotificationTypeNone object:nil];
    
    ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"update contacts set user_status='offline'" ];
    //NSLog(@"cuurent time option %@",[NSString getCurrentUTCFormateDate ]);
    [self setXmpp];
    //NSLog(@"cuurent time option %@",[NSString getCurrentUTCFormateDate ]);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [globleData getSharedInstance];
    [self setLoginView];
    // }
    //NSLog(@"notify %@",  [application observationInfo]);
    //NSLog(@"cuurent time option %@",[NSString getCurrentUTCFormateDate ]);
    NSDictionary *userInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]){
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    
    // iOS < 8 Notifications
    [application registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    

    
    //NSLog(@"notif %@ ",userInfo);
    //  [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if ([[ver objectAtIndex:0] intValue] >= 7)
        //  [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        if ( userInfo != nil )
            [self application:application didReceiveRemoteNotification:userInfo];
    
    
    [self removeOlderPost];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs://"]];
    return YES;
}

-(void)removeOlderPost{
    
    NSString *query=[NSString stringWithFormat:@"SELECT post_id,updated from Post"];
    NSArray *postDataArray =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:query];
    
    double currentDataMiliSecend  = [[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //    NSDate *currentData = [NSDate dateWithTimeIntervalSince1970:currentDataMiliSecend/1000];
    //    NSDateComponents *currentDateComponents = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:currentData];
    for (NSDictionary *post in postDataArray) {
        
        double updateTime = [[post objectForKey:@"UPDATED"] doubleValue];
        int postid = [[post objectForKey:@"POST_ID"] intValue];
        
        //        NSDate *dateDate = [NSDate dateWithTimeIntervalSince1970:(updateTime-1439452)/1000];
        //        NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:dateDate];
        
        double timeDifference = currentDataMiliSecend - (updateTime);
        //        double satimeDifference = currentDataMiliSecend - (2*24*60*60*1000);
        
        if(timeDifference > 24*2*60*60*1000){
            
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:[NSString stringWithFormat:@"DELETE FROM PostImageUrl WHERE post_id = %d",postid]];
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:[NSString stringWithFormat:@"DELETE FROM Post WHERE post_id = %d",postid]];
            
        }
        
        
    }
    NSLog(@"%@",postDataArray);
    
}

-(void)UpdateUserDeviceToken{
    NSArray *output=   [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select  social_login_type,password from master_table"];
    
    NSString *socialLoginType=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ;
    //  NSString *emailID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"EMAIL" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"EMAIL" ForRowIndex:0 givenOutput:output] ;
    NSString *passwordFetched=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output];
    /*if ([output count]!=0)
        if (![socialLoginType isEqualToString:@" "]||![passwordFetched isEqualToString:@" "])
        {*/
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            //NSLog(@"d i %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
            NSString *postData = [NSString stringWithFormat:@"deviceToken=%@&deviceType=2&user_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"],[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_device_token.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            updateUser = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [updateUser scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [updateUser start];
            updateResponce = [[NSMutableData alloc] init];
       // }
    
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *str = [NSString stringWithFormat:@"%@",deviceToken];
    str= [[[str
            stringByReplacingOccurrencesOfString:@"<"withString:@""]
           stringByReplacingOccurrencesOfString:@">" withString:@""]
          stringByReplacingOccurrencesOfString: @" " withString: @""];
    DeviceToken= str;
    //NSLog(@"%@", str);
    if (str==nil)
        str=@" ";
    NSLog(@"obje %@ temp %@",str,[[NSUserDefaults standardUserDefaults]objectForKey:@"DeviceToken"]);
    //[[NSUserDefaults standardUserDefaults]setObject:@"123" forKey:@"DeviceToken" ];
    // str=@"123"
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"DeviceToken"]||![[[NSUserDefaults standardUserDefaults]objectForKey:@"DeviceToken"] isEqual:str])
    {
        [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"DeviceToken" ];
        [self UpdateUserDeviceToken];
        
    }
    else
        [[NSUserDefaults standardUserDefaults]setObject:str forKey:@"DeviceToken" ];
    
    
    
    //NSLog(@"dtv %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
    //  ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    //  [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"update contacts set user_status='offline'" ];
    //  [self setXmpp];
    
    //   [[UIApplication sharedApplication]setStatusBarHidden:YES];
    // [globleData getSharedInstance];
    
    // [self setLoginView];
    //
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    DeviceToken=@"";
    //NSLog(@"%@",str);
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:str delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}


-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"STREAM CONNECTION TIME OUT");
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    //NSLog(@"user %@",sender);
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    myUserID=[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID];
    
    //NSLog(@"user id %@",myUserID);
    
    NSArray *excutedOutput=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select id,status from master_table"];
    //NSLog(@"output=%@",excutedOutput);
    if ([excutedOutput count]==1){//&&![userStatus isEqual:@"tempUnailable"])
        
        /*if(![xmppStream isConnected])
         {
         NSArray *output=   [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select social_login_type,password from master_table"];
         NSString *socialLoginType=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ;
         NSString *passwordFetched=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output];
         if (![socialLoginType isEqualToString:@" "]||![passwordFetched isEqualToString:@" "])
         {
         
         [self connect];
         }
         }*/
        NSString *userStatuss=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"STATUS" ForRowIndex:0 givenOutput:excutedOutput];
        
        if ([userStatuss isEqual:@"offline"]) {
            [self goOffline];
        }
        else if([userStatuss isEqual:@"away"]){
            [self goAway];
        }else if([userStatuss isEqual:@"online"]){
            [self goOnline];
            [self joinPandingMessageGroup];
            
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self joinGroup];
            [self likePost];
            //            });
            // [self performSelectorInBackground:@selector(joinGroup) withObject:nil];
        }
    }
    
    [self tryResendingMessages];
    [NSTimer scheduledTimerWithTimeInterval:130
                                     target:self
                                   selector:@selector(changeAutoTimeInterval:)
                                   userInfo:nil
                                    repeats:NO];
    
    
    
}

-(void)joinPandingMessageGroup{
    //     NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select group_id from chat_group INNER  JOIN chat_message where user_id=%@ AND  messageStatus=0 order by chat_group.time_stamp ASC group by group_id",myUserID]];
    
    NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select distinct group_id from chat_group INNER JOIN chat_message where user_id=%@ AND messageStatus=0 AND  message_id=chat_message.id order by chat_group.time_stamp ASC",myUserID]];
    
    
    XMPPRoomCoreDataStorage *roomMemoryStorage = [XMPPRoomCoreDataStorage sharedInstance];
    for (NSDictionary *data in groupUnsendMessages) {
        
        NSString *tojid = [NSString stringWithFormat:@"group_%@@%@",[data objectForKey:@"DISTINCTGROUP_ID"],groupJabberUrl];
        XMPPJID *roomJID = [XMPPJID jidWithString:tojid];
        XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:roomJID ];
        [xmppRoom activate:self.xmppStream];
        [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"%@",[[self.myjid componentsSeparatedByString:@"@"] firstObject]] history:nil];
    }
    
    
}

//-(void)joinGroup{
//
//    NSArray *postList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select post_id from Post"];
//    if([postList count]>0){
//
//        for (NSMutableDictionary *group in postList) {
//            NSString *tojid = [NSString stringWithFormat:@"post_%@@%@",[group objectForKey:@"POST_ID"],groupJabberUrl];
//            XMPPPresence *presence = [XMPPPresence presenceWithType:nil to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@/user_%@",tojid,myUserID]]];
//            [presence addAttributeWithName:@"from" stringValue:self.myjid];
//            NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
//            [presence addChild:x];
//            [self.xmppStream sendElement:presence];
//
//        }
//
//    }
//
//}

-(void)xmppAutoTime:(XMPPAutoTime *)sender didUpdateTimeDifference:(NSTimeInterval)timeDifference{
    NSLog(@"\n\ntime differtance %f\n\n",timeDifference);
    
}

-(void)tryResendingMessages{
    
    NSArray *personalUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_personal.id,user_id,receivers_id,time_stamp,message_id,message_type,message_text,message_filename   from chat_personal INNER  JOIN chat_message where chat_personal.user_id=%@ AND chat_personal.message_id=chat_message.id AND messageStatus=0 AND deleted=0 order by time_stamp ASC ",myUserID]];
    NSArray *master_table=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name,logged_in_user_id,chat_wall_paper from master_table"];
    
    for (int i=0; i<[personalUnsendMessages count]; i++){
        
        NSMutableDictionary *arrayTobePassed=[[NSMutableDictionary alloc]init];
        NSDictionary *row=   [[DatabaseManager getSharedInstance]DatabaseOutputParserRetrieveRowFromRowIndex:i FromOutput:personalUnsendMessages];
        
        NSString *message_ID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_ID" givenRow:row];
        NSString *referance_ID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"CHAT_PERSONAL.ID" givenRow:row];
        NSString *sendersID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"USER_ID" givenRow:row];
        NSArray *chatMessageRow=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT message_type,message_text,message_filename from chat_message where id =%@",message_ID]];
        NSString *recieversID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"RECEIVERS_ID" givenRow:row];
        NSString *message_type=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_TYPE" ForRowIndex:0 givenOutput:chatMessageRow];
        NSString *message;
        if ([message_type isEqualToString:@"text"]||[message_type isEqualToString:@"vcard"])
            message=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_TEXT" ForRowIndex:0 givenOutput:chatMessageRow];
        else
            message=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_FILENAME" ForRowIndex:0 givenOutput:chatMessageRow];
        message=[message stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        message =[message stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *timestamp=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"TIME_STAMP" givenRow:row];
        
        [arrayTobePassed setValue:timestamp forKey:@"time_stamp"];
        [arrayTobePassed setValue:message forKey:@"message"];
        [arrayTobePassed setValue:message_type forKey:@"message_type"];
        [arrayTobePassed setValue:message_ID forKey:@"message_Id"];
        [arrayTobePassed setValue:referance_ID forKey:@"referenceID"];
        [arrayTobePassed setValue:sendersID forKey:@"senders_id"];
        [arrayTobePassed setValue:recieversID forKey:@"recievers_id"];
        [arrayTobePassed setValue:@"0" forKey:@"isGroup"];
        [arrayTobePassed setValue:@"" forKey:@"groupID"];
        [arrayTobePassed setValue:@"" forKey:@"groupCounter"];
        [arrayTobePassed setValue:@"1" forKey:@"isResending"];
        [self sendMessageWithMessageData:arrayTobePassed];
        
    }
    NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_group.id,group_id,post_id,user_id,time_stamp,message_id,message_type,message_text,message_filename  from chat_group INNER  JOIN chat_message where user_id=%@ AND messageStatus=0 AND message_id=chat_message.id order by chat_group.time_stamp ASC",myUserID]];
    for (int i=0; i<[groupUnsendMessages count]; i++)   {
        NSMutableDictionary *arrayTobePassed=[[NSMutableDictionary alloc]init];
        NSDictionary *row = [[DatabaseManager getSharedInstance]DatabaseOutputParserRetrieveRowFromRowIndex:i FromOutput:groupUnsendMessages];
        
        NSString *message_ID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_ID" givenRow:row];
        NSString *referance_ID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"CHAT_GROUP.ID" givenRow:row];
        NSString *sendersID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"USER_ID" givenRow:row];
        NSArray *chatMessageRow=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT message_type,message_text,message_filename from chat_message where id =%@",message_ID]];
        NSString *groupID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"GROUP_ID" givenRow:row];
        NSMutableArray *grpMem=[self getMembersListFromGroupID:groupID];
        for (int y=0;y<[grpMem  count];y++ ){
            NSString *recieversID=[grpMem objectAtIndex:y];
            
            NSString *message_type=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_TYPE" ForRowIndex:0 givenOutput:chatMessageRow];
            NSString *message;
            if ([message_type isEqualToString:@"text"]||[message_type isEqualToString:@"vcard"])
                message=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_TEXT" ForRowIndex:0 givenOutput:chatMessageRow];
            else
                message=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_FILENAME" ForRowIndex:0 givenOutput:chatMessageRow];
            message=[[message UTFDecoded] stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            message =[message stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *timestamp=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"TIME_STAMP" givenRow:row];
            [arrayTobePassed setValue:timestamp forKey:@"time_stamp"];
            [arrayTobePassed setValue:message forKey:@"message"];
            [arrayTobePassed setValue:message_type forKey:@"message_type"];
            [arrayTobePassed setValue:message_ID forKey:@"message_Id"];
            [arrayTobePassed setValue:referance_ID forKey:@"referenceID"];
            [arrayTobePassed setValue:sendersID forKey:@"senders_id"];
            [arrayTobePassed setValue:recieversID forKey:@"recievers_id"];
            [arrayTobePassed setValue:@"1" forKey:@"ispost"];
            [arrayTobePassed setValue:groupID forKey:@"groupID"];
            [arrayTobePassed setValue:@"" forKey:@"groupCounter"];
            [arrayTobePassed setValue:@"1" forKey:@"isResending"];
            [self sendMessageWithMessageData:arrayTobePassed];
        }
        
        
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        NSDictionary *userDictonary = [master_table lastObject];
        NSString *referanceID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"CHAT_GROUP.ID" givenRow:row];
        [data setObject:[row objectForKey:@"MESSAGE_TEXT"] forKey:@"message"];
        [data setObject:[row objectForKey:@"MESSAGE_TYPE"]  forKey:@"messagetype"];
        [data setObject:[userDictonary objectForKey:@"DISPLAY_NAME"] forKey:@"sendername"];
        [data setObject:[row objectForKey:@"TIME_STAMP"] forKey:@"TimeStamp"];
        [data setObject:referanceID forKey:@"referenceID"];
        [data setObject:[row objectForKey:@"GROUP_ID"] forKey:@"groupID"];
        [data setObject:[row objectForKey:@"USER_ID"] forKey:@"senderid"];
        NSError *writeError = nil;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&writeError];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:jsonString];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"group_%@@%@",[row objectForKey:@"GROUP_ID"],groupJabberUrl]];
        
        [message addChild:body];
        [[self xmppStream] sendElement:message];
    }
    
    
}

-(void)joinGroup{
    
    NSArray *privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select group_server_id,group_name from groups_private"];
    NSArray *groupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select group_server_id,group_name from groups_public"];
    
    NSMutableArray *finalgroups = [[NSMutableArray alloc] init];
    [finalgroups addObjectsFromArray:privateGroupList];
    [finalgroups addObjectsFromArray:groupList];
    if([finalgroups count]>0){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //
            //        XMPPRoomCoreDataStorage *roomMemoryStorage = [XMPPRoomCoreDataStorage sharedInstance];
            
            for (NSMutableDictionary *group in finalgroups) {
                NSString *tojid = [NSString stringWithFormat:@"group_%@@%@",[group objectForKey:@"GROUP_SERVER_ID"],groupJabberUrl];
                
                XMPPPresence *presence = [XMPPPresence presenceWithType:nil to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@/user_%@",tojid,myUserID]]];
                [presence addAttributeWithName:@"from" stringValue:self.myjid];
                NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
                [presence addChild:x];
                [self.xmppStream sendElement:presence];
                
            }
        });
        
    }
    
}


-(void)likePost{
    
    NSArray *likePost = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select postid, groupid, likestatus, updatedTime from offlinelike"];
    NSDate *now = [NSDate date];
    NSTimeInterval seconds =  [now timeIntervalSince1970];
    double time1 = seconds*1000;
    
    if (likePost.count>0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSMutableDictionary *group in likePost) {
                
                XMPPPresence *likeiq = [XMPPPresence elementWithName:@"presence"];
                [likeiq addAttributeWithName:@"to" stringValue:jabberUrl];
                [likeiq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"like_%.0f",time1]];
                NSXMLElement *likeuser = [NSXMLElement elementWithName:@"status" stringValue:@"like"];
                NSXMLElement *show = [NSXMLElement elementWithName:@"likedata" xmlns:@"urn:xmpp:guplike"];
                NSXMLElement *user = [NSXMLElement elementWithName:@"user" stringValue:self.MyUserName];
                NSXMLElement *userid = [NSXMLElement elementWithName:@"userid" stringValue:self.myUserID];
                NSXMLElement *status = [NSXMLElement elementWithName:@"likestatus" stringValue:[group objectForKey:@"LIKESTATUS"]];
                NSXMLElement *groupid = [NSXMLElement elementWithName:@"groupid" stringValue:[group objectForKey:@"GROUPID"]];
                NSXMLElement *postid = [NSXMLElement elementWithName:@"postid" stringValue:[group objectForKey:@"POSTID"]];
                NSXMLElement *updatedTime = [NSXMLElement elementWithName:@"updatedTime" stringValue:[group objectForKey:@"UPDATEDTIME"]];
                
                [show addChild:user];
                [show addChild:userid];
                [show addChild:status];
                [show addChild:groupid];
                [show addChild:postid];
                [show addChild:updatedTime];
                
                [likeiq addChild:likeuser];
                [likeiq addChild:show];
                NSLog(@"%@",likeiq);
                [self.xmppStream sendElement:likeiq];
            }
            
        });
    }
    
}


-(NSMutableArray*)getMembersListFromGroupID:(NSString*)groupid{
    
    NSMutableArray *groupMembers=[[NSMutableArray alloc]init];
    NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@",groupid]];
    
    for (int i=0;i<[tempmembersID count];i++){
        
        [groupMembers addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
    }
    return groupMembers;
    //NSLog(@"membersID %@",membersID);
}


//-(void)tryResendingMessages
//{
//    NSArray *FailedMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select is_group,senders_id,message_id,recievers_id,referenceID,groupCounter,groupID,time_stamp from failedMessages"];
//    if ([FailedMessages count]!=0)
//        for (int i=0; i<[FailedMessages count]; i++)
//        {
//            NSMutableDictionary *arrayTobePassed=[[NSMutableDictionary alloc]init];
//            NSDictionary *row=   [[DatabaseManager getSharedInstance]DatabaseOutputParserRetrieveRowFromRowIndex:i FromOutput:FailedMessages];
//            BOOL isGroup=[[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"IS_GROUP" givenRow:row] boolValue];
//            NSString *message_ID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_ID" givenRow:row];
//            NSArray *chatMessageRow=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT message_type,message_text,message_filename from chat_message where id =%@",message_ID]];
//            NSString *message_type=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_TYPE" ForRowIndex:0 givenOutput:chatMessageRow];
//            NSString *message;
//            if ([message_type isEqualToString:@"text"]||[message_type isEqualToString:@"vcard"])
//                message=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_TEXT" ForRowIndex:0 givenOutput:chatMessageRow];
//            else
//                message=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_FILENAME" ForRowIndex:0 givenOutput:chatMessageRow];
//            message=[message UTFDecoded];
//           //praful pisso NSString *timestamp=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"TIME_STAMP" givenRow:row];
//           NSString    *timestamp = [[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] ;
//            //NSLog(@"row %@",row);
//            //NSLog(@"%@",[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"MESSAGE_ID" givenRow:row]);
//            [arrayTobePassed setValue:timestamp forKey:@"time_stamp"];
//            [arrayTobePassed setValue:message forKey:@"message"];
//            [arrayTobePassed setValue:message_type forKey:@"message_type"];
//            [arrayTobePassed setValue:message_ID forKey:@"message_Id"];
//            [arrayTobePassed setValue:[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"REFERENCEID" givenRow:row] forKey:@"referenceID"];
//            [arrayTobePassed setValue:[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SENDERS_ID" givenRow:row] forKey:@"senders_id"];
//            [arrayTobePassed setValue:[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"RECIEVERS_ID" givenRow:row] forKey:@"recievers_id"];
//            [arrayTobePassed setValue:[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"IS_GROUP" givenRow:row] forKey:@"isGroup"];
//            [arrayTobePassed setValue:isGroup?[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"GROUPID" givenRow:row]:@"" forKey:@"groupID"];
//            [arrayTobePassed setValue:isGroup?[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"GROUPCOUNTER" givenRow:row]:@"" forKey:@"groupCounter"];
//
//            [arrayTobePassed setValue:@"1" forKey:@"isResending"];
//            //NSLog(@"array %@",arrayTobePassed);
//            [self sendMessageWithMessageData:arrayTobePassed];
//
//        }
//
//}

-(void)composeMessageWithAttributes:(NSDictionary*)attr andElements:(NSDictionary*)element body:(NSString*)bodystr{
    //NSLog(@"att  %@ el %@",attr,element);
    XMPPMessage *msg = [XMPPMessage message];
    NSArray *attrKeys=[attr allKeys];
    for (int i=0;i<[attrKeys count];i++ )
    {NSString *value=[attr objectForKey:[attrKeys objectAtIndex:i]];
        [msg addAttributeWithName:[attrKeys objectAtIndex:i] stringValue:value];
    }
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:bodystr];
    
    NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
    NSArray *elemKeys=[element allKeys];
    //NSLog(@"el %@",element);
    for (int j=0; j<[elemKeys count]; j++){
        NSString *key=(NSString*)[elemKeys objectAtIndex:j];
        NSString *value=(NSString*)[element objectForKey:key];
        //NSLog(@"va %@ key %@",value,key);
        NSXMLElement *message_type = [NSXMLElement elementWithName:key stringValue:value];
        [gup addChild:message_type];
    }
    [msg addChild:gup];
    [msg addChild:body];
    //NSLog(@"%@",msg);
    [xmppStream sendElement:msg];
    
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    
    NSLog(@"xmppRoomDidCreate - group %@",sender);
    [sender fetchConfigurationForm];
    
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    NSLog(@"xmppRoomDidJoin - group %@",sender.roomJID);
    
    //    NSArray *master_table=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name,logged_in_user_id,chat_wall_paper from master_table"];
    
    NSString *roomid =[[[[[NSString stringWithFormat:@"%@",sender.roomJID] componentsSeparatedByString:@"@"] firstObject] componentsSeparatedByString:@"_"] lastObject];
    
    NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_group.id,user_id,time_stamp,message_id,message_type,message_text,message_filename,post_id from chat_group INNER  JOIN chat_message where user_id=%@ AND group_id = %@ AND messageStatus=0 AND  message_id=chat_message.id order by chat_group.time_stamp ASC",myUserID,roomid]];
    if(groupUnsendMessages.count>0)
        for (int i=0; i<[groupUnsendMessages count]; i++)   {
            
            NSDictionary *row=   [[DatabaseManager getSharedInstance]DatabaseOutputParserRetrieveRowFromRowIndex:i FromOutput:groupUnsendMessages];
            NSString *referance_ID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"CHAT_GROUP.ID" givenRow:row];
            
            
            //        NSString *messageBody=[messageData objectForKey:@"message"];
            
            XMPPMessage *msg = [XMPPMessage message];
            [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
            [msg addAttributeWithName:@"groupCounter" integerValue:[@"" integerValue]];
            [msg addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",sender.roomJID]];
            [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ];
            [msg addAttributeWithName:@"isResend" boolValue:[@"1" boolValue]];
            //        NSString *recieversID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"RECEIVERS_ID" givenRow:row];
            [msg addAttributeWithName:@"referenceID" integerValue:[referance_ID integerValue]];
            
            NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
            NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[row objectForKey:@"MESSAGE_TEXT"]];
            NSXMLElement *referanceID = [NSXMLElement elementWithName:@"referenceID" stringValue:referance_ID];
            NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[row objectForKey:@"USER_ID"]];
            NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:user_name];
            NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:[row objectForKey:@"MESSAGE_TYPE"]];
            NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[row objectForKey:@"TIME_STAMP"]];
            NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:roomid];
            NSXMLElement *isgroup =[NSXMLElement elementWithName:@"ispost" stringValue:@"1"];
            NSXMLElement *postid =[NSXMLElement elementWithName:@"postid" stringValue:[row objectForKey:@"POST_ID"]];
            
            [gup addChild:body];
            [gup addChild:from_user_id];
            [gup addChild:from_user_name];
            [gup addChild:timeStamp];
            [gup addChild:message_type];
            [gup addChild:referanceID];
            [gup addChild:isgroup];
            [gup addChild:postid];
            [gup addChild:groupIDs];
            [msg addChild:gup];
            NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:[row objectForKey:@"MESSAGE_TEXT"]]];
            [msg addChild:body1];
            [xmppStream sendElement:msg];
            
            NSLog(@"%@",msg);
            
            
            //        [data setObject:[row objectForKey:@"MESSAGE_TEXT"] forKey:@"message"];
            //        [data setObject:[row objectForKey:@"MESSAGE_TYPE"]  forKey:@"messagetype"];
            //        [data setObject:[userDictonary objectForKey:@"DISPLAY_NAME"] forKey:@"sendername"];
            //        [data setObject:[row objectForKey:@"TIME_STAMP"] forKey:@"TimeStamp"];
            //        [data setObject:referance_ID forKey:@"referenceID"];
            //        [data setObject:roomid forKey:@"groupID"];
            //        [data setObject:[row objectForKey:@"USER_ID"] forKey:@"senderid"];
            //        NSError *writeError = nil;
            //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&writeError];
            //        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            //        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
            //        [body setStringValue:jsonString];
            //        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
            //        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
            //        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",sender.roomJID]];
            //
            //        [message addChild:body];
            //        [[self xmppStream] sendElement:message];
            
        }
    
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    
    NSArray *fields = [configForm elementsForName:@"field"];
    for (NSXMLElement *field in fields) {
        if([[[field attributeForName:@"label"] stringValue] isEqualToString:@"Allow Occupants to change nicknames"]){
            NSString *value = [[field elementForName:@"value"] stringValue];
            if ([value intValue] == 1)
                val = @"0";
            else
                val = @"1";
            break;
        }
        
    }
    //    NSString *roomid = [[[[[NSString stringWithFormat:@"%@",sender.roomJID] componentsSeparatedByString:@"@"] firstObject] componentsSeparatedByString:@"_"] lastObject];
    //    NSArray *privateGroupList;
    //    privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select admin_id,group_name,group_description from groups_private where group_server_id = '%@'",roomid]];
    //
    //    if([privateGroupList count]==0){
    //        privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select admin_id from groups_public where group_server_id = '%@'",roomid]];
    //
    //    }
    
    //    [sender configureRoomUsingOptions:[self setConfig:sender.roomJID] from:self.myjid];
    
}

-(NSXMLElement *)setConfig:(XMPPJID *)roomjid{
    
    NSString *roomid = [[[[[NSString stringWithFormat:@"%@",roomjid] componentsSeparatedByString:@"@"] firstObject] componentsSeparatedByString:@"_"] lastObject];
    NSString *roomType;
    NSArray *privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select admin_id,group_name,group_description from groups_private where group_server_id = '%@'",roomid]];
    if([privateGroupList count]>0){
        roomType = @"private";
    }else{
        privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select admin_id,group_name,group_description from groups_public where group_server_id = '%@'",roomid]];
        roomType = @"public";
    }
    
    NSXMLElement *x = [[NSXMLElement alloc] initWithName:@"x" xmlns:@"jabber:x:data"];
    NSXMLElement *field = [[NSXMLElement alloc] initWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    NSXMLElement *value = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"];
    [field addChild:value];
    
    NSXMLElement *field1 = [[NSXMLElement alloc] initWithName:@"field"];
    [field1 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];
    NSXMLElement *value1 = [[NSXMLElement alloc] initWithName:@"value" stringValue:[[privateGroupList objectAtIndex:0] objectForKey:@"GROUP_NAME"]];
    [field1 addChild:value1];
    
    NSXMLElement *field2 = [[NSXMLElement alloc] initWithName:@"field"];
    [field2 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_membersonly"];
    NSXMLElement *value2 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"0"];
    [field2 addChild:value2];
    
    NSXMLElement *field3 = [[NSXMLElement alloc] initWithName:@"field"];
    [field3 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    NSXMLElement *value3 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"1"];
    [field3 addChild:value3];
    
    //    //    NSXMLElement *field3 = [[NSXMLElement alloc] initWithName:@"field"];
    //    //    [field3 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    //    //    NSXMLElement *value3 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"1"];
    //    //    [field3 addChild:value3];
    
    
    NSXMLElement *fieldz = [[NSXMLElement alloc] initWithName:@"field"];
    [fieldz addAttributeWithName:@"var" stringValue:@"muc#roomconfig_whois"];
    NSXMLElement *valuez = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"anyone"];
    [fieldz addChild:valuez];
    
    NSXMLElement *field4 = [[NSXMLElement alloc] initWithName:@"field"];
    [field4 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];
    
    NSXMLElement *value4;
    if([roomType isEqualToString:@"private"])
        value4 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"0"];
    else
        value4 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"1"];
    [field4 addChild:value4];
    
    NSXMLElement *field5 = [[NSXMLElement alloc] initWithName:@"field"];
    [field5 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomadmins"];
    NSXMLElement *value5 = [[NSXMLElement alloc] initWithName:@"value" stringValue:[NSString stringWithFormat:@"group_%@@%@",[[privateGroupList objectAtIndex:0] objectForKey:@"ADMIN_ID"],groupJabberUrl]];
    [field5 addChild:value5];
    
    NSXMLElement *field6 = [[NSXMLElement alloc] initWithName:@"field"];
    [field6 addAttributeWithName:@"label" stringValue:@"Short Description of Room"];
    [field6 addAttributeWithName:@"type" stringValue:@"text-single"];
    [field6 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomdesc"];
    NSXMLElement *value6 = [[NSXMLElement alloc] initWithName:@"value" stringValue:[[privateGroupList objectAtIndex:0] objectForKey:@"GROUP_DESCRIPTION"]];
    [field6 addChild:value6];
    
    NSXMLElement *field7 = [[NSXMLElement alloc] initWithName:@"field"];
    [field7 addAttributeWithName:@"label" stringValue:@"Allow Occupants to change nicknames"];
    [field7 addAttributeWithName:@"var" stringValue:@"x-muc#roomconfig_canchangenick"];
    NSXMLElement *value7 = [[NSXMLElement alloc] initWithName:@"value" stringValue:val];
    [field7 addChild:value7];
    
    [x addChild:field];
    [x addChild:field1];
    //          [x addChild:field2];
    [x addChild:field3];
    [x addChild:field4];
    //          [x addChild:fieldz];
    [x addChild:field5];
    [x addChild:field6];
    [x addChild:field7];
    return x;
}


- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
    NSLog(@"configer success");
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:nil to:sender.roomJID];
    [presence addAttributeWithName:@"from" stringValue:self.myjid];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
    [presence addChild:x];
    [self.xmppStream sendElement:presence];
    
    
    NSString *roomid = [[[[[NSString stringWithFormat:@"%@",sender.roomJID] componentsSeparatedByString:@"@"] firstObject] componentsSeparatedByString:@"_"] lastObject];
    
    NSArray *privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select admin_id,group_name,group_description from groups_private where group_server_id = '%@'",roomid]];
    
    if([privateGroupList count]==0){
        privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select admin_id from groups_public where group_server_id = '%@'",roomid]];
        
    }
    
    NSString *data = [[privateGroupList objectAtIndex:0] objectForKey:@"GROUP_MEMBER"];
    NSArray *members;
    if([[[privateGroupList objectAtIndex:0] objectForKey:@"GROUP_MEMBER"] isKindOfClass:[NSString class]]){
        NSString *membersString = [[[[data componentsSeparatedByString:@"("] lastObject] componentsSeparatedByString:@")"] firstObject];
        members = [membersString componentsSeparatedByString:@","];
    }else{
        members = [[privateGroupList objectAtIndex:0] objectForKey:@"GROUP_MEMBER"];
    }
    
    
    //    NSArray *members = [membersString componentsSeparatedByString:@","];
    if(members.count>0){
        for (int k=0; k<members.count; k++){
            NSString *recieversID=[NSString stringWithFormat:@"user_%@@%@",[members objectAtIndex:k],jabberUrl];
            [sender inviteUser:[XMPPJID jidWithString:recieversID] withMessage:@""];
        }
    }
    
    
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult{
    
    NSLog(@"configer success fail");
}


-(void)sendMessageWithMessageData:(NSDictionary*)messageData{
    
    NSString *messageBody=[messageData objectForKey:@"message"];
    
    XMPPMessage *msg = [XMPPMessage message];
    [msg addAttributeWithName:@"type" stringValue:@"chat"];
    [msg addAttributeWithName:@"groupCounter" integerValue:[[messageData objectForKey:@"groupCounter"] integerValue]];
    [msg addAttributeWithName:@"to" stringValue:[[messageData objectForKey:@"recievers_id"]JID]];
    [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ];
    [msg addAttributeWithName:@"isResend" boolValue:[[messageData objectForKey:@"isResending"] boolValue] ];
    [msg addAttributeWithName:@"referenceID" integerValue:[[messageData objectForKey:@"referenceID"] integerValue]];
    
    NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[messageBody stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]];
    NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]];
    NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:user_name];
    NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:[messageData objectForKey:@"message_type"]];
    NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[messageData objectForKey:@"time_stamp"]];
    NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:[messageData objectForKey:@"groupID"]];
    NSXMLElement *isgroup =[NSXMLElement elementWithName:@"ispost" stringValue:[messageData objectForKey:@"isGroup"]];
    
    
    [gup addChild:body];
    [gup addChild:from_user_id];
    [gup addChild:from_user_name];
    [gup addChild:timeStamp];
    [gup addChild:message_type];
    [gup addChild:isgroup];
    [gup addChild:groupIDs];
    [msg addChild:gup];
    NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:messageBody]];
    [msg addChild:body1];
    [xmppStream sendElement:msg];
    
    
}
-(NSString*)getStringFromBody:(NSXMLElement*)gupElement andBody:(NSString*)body{
    
    //NSLog(@"count %i",[gupElement childCount]);
    //NSLog(@"count 2 %i",[gupElement.children count]);
    //NSLog(@"childs %@",gupElement.children);
    NSString *returnString=[[NSString alloc]init];
    for (int i=0; i<[gupElement.children count]; i++){
        
        DDXMLNode *targetElement=[gupElement childAtIndex:i];
        //NSLog(@"child element name %@ value %@",targetElement.name ,targetElement.stringValue);
        returnString=[returnString stringByAppendingString:[NSString stringWithFormat:@"(%@)",targetElement.name]];
        if([targetElement.name isEqual:@"body"])
            returnString= [returnString stringByAppendingString:[NSString stringWithFormat:@"%@",body]];
        else
            returnString= [returnString stringByAppendingString:[NSString stringWithFormat:@"%@",targetElement.stringValue]];
        returnString= [returnString stringByAppendingString:[NSString stringWithFormat:@"(/%@)",targetElement.name]];
        
    }
    return [NSString stringWithFormat:@"(gup)%@(/gup)", returnString];
}
- (void)xmppStream:(XMPPStream*)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"Did not authenticate %@",error);
    //[xmppStream disconnect];
    [self goActualOffline];
}

-(void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq{}

-(void) getConversationMessagesFromServer:(NSXMLElement *)aChat{
    XMPPElement *set=(XMPPElement*)[XMPPElement elementWithName:@"set" xmlns:@"http://jabber.org/protocol/rsm"];
    //[set addChild:[XMPPElement elementWithName:@"max" stringValue:@"100"]];
    XMPPElement *retrieve=(XMPPElement*)[XMPPElement elementWithName:@"retrieve" xmlns:@"urn:xmpp:archive"];
    [retrieve addAttributeWithName:@"with" stringValue:[aChat attributeStringValueForName:@"with"]];
    [retrieve addAttributeWithName:@"start" stringValue:[aChat attributeStringValueForName:@"start"]];
    [retrieve addChild:set];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" elementID:@"page1"];
    [iq addChild:retrieve];
    [self.xmppStream sendElement:iq];
    
}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSXMLElement *queryElement = [iq elementForName: @"query" xmlns: @"jabber:iq:roster"];
    NSMutableArray *ArrayUsers=[[NSMutableArray alloc]init];
    
    if (queryElement) {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        [ArrayUsersIDs removeAllObjects];
        [ArrayUsers removeAllObjects];
        for (int i=0; i<[itemElements count]; i++) {
            
            NSString *jid=[[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
            [ArrayUsers addObject:jid];
            [ArrayUsersIDs addObject:[jid userID]];
        }
        
    }
    //NSLog(@"array user %@",ArrayUsersIDs);
    
    
    NSXMLElement *pingElement = [iq elementForName: @"ping" xmlns: @"urn:xmpp:ping"];
    if (pingElement){
        NSString *from=[[iq attributeForName:@"from"] stringValue];
        NSString *to=[[iq attributeForName:@"to"] stringValue];
        NSString *myJid=[NSString stringWithFormat:@"%@",[xmppStream myJID]];
        if ([to isEqualToString:myJid ]&&[from isEqual:[NSString stringWithFormat:@"%@",jabberUrl]]){
            
            [xmppping sendPingToServer];
        }
        
    }
    
    NSString *type = [iq type];
    
    if ([type isEqualToString:@"result"]){
        NSXMLElement *list = [iq elementForName:@"list" xmlns:@"urn:xmpp:archive"];
        
        if (list){
            for (NSXMLElement *aChat in [list elementsForName:@"chat"]) {
                NSLog(@"Chat : %@",aChat);
                [self getConversationMessagesFromServer:aChat];
            }
        }else{
            NSXMLElement *chat = [iq elementForName:@"chat"];
            
            if (chat){
                XMPPJID *to;
                XMPPJID *from;
                for (NSXMLElement *aMessage in [chat children]) {
                    
                    
                    NSString *bodyStr = [[aMessage elementForName:@"body"] stringValue];
                    BOOL isOutGoing=NO;
                    if ([bodyStr length] > 0){
                        if ([[aMessage name] isEqualToString:@"from"]){
                            isOutGoing=NO;
                            to = self.xmppStream.myJID.bareJID;
                            from=[[XMPPJID jidWithString:[chat attributeStringValueForName:@"with"]] bareJID];
                            
                        }else if ([[aMessage name] isEqualToString:@"to"]){
                            isOutGoing=YES;
                            to = [[XMPPJID jidWithString:[chat attributeStringValueForName:@"with"]] bareJID];
                            from=self.xmppStream.myJID.bareJID;
                        }
                        
                        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:bodyStr];
                        
                        NSXMLElement *timeStamp = [NSXMLElement elementWithName:@"delay" xmlns:@"urn:xmpp:delay"];
                        [timeStamp addAttributeWithName:@"stamp" stringValue:[chat attributeStringValueForName:@"start"]];
                        XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:to];
                        [message addAttributeWithName:@"from" stringValue:[from bare]];
                        [message addChild:body];
                        [message addChild:timeStamp];
                        
                    }
                }
                
            }
        }
    }
    
    return NO;
}

-(NSString*)CheckIfMessageExist:(NSString*)message ofMessageType:(NSString*)type{
    NSString *columnName;
    if([type isEqualToString:@"text" ]||[type isEqualToString:@"vcard" ])
        columnName=@"message_text";
    else
        columnName=@"message_filename";
    NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select id from chat_message where %@='%@' AND message_type='%@' ",columnName,message,type]];
    if ([output count]==0){
        return nil;
    }else{
        return [[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"ID" ForRowIndex:0 givenOutput:output];
        
    }
}
-(NSString*)PutMessageInStorage:(NSString*)message ofMessageType:(NSString*)type{
    NSString *columnName;
    if([type isEqualToString:@"text" ]||[type isEqualToString:@"vcard" ])
        columnName=@"message_text";
    else
        columnName=@"message_filename";
    
    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_message (message_type,%@,message_deleted )VALUES('%@','%@',0)",columnName,type,message]];
    
    return [(NSDictionary*)[(NSArray*)[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select MAX(ID) from chat_message"]objectAtIndex:0] objectForKey:@"MAX(ID)" ];
    
    
}
-(BOOL)PutLinkOfMessageInStorageForType:(NSString*)form withMessageData:(NSDictionary*)messageComponents{
    //NSLog(@"msg %@",messageComponents);
    NSString *isRead=@"0",*received_time_test,*orignal;
    if (![messageComponents objectForKey:@"pinned"]){
        [messageComponents setValue:@"0" forKey:@"pinned"];
    }
    if([messageComponents objectForKey:@"read"]){
        isRead=[messageComponents objectForKey:@"read"];
    }
    if ([messageComponents objectForKey:@"timestamp"]){
        received_time_test=[messageComponents objectForKey:@"timestamp"];
    }else{
        double tempTime=[[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"]){
            
            tempTime=tempTime+[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue];
        }
        received_time_test=[NSString stringWithFormat:@"%f",tempTime];
        NSLog(@"time %@",[received_time_test getDateTimeFromUTCTimeInterval]);
    }
    if ([messageComponents objectForKey:@"orignal_time"]){
        orignal=[messageComponents objectForKey:@"orignal_time"];
    }else{
        orignal=[messageComponents objectForKey:@"timestamp"];
    }
    if([form isEqualToString:@"personal"]){
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update contacts set deleted=0 where user_id=%@",[messageComponents objectForKey:@"sendersUserID" ]]];
        if(![[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"SELECT * FROM contacts where user_id=%@",[messageComponents objectForKey:@"sendersUserID" ]]]&![myUserID isEqualToString:[messageComponents objectForKey:@"sendersUserID"]]){
            [self getContactInfoWhereUserId:[[messageComponents objectForKey:@"sendersUserID" ] integerValue]];
            [_chatDelegate buddyStatusUpdated];
        }
        return [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_personal (user_id,receivers_id,time_stamp,message_id,pinned,spam,deleted,read,messageStatus,received_time,sender_image)VALUES(%@,%@,'%@',%@,%@,0,0,%@,%@,'%@','%@')",[messageComponents objectForKey:@"sendersUserID"],[messageComponents objectForKey:@"receiveruserID"],[messageComponents objectForKey:@"timestamp"]/*[NSString DateTime]*//*[NSString stringWithFormat:@"%@,%@",[NSString CurrentTime],[NSString CurrentDate]]*/,[messageComponents objectForKey:@"messageid"],[messageComponents objectForKey:@"pinned"],isRead,[messageComponents objectForKey:@"messageStatus"],received_time_test,[messageComponents objectForKey:@"senderimage"]]];
        
    }
    else
        return [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_group (group_id,user_id,time_stamp,message_id,pinned,spam,deleted,read,messageStatus,received_time,sendername,orignal_time,post_id,sender_image)VALUES(%@,%@,'%@',%@,%@,0,0,%@,%@,'%@','%@','%@',%@,'%@')",[messageComponents objectForKey:@"groupID"],[messageComponents objectForKey:@"sendersUserID"],[messageComponents objectForKey:@"timestamp"],[messageComponents objectForKey:@"messageid"],[messageComponents objectForKey:@"pinned"],isRead,[messageComponents objectForKey:@"messageStatus"],received_time_test,[messageComponents objectForKey:@"sendername"],orignal,[messageComponents objectForKey:@"postid"],[messageComponents objectForKey:@"senderimage"]]];
    
    
}
-(BOOL)storeFailedMessagesForType:(NSString*)idPassed messageComponents:(NSDictionary*)components
{
    NSString *linkID;
    NSArray *maximaArray;
    if ([idPassed isEqualToString:@"personal"])
        maximaArray=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select MAX(ID) from chat_personal"];
    else
        maximaArray=    [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select MAX(ID) from chat_group"];
    linkID=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MAX(ID)" ForRowIndex:0 givenOutput:maximaArray];
    linkID=[linkID isEqual:[NSNull null]]?@"0":linkID;
    //NSLog(@"%@ cont %@",maximaArray,linkID);
    if ([idPassed isEqualToString:@"personal"])
    {
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into failedMessages (is_group,senders_id,message_id,recievers_id,referenceID,time_stamp) values(0,%@,%@,%@,%@,%@)",[components objectForKey:@"sendersUserID"],[components objectForKey:@"messageid"],[components objectForKey:@"receiveruserID"],linkID,[components objectForKey:@"timestamp"]/* getTimeIntervalFromStringDate]*/]];
    }else{
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into failedMessages (is_group,senders_id,message_id,recievers_id,referenceID,groupCounter,groupID,time_stamp) values(1,%@,%@,%@,%@,%@,%@,%@)",[components objectForKey:@"sendersUserID"],[components objectForKey:@"messageid"],[components objectForKey:@"receiveruserID"],linkID,[components objectForKey:@"groupCounter"],[components objectForKey:@"groupID"],[components objectForKey:@"timestamp"]/* getTimeIntervalFromStringDate]*/]];
    }
    return YES;
}
-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    //NSLog(@"did send messege %@ ",message);
    if ([message isMessageResending])
    {
        
    }else if ([message isChatMessageAsNotification]){
        
    }else if([message isChatMessageWithBody]){
        //		//XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]		                                                         xmppStream:xmppStream		                                               managedObjectContext:[self managedObjectContext_roster]];
        //        NSXMLElement *gup=[message elementForName:@"gup"];
        //        NSString *msgType = [[gup elementForName:@"message_type"] stringValue];
        //        NSString *groupID=[[gup elementForName:@"groupID"]stringValue];
        //        NSString *timestamp=[[gup elementForName:@"TimeStamp"]stringValue];
        //
        //        // timestamp=[timestamp getDateTimeFromTimeInterval];
        //        BOOL isGroup=[[[gup elementForName:@"isgroup"] stringValue] boolValue];
        //        NSString *body = [[gup elementForName:@"body"] stringValue];
        //        NSString *to = [[message attributeForName:@"to"] stringValue];
        //        to=[(NSArray*)[to componentsSeparatedByString:@"/"]objectAtIndex:0 ];
        //        NSString *from = [[message attributeForName:@"from"] stringValue];
        //        from=[(NSArray*)[from componentsSeparatedByString:@"/"]objectAtIndex:0 ];
        //        //NSLog(@"from %@",from);
        //        //	NSString *displayName = [user displayName];
        //
        //        //NSLog(@"from %@ current user %@ ",from,currentUser);
        //
        //        //NSLog(@"received msg %@ body =%@ ",message,body);
        //
        //        //NSLog(@"msgtype %@ msg body %@",msgType,body);
        //        NSString *messageid;
        //        /*  if ([msgType isEqualToString:@"text" ]||[msgType isEqualToString:@"vcard" ])
        //         {    NSArray *e=     [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select id from chat_message where message_text='%@'",body]];
        //         NSLog(@"array %@",e);
        //
        //         if ([e count]==0)
        //         {
        //         [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_message (message_type,message_text,message_filename,message_deleted )VALUES('%@','%@','',0)",msgType,body]];
        //         messageid=[(NSDictionary*)[(NSArray*)[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select MAX(ID) from chat_message"]objectAtIndex:0] objectForKey:@"MAX(ID)" ];
        //         }
        //         else
        //         {
        //         messageid=[(NSDictionary*)[e objectAtIndex:0]objectForKey:@"ID" ];
        //         }
        //
        //
        //         }
        //         else
        //         {  NSArray *e=     [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select id from chat_message where message_text='%@'",body]];
        //         NSLog(@"array %@",e);
        //
        //         if ([e count]==0)
        //         {
        //
        //         [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_message (message_type,message_text,message_filename,message_deleted )VALUES('%@','','%@',0)",msgType,body]];
        //         messageid=[(NSDictionary*)[(NSArray*)[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select MAX(ID) from chat_message"]objectAtIndex:0] objectForKey:@"MAX(ID)" ];
        //         }
        //         else
        //         {messageid=[(NSDictionary*)[e objectAtIndex:0]objectForKey:@"ID" ];
        //         }
        //         }*/
        //        messageid=[self CheckIfMessageExist:[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
        //        if (messageid==nil)
        //            messageid=[self PutMessageInStorage:[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
        //        NSMutableDictionary *ComposedMessaage=[[NSMutableDictionary alloc]init];
        //        [ComposedMessaage setValue:[from userID] forKey:@"sendersUserID"];
        //        [ComposedMessaage setValue:[to userID] forKey:@"receiveruserID"];
        //        [ComposedMessaage setValue:groupID  forKey:@"groupID"];
        //        [ComposedMessaage setValue:timestamp forKey:@"timestamp"];
        //        [ComposedMessaage setValue:messageid forKey:@"messageid"];
        //        [ComposedMessaage setValue:@"0" forKey:@"messageStatus"];
        //        [ComposedMessaage setValue:@"0" forKey:@"pinned"];
        //
        //        //   NSInteger sendersUserID= [[from userID] integerValue];
        //        //   NSInteger receiveruserID=[[to userID]integerValue];
        //        //   NSString *messageid=[(NSDictionary*)[(NSArray*)[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select MAX(ID) from chat_message"]objectAtIndex:0] objectForKey:@"MAX(ID)" ];
        //        //    NSLog(@"max id is %@ my id %i senders Id=%i groupCounter %@",messageid,[myUserID integerValue],sendersUserID,groupCounter);
        //        if (isGroup)
        //        {
        //            if ([[[message attributeForName:@"groupCounter"] stringValue]isEqualToString:@"0"])
        //                //{
        //
        //                //    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_group (group_id,user_id,time_stamp,message_id,pinned,spam,deleted,read)VALUES(%i,%i,'%@',%i,0,0,0,0)",[[groupID userID] integerValue],sendersUserID,[NSString stringWithFormat:@"%@,%@",[NSString CurrentTime],[NSString CurrentDate]],[messageid integerValue]]];
        //
        //                [self PutLinkOfMessageInStorageForType:@"group" withMessageData:ComposedMessaage];
        //            [ComposedMessaage setValue:[[message attributeForName:@"groupCounter"]stringValue ] forKey:@"groupCounter"];
        //            [self storeFailedMessagesForType:@"group" messageComponents:ComposedMessaage];
        //
        //
        //            //}
        //            to=[NSString stringWithFormat:@"user_%@@%@", groupID,jabberUrl];
        //
        //        }
        //
        //        else
        //        {
        //            // [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_personal (user_id,receivers_id,time_stamp,message_id,pinned,spam,deleted,read)VALUES(%i,%i,'%@',%i,0,0,0,0)",sendersUserID,receiveruserID,[NSString stringWithFormat:@"%@,%@",[NSString CurrentTime],[NSString CurrentDate]],[messageid integerValue]]];
        //            [self PutLinkOfMessageInStorageForType:@"personal" withMessageData:ComposedMessaage];
        //            [ComposedMessaage setValue:[[message attributeForName:@"groupCounter"] stringValue] forKey:@"groupCounter"];
        //            [self storeFailedMessagesForType:@"personal" messageComponents:ComposedMessaage];
        //        }
        //        //NSLog(@"flag1 %d , %d flag2 user %@ %@",[[UIApplication sharedApplication] applicationState], UIApplicationStateActive ,currentUser ,to);
        //		if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )
        //		{
        //            // [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"UPDATE chat_personal SET read=1 WHERE id=%i",[messageid integerValue]]];
        //            if ( [[currentUser userID] isEqualToString:[to userID]])
        //                [_messageDelegate newMessageReceived ];
        //            // if ([xmppStream isConnecting])
        //            //[self connect];
        //		}
        //        /*	else
        //         {
        //         // We are not active, so use a local notification instead
        //         UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        //         localNotification.alertAction = @"Ok";
        //         localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
        //
        //         [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        //         }*/
    }
    
    
    
    
}

-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    //message_filename
    
    if([[[message attributeForName:@"type"] stringValue] isEqualToString:@"groupchat"] && [message isMessageWithBody]){
        
        NSXMLElement *gup = [message elementForName:@"gup"];
        @try{
            if(![gup elementForName:@"newpostnotification"]){
                //            double time =[[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
                NSString *likestatus;
                double time = [self getUtcTimeInMilliSecend];
                NSString *updateQue = [NSString stringWithFormat:@"UPDATE Post SET total_comments = total_comments + 1,updated=%.0f WHERE post_id = %@",time,[[gup elementForName:@"postid"] stringValue]];
                [[DatabaseManager getSharedInstance] executeQueryWithQuery:updateQue];
                
                NSString *query=[NSString stringWithFormat:@"UPDATE Post SET is_fav = 1 WHERE post_id = %@ AND is_fav <> 1",[[gup elementForName:@"postid"] stringValue]];
                [[DatabaseManager getSharedInstance] executeQueryWithQuery:query];
                
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_group set messageStatus=1 where id=%@",[[gup elementForName:@"referenceID"] stringValue]]];
                NSString *selectComments = [NSString stringWithFormat:@"SELECT total_comments FROM Post WHERE post_id = %@",[[gup elementForName:@"postid"] stringValue]];
                NSArray *commentArr = [[DatabaseManager getSharedInstance] retrieveDataFromTableWithQuery:selectComments];
                
                NSMutableDictionary *commentDic = [NSMutableDictionary dictionary];
                [commentDic setValue:[[commentArr firstObject] objectForKey:@"TOTAL_COMMENTS"] forKey:@"total_comments"];
                [commentDic setValue:[[gup elementForName:@"groupID"] stringValue] forKey:@"groupid"];
                [commentDic setValue:[[gup elementForName:@"postid"] stringValue] forKey:@"postid"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"commentNotification" object:nil userInfo:commentDic];
                if (  ![currentUser isEqual:@""])
                    [_messageDelegate newMessageReceived];
            }
        }
        @catch (NSException *exception) {
            
        }
    }
    
    if ([[[message attributeForName:@"type"] stringValue] isEqualToString:@"chat"]){
        
        if([message elementForName:@"gup"]){
            NSXMLElement *gup = [message elementForName:@"gup"];
            NSInteger referenceID=[[[gup elementForName:@"referenceID"] stringValue] integerValue];
           [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update .chat_personal  set messageStatus=1 where id=%i",referenceID]];
           [_messageDelegate newMessageReceived];

        }
        
    }
    
}

-(double)getUtcTimeInMilliSecend{
    NSDate *now = [NSDate date];
    NSTimeInterval seconds =  [now timeIntervalSince1970];
    double time = seconds*1000;
    return time;
}
-(void)addFriendWithJid:(NSString*)jid nickName:(NSString*)nickName
{
    //NSLog(@"jid %@ \n name %@",jid,nickName);
    [xmppRoster  addUser:[XMPPJID jidWithString:jid] withNickname:nickName];
}
-(void)removeFriendWithJid:(NSString*)jid
{
    //NSLog(@"jid %@ \n name ",jid);
    [xmppRoster removeUser:[XMPPJID jidWithString:jid]];
}
-(BOOL)CheckIfMessageIsDuplicateFrom:(NSString*)sender ofMessageTime:(NSString*)timestamp isGroupMsg:(BOOL)isGroup{
    NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:isGroup?[NSString stringWithFormat:@"SELECT id from chat_group where orignal_time='%@'",timestamp]:[NSString stringWithFormat:@"SELECT id from chat_personal where time_stamp='%@' AND user_id='%@'",timestamp,sender]];
    if ([output count]==0){
        return false;
    }else{
        return true;
        
    }
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if([[[message elementForName:@"subject"] stringValue] isEqualToString:@"likedata"]){
        //        NSXMLElement *body=[mess  age elementForName:@"body"];
        NSXMLElement *likedata=[message elementForName:@"likedata"];
        if ([[[likedata elementForName:@"userid"] stringValue] intValue]!=[self.myUserID intValue]) {
            
            NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
            
            [json setValue:[[likedata elementForName:@"user"] stringValue] forKey:@"user"];
            [json setValue:[[likedata elementForName:@"userid"] stringValue] forKey:@"userid"];
            [json setValue:[[likedata elementForName:@"likestatus"] stringValue] forKey:@"status"];
            [json setValue:[[likedata elementForName:@"groupid"] stringValue] forKey:@"groupid"];
            [json setValue:[[likedata elementForName:@"postid"] stringValue] forKey:@"postid"];
            [json setValue:[[likedata elementForName:@"updatedTime"] stringValue] forKey:@"updatedTime"];
            
            NSString *query=[NSString stringWithFormat:@"SELECT total_likes from Post WHERE group_id = %d  AND post_id = %d  ",[[json objectForKey:@"groupid"] intValue],[[json objectForKey:@"postid"] intValue]];
            int totalLikes =  [[[[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:query] firstObject] objectForKey:@"TOTAL_LIKES"] intValue];
            
            if( [[json objectForKey:@"status"] caseInsensitiveCompare:@"like"] == NSOrderedSame){
                ++totalLikes;
            }else{
                --totalLikes;
            }
            if(totalLikes>=0){
                
                NSString *update=[NSString stringWithFormat:@"UPDATE Post SET total_likes=%d WHERE post_id = %@",totalLikes,[json objectForKey:@"postid"]];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:update];
                NSString *timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
                [self updateGroupTime:timeInMiliseconds groupid:[[likedata elementForName:@"groupid"] stringValue]];
                
                //                double time =[[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
                
                double time = [self getUtcTimeInMilliSecend];
                NSString *updateTime=[NSString stringWithFormat:@"UPDATE Post SET updated=%.0f WHERE post_id = %@ AND is_fav=1",time,[json objectForKey:@"postid"]];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateTime];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"newCommentNotification" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@ like your post",[[likedata elementForName:@"user"] stringValue]] forKey:@"notificationData"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"likeNotification" object:nil userInfo:json];
                
                
                NSString *selectComments1 = [NSString stringWithFormat:@"SELECT is_fav FROM Post WHERE post_id = %@",[[likedata elementForName:@"postid"] stringValue]];
                NSArray *fav = [[DatabaseManager getSharedInstance] retrieveDataFromTableWithQuery:selectComments1];
                
                int isfav = [[[fav firstObject] objectForKey:@"IS_FAV"] intValue];
                
                if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive && isfav && [[json objectForKey:@"status"] caseInsensitiveCompare:@"like"] == NSOrderedSame){
                    [self generateNotifications:[NSString stringWithFormat:@"%@ like your post",[[likedata elementForName:@"user"] stringValue]]];
                }
            }
        }
        
    }
    
    if([[[message attributeForName:@"type"] stringValue] isEqualToString:@"chat"]){
        
        if ([message isChatMessageAsNotification]){
            NSXMLElement *gup=[message elementForName:@"gup"];
            if (![[[gup elementForName:@"isgroup"] stringValue] boolValue]){
                NSString *displayNo = [[gup elementForName:@"show_notification"] stringValue];
                NSString *displayNo1 = [[gup elementForName:@"is_notify"] stringValue];
                if (displayNo!=(NSString*)[NSNull null]&&[displayNo boolValue]) {
                    //[self generateNotifications:body];
                }
                if (displayNo1!=(NSString*)[NSNull null]&&[displayNo1 boolValue]) {
                    // [self generateNotifications:body];
                }
                if([[[gup elementForName:@"contactUpdate"] stringValue] boolValue]){
                    NSString *userID=[[gup elementForName:@"from_user_id"] stringValue];
                    if(![userID isEqual:Nil])
                        [self getContactInfoWhereUserId:[userID integerValue]];
                }else if ([[[gup elementForName:@"contactDelete"] stringValue] boolValue]){
                    
                    NSString *userID=[[gup elementForName:@"from_user_id"] stringValue];
                    if(![userID isEqual:Nil])
                        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update contacts set user_status='offline' where user_id=%@",userID]];
                    [_chatDelegate buddyStatusUpdated];
                    
                }
            }else{
                
                
                NSString *displayNo = [[gup elementForName:@"show_notification"] stringValue];
                NSString *displayNo1 = [[gup elementForName:@"is_notify"] stringValue];
                NSString *UpdateGroup = [[gup elementForName:@"grpUpdate"] stringValue];
                NSString *deleteGroup = [[gup elementForName:@"grpDelete"] stringValue];
                
                if (displayNo!=(NSString*)[NSNull null]&&[displayNo boolValue]) {
                    // [self generateNotifications:body];
                }
                if (displayNo1!=(NSString*)[NSNull null]&&[displayNo1 boolValue]) {
                    //                      [self generateNotifications:body];
                }
                NSString *groupID=[[gup elementForName:@"groupID"]stringValue];
                
                if (displayNo!=(NSString*)[NSNull null]&&[deleteGroup boolValue]) {
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from groups_public where group_server_id=%@",groupID]];
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from groups_private where group_server_id=%@",groupID]];
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from group_invitations where group_id=%@",groupID]];
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from group_members where group_id=%@",groupID ]];
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from chat_group where group_id=%@",groupID ]];
                    [_chatDelegate buddyStatusUpdated];
                }else if([UpdateGroup boolValue]){
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    NSString *myID=[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"];
                    NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",groupID,[myID userID]];
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_detail_user.php",gupappUrl]]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                    groupInfoConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                    [groupInfoConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [groupInfoConn start];
                    groupInfoResponse = [[NSMutableData alloc] init];
                    [_chatDelegate buddyStatusUpdated];
                    
                }else{
                    
                }
            }
        }
        else if ([message isChatMessageWithBody]){
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSXMLElement *gup=[message elementForName:@"gup"];
                NSString *msgType = [[gup elementForName:@"message_type"] stringValue];
                BOOL isGroup=[[[gup elementForName:@"isgroup"] stringValue] boolValue];
                NSString *groupID=[[gup elementForName:@"groupID"]stringValue];
                NSString *body = [[gup elementForName:@"body"] stringValue];
                NSString *sender_name=@" ",*sender_id=@" ",*senderImage=@" ";
                @try {
                    if([[gup elementsForName:@"from_user_name"] count]>0){
                        
                        NSLog(@"11");
                        sender_name = [[gup elementForName:@"from_user_name"] stringValue];
                    }else{
                        NSLog(@"22");
                        sender_name = @" ";
                    }
                    
                }
                @catch (NSException *exception) {
                    sender_name = @" ";
                }
                @try {
                    if([[gup elementsForName:@"from_user_image"] count]>0){
                        
                        senderImage = [[gup elementForName:@"from_user_image"] stringValue];
                    }else{
                        senderImage = @" ";
                    }
                    
                }
                @catch (NSException *exception) {
                    senderImage = @" ";
                }

                @try {
                    if([[gup elementsForName:@"from_user_id"] count]>0)
                        sender_id = [[gup elementForName:@"from_user_id"] stringValue];
                    else
                        sender_id = @" ";
                }
                @catch (NSException *exception) {
                    sender_id = @" ";
                }
                
                NSString *timestamp=[[gup elementForName:@"TimeStamp"]stringValue]==nil?[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate]:[[gup elementForName:@"TimeStamp"]stringValue];
                //  timestamp=[timestamp getDateTimeFromTimeInterval];
                NSString *to = [[message attributeForName:@"to"] stringValue];
                to=[(NSArray*)[to componentsSeparatedByString:@"/"]objectAtIndex:0 ];
                __block NSString *from = [[message attributeForName:@"from"] stringValue];
                from=[(NSArray*)[from componentsSeparatedByString:@"/"]objectAtIndex:0 ];
                NSString *senderName = [[gup elementForName:@"from_user_name"] stringValue];
//                dispatch_async(dispatch_get_main_queue(), ^{
            
                    if (![[from userID]isEqualToString:myUserID]&&![self CheckIfMessageIsDuplicateFrom:[NSString stringWithFormat:@"%@",[from userID]] ofMessageTime:timestamp isGroupMsg:isGroup]){
                        
                        [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@""];
                        NSString *messageid;
                        
                        NSLog(@"body %@ username %@ found %d",[body uppercaseString],[MyUserName uppercaseString],[[body uppercaseString] rangeOfString:[MyUserName uppercaseString]].location!=NSNotFound);
                        BOOL pinThisMessage=[[body uppercaseString] rangeOfString:[MyUserName uppercaseString]].location!=NSNotFound?1:0;
                        
                        messageid=[self CheckIfMessageExist:[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
                        if (messageid==nil)
                            messageid=[self PutMessageInStorage:[body stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
                        NSMutableDictionary *ComposedMessaage=[[NSMutableDictionary alloc]init];
                        [ComposedMessaage setValue:[from userID] forKey:@"sendersUserID"];
                        [ComposedMessaage setValue:[to userID] forKey:@"receiveruserID"];
                        [ComposedMessaage setValue:groupID  forKey:@"groupID"];
                        [ComposedMessaage setValue:timestamp forKey:@"timestamp"];
                        
                        [ComposedMessaage setValue:senderName forKey:@"sendername"];
                        [ComposedMessaage setValue:messageid forKey:@"messageid"];
                        [ComposedMessaage setValue:@"1" forKey:@"messageStatus"];
                        [ComposedMessaage setValue:senderImage forKey:@"senderimage"];
                        if([[from userID] intValue] == self.chatUserId)
                            [ComposedMessaage setValue:@"1" forKey:@"read"];
                        else
                            [ComposedMessaage setValue:@"0" forKey:@"read"];
                        
                        [ComposedMessaage setValue:[NSString stringWithFormat:@"%i",pinThisMessage] forKey:@"pinned"];
                        
                        NSString *timeInMiliseconds=[[gup elementForName:@"TimeStamp"] stringValue]==nil?[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate]:[[gup elementForName:@"TimeStamp"] stringValue];
                        
                        [ComposedMessaage setValue:timeInMiliseconds forKey:@"orignal_time"];
                        
                        
                        if (isGroup){
                            //[[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_group (group_id,user_id,time_stamp,message_id,pinned,spam,deleted,read)VALUES(%i,%i,'%@',%i,0,0,0,0)",[[groupID userID] integerValue],sendersUserID,[NSString stringWithFormat:@"%@,%@",[NSString CurrentTime],[NSString CurrentDate]],[messageid integerValue]]];
                            if (![self CheckIfMessageIsDuplicateFrom:[[gup elementForName:@"from_user_id"] stringValue] ofMessageTime:[[gup elementForName:@"TimeStamp"] stringValue] isGroupMsg:YES]){
                                
                                [self PutLinkOfMessageInStorageForType:@"group" withMessageData:ComposedMessaage];
                            }
                            
                            from=[NSString stringWithFormat:@"user_%@@%@", groupID,jabberUrl];
                            
                            BOOL memberCheck=[[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"select contact_name  from group_members where contact_id=%@",sender_id]];
                            if (!memberCheck&&![sender_id isEqual:@" "]) {
                                if (![sender_name isEqual:@" "]) {
                                    
                                    
                                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@')",groupID,sender_id,sender_name,@" ",@" "]];
                                }
                                else
                                    [self groupUpdate:groupID];
                            }
                            [_chatDelegate newGroupMessageRe];
                        }else{
                            //  [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into chat_personal (user_id,receivers_id,time_stamp,message_id,pinned,spam,deleted,read)VALUES(%i,%i,'%@',%i,0,0,0,0)",sendersUserID,receiveruserID,[NSString stringWithFormat:@"%@,%@",[NSString CurrentTime],[NSString CurrentDate]],[messageid integerValue]]];
                            [self PutLinkOfMessageInStorageForType:@"personal" withMessageData:ComposedMessaage];
                            NSArray *notificatioData=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select blocked from contacts where user_id=%@",[from userID]]];
                            
                            
                            BOOL showNotification1=![[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"BLOCKED" ForRowIndex:0 givenOutput:notificatioData ] boolValue];
                            if (showNotification1)
                                [_chatDelegate newContactMessageRe];
                            
                        }
                        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive ){
                            if ([[currentUser userID] isEqualToString:[from userID]]){
                                
                                @try {
                                    [_messageDelegate newMessageReceived ];
                                }
                                @catch (NSException *exception) {
                                    
                                }
                                
                            }
                            else
                                [_chatDelegate buddyStatusUpdated];
                            
                        }else{
                            NSString *receiverName;
                            //NSLog(@"%i",isGroup);
                            // We are not active, so use a local notification instead
                            if (isGroup){
                                if([[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"SELECT group_name FROM groups_private where group_server_id=%@",groupID]]){
                                    
                                    NSArray *notificatioData=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT group_name,mute_notification FROM groups_private  where group_server_id=%@",groupID]];
                                    receiverName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"GROUP_NAME" ForRowIndex:0 givenOutput:notificatioData ];
                                    BOOL showNotification=![[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MUTE_NOTIFICATION" ForRowIndex:0 givenOutput:notificatioData ] boolValue];
                                }
                                else if([[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"SELECT group_name FROM groups_public where group_server_id=%@",groupID]])
                                {
                                    NSArray *notificatioData=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT group_name,mute_notification FROM groups_public  where group_server_id=%@",groupID]];
                                    receiverName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"GROUP_NAME" ForRowIndex:0 givenOutput:notificatioData ];
                                    BOOL showNotification=![[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MUTE_NOTIFICATION" ForRowIndex:0 givenOutput:notificatioData ] boolValue];
                                }
                                
                            }
                            if (!isGroup){
                                NSArray *notificatioData=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select user_name,MUTE_NOTIFICATION,blocked from contacts where user_id=%@",[from userID]]];
                                receiverName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_NAME" ForRowIndex:0 givenOutput:notificatioData ];
                                BOOL showNotification=![[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MUTE_NOTIFICATION" ForRowIndex:0 givenOutput:notificatioData ] boolValue];
                                BOOL showNotification1=![[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"BLOCKED" ForRowIndex:0 givenOutput:notificatioData ] boolValue];
                                
                                //receiverName=[(NSDictionary*)[( NSArray*)[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select user_name from contacts where user_id=%@",[from userID]]]objectAtIndex:0] objectForKey:@"USER_NAME"];
                                if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"personalChat"] boolValue]&&showNotification&&showNotification1){
                                    //NSLog(@"rname %@",receiverName);
                                    if (receiverName ==NULL)
                                        [self getContactDataWithNotificationForUserId:from];
                                    else
                                        [self generateNotifications:[NSString stringWithFormat:@"Hey !! You have got a message from %@ ",receiverName]];
                                    
                                }
                                
                            }
                            
                            if ([[currentUser userID] isEqualToString:from])
                                [_messageDelegate newMessageReceived ];
                            else
                                [_chatDelegate buddyStatusUpdated];
                            
                        }
                    }
//                });
                
//            });
            
        }else if([message isAcknoledgment]){
            BOOL isgroup = [[[message attributeForName:@"isGroupAcknolegment"] stringValue] boolValue];
            NSString *messageID = [[message attributeForName:@"message_id"] stringValue];
            
            if (isgroup)
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_group set messageStatus=1 where id=%@",messageID]];
            else
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_personal set messageStatus=2 where id=%@",messageID]];
            if (  ![currentUser isEqual:@""])
                [_messageDelegate newMessageReceived];
            // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self tryResendingMessages];
            // });
        }
    }else if([[[message attributeForName:@"type"] stringValue] isEqualToString:@"groupchat"] && [message isMessageWithBody]){
        
        
        //        NSString *chatData = [[message elementForName:@"body"] stringValue];
        //        NSData *data = [chatData dataUsingEncoding:NSUTF8StringEncoding];
        
        //         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @try {
            //            NSError *err = nil;
            //            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];//message sendername id
            
            NSXMLElement *gup = [message elementForName:@"gup"];
            if([gup elementForName:@"newpostnotification"]){
                NSString *userid = [[gup elementForName:@"userid"] stringValue];
                if([userid intValue] != [self.myUserID intValue]){
                    //                    NSString *selectComments1 = [NSString stringWithFormat:@"SELECT is_fav FROM Post WHERE post_id = %@",[[gup elementForName:@"postid"] stringValue]];
                    //                    NSArray *fav = [[DatabaseManager getSharedInstance] retrieveDataFromTableWithQuery:selectComments1];
                    //                    int isfav = [[[fav firstObject] objectForKey:@"IS_FAV"] intValue];
                    
                    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive){
                        
                        [self generateNotifications:[NSString stringWithFormat:@"You have received a post in group %@",[[gup elementForName:@"groupname"] stringValue]]];
                        
                    }else{
                        NSDictionary *postdic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[gup elementForName:@"groupid"] stringValue],[[gup elementForName:@"postid"] stringValue], nil] forKeys:[NSArray arrayWithObjects:@"groupid",@"postid", nil]];
                        
                        NSString *timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
                        [self updateGroupTime:timeInMiliseconds groupid:[[gup elementForName:@"groupid"] stringValue]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"newpostnotification" object:nil userInfo:postdic];
                        
                    }
                }
                
            }else{
                NSString *senderID = [[gup elementForName:@"from_user_id"] stringValue];
                //                NSString *senderGroupID = [[gup elementForName:@"groupID"] stringValue];
                
                if([senderID intValue] != [self.myUserID intValue]){
                    //                    double time =[[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
                    
                    //update total comment on post
                    NSString *senderImage=@" ";
                    if([gup elementForName:@"from_user_image"])
                         senderImage = [[gup elementForName:@"from_user_image"] stringValue];
                    
                    NSString *chatMessage = [[gup elementForName:@"body"] stringValue];
                    NSString *senderName = [[gup elementForName:@"from_user_name"] stringValue];
                    NSString *msgType = [[gup elementForName:@"message_type"] stringValue];
                    NSString *timeInMiliseconds=[[gup elementForName:@"TimeStamp"] stringValue]==nil?[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate]:[[gup elementForName:@"TimeStamp"] stringValue];
                    NSString *senderGroupID = [[gup elementForName:@"groupID"] stringValue];
                    if (![self CheckIfMessageIsDuplicateFrom:[NSString stringWithFormat:@"%@",senderID] ofMessageTime:timeInMiliseconds isGroupMsg:YES]){
                        
                        NSString *updateQue = [NSString stringWithFormat:@"UPDATE Post SET total_comments = total_comments + 1 WHERE post_id = %@",[[gup elementForName:@"postid"] stringValue]];
                        [[DatabaseManager getSharedInstance] executeQueryWithQuery:updateQue];
                        //update time if fav =1
                        double time = [self getUtcTimeInMilliSecend];
                        NSString *selectComments1 = [NSString stringWithFormat:@"SELECT is_fav FROM Post WHERE post_id = %@",[[gup elementForName:@"postid"] stringValue]];
                        NSArray *fav = [[DatabaseManager getSharedInstance] retrieveDataFromTableWithQuery:selectComments1];
                        
                        int isfav = [[[fav firstObject] objectForKey:@"IS_FAV"] intValue];
                        NSString *updateTimeQue = [NSString stringWithFormat:@"UPDATE Post SET updated = %.0f WHERE post_id = %@ AND is_fav=1",time,[[gup elementForName:@"postid"] stringValue]];
                        [[DatabaseManager getSharedInstance] executeQueryWithQuery:updateTimeQue];
                        
                        NSString *selectComments = [NSString stringWithFormat:@"SELECT total_comments FROM Post WHERE post_id = %@",[[gup elementForName:@"postid"] stringValue]];
                        NSArray *commentArr = [[DatabaseManager getSharedInstance] retrieveDataFromTableWithQuery:selectComments];
                        
                        NSMutableDictionary *commentDic = [NSMutableDictionary dictionary];
                        [commentDic setValue:[[commentArr firstObject] objectForKey:@"TOTAL_COMMENTS"] forKey:@"total_comments"];
                        [commentDic setValue:[[gup elementForName:@"groupID"] stringValue] forKey:@"groupid"];
                        [commentDic setValue:[[gup elementForName:@"postid"] stringValue] forKey:@"postid"];
                        
                        NSString *timeInMiliseconds1 =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
                        [self updateGroupTime:timeInMiliseconds1 groupid:[[gup elementForName:@"groupID"] stringValue]];
                        
                        BOOL pinThisMessage=[[chatMessage uppercaseString] rangeOfString:[senderName uppercaseString]].location!=NSNotFound?1:0;
                        
                        NSString *messageid;
                            messageid=[self CheckIfMessageExist:[chatMessage stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
                        if (messageid==nil)
                            messageid=[self PutMessageInStorage:[chatMessage stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] ofMessageType:msgType];
                        
                        NSMutableDictionary *ComposedMessaage=[[NSMutableDictionary alloc]init];
                        [ComposedMessaage setValue:senderID forKey:@"sendersUserID"];
                        [ComposedMessaage setValue:[[[[self.myjid componentsSeparatedByString:@"@"] firstObject] componentsSeparatedByString:@"_"] lastObject] forKey:@"receiveruserID"];
                        [ComposedMessaage setValue:senderGroupID  forKey:@"groupID"];
                        
                        [ComposedMessaage setValue:timeInMiliseconds forKey:@"orignal_time"];
                        [ComposedMessaage setValue:timeInMiliseconds forKey:@"timestamp"];
                        [ComposedMessaage setValue:messageid forKey:@"messageid"];
                        [ComposedMessaage setValue:@"1" forKey:@"messageStatus"];
                        [ComposedMessaage setValue:senderName forKey:@"sendername"];
                        [ComposedMessaage setValue:[NSString stringWithFormat:@"%i",pinThisMessage] forKey:@"pinned"];
                        [ComposedMessaage setValue:[[gup elementForName:@"postid"] stringValue] forKey:@"postid"];
                        [ComposedMessaage setValue:senderImage forKeyPath:@"senderimage"];
                        
                        [self PutLinkOfMessageInStorageForType:@"group" withMessageData:ComposedMessaage];
                        NSArray *notificatioData=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT group_name,mute_notification FROM groups_public  where group_server_id=%@",senderGroupID]];
                        if(notificatioData.count==0){
                            notificatioData=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT group_name,mute_notification FROM groups_private  where group_server_id=%@",senderGroupID]];
                        }
                        NSString* receiverName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"GROUP_NAME" ForRowIndex:0 givenOutput:notificatioData ];
                        [commentDic setValue:receiverName forKey:@"groupName"];
                        BOOL showNotification=![[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"MUTE_NOTIFICATION" ForRowIndex:0 givenOutput:notificatioData ] boolValue];
                        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive ){
                            if (isfav && showNotification){
                                [self generateNotifications:[NSString stringWithFormat:@"You have received a comment from the group %@",receiverName]];
                                // [_chatDelegate newGroupMessageRe];
                            }
                            
                        }else{
                            [_chatDelegate newGroupMessageRe];
                            
                            //                            if ( ![currentUser isEqual:@""] && _messageDelegate!=nil && [_messageDelegate respondsToSelector:@selector(UpdateScreen)]){
                            @try {
                                [_messageDelegate postUpdate:[[gup elementForName:@"postid"] stringValue] messageID:messageid groupID:senderGroupID];
                                [self.chatTableUpdate reloadTable:senderGroupID];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"commentNotification" object:nil userInfo:commentDic];
                            }
                            @catch (NSException *exception) {
                                
                            }
                            //                            }
                        }
                        
                        BOOL memberCheck=[[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"select contact_name from group_members where contact_id=%@",senderID]];
                        if (!memberCheck&&![senderID isEqual:@" "]){
                            if (![senderName isEqual:@" "]) {
                                
                                //                       [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, contact_name, contact_location,contact_image)values('%@','%@','%@','%@','%@')",senderGroupID,senderID,senderName,@" ",@" "]];
                            }else{
                                [self groupUpdate:senderGroupID];
                            }
                        }
                        
                    }
                    //                        });
                    
                    
                    
                    //                [self.chatDelegate1 updateChatView:JSON];
                }
                
                
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Message error");
        }
        //              });
        
    }
    
    if([message elementForName:@"x"]){
        
        NSArray *xArray = [message elementsForName:@"x"];
        if(xArray.count>1){
            NSXMLElement *x = [xArray firstObject];
            //            for (NSXMLElement *x in xArray) {
            if([x elementForName:@"invite"]){
                NSXMLElement *x1 = [xArray lastObject];
                NSString *roomjid = [[x1 attributeForName:@"jid"] stringValue];
                NSString *to = [[message attributeForName:@"from"] stringValue];
                /*accept invitation*/
                XMPPPresence *presence = [XMPPPresence presenceWithType:nil to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@/%@",to,[[_myjid componentsSeparatedByString:@"@"] firstObject]]]];
                [presence addAttributeWithName:@"from" stringValue:self.myjid];
                NSXMLElement *xe = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
                [presence addChild:xe];
                NSLog(@"%@",presence);
                
                NSString *groupID =[[[[roomjid componentsSeparatedByString:@"@"] firstObject] componentsSeparatedByString:@"_"] lastObject];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from groups_public where group_server_id=%@",groupID]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from groups_private where group_server_id=%@",groupID]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from group_invitations where group_id=%@",groupID]];
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"delete from group_members where group_id=%@",groupID ]];
                [self.xmppStream sendElement:presence];
                [_chatDelegate buddyStatusUpdated];
            }
            //            }
        }
    }
    
}


//-(void)generateNotification{
//    UIUserNotificationAction *openAction = [UIUserNotificationAction foregroundActionWithIdentifier:@"open_action" title:@"Open with alert 😉"];
//    UIUserNotificationAction *deleteAction = [UIUserNotificationAction backgroundDestructiveActionWithIdentifier:@"delete_action" title:@"Delete 😱" authenticationRequired:YES];
//    UIUserNotificationAction *okAction = [UIUserNotificationAction backgroundActionWithIdentifier:@"ok_action" title:@"Ok 👍" authenticationRequired:NO];
//
//    UIUserNotificationCategory *userNotificationCategory = [UIUserNotificationCategory categoryWithIdentifier:@"default_category" defaultActions:@[openAction, deleteAction, okAction] minimalActions:@[okAction, deleteAction]];
//
//    UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAll categoriesArray:@[userNotificationCategory]];
//
//    [application registerUserNotificationSettings:userNotificationSettings];
//        UILocalNotification *localNotification = UILocalNotification.new;
//        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
//        localNotification.alertBody = @"You've closed me?!? 😡";
//        localNotification.alertAction = @"Open 😉";
//        localNotification.category = @"default_category";
//        [application scheduleLocalNotification:localNotification];

//}



-(void)getContactDataWithNotificationForUserId:(NSString*)userId{
    
    NSMutableURLRequest *urlRequest=[[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@",userId];
    [urlRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/member_detail.php",gupappUrl]]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if ([data length] >0 && error == nil)
         {
             //NSLog(@"====EVENTS");
             
             NSString *str = [[NSMutableString alloc] initWithData:data encoding:NSASCIIStringEncoding];
             
             //NSLog(@"Response:%@",str);
             //[activityIndicator stopAnimating];
             //[activityIndicator setHidden:YES];
             //[freezer setHidden:YES];
             
             SBJSON *jsonparser=[[SBJSON alloc]init];
             //NSLog(@"====EVENTS==1");
             NSDictionary *res= [jsonparser objectWithString:str];
             //NSLog(@"====EVENTS==2");
             
             NSDictionary *results = res[@"response"];
             //NSLog(@"results: %@", results);
             NSDictionary *userDetails=results[@"User_Details"];
             
             //NSLog(@"user count %i",[userDetails count]);
             if ([userDetails count]==0 ){
                 
                 //   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""        message:@"User not registered"                                                                                               delegate:self                        cancelButtonTitle:@"OK"                   otherButtonTitles:nil];
                 //    [alert show];
             }else{
                 
                 //NSLog(@"====EVENTS==3 %@",res);
                 NSString *contactId = userDetails[@"id"];
                 NSString *memName = userDetails[@"display_name"];
                 NSString *location = userDetails[@"location_name"];
                 NSString *memberPic = userDetails[@"profile_pic"];
                 NSString *emailID=userDetails[@"valid"];
                 //NSLog(@"member id: %@",contactId);
                 //NSLog(@"name: %@",name);
                 //NSLog(@"location: %@",location);
                 //NSLog(@"display pic: %@",memberPic);
                 
                 
                 //NSLog(@"selected%@,%@,%@,%@,%@,%@",contactId,@"",memName,memberPic,@"offline",location);
                 if (![[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"SELECT * FROM contacts where user_id=%@",contactId]]){
                     NSString *insertQuery=[NSString stringWithFormat:@"insert into contacts (user_id, user_email, user_name, user_pic, user_status,user_location) values ('%@','%@','%@','%@','%@','%@')",contactId,emailID,[memName  normalizeDatabaseElement],memberPic,@"online",location];
                     //NSLog(@"query %@",insertQuery);
                     //   [DatabaseManager getSharedInstance]executeQueryWithQuery:@"delete from contacts where "
                     [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
                     
                     //  [self generateNotifications:[NSString stringWithFormat:@"Hey !! You have got a message from %@ ",name]];
                 }
                 else
                 {
                     [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update contacts set user_email='%@' , user_name='%@'  ,user_pic='%@' ,  user_status='%@', user_location='%@', deleted='0' where user_id=%@ ",emailID,[memName normalizeDatabaseElement],memberPic,@"online",location,contactId]];
                 }
                 [self generateNotifications:[NSString stringWithFormat:@"Hey !! You have got a message from %@ ",name]];
                 NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set contact_name ='%@', contact_location ='%@', contact_image='%@' where contact_id = '%@'",[memName normalizeDatabaseElement],location,memberPic,contactId];
                 
                 //NSLog(@"query %@",updateMembers);
                 
                 [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                 
                 
                 //download image and save in the cache
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                     //NSLog(@"path %@",[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,memberPic]);
                     NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,memberPic]]];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         //cell.imageView.image = [UIImage imageWithData:imgData];
                         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                         //NSLog(@"paths=%@",paths);
                         NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",memberPic]];
                         //NSLog(@"conatct pic path=%@",contactPicPath);
                         //imageData=UIImageJPEGRepresentation(groupPic.image, 1);
                         //Writing the image file
                         [imgData writeToFile:contactPicPath atomically:YES];
                         [_chatDelegate buddyStatusUpdated];
                         
                     });
                     
                 });
                 
                 
                 // [_chatDelegate buddyStatusUpdated];
             }
             
             
         }
         else if ([data length] == 0 && error == nil)
         {
             //NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil){
             //NSLog(@"Error = %@", error);
         }
         
     }];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == contactDetailConn) {
        
        [contactDetailResponse setLength:0];
        
    }
    if (connection == loginDetailsConn) {
        
        [loginDetails setLength:0];
        
    }
    if (connection == groupInfoConn) {
        
        [groupInfoResponse setLength:0];
        
    }
    if (connection==updateUser) {
        [updateResponce setLength:0];
    }
    if (connection==getdeviceToken) {
        [getDeviceTokenResponc setLength:0];
    }
    if (connection== getUTCtime)
    {
        [getUTCtimeResponce setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    //NSLog(@"did recieve data");
    if (connection == getdeviceToken) {
        
        [getDeviceTokenResponc appendData:data];
        
    }
    if (connection == groupInfoConn) {
        
        [groupInfoResponse appendData:data];
        
    }
    if (connection == contactDetailConn) {
        
        [contactDetailResponse appendData:data];
        
    }
    if (connection == loginDetailsConn) {
        
        [loginDetails appendData:data];
        
    }
    if (connection==updateUser)
    {
        [updateResponce appendData:data];
    }
    if (connection== getUTCtime)
    {[getUTCtimeResponce appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == contactDetailConn) {
        
        //     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        //   [alert show];
    }
    if (connection== getdeviceToken) {
        
    }
    if (connection == loginDetailsConn) {
        
        //   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        // [alert show];
    }
    if (connection==updateUser)
    {NSLog(@"update user");
        [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
    }
    if (connection== getUTCtime)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        
        [alert show];
        getUTCtime=nil;
        
        if (  ![currentUser isEqual:@""]&&_messageDelegate!=nil&&previousTimeDifferance!=0.0000)
        {
            [_messageDelegate freezerRemove];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //NSLog(@" finished loading");
    if (connection== getUTCtime)
    {
        NSString *str = [[NSMutableString alloc] initWithData:getUTCtimeResponce encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *responce  = [jsonparser objectWithString:str];
        NSDictionary *res=[responce objectForKey:@"final_array"];
        if (getUTCtimeResponce != nil)
        {
            
            @try {
                //NSLog(@"utc time %f",timestamp+offset );
                // NSDate * currDate = [NSDate dateWithTimeIntervalSince1970: timestamp+offset];
                //  NSLog (@ " date is:%@", [currDate description]);
                
                double timestamp=[[res objectForKey:@"timestamp"] doubleValue];
                double offset=[[res objectForKey:@"gmtOffset"] doubleValue];
                
                NSLog(@"utc time %f",(timestamp-offset)*1000 );
                double ServerTimeStamp=(timestamp-offset)*1000;
                NSLog(@"get utc forma%@",[NSString getCurrentUTCFormateDate]);
                NSLog(@"get utc forma%@",[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate]);
                double AppTimeStamp= [[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
                double timeDifferance=AppTimeStamp-ServerTimeStamp;
                [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",timeDifferance] forKey:@"TimeDifferance"];
                NSLog(@"time %f mimn %f",fabs(ServerTimeStamp-AppTimeStamp),fabs(ServerTimeStamp-AppTimeStamp)*0.001);
                NSLog(@"get utc forma%@",[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate]);
                if(fabs(AppTimeStamp -ServerTimeStamp )>903333)
                {
                    //   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please set the correct device time"   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    
                    //  [alert show];
                }
                if (  ![currentUser isEqual:@""]&&_messageDelegate!=nil)
                {
                    [_messageDelegate freezerRemove];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"try again");
                [self get_UTC_Time];
            }
            
            //  NSString * tempString = [NSString stringWithUTF8String: [data bytes]];
            //  NSDate * currDate = [NSDate dateWithTimeIntervalSince1970: [tempString doubleValue]];
            //  NSLog (@ "String returned from the site is:%@ and date is:%@", tempString, [currDate description]);
            
        }
        else {
            NSLog (@ "nsdata download failed");
            [self get_UTC_Time];
        }
        getUTCtime=nil;
        getDeviceTokenResponc=nil;
    }if (connection==getdeviceToken){  //NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:getDeviceTokenResponc encoding:NSASCIIStringEncoding];
        
        //NSLog(@"Response:%@",str);
        //[activityIndicator stopAnimating];
        //[activityIndicator setHidden:YES];
        //[freezer setHidden:YES];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        //NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        if([results[@"status"] boolValue])
        {
            NSDictionary *deviceData=results[@"device"];
            if ([deviceData[@"deviceToken"] isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]]) {
                [self checkAuthenticityOfCurrentUser];
            }
            else
            {
                //                [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
                //                [self goOffline ];
                //                [self disconnect];
                //                [self setLoginView];
                [self checkAuthenticityOfCurrentUser];
            }
        }else{
            [self checkAuthenticityOfCurrentUser];
            
            //            [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
            //            [self goOffline ];
            //            [self disconnect];
            //            [self setLoginView];
        }
        
        
        
    }
    if (connection == contactDetailConn) {
        
        //NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:contactDetailResponse encoding:NSASCIIStringEncoding];
        
        //NSLog(@"Response:%@",str);
        //[activityIndicator stopAnimating];
        //[activityIndicator setHidden:YES];
        //[freezer setHidden:YES];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        //NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        //NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        //NSLog(@"results: %@", results);
        NSDictionary *userDetails=results[@"User_Details"];
        
        //NSLog(@"user count %i",[userDetails count]);
        if ([userDetails count]==0 )
        {
            
            //   UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""        message:@"User not registered"                                                                                               delegate:self                        cancelButtonTitle:@"OK"                   otherButtonTitles:nil];
            //    [alert show];
        }
        else
        {
            
            //NSLog(@"====EVENTS==3 %@",res);
            NSString *contactId = userDetails[@"id"];
            NSString *memName = userDetails[@"display_name"];
            NSString *location = userDetails[@"location_name"];
            NSString *memberPic = userDetails[@"profile_pic"];
            NSString *emailID=userDetails[@"valid"];
            //NSLog(@"member id: %@",contactId);
            //NSLog(@"name: %@",name);
            //NSLog(@"location: %@",location);
            //NSLog(@"display pic: %@",memberPic);
            
            
            //NSLog(@"selected%@,%@,%@,%@,%@,%@",contactId,@"",memName,memberPic,@"offline",location);
            if (![[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"SELECT * FROM contacts where user_id=%@",contactId]]){
                NSString *insertQuery=[NSString stringWithFormat:@"insert into contacts (user_id, user_email, user_name, user_pic, user_status,user_location) values ('%@','%@','%@','%@','%@','%@')",contactId,emailID,[memName  normalizeDatabaseElement],memberPic,@"online",location];
                //NSLog(@"query %@",insertQuery);
                //   [DatabaseManager getSharedInstance]executeQueryWithQuery:@"delete from contacts where "
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertQuery];
                //  [self generateNotifications:[NSString stringWithFormat:@"Hey !! You have got a message from %@ ",name]];
            }else{
                [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update contacts set user_email='%@' , user_name='%@'  ,user_pic='%@' ,  user_status='%@', user_location='%@', deleted='0' where user_id=%@ ",emailID,[memName normalizeDatabaseElement],memberPic,@"online",location,contactId]];
            }
            
            NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set contact_name ='%@', contact_location ='%@', contact_image='%@' where contact_id = '%@'",[memName normalizeDatabaseElement],location,memberPic,contactId];
            
            //NSLog(@"query %@",updateMembers);
            
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
            
            
            //download image and save in the cache
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                //NSLog(@"path %@",[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,memberPic]);
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,memberPic]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    //NSLog(@"paths=%@",paths);
                    NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",memberPic]];
                    //NSLog(@"conatct pic path=%@",contactPicPath);
                    //imageData=UIImageJPEGRepresentation(groupPic.image, 1);
                    //Writing the image file
                    [imgData writeToFile:contactPicPath atomically:YES];
                    [_chatDelegate buddyStatusUpdated];
                    
                });
                
            });
            
            
            // [_chatDelegate buddyStatusUpdated];
        }
        contactDetailConn=nil;
        
        [contactDetailConn cancel];
        // [_chatDelegate buddyStatusUpdated];
    }
    else if (connection == groupInfoConn) {
        
        //NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:groupInfoResponse encoding:NSASCIIStringEncoding];
        
        //NSLog(@"Response:%@",str);
        //NSLog(@"end connection");
        @try{
            SBJSON *jsonparser=[[SBJSON alloc]init];
            //NSLog(@"====EVENTS==1");
            NSDictionary *res= [jsonparser objectWithString:str];
            //NSLog(@"====EVENTS==2");
            
            
            NSDictionary *results = res[@"response"];
            //NSLog(@"results: %@", results);
            NSDictionary *groups=results[@"Group_Details"];
            NSString *status=results[@"status"];
            
            //NSLog(@"status: %@",status);
            //NSLog(@"groups: %@", groups);
            NSDictionary *members=groups[@"member_details"];
            //NSLog(@"members: %@",members);
            NSDictionary *deletedMembers = groups[@"deleted_members"];
            //NSLog(@"deleted members%@",deletedMembers);
            
            //[imageView removeAllObjects];
            if (![status isEqualToString:@"1"])
            {
                
                if ([groups[@"group_type"] isEqual:@"private#local"]||[groups[@"group_type"] isEqual:@"private#global"])
                {
                    
                    NSString *checkIfPrivateGroupExists=[NSString stringWithFormat:@"select * from groups_private where group_server_id=%@",groups[@"id"]];
                    BOOL privateGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPrivateGroupExists];
                    if (privateGroupExistOrNot) {
                        NSString *updateGroup=[NSString stringWithFormat:@"update  groups_private set group_server_id = '%@', created_on = '%@', created_by = '%@', group_name ='%@', group_pic ='%@', category_name='%@', group_type='%@', total_members='%d', group_description='%@' where group_server_id = '%@' ",groups[@"id"],groups[@"creation_date"], groups[@"admin"],[groups[@"group_name"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"group_pic"],groups[@"category_name"],groups[@"group_type"],[members count]-[deletedMembers count],[groups[@"group_description"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"],groups[@"id"]];
                        //NSLog(@"query %@",updateGroup);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateGroup];
                    }
                    else
                    {
                        NSString *insertGroup=[NSString stringWithFormat:@"insert into groups_private (group_server_id, created_on, created_by, group_name, group_pic, category_name,group_type,total_members,group_description) values ('%@','%@','%@','%@','%@','%@','%@','%d','%@')",groups[@"id"],groups[@"creation_date"], groups[@"admin"],[groups[@"group_name"] normalizeDatabaseElement],groups[@"group_pic"],groups[@"category_name"],groups[@"group_type"],[members count]-[deletedMembers count],[groups[@"group_description"] normalizeDatabaseElement]];
                        //NSLog(@"query %@",insertGroup);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertGroup];
                        
                        ChatScreen *chatScreen = [[ChatScreen alloc]init];
                        chatScreen.chatType = @"group";
                        chatScreen.chatTitle=[groups[@"group_name"] normalizeDatabaseElement];
                        [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[groups[@"id"] integerValue],(NSString*)jabberUrl]];
                        
                        chatScreen.groupType=groups[@"group_type"] ;
                        if ([chatScreen.chatHistory count]==0)
                            [chatScreen retreiveHistory:nil];
                        currentUser=@"";
                        
                    }
                    
                }
                else
                {
                    NSString *checkIfPublicGroupExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groups[@"id"]];
                    BOOL publicGroupExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfPublicGroupExists];
                    if (publicGroupExistOrNot) {
                        NSString *updatePublicGroup=[NSString stringWithFormat:@"update  groups_public set group_server_id = '%@', location_name = '%@', category_name = '%@', added_date ='%@', group_name ='%@', group_type='%@', group_pic='%@', group_description='%@', total_members='%d' where group_server_id = '%@' ",groups[@"id"],groups[@"location_name"],groups[@"category_name"],groups[@"creation_date"],[groups[@"group_name"] normalizeDatabaseElement],groups[@"group_type"],groups[@"group_pic"],[groups[@"group_description"] normalizeDatabaseElement],[members count]-[deletedMembers count],groups[@"id"]];
                        //NSLog(@"query %@",updatePublicGroup);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updatePublicGroup];
                    }
                    else
                    {
                        
                        NSString *insertPublicGroup=[NSString stringWithFormat:@"insert into groups_public (group_server_id, location_name, category_name, added_date, group_name,group_type, group_pic,group_description,total_members) values ('%@','%@','%@','%@','%@','%@','%@','%@','%d')",groups[@"id"],groups[@"location_name"],groups[@"category_name"],groups[@"creation_date"],[groups[@"group_name"] normalizeDatabaseElement],groups[@"group_type"],groups[@"group_pic"],[groups[@"group_description"] normalizeDatabaseElement],[members count]-[deletedMembers count]];
                        //NSLog(@"query %@",insertPublicGroup);
                        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertPublicGroup];
                        ChatScreen *chatScreen = [[ChatScreen alloc]init];
                        chatScreen.chatType = @"group";
                        chatScreen.chatTitle=[groups[@"group_name"] normalizeDatabaseElement];
                        [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[groups[@"id"] integerValue],(NSString*)jabberUrl]];
                        
                        chatScreen.groupType=groups[@"group_type"] ;
                        if ([chatScreen.chatHistory count]==0)
                            [chatScreen retreiveHistory:nil];
                        currentUser=@"";
                    }
                    
                    
                }
                if ([members count]==0 )
                {
                    //NSLog(@"no members");
                }
                else
                {
                    for (NSDictionary *member in members)
                    {
                        NSString *checkIfMemberExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@",groups[@"id"],member[@"user_id"]];
                        BOOL memberExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberExists];
                        if (memberExistOrNot) {
                            NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set group_id = '%@', contact_id = '%@', is_admin = '%@', contact_name ='%@', contact_location ='%@', contact_image='%@' ,deleted=0 where group_id = '%@' and contact_id='%@' ",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] normalizeDatabaseElement],member[@"location_name"],member[@"profile_pic"],groups[@"id"],member[@"user_id"]];
                            //NSLog(@"query %@",updateMembers);
                            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                        }
                        else
                        {
                            
                            NSString *insertMembers=[NSString stringWithFormat:@"insert into group_members (group_id, contact_id, is_admin, contact_name, contact_location,contact_image) values ('%@','%@','%@','%@','%@','%@')",groups[@"id"],member[@"user_id"],member[@"is_admin"],[member[@"display_name"] normalizeDatabaseElement],member[@"location_name"],member[@"profile_pic"]];
                            NSLog(@"query %@",insertMembers);
                            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertMembers];
                            //NSLog(@"current user id %@ group[@ids] %@",[currentUser userID] ,groups[@"id"]);
                            if ([[currentUser userID] isEqual:groups[@"id"] ]&&![currentUser isEqualToString:@""])
                                [_messageDelegate getMembersList];
                        }
                        //download image and save in the cache
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,member[@"profile_pic"]]]];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //cell.imageView.image = [UIImage imageWithData:imgData];
                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                //NSLog(@"paths=%@",paths);
                                NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",member[@"profile_pic"]]];
                                //NSLog(@"member pic path=%@",memberPicPath);
                                //Writing the image file
                                [imgData writeToFile:memberPicPath atomically:YES];
                                
                                
                            });
                            
                        });
                        
                        
                    }
                }
                if ([deletedMembers count]==0 ){
                    //NSLog(@"no members");
                }else{
                    //                      NSString *updateMemberQuery=[NSString stringWithFormat:@"update group_members set deleted=0 where group_id=%@  ",groups[@"id"]];
                    //                      NSLog(@"query %@",updateMemberQuery);
                    //                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMemberQuery];
                    for (NSDictionary *deletedMember in deletedMembers){
                        //NSLog(@"deleted user id%@ \n",deletedMember);
                        NSString *checkIfMemberToDeleteExists=[NSString stringWithFormat:@"select * from group_members where group_id=%@ and contact_id=%@",groups[@"id"],deletedMember];
                        BOOL memberToDeleteExistOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfMemberToDeleteExists];
                        
                        if (memberToDeleteExistOrNot) {
                            // NSString *deleteMemberQuery=[NSString stringWithFormat:@"delete from group_members where group_id=%@ and contact_id=%@ ",groups[@"id"],deletedMember];
                            //NSLog(@"query %@",deleteMemberQuery);
                            //[[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteMemberQuery];
                            //NSLog(@"current user id %@ group[@ids] %@",[currentUser userID] ,groups[@"id"]);
                            NSString *updateMemberQuery=[NSString stringWithFormat:@"update group_members set deleted=1 where group_id=%@ and contact_id=%@ ",groups[@"id"],deletedMember];
                            NSLog(@"query %@",updateMemberQuery);
                            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMemberQuery];
                            if ([[currentUser userID] isEqual:groups[@"id"] ])
                                [_messageDelegate getMembersList];
                        }
                        
                    }
                }
                
                //download image and save in the cache
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,groups[@"group_pic"]]]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //cell.imageView.image = [UIImage imageWithData:imgData];
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                        //NSLog(@"paths=%@",paths);
                        NSString *memberPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",groups[@"group_pic"]]];
                        //NSLog(@"member pic path=%@",memberPicPath);
                        //Writing the image file
                        [imgData writeToFile:memberPicPath atomically:YES];
                        
                        
                    });
                    
                });
                
                NSString *grouID=groups[@"id"];
                if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive )              {
                    if ([[currentUser userID] isEqualToString:grouID])
                    {
                        
                        @try{
                            [_messageDelegate UpdateScreen ];
                        }
                        @catch (NSException *exception) {
                            
                        }
                        
                    }
                    
                }
                
            }
            
            groupInfoConn=nil;
            [_chatDelegate buddyStatusUpdated];
            [groupInfoConn cancel];
        }
        @catch (NSException *ff)
        {
            //NSLog(@"exception %@",ff);
        }
    }else if(connection==loginDetailsConn){
        //NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:loginDetails encoding:NSASCIIStringEncoding];
        
        //NSLog(@"Response:%@",str);
        //[activityIndicator stopAnimating];
        //[activityIndicator setHidden:YES];
        //[freezer setHidden:YES];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        //NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        //NSLog(@"====EVENTS==2");
        
        NSDictionary *responce=res[@"response"];
        NSLog(@"login responce %@",responce);
        AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if ([responce[@"status"] isEqualToString:@"1"]){
            UIAlertView *loginError=[[UIAlertView alloc]initWithTitle:Nil message:responce[@"error_message"] delegate:appDelegateObj.viewController1 cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [loginError setTag:55];
            [loginError show];
            
            
        }else if ([responce[@"status"] isEqualToString:@"2"]){
            UIAlertView *loginError=[[UIAlertView alloc]initWithTitle:Nil message:responce[@"error_message"] delegate:appDelegateObj.viewController1 cancelButtonTitle:@"OK" otherButtonTitles:@"Resend E-mail", nil];
            [loginError dismissWithClickedButtonIndex:1 animated:NO];
            [loginError setTag:55];
            [loginError show];
            //[self setLoginView];
            
        }else if([responce[@"status"] isEqualToString:@"0"]){
            //NSLog(@"responce %@",responce);
            NSString *displayPic=[responce[@"display_pic_300"] isEqual:[NSNull null]]?@"":responce[@"display_pic_300"];
            BOOL email_verified=[responce[@"email_verified"] isEqual:[NSNull null]]?0:[responce[@"email_verified"]integerValue];
            int locationID=[responce[@"location_id"] isEqual:[NSNull null]]?0:[responce[@"location_id"] integerValue ];
            NSString *locationName=[responce[@"location_name"] isEqual:[NSNull null]]?@"":responce[@"location_name"];
            NSString *about_us=[responce[@"about_us"] isEqual:[NSNull null]]?@"":responce[@"about_us"];
            int userID=[responce[@"logged_in_user_id"] isEqual:[NSNull null]]?0:[responce[@"logged_in_user_id"]integerValue];
            // int status=[responce[@"user_status"] isEqual:[NSNull null]]?0:[responce[@"user_status"]integerValue];
            NSString *userName=[responce[@"user_name"] isEqual:[NSNull null]]?@"":responce[@"user_name"];
            int verify_days=[responce[@"verify_days"] isEqual:[NSNull null]]?0:[responce[@"verify_days"]integerValue];
            
            [[DatabaseManager getSharedInstance] executeQueryWithQuery:[NSString stringWithFormat:@"update master_table set display_pic='%@' ,verified=%i ,location_id=%i  ,   location='%@', logged_in_user_id=%i,display_name='%@' ,last_logged_in='%@',about_us='%@' where id=1",displayPic,email_verified,locationID,locationName,userID,[userName normalizeDatabaseElement],[NSString CurrentDate],about_us]];
            
            if (!email_verified){
                UIAlertView *verifyNoti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"Verification Pending,Verification Link will Expire in %i Days",verify_days] delegate:appDelegateObj.viewController1 cancelButtonTitle:@"OK" otherButtonTitles:@"Resend Email", nil];
                [verifyNoti setTag:66];
                [verifyNoti show];
            }
            
            NSString *deviceStatus=responce[@"device_status"];
            if ([deviceStatus boolValue]){
                
//                UIAlertView *verifyNoti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"You are logged in from another device. Continue ?"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
//                [verifyNoti setTag:77];
//                [verifyNoti show];
                
                
            }
            
        }
        
        
    }
    
    
    if (connection==updateUser){
        //NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:updateResponce encoding:NSASCIIStringEncoding];
        //NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        //NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        //NSLog(@"====EVENTS==2");
        
        //NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        //NSLog(@"vishals responce %@",responce);
        if ([responce[@"status"] boolValue])
        {
            
            
        }
        
        
        
        
    }
    
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==77){
        if (buttonIndex==0){
            //            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            //            //NSLog(@"d i %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
            //            NSString *postData = [NSString stringWithFormat:@"deviceToken=%@&deviceType=2&user_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"],[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]];
            //            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_device_token.php",gupappUrl]]];
            //            [request setHTTPMethod:@"POST"];
            //            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            //            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            //            updateUser = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            //            [updateUser scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            //            [updateUser start];
            //            updateResponce = [[NSMutableData alloc] init];
            [self UpdateUserDeviceToken];
        }else{
            [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
            [self goOffline ];
            [self disconnect];
            [self setLoginView];
        }
        
        
    }
    //    if (alertView.tag==2)
    //    {
    //        if (buttonIndex == 0)
    //        {
    //            // this is the cancel button
    //        }
    //        else if (buttonIndex == 1)
    //        {
    //            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    //        }
    //    }
}
-(void)getContactInfoWhereUserId:(NSInteger)userid{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"user_id=%i",userid];
    //NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/member_detail.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    contactDetailConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [contactDetailConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [contactDetailConn start];
    contactDetailResponse = [[NSMutableData alloc] init];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    DDLogVerbose(@"%@: %@ ", THIS_FILE, THIS_METHOD);
    if([[[presence elementForName:@"status"] stringValue] isEqualToString:@"like"] && [presence elementForName:@"likedata"]){
        NSXMLElement *likedata = [presence elementForName:@"likedata"];
        if ([[[likedata elementForName:@"userid"] stringValue] intValue]!=[self.myUserID intValue]) {
            
            //            //            NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
            //            //
            //            //            [json setValue:[[likedata elementForName:@"user"] stringValue] forKey:@"user"];
            //            //            [json setValue:[[likedata elementForName:@"userid"] stringValue] forKey:@"userid"];
            //            //            [json setValue:[[likedata elementForName:@"status"] stringValue] forKey:@"status"];
            //            //            [json setValue:[[likedata elementForName:@"groupid"] stringValue] forKey:@"groupid"];
            //            //            [json setValue:[[likedata elementForName:@"postid"] stringValue] forKey:@"postid"];
            //            //            [json setValue:[[likedata elementForName:@"updatedTime"] stringValue] forKey:@"updatedTime"];
            //            //
            //            //            NSString *query=[NSString stringWithFormat:@"SELECT total_likes from Post WHERE group_id = %d  AND post_id = %d  ",[[json objectForKey:@"groupid"] intValue],[[json objectForKey:@"postid"] intValue]];
            //            //            int totalLikes =  [[[[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:query] firstObject] objectForKey:@"TOTAL_LIKES"] intValue];
            //            //
            //            //            if([[json objectForKey:@"status"] isEqualToString:@"like"]){
            //            //                ++totalLikes;
            //            //            }else{
            //            //                --totalLikes;
            //            //            }
            //            //
            //            //            NSString *update=[NSString stringWithFormat:@"UPDATE Post SET updated=%@,total_likes=%d WHERE post_id = %@",[json objectForKey:@"updatedTime"],totalLikes,[json objectForKey:@"postid"]];
            //            //            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:update];
            //            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"likeNotification" object:nil userInfo:json];
        }
    }else{
        
        NSLog(@"presence recieved in appdelegate %@",presence);
        NSString *status=[[presence elementForName:@"status"] stringValue];
        NSString *presenceType = [presence type]; // online/offline
        if([presenceType isEqual:@"unavailable"]&&status==nil)
            status=@"offline";
        NSString *myUsername = [[sender myJID] user];
        NSString *presenceFromUser = [[presence from] user];
        NSString *from = [[presence attributeForName:@"from"] stringValue];
        from=[(NSArray*)[from componentsSeparatedByString:@"/"]objectAtIndex:0 ];
        if(![[[from componentsSeparatedByString:@"_"] firstObject] isEqualToString:@"group"]){
            
            if (![presenceFromUser isEqualToString:myUsername]) {
                
                if ([status isEqualToString:@"online"]||[status isEqualToString:@"offline"]||[status isEqualToString:@"away"]/*||[presenceType isEqualToString:@"unsubcribed"]*/) {
                    
                    //_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"localhost"]];
                    
                    //} else if ([presenceType isEqualToString:@"unavailable"]) {
                    
                    //	[_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"localhost"]];
                    /*  if ([presenceType isEqualToString:@"unsubcribed"])
                     { [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update contacts set user_status='%@' where user_id=%@",@"offline",[presenceFromUser stringByReplacingOccurrencesOfString:@"user_" withString:@""]] ];
                     
                     }
                     else*/
                    [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update contacts set user_status='%@' where user_id=%@",status,[presenceFromUser stringByReplacingOccurrencesOfString:@"user_" withString:@""]] ];
                    //            NSString *a=[[[presence from] user] stringByReplacingOccurrencesOfString:@"user_" withString:@""];
//                    [_chatDelegate refreshChatList];
                    
                    //  [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update contacts set user_status='%@' where user_id=%i",status,[a integerValue]]];
                    
                    if ([currentUser isEqualToString:from] && isUSER){
                        [_messageDelegate updateTitleStatus];
                    }
                }else if([status isEqualToString:@"update"] &&[[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"SELECT * FROM contacts where user_id=%@",[from userID]]] ){
                    
                    if(![[from userID] isEqual:Nil])
                        
                        [self getContactInfoWhereUserId:[[from userID ] integerValue]];
                }else if  ([presenceType isEqualToString:@"subscribe"]){
                    
                    
                    /*  NSMutableDictionary *temp=[[NSMutableDictionary alloc] init];
                     [temp setValue:presence.from forKey:@"from"];
                     [temp setValue:presenceFromUser forKey:@"name"];
                     [pendingRequest addObject:temp ];*/
                    NSArray *unblockedUserData= [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select user_id from contacts where blocked=1"];
                    NSMutableArray *userID=[[NSMutableArray alloc]init];
                    [userID removeAllObjects];
                    for (int user_row=0; user_row<[unblockedUserData count];user_row++){
                        NSString *unblockUser=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_ID" ForRowIndex:user_row givenOutput:unblockedUserData];
                        [userID addObject:unblockUser];
                    }
                    NSString *userid=[[presence.from user] stringByReplacingOccurrencesOfString:@"user_" withString:@""];
                    if (![userID containsObject:userid]){
                        [xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
                        
                    }
                    
                    
                }else if ([presenceType isEqualToString:@"unsubcribed"]){
                }
                
            }
        }
        
        NSString *roomJid = [[presence attributeForName:@"from"] stringValue];
        if([[[presence attributeForName:@"type"] stringValue] isEqualToString:@"error"]){
            
            NSArray *x = [presence elementsForName:@"x"];
            if(x.count>0){
                NSXMLElement *xmlX = [x objectAtIndex:0];
                NSString *as = [xmlX xmlns] ;
                if([as  isEqualToString:@"http://jabber.org/protocol/muc"]&&[[[[presence elementForName:@"error"] attributeForName:@"code"]stringValue] isEqualToString:@"404"]){
                    
                    
                    //            NSString *roomJid = [[presence attributeForName:@"from"] stringValue];
                    //
                    //            XMPPRoomCoreDataStorage *roomMemoryStorage = [XMPPRoomCoreDataStorage sharedInstance];
                    //
                    //            NSString *tojid = [[roomJid componentsSeparatedByString:@"/"] firstObject];
                    //            XMPPJID *roomJID = [XMPPJID jidWithString:tojid];
                    //            XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage jid:roomJID ];
                    //            [xmppRoom activate:self.xmppStream];
                    //            [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
                    //            [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"user_%@",myUserID] history:nil];
                    
                }
            }
            
        }else if([[[roomJid componentsSeparatedByString:@"_"] firstObject] isEqualToString:@"group"]){
            
            NSString *roomid =[[[[[NSString stringWithFormat:@"%@",roomJid] componentsSeparatedByString:@"@"] firstObject] componentsSeparatedByString:@"_"] lastObject];
            
            NSArray *groupUnsendMessages=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select chat_group.id,user_id,time_stamp,message_id,message_type,message_text,message_filename from chat_group INNER  JOIN chat_message where user_id=%@ AND group_id = %@ AND messageStatus=0 AND  message_id=chat_message.id order by chat_group.time_stamp ASC",myUserID,roomid]];
            if(groupUnsendMessages.count>0)
                for (int i=0; i<[groupUnsendMessages count]; i++)   {
                    
                    NSDictionary *row=   [[DatabaseManager getSharedInstance]DatabaseOutputParserRetrieveRowFromRowIndex:i FromOutput:groupUnsendMessages];
                    
                    //        NSMutableDictionary *data = [NSMutableDictionary dictionary];
                    //        NSDictionary *userDictonary = [master_table lastObject];
                    NSString *referance_ID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"CHAT_GROUP.ID" givenRow:row];
                    
                    
                    //        NSString *messageBody=[messageData objectForKey:@"message"];
                    
                    //                if(![[row objectForKey:@"MESSAGE_TYPE"] isEqualToString:@"image"])
                    
                    
                    XMPPMessage *msg = [XMPPMessage message];
                    [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
                    [msg addAttributeWithName:@"groupCounter" integerValue:[@"" integerValue]];
                    [msg addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",[[roomJid componentsSeparatedByString:@"/"] firstObject]]];
                    [msg addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] ];
                    [msg addAttributeWithName:@"isResend" boolValue:[@"1" boolValue]];
                    //        NSString *recieversID=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"RECEIVERS_ID" givenRow:row];
                    [msg addAttributeWithName:@"referenceID" integerValue:[referance_ID integerValue]];
                    
                    NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
                    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:[row objectForKey:@"MESSAGE_TEXT"]];
                    NSXMLElement *referanceID = [NSXMLElement elementWithName:@"referenceID" stringValue:referance_ID];
                    NSXMLElement *from_user_id = [NSXMLElement elementWithName:@"from_user_id" stringValue:[row objectForKey:@"USER_ID"]];
                    NSXMLElement *from_user_name = [NSXMLElement elementWithName:@"from_user_name" stringValue:user_name];
                    NSXMLElement *message_type = [NSXMLElement elementWithName:@"message_type" stringValue:[row objectForKey:@"MESSAGE_TYPE"]];
                    NSXMLElement *timeStamp=[NSXMLElement elementWithName:@"TimeStamp" stringValue:[row objectForKey:@"TIME_STAMP"]];
                    NSXMLElement *postid=[NSXMLElement elementWithName:@"post_id" stringValue:[row objectForKey:@"POST_ID"]];
                    NSXMLElement *groupIDs = [NSXMLElement elementWithName:@"groupID" stringValue:roomid];
                    NSXMLElement *isgroup =[NSXMLElement elementWithName:@"ispost" stringValue:@"1"];
                    
                    [gup addChild:body];
                    [gup addChild:from_user_id];
                    [gup addChild:from_user_name];
                    [gup addChild:timeStamp];
                    [gup addChild:message_type];
                    [gup addChild:postid];
                    [gup addChild:referanceID];
                    [gup addChild:isgroup];
                    [gup addChild:groupIDs];
                    [msg addChild:gup];
                    NSXMLElement *body1 = [NSXMLElement elementWithName:@"body" stringValue:[self getStringFromBody:gup andBody:[row objectForKey:@"MESSAGE_TEXT"]]];
                    [msg addChild:body1];
                    //                if(![[row objectForKey:@"MESSAGE_TEXT"] isEqualToString:@"0"] && ![[row objectForKey:@"MESSAGE_TYPE"] isEqualToString:@"text"]){
                    //                    [xmppStream sendElement:msg];
                    //                }
                    NSLog(@"%@",msg);
                    
                }
        }
        
    }
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"error %@",error);
    NSArray *output=   [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select logged_in_user_id,social_login,social_login_type,social_login_id,email,password from master_table"];
    
    //NSLog(@"output =%@",output);
    
    
    if ([output count]!=0)    {
        NSString *socialLoginType=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_TYPE" ForRowIndex:0 givenOutput:output] ;
        
        NSString *passwordFetched=[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output] ==(NSString*)[NSNull null]?@"":[[DatabaseManager getSharedInstance] DatabaseRowParserRetrieveColumnFromColumnName:@"PASSWORD" ForRowIndex:0 givenOutput:output];
        if (![socialLoginType isEqualToString:@" "]||![passwordFetched isEqualToString:@" "]){
            if(error)
                [self connect];
        }
    }
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"streamDisconnect" object:nil userInfo:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence{
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }else{
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    
}

- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitation:(XMPPMessage *)message{
    
    NSLog(@"%@",message);
    
}
- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitationDecline:(XMPPMessage *)message{
    NSLog(@"%@",message);
}

-(void)updateGroupTime:(NSString*)time groupid:(NSString*)groupId{
    
    NSArray *privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT group_name FROM groups_private WHERE group_server_id = %@",groupId]];
    if (privateGroupList.count) {
        NSString *query2=[NSString stringWithFormat:@"UPDATE groups_private SET updatetime=%@ WHERE group_server_id = %@",time,groupId];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query2];
    }else{
        NSString *query2=[NSString stringWithFormat:@"UPDATE groups_public SET updatetime=%@ WHERE group_server_id = %@",time,groupId];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query2];
    }
   [_chatDelegate newGroupMessageRe];
}

//project SHAN4552 end's

@end