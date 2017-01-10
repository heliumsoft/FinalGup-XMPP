//
//  Login.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "Login.h"
#import "GLoginWebview.h"
#import "HelpViewController.h"
#import "SignUp.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Utils.h"
#import "CreateProfile.h"
#import "JSON.h"
#import "globleData.h"
#import "ChangePassword.h"
#import "ForgotPassword.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
static NSString * const kClientId = @"1049791696445.apps.googleusercontent.com";

@interface Login ()
{
    BOOL status;
    BOOL email_verified;
    BOOL password_Reset;
    NSInteger logged_In_User_Id;
    NSString *error_Message;
    NSInteger noOfDays;
    NSString *verification_Message;
    
    
}

@property (strong, nonatomic) IBOutlet UIButton *buttonLoginLogout,*twitter,*gmail;
@end

@implementation Login
@synthesize SwitchTimer,buttonLoginLogout,signInButton,gmail,twitter,emailId,password;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        emailId=[[UITextField alloc]init];
        // Custom initialization
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self
         
                                                 selector:@selector(keyboardWillShow:)
         
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
         
                                                 selector:@selector(keyboardWillHide:)
         
                                                     name:UIKeyboardWillHideNotification object:nil];
        return self;
        
    }
    return self;
}



-(void)setActivityIndicator
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}

#pragma facebook delegates
-(void)viewDidDisappear:(BOOL)animated
{  AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    appDelegate.rootViewControllerL=nil;
    
}

- (void)updateView {
    
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        
        AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
        [FBSession setActiveSession:appDelegate.session];
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 
                 [self freezerAnimate];
                 // NSLog(@"==username %@",user.name);
                 // NSLog(@"==id %@",user.id);
                 
                 NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                 double tempTime=[[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
                 tempTime=tempTime+[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue];
                 tempTime=tempTime/1000;
                 NSString *postData = [NSString stringWithFormat:@"social_login=1&social_login_type=FACEBOOK&social_login_id=%@&deviceToken=%@&deviceType=2&timestamp=%.0f&versionCode=%@",user.objectID,[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"],tempTime,appVersionString];
                 NSLog(@" post data %@",postData);
                 [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/login_user.php",gupappUrl]]];
                 [request setHTTPMethod:@"POST"];
                 [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                 [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                 
                 NSError *error = nil;
                 NSURLResponse *responce1;
                 [self setActivityIndicator];
                 NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce1 error:&error];
                 //NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                 [self freezerRemove];
                 
                 //NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
                 NSDictionary *dict;
                 @try {
                     dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
                 }
                 @catch (NSException *exception) {
                     NSLog(@"try again");
                 }
                 NSLog(@" return %@",dict);
                 NSDictionary *responce=dict[@"response"];
                 [buttonLoginLogout setUserInteractionEnabled:YES];
                 NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select social_login_id from master_table where id =1"];
                 if ([output count]!=0) {
                     NSString *emailID= [[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_ID" ForRowIndex:0 givenOutput:output];
                     if(![user.id isEqualToString:emailID])
                     {
                         [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from master_table "];
                         [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from blocked_user "];
                         [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_group "];
                         [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_message "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_personal "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from contacts "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_category "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_join_request "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_members "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_private "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_public "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from notify_settings "];
                         [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_invitations "];
                         
                     }
                     
                 }
                 if ([responce[@"time_status" ] boolValue]){
                     
                     UIAlertView *IncorrectTimeNotification=[[UIAlertView alloc]initWithTitle:Nil message:[responce objectForKey:@"time_alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [IncorrectTimeNotification show];
                 }
                 
                 if ([responce objectForKey:@"status"]&&[responce[@"status"] isEqualToString:@"1"]){
                     
                     CreateProfile *obj=[[CreateProfile alloc]init];
                     [obj initCreatePofileWith:@"FACEBOOK" social_Login_ID: user.id];
                     [appDelegate.session closeAndClearTokenInformation];
                     [self.navigationController pushViewController:obj animated:NO];
                 }
                 else if([responce objectForKey:@"status"]&&[responce[@"status"] isEqualToString:@"0"]){
                     
                     NSString *defaultDBPath = @"wallpaper.jpg";
                     int userID=[responce[@"logged_in_user_id"] isEqual:[NSNull null]]?0:[responce[@"logged_in_user_id"]integerValue];
                     NSString *userName=[responce[@"user_name"] isEqual:[NSNull null]]?@"":responce[@"user_name"];
                     NSString *about_us=[responce[@"about_us"] isEqual:[NSNull null]]?@"":responce[@"about_us"];
                     NSString *displayPic=[responce[@"display_pic_300"] isEqual:[NSNull null]]?@"":responce[@"display_pic_300"];
                     NSString *social_login_type=@"FACEBOOK";
                     NSString *social_login_idl_login=user.id;
                     int locationID=[responce[@"location_id"] isEqual:[NSNull null]]?0:[responce[@"location_id"] integerValue ];
                     NSString *locationName=[responce[@"location_name"] isEqual:[NSNull null]]?@"":responce[@"location_name"];
                     [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:@"delete from master_table"] ;
                     
                     [[DatabaseManager getSharedInstance] saveDataInTableWithQuery:[NSString stringWithFormat:@"INSERT INTO master_table (id ,logged_in_user_id,verified, display_name,display_pic,social_login,social_login_type,social_login_id,location_id,location,chat_wall_paper,last_logged_in,version_no,status,about_us) VALUES(%i,%i,1,'%@','%@',1,'%@','%@',%i,'%@','%@','%@',%@,'online','%@')",1,userID,[userName normalizeDatabaseElement],[displayPic normalizeDatabaseElement],social_login_type,[social_login_idl_login normalizeDatabaseElement],locationID,[locationName normalizeDatabaseElement],[defaultDBPath normalizeDatabaseElement],[NSString CurrentDate],appVersionString,about_us]];
                     [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"user_%d@%@",userID,jabberUrl] forKey:@"Jid"];
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                         NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,displayPic]]];
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             //cell.imageView.image = [UIImage imageWithData:imgData];
                             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                             NSLog(@"paths=%@",paths);
                             NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",displayPic]];
                             NSLog(@"conatct pic path=%@",contactPicPath);
                             //Writing the image file
                             [imgData writeToFile:contactPicPath atomically:YES];
                             
                             
                         });
                         
                     });
                     NSString *deviceStatus=responce[@"device_status"];
                     AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                     [appDelegate.session closeAndClearTokenInformation];
                     if ([deviceStatus boolValue]){
                         //[[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
                         userId=[NSString stringWithFormat:@"%i",logged_In_User_Id];
//                         UIAlertView *verifyNoti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"You are logged in from another device. Continue ?"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
//                         [verifyNoti setTag:77];
//                         [verifyNoti show];
                         
                         
                     }else{
                         
                         [appDelegateObj setTabBar];
                         [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
                         [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
                         [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
                         [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
                     }
                     
                 }
             }
             
             NSLog(@"error %@",error);
             
         }];
        
    } else {
        
        
    }
}


- (IBAction)facebook:(id)sender{
    
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    // [buttonLoginLogout setUserInteractionEnabled:NO];
    if (!appDelegate.session.isOpen) {
        if (appDelegate.session.state != FBSessionStateCreated) {
            appDelegate.session = [[FBSession alloc] init];
        }
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            [self freezerAnimate];
            [self updateView];
            
        }];
    }else{
        [self freezerAnimate];
        [self updateView];
    }
}

#pragma twitter Delegates
- (void)storeAccessToken:(NSString *)accessToken {
    
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
    
}
- (NSString *)loadAccessToken {
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
    
}
- (IBAction)showLoginWindow:(id)sender {
    //  [twitter setUserInteractionEnabled:NO];
    [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
        
        NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
        
    }];
    
}




#pragma google+

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{[self freezerAnimate];
    NSLog(@"Received error %@ and auth object %@",error, auth);
    
    if (error) {
        AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegateObj.gpError=error;
        [self freezerRemove];
        // Do some error handling here.
    } else {
        //  _labelFirstName.text = [NSString stringWithFormat:@"Hello %@  ", signIn.authentication.userEmail];
        NSLog(@"user id  ==++= %@", signIn.userID);
        NSLog(@"google plus user ==++= %@", signIn.googlePlusUser);
        
        NSLog(@"user email  === %@", signIn.userEmail);
        if (ii==0&&signIn.userEmail!=nil&&signIn.userID!=nil )
        {
            googlePlusID=[[NSString alloc]init];
            googlePlusID=signIn.userID;
            if (notifyGp.tag!=45)
            {
                notifyGp=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"Do You Want to Sign in as %@",signIn.userEmail] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Different Account", nil];
                [notifyGp setTag:45];
                [notifyGp show];
            }
            else
            {
                
                [self freezerAnimate];
                [self performSelectorInBackground:@selector(useAccount) withObject:nil];
            }
        }
    }
    
}
-(void)useAccount
{
    
}
-(void)gmailLoginOnGupWithUserId:(NSString*)gplusUserId
//-(void)useAccount
{//[self freezerAnimate];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    double tempTime=[[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
    tempTime=tempTime+[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue];
    tempTime=tempTime/1000;
    NSString *postData = [NSString stringWithFormat:@"social_login=1&social_login_type=GOOGLEPLUS&social_login_id=%@&deviceToken=%@&deviceType=2&timestamp=%.0f&versionCode=%@",gplusUserId,[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"],tempTime,appVersionString];
    NSLog(@" post data %@",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/login_user.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    //NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSDictionary *dict;
    @try {
        dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"try again");
    }
    
    
    NSLog(@" return %@",dict);
    NSDictionary *responce=dict[@"response"];
    [gmail setUserInteractionEnabled:YES];
    NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select social_login_id from master_table where id =1"];
    if ([output count]!=0) {
        NSString *emailID= [[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_ID" ForRowIndex:0 givenOutput:output];
        if(![gplusUserId isEqualToString:emailID])
        {
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from master_table "];
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from blocked_user "];
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_group "];
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_message "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_personal "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from contacts "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_category "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_join_request "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_members "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_private "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_public "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from notify_settings "];
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_invitations "];
            
        }
        
    }
    if ([responce[@"time_status" ] boolValue])
    {
        
        
        UIAlertView *IncorrectTimeNotification=[[UIAlertView alloc]initWithTitle:Nil message:[responce objectForKey:@"time_alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [IncorrectTimeNotification show];
    }
    if ([responce objectForKey:@"status"]&&[responce[@"status"] isEqualToString:@"1"])
    {
        CreateProfile *obj=[[CreateProfile alloc]init];
        [obj initCreatePofileWith:@"GOOGLEPLUS" social_Login_ID: gplusUserId];
        [self.navigationController pushViewController:obj animated:NO];
        
    }
    else if([responce objectForKey:@"status"]&&[responce[@"status"] isEqualToString:@"0"])
    { NSString *defaultDBPath = @"wallpaper.jpg";
        
        int userID=[responce[@"logged_in_user_id"] isEqual:[NSNull null]]?0:[responce[@"logged_in_user_id"]integerValue];
        NSString *userName=[responce[@"user_name"] isEqual:[NSNull null]]?@"":responce[@"user_name"];
        NSString *about_us=[responce[@"about_us"] isEqual:[NSNull null]]?@"":responce[@"about_us"];
        NSString *displayPic=[responce[@"display_pic_300"] isEqual:[NSNull null]]?@"":responce[@"display_pic_300"];
        NSString *social_login_type=@"GOOGLEPLUS";
        NSString *social_login_idl_login=gplusUserId;
        int locationID=[responce[@"location_id"] isEqual:[NSNull null]]?0:[responce[@"location_id"] integerValue ];
        NSString *locationName=[responce[@"location_name"] isEqual:[NSNull null]]?@"":responce[@"location_name"];
        [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:@"delete from master_table"] ;
        
        [[DatabaseManager getSharedInstance] saveDataInTableWithQuery:[NSString stringWithFormat:@"INSERT INTO master_table (id ,logged_in_user_id,verified, display_name,display_pic,social_login,social_login_type,social_login_id,location_id,location,chat_wall_paper,last_logged_in,version_no,status,about_us) VALUES(%i,%i,1,'%@','%@',1,'%@','%@',%i,'%@','%@','%@',%@,'online','%@')",1,userID,[userName normalizeDatabaseElement],[displayPic normalizeDatabaseElement],social_login_type,[social_login_idl_login normalizeDatabaseElement],locationID,[locationName normalizeDatabaseElement],[defaultDBPath normalizeDatabaseElement],[NSString CurrentDate],appVersionString,about_us]];
        // NSLog(@"url %@",[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,displayPic]);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,displayPic]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //cell.imageView.image = [UIImage imageWithData:imgData];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSLog(@"paths=%@",paths);
                NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",displayPic]];
                NSLog(@"conatct pic path=%@",contactPicPath);
                //Writing the image file
                [imgData writeToFile:contactPicPath atomically:YES];
                
                
            });
            
        });
        NSString *deviceStatus=responce[@"device_status"];
        
        if ([deviceStatus boolValue])
        {//[[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
            userId=[NSString stringWithFormat:@"%i",logged_In_User_Id];
//            UIAlertView *verifyNoti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"You are logged in from another device. Continue ?"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
//            [verifyNoti setTag:77];
//            [verifyNoti show];
            
            
        }
        else
        {
            AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            
            [appDelegateObj setTabBar];
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
        }
    }
    
    
    
    
    
    [self freezerRemove];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{if (alertView.tag==45)
{
    if (buttonIndex==0)
    {[alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self freezerAnimate];
        [self performSelectorInBackground:@selector(useAccount) withObject:nil];
    }
    if (buttonIndex==1)
    {[self freezerAnimate ];
        //[progress startAnimating];
        [[GPPSignIn sharedInstance] signOut];
        [[GPPSignIn sharedInstance] disconnect];
        [signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
    if (alertView.tag==77){
        
        if (buttonIndex==0){
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSLog(@"d i %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
            NSString *postData = [NSString stringWithFormat:@"deviceToken=%@&deviceType=2&user_id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"],userId];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_device_token.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            updateUser = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [updateUser scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [updateUser start];
            updateResponce = [[NSMutableData alloc] init];
            
        }
        if (buttonIndex==1){
            [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
            [self freezerRemove];
        }
        
    }
}
-(void)freezerAnimate
{
    if (HUD==nil )
    {
        [self setActivityIndicator];
    }
    [HUD setHidden:NO];
}
-(void)freezerRemove
{if(HUD!=nil)
{[HUD setHidden:YES];}
}

- (void)finishedSharingWithError:(NSError *)error {
    if (!error) {
        NSLog(@"Shared succesfully");
    } else if(error.code == kGPPErrorShareboxCanceled) {
        NSLog(@"User cancelled share");
    } else {
        NSLog(@"Unknown share error: %@", [error localizedDescription]);
    }
}




-(void)updateLoginText:(NSString*)EID
{
    [emailId setText:EID];
    
}
- (void) keyboardWillShow:(NSNotification *)notification {
    
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"hei %f wi %f",kbSize.height,kbSize.width);
    float keyBdHeight;
    if (kbSize.height<kbSize.width)
    {
        keyBdHeight=kbSize.height;
    }
    else
    {
        keyBdHeight=kbSize.width;
        
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(00.0, 0.0, keyBdHeight+60, 0.0);
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;
    
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyBdHeight;
    
    if (!CGRectContainsPoint(aRect, TXFRAME.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, TXFRAME.origin.y-keyBdHeight);
        [mainScroll setContentOffset:scrollPoint animated:YES];
    }
    
    
    
}
- (void) keyboardWillHide:(NSNotification *)notification {
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 0.0);
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;
    
}

-(void)plistSpooler
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AppData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: path])
    {
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        NSLog(@"data %@",data);
    }
    else
    {
        
        data = [[NSMutableDictionary alloc] init];
        
        [data setObject:[NSNumber numberWithInt:true] forKey:@"IsSuccesfullRun"];
        //  [data setObject:[NSNumber numberWithInt:false] forKey:@"ChatScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"HomeScreen"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"CreateGroup"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"Location"];
        [data setObject:[NSNumber numberWithInt:false] forKey:@"Explore"];
        // [data setObject:[NSNumber numberWithInt:false] forKey:@"SearchLocation"];
        [data writeToFile: path atomically:YES];
       // [self SplashScreen];
        splashscreen.hidden =YES;
        
    }
    
    
    
    
    
    
    
}


-(void)SplashScreen
{//[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade ];
    splashscreen=[[UIView alloc]initWithFrame:self.view.frame];
    [splashscreen setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [splashscreen setBackgroundColor:[UIColor colorWithRed:21.0f/255.0f green:124.0f/255.0f blue:193.0f/255.0f alpha:1] ];
    // [splashscreen]
    UIImageView *dummyicon=[[UIImageView alloc]initWithFrame:splashscreen.frame];
    [dummyicon setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    // dummyicon.layer.borderWidth=5;
    [dummyicon setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"5"]]];
    //[dummyicon setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    //  [dummyicon sendSubviewToBack:splashscreen];
    [splashscreen addSubview:dummyicon];
    logo=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"GupLOGO.png"]];
    [logo setFrame:CGRectMake(0, 0,self.view.frame.size.width-30 , 200)];
    [logo setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [logo setCenter:self.view.center];
    [splashscreen addSubview:logo];
    [self.view addSubview:splashscreen];
    [self testConnection];
    
    
}







-(void)testConnection
{
    
    [self ProceedNext];
    
}
-(void)ProceedNext
{    logo.alpha  =0;
    [self fadeIn : logo withDuration: 3 andWait : 1 ];
    
    SwitchTimer =[NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(nextview)userInfo:nil repeats:NO];
    
    
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
}


-(IBAction)forgotPassword:(id)sender{
    ForgotPassword *fp=[[ForgotPassword alloc]init];
    [fp SetEmailID:emailId.text from:self];
    [self.navigationController pushViewController:fp animated:YES];
}
- (void)viewDidLoad
{
   // [self plistSpooler];
    statusBarHidden=true;
    appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.signup.layer.cornerRadius = 10.0f;
     self.loginb.layer.cornerRadius = 10.0f;
    loginusing.font = [UIFont fontWithName:@"Dosis-Regular" size:13];
    notamem.font = [UIFont fontWithName:@"Dosis-Regular" size:16];
    [self.signup.titleLabel setFont:[UIFont fontWithName:@"Dosis-Bold" size:16]];
    [self.loginb.titleLabel setFont:[UIFont fontWithName:@"Dosis-Bold" size:16]];
    [forget.titleLabel setFont:[UIFont fontWithName:@"Dosis-Regular" size:14]];
    loginform.backgroundColor = [UIColor clearColor];
    loginform.separatorStyle =UITableViewCellSeparatorStyleNone;
    // loginform.layer.borderWidth=2;
    //mainScroll.layer.borderWidth=1;
    //  [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [super viewDidLoad];
    // [self updateView];
    
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        appDelegate.session = [[FBSession alloc] init];
        
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            [appDelegate.session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                [self updateView];
            }];
        }
    }
    
    
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"vcWbLICVScAoqiLT186QjQ" andSecret:@"xiA0N9JIuCv3VAmVCgjOgFuHnU7RXwn1Jg2xqrG6k"];
    
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserID = YES;
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    signIn.scopes = [NSArray arrayWithObjects: kGTLAuthScopePlusLogin, // defined in GTLPlusConstants.h
                     nil];
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    
    password.secureTextEntry=YES;
    self.view.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0];
    mainScroll.scrollEnabled=true;
    mainScroll.showsVerticalScrollIndicator=true;
    NSLog(@"scroll frame %f %f %f %f",mainScroll.frame.origin.x,mainScroll.frame.origin.y,mainScroll.frame.size.width,mainScroll.frame.size.height);
    [mainScroll setContentSize:CGSizeMake(mainScroll.frame.size.width,mainScroll.frame.size.height-64)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    CGSize deviceSize=[UIScreen mainScreen].bounds.size;
    NSLog(@"size w=%f h=%f ",deviceSize.width,deviceSize.height);
    
    //  freezer=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, deviceSize.width, deviceSize.height)];
    //  [freezer setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
    //[freezer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    //   progress=[[UIActivityIndicatorView alloc]init ];
    // [progress setCenter:freezer.center];
    // [progress setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    NSLog(@"center x=%f y=%f ",self.view.center.x,self.view.center.y);
    CGRect facebookframe=buttonLoginLogout.frame;
    CGFloat MinWidth=facebookframe.size.width<facebookframe.size.height?facebookframe.size.width:facebookframe.size.height;
    facebookframe.size.width=MinWidth;
    facebookframe.size.height=MinWidth;
    CGPoint facebookbuttonCenter=buttonLoginLogout.center;
    [buttonLoginLogout setFrame:facebookframe];
    [buttonLoginLogout setCenter:facebookbuttonCenter];
    CGRect twitterframe=twitter.frame;
    twitterframe.size.width=MinWidth;
    twitterframe.size.height=MinWidth;
    CGPoint twitterbuttonCenter=twitter.center;
    [twitter setFrame:twitterframe];
    [twitter setCenter:twitterbuttonCenter];
    CGRect gmailframe=gmail.frame;
    gmailframe.size.width=MinWidth;
    gmailframe.size.height=MinWidth;
    CGPoint gmailbuttonCenter=gmail.center;
    [gmail setFrame:gmailframe];
    [gmail setCenter:gmailbuttonCenter];
    
}
-(IBAction)googleplus:(id)sender
{//[gmail setUserInteractionEnabled:NO];
    //  signInButton=[[GPPSignInButton alloc]init];
    //  [signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    GLoginWebview *gPlusLogin=[[GLoginWebview alloc]init];
    gPlusLogin.Caller=self;
    [self.navigationController pushViewController:gPlusLogin animated:YES];
    ii=0;
}-(void)dismissKeyboard {
    [self.view endEditing:YES];
}
-(IBAction)openSignUp:(id)sender
{
    SignUp *signUpPage = [[SignUp alloc]init];
    [self.navigationController pushViewController:signUpPage animated:NO];
}

-(IBAction)openHomePage:(id)sender
{
    
    [self.view endEditing:YES];
    
    BOOL validEmailID=[self validateEmail:[NSString stringWithFormat:@"%@",emailId.text]];
    if ([self ValidateForCompletnessOfForm])
    {
        if (!validEmailID)
        {       UIAlertView *popAV=[[UIAlertView alloc]initWithTitle:Nil message:@"Enter Valid Email ID" delegate:
                                    nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [popAV show];
            [password setText:@""];
        }
        
        
        else
        {
            [self freezerAnimate];
            
            NSLog(@"x=%f y%f wi=%f he=%f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
            [globleData setuserPass:password.text];
            //[progress startAnimating];
            NSString *name=[NSString stringWithFormat:@"%@",emailId.text];
            NSString *passwordTS=[NSString stringWithFormat:@"%@",password.text];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            
            NSLog(@"d i %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
            double tempTime=[[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
            tempTime=tempTime+[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue];
            tempTime=tempTime/1000;
            NSString *postData = [NSString stringWithFormat:@"email=%@&password=%@&deviceToken=%@&deviceType=2&timestamp=%.0f&versionCode=%@",name,passwordTS,[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"],tempTime,appVersionString];
            NSLog(@" post data %@",postData);
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/login_user.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [connection1 start];
            eventsResponse = [[NSMutableData alloc] init];
        }
        
    }
    
}



-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}
-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}
-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == connection1) {
        [eventsResponse setLength:0];
    }
    if (connection==updateUser) {
        [updateResponce setLength:0];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did recieve data");
    if (connection == connection1) {
        [eventsResponse appendData:data];
    }
    if (connection==updateUser)
    {
        [updateResponce appendData:data];
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    // [progress stopAnimating];
    
    // [progress setHidden:YES];
    // [freezer setHidden:YES];
    [self freezerRemove];
    if (connection==updateUser)
    {
        //  [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
    }
    
}
- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == connection1) {

        NSString *str = [[NSMutableString alloc] initWithData:eventsResponse encoding:NSASCIIStringEncoding];
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"response"];
        status= [responce[@"status"] integerValue];
        
        logged_In_User_Id=[responce[@"logged_in_user_id"] integerValue];
        [globleData setuserID:logged_In_User_Id] ;

        if (status==0){
            
            NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select email from master_table where id =1"];
            if ([output count]!=0) {
                NSString *emailID= [[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"EMAIL" ForRowIndex:0 givenOutput:output];
                if(![emailId.text isEqualToString:emailID]){
                    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
                    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
                    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
                    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
                    
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from master_table "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from blocked_user "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_group "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_message "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_personal "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from contacts "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_category "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_join_request "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_members "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_private "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_public "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from notify_settings "];
                    [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_invitations "];
                    
                }
                
            }
            if ([responce[@"time_status" ] boolValue]){
                
                
                UIAlertView *IncorrectTimeNotification=[[UIAlertView alloc]initWithTitle:Nil message:[responce objectForKey:@"time_alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [IncorrectTimeNotification show];
            }
            NSInteger d=[globleData userID];
            password_Reset=[responce[@"password_reset" ]integerValue];
            NSLog(@"%d",d);
            NSString *displayPic=responce[@"display_pic_300"];
           NSString *about_us=[responce[@"about_us"] isEqual:[NSNull null]]?@"":responce[@"about_us"];
            error_Message=responce[@"error_message"] ;
            NSString *userName=responce[@"user_name"];
            noOfDays=[responce[@"verify_days"] integerValue];
            
            NSInteger locationId=[responce[@"location_id"] integerValue];
            NSString *locationName=responce[@"location_name"];
            email_verified=[responce[@"email_verified"]integerValue];
            verification_Message=responce[@"verification_message"];
            // NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"wallpaper1@2x.png"];
            NSLog(@"query %@",[NSString stringWithFormat:@"INSERT INTO master_table (id, logged_in_user_id,email, password,verified, display_name, display_pic,social_login,location_id,location,last_logged_in,version_no,status,about_us) VALUES(%i,%i,'%@','%@',%i,'%@','%@',0,%i,'%@','%@',%@,'online','%@')",1,logged_In_User_Id,[emailId.text normalizeDatabaseElement],[password.text normalizeDatabaseElement],email_verified,userName,displayPic,locationId,[locationName normalizeDatabaseElement] ,[NSString CurrentDate],appVersionString,about_us]);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:@"delete from master_table"];
            NSString *passwordTS=password.text;
            passwordTS=[passwordTS normalizeDatabaseElement];
            userName=[userName normalizeDatabaseElement];
            [[DatabaseManager getSharedInstance] saveDataInTableWithQuery:[NSString stringWithFormat:@"INSERT INTO master_table (id, logged_in_user_id,email, password,verified, display_name, display_pic,location_id,location,last_logged_in,version_no,status,about_us) VALUES(%i,%i,'%@','%@',%i,'%@','%@',%i,'%@','%@',%@,'online','%@')",1,logged_In_User_Id,[emailId.text normalizeDatabaseElement],passwordTS,email_verified,userName,[displayPic normalizeDatabaseElement],locationId,[locationName normalizeDatabaseElement],[NSString CurrentDate],appVersionString,about_us ]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,displayPic]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",displayPic]];
                    NSLog(@"conatct pic path=%@",contactPicPath);
                    //Writing the image file
                    [imgData writeToFile:contactPicPath atomically:YES];
                    
                    
                });
                
            });
            
            
            NSString *deviceStatus=responce[@"device_status"];
            if ([deviceStatus boolValue]){
                userId=[NSString stringWithFormat:@"%i",logged_In_User_Id];
//                UIAlertView *verifyNoti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"You are logged in from another device. Continue ?"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
//                [verifyNoti setTag:77];
//                [verifyNoti show];
                
                ispasswordreset=password_Reset;
            }else{
                if (!password_Reset) {
                
                AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if (!email_verified){
                    UIAlertView *verifyNoti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"Verification Pending,Verification Link will Expire in %i Days",noOfDays] delegate:appDelegateObj.viewController1 cancelButtonTitle:@"OK" otherButtonTitles:@"Resend E-mail", nil];
                    [verifyNoti setTag:66];
                    [verifyNoti show];
                }
                [self freezerRemove];
                [appDelegateObj setTabBar];
                
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
                
            }else{
                [self freezerRemove];
                noOfDays=[responce[@"verify_days"] integerValue];
                ChangePassword *changePasswordPage = [[ChangePassword alloc]init];
                [globleData setTextFieldHidden:YES];
                
                changePasswordPage.userId=[NSString stringWithFormat:@"%i",[globleData userID] ];
                
                [self.navigationController pushViewController:changePasswordPage animated:YES];
                //   [globleData setTextFieldHidden:NO];
            }
                
            }
            
            
        }else if (status==2){
            [self freezerRemove];
            AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UIAlertView *verifyNoti=[[UIAlertView alloc]initWithTitle:Nil message:responce[@"error_message"] delegate:appDelegateObj.viewController1 cancelButtonTitle:@"OK" otherButtonTitles:@"Resend E-mail", nil];
            [verifyNoti dismissWithClickedButtonIndex:1 animated:YES];
            [verifyNoti setTag:66];
            [verifyNoti show];
        }else{
            password.text=@"";
            [self freezerRemove];
            UIAlertView *loginWarning=[[UIAlertView alloc]initWithTitle:Nil message:responce[@"error_message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [loginWarning show];
        }
        
        connection1=nil;
        [connection1 cancel];
    }
    if (connection==updateUser){
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:updateResponce encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        NSLog(@"vishals responce %@",responce);
        if ([responce[@"status"] boolValue]){
            
            AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!ispasswordreset) {
                [appDelegateObj setTabBar];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
            }
            else{
                [[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
                noOfDays=[responce[@"verify_days"] integerValue];
                ChangePassword *changePasswordPage = [[ChangePassword alloc]init];
                [globleData setTextFieldHidden:YES];
                
                changePasswordPage.userId=[NSString stringWithFormat:@"%i",[globleData userID] ];
                
                [self.navigationController pushViewController:changePasswordPage animated:YES];}
            
        }
        
        
        [self freezerRemove];
    }
    
    
}

- (BOOL) validateEmail: (NSString *) emailstring {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailstring];
}
-(BOOL)ValidateForCompletnessOfForm
{BOOL valid;
    if ([emailId.text length]==0&&[password.text length]==0)
    {UIAlertView *warning=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter E-mail ID and Password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [warning show];
        return false;
    }
    else if ([emailId.text length]==0)
    {UIAlertView *warning=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter Registered E-mail ID " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [warning show];
        return false;
    }
    else if(([password.text length]==0))
    {          UIAlertView *warning=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter the Password " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [warning show];
        
        return  false;
        
    }
    else
        valid=true;
    return valid;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [emailId resignFirstResponder];
    [password resignFirstResponder];
    return YES;
}
-(void)fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration 	  andWait:(NSTimeInterval)wait
{
    NSLog(@"fade in");
    [UIView beginAnimations: @"Fade In" context:nil];
    
    // wait for time before begin
    [UIView setAnimationDelay:wait];
    
    // druation of animation
    [UIView setAnimationDuration:duration];
    viewToFadeIn.alpha = 1;
    [UIView commitAnimations];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 0.0);
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;
}
-(void)viewWillAppear:(BOOL)animated{
    [self.view endEditing:YES];
    
    
    //  [[UIApplication sharedApplication]setStatusBarHidden:YES];
    
    //    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0.0, 0.0, 0.0);
    //    mainScroll.contentInset = contentInsets;
    //    mainScroll.scrollIndicatorInsets = contentInsets;
    [[FHSTwitterEngine sharedEngine]loadAccessToken];
    
    NSString *username = [[FHSTwitterEngine sharedEngine]loggedInUsername];
    
    
    
    NSString *userid = [[FHSTwitterEngine sharedEngine] loggedInID];
    
    
    if (username.length > 0) {
        
        
        
        NSLog(@"twitter username %@",username);
        
        NSLog(@"twitter userid %@",userid);
        
        NSLog(@"twitter login hidden");
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        double tempTime=[[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
        tempTime=tempTime+[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue];
        tempTime=tempTime/1000;
        NSString *postData = [NSString stringWithFormat:@"social_login=1&social_login_type=TWITTER&social_login_id=%@&deviceToken=%@&deviceType=2&timestamp=%.0f&versionCode=%@",userid,[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"],tempTime,appVersionString];
        NSLog(@" post data %@",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/login_user.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        //NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        // NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
        
        NSDictionary *dict;
        @try {
            dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
        }
        @catch (NSException *exception) {
            NSLog(@"try again");
        }
        
        NSLog(@" return %@",dict);
        NSDictionary *responce=dict[@"response"];
        [twitter setUserInteractionEnabled:YES];
        NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select social_login_id from master_table where id =1"];
        if ([output count]!=0) {
            NSString *emailID= [[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN_ID" ForRowIndex:0 givenOutput:output];
            if(![userid isEqualToString:emailID])
            {
                [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from master_table "];
                [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from blocked_user "];
                [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_group "];
                [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_message "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_personal "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from contacts "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_category "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_join_request "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_members "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_private "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_public "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from notify_settings "];
                [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_invitations "];
                
            }
            
        }
        if ([responce[@"time_status" ] boolValue])
        {
            
            
            UIAlertView *IncorrectTimeNotification=[[UIAlertView alloc]initWithTitle:Nil message:[responce objectForKey:@"time_alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [IncorrectTimeNotification show];
        }
        if ([responce objectForKey:@"status"]&&[responce[@"status"] isEqualToString:@"1"])
        {
            CreateProfile *obj=[[CreateProfile alloc]init];
            [obj initCreatePofileWith:@"TWITTER" social_Login_ID:userid];
            [self.navigationController pushViewController:obj animated:NO];
        }
        else if([responce objectForKey:@"status"]&&[responce[@"status"] isEqualToString:@"0"])
        {
            NSString *defaultDBPath = @"wallpaper.jpg";
            
            int userID=[responce[@"logged_in_user_id"] isEqual:[NSNull null]]?0:[responce[@"logged_in_user_id"]integerValue];
            NSString *userName=[responce[@"user_name"] isEqual:[NSNull null]]?@"":responce[@"user_name"];
            NSString *about_us=[responce[@"about_us"] isEqual:[NSNull null]]?@"":responce[@"about_us"];
            NSString *displayPic=[responce[@"display_pic_300"] isEqual:[NSNull null]]?@"":responce[@"display_pic_300"];
            NSString *social_login_type=@"TWITTER";
            NSString *social_login_idl_login=userid;
            int locationID=[responce[@"location_id"] isEqual:[NSNull null]]?0:[responce[@"location_id"] integerValue ];
            NSString *locationName=[responce[@"location_name"] isEqual:[NSNull null]]?@"":responce[@"location_name"];
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:@"delete from master_table"] ;
            
            [[DatabaseManager getSharedInstance] saveDataInTableWithQuery:[NSString stringWithFormat:@"INSERT INTO master_table (id ,logged_in_user_id,verified, display_name,display_pic,social_login,social_login_type,social_login_id,location_id,location,chat_wall_paper,last_logged_in,version_no,status,about_us) VALUES(%i,%i,1,'%@','%@',1,'%@','%@',%i,'%@','%@','%@',%@,'online','%@')",1,userID,[userName normalizeDatabaseElement],[displayPic normalizeDatabaseElement],social_login_type,[social_login_idl_login normalizeDatabaseElement],locationID,[locationName normalizeDatabaseElement],[defaultDBPath normalizeDatabaseElement],[NSString CurrentDate],appVersionString,about_us]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,displayPic]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //cell.imageView.image = [UIImage imageWithData:imgData];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSLog(@"paths=%@",paths);
                    NSString *contactPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",displayPic]];
                    NSLog(@"conatct pic path=%@",contactPicPath);
                    //Writing the image file
                    [imgData writeToFile:contactPicPath atomically:YES];
                    
                    
                });
                
            });
            NSString *deviceStatus=responce[@"device_status"];
            
            if ([deviceStatus boolValue])
            {//[[DatabaseManager getSharedInstance] executeQueryWithQuery:@"update master_table set password=' ' , SOCIAL_LOGIN_TYPE=' ' where id=1"];
                userId=[NSString stringWithFormat:@"%i",logged_In_User_Id];
//                UIAlertView *verifyNoti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"You are logged in from another device. Continue ?"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
//                [verifyNoti setTag:77];
//                [verifyNoti show];
                
                
            }
            else
            {
                AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegateObj setTabBar];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
            }
            
        }
        
        
        
        
        [[FHSTwitterEngine sharedEngine]clearAccessToken];
        
        
    } else {
        
        
        
        NSLog(@"twitter logout hidden");
        
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    [self.navigationController.navigationBar setHidden:true];
    
    
}

-(void)nextview{
    //  BOOL ItDoExist=[[DatabaseManager getSharedInstance] checkForConditionIfExistsWithQuery:@"SELECT * FROM MasterTable where UniqueID=1"];
    [splashscreen removeFromSuperview];
    //  if (ItDoExist)
    //  {
    
    //  }
    statusBarHidden=false;
    [self.navigationController.navigationBar setHidden:TRUE];
    HelpViewController *helper=[[HelpViewController alloc]init];
    [self.navigationController pushViewController:helper animated:NO];
    
}

- (CGRect) convertView:(UIView*)view
{
    CGRect rect = view.frame;
    
    while(view.superview)
    {
        view = view.superview;
        rect.origin.x += view.frame.origin.x;
        rect.origin.y += view.frame.origin.y;
    }
    
    return rect;
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    TXFRAME=[self convertView:textField];
    TXFRAME=CGRectMake(TXFRAME.origin.x, TXFRAME.origin.y+44, TXFRAME.size.width,TXFRAME.size.height);
    NSLog(@"frame x=%f y=%f wi=%f he=%f",TXFRAME.origin.x,TXFRAME.origin.y,TXFRAME.size.width,TXFRAME.size.height);
}
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.000001;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if (indexPath.row==0)
        {
            password=[[UITextField alloc]init];
            [emailId setPlaceholder:@"Email Address"];
            [emailId setKeyboardType:UIKeyboardTypeEmailAddress];
            [emailId setAutocorrectionType:UITextAutocorrectionTypeDefault];
            [emailId setDelegate:self];
            [emailId setFont:[UIFont fontWithName:@"Dosis-Regular" size:15]];
            [emailId setTextColor:[UIColor whiteColor]];
            [emailId setFrame:CGRectMake(10, 0, cell.contentView.frame.size.width-20,30)];
            [emailId setTintColor:[UIColor whiteColor]];
            emailId.textAlignment = UIControlContentVerticalAlignmentCenter;
            emailId.layer.cornerRadius =10.0f;
            emailId.layer.borderColor = [[UIColor whiteColor]CGColor ];
            emailId.layer.borderWidth =1.0f;
            [emailId setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            if ([emailId respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                UIColor *color = [UIColor whiteColor];
                emailId.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address" attributes:@{NSForegroundColorAttributeName: color}];
            }
            
            emailId.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            
            emailId.autocapitalizationType = UITextAutocapitalizationTypeNone;
            emailId.clearButtonMode = UITextFieldViewModeWhileEditing;
            emailId.textAlignment = NSTextAlignmentCenter;
            cell.backgroundColor = [UIColor clearColor];
            emailId.backgroundColor = [UIColor clearColor];
            [cell addSubview:emailId];
        }
        if (indexPath.row==1)
        {
            
            password=[[UITextField alloc]init];
            [password setPlaceholder:@"Password"];
            [password setFont:[UIFont fontWithName:@"Dosis-Regular" size:15]];
            
            [password setAutocorrectionType:UITextAutocorrectionTypeDefault];
            [password setFrame:CGRectMake(10, 0, cell.contentView.frame.size.width-20,30)];
            password.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [password setDelegate:self];
            password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            password.secureTextEntry = YES;
            password.layer.cornerRadius =10.0f;
            [password setTextColor:[UIColor whiteColor]];
            [password setTintColor:[UIColor whiteColor]];
            password.layer.borderColor = [[UIColor whiteColor]CGColor ];
            password.layer.borderWidth =1.0f;
            [password setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            password.clearButtonMode = UITextFieldViewModeWhileEditing;
            cell.backgroundColor = [UIColor clearColor];
            password.backgroundColor = [UIColor clearColor];
             password.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:password];
            if ([password respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                UIColor *color = [UIColor whiteColor];
                password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
            }
            
        }
    }
    return cell;
    
    
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma social

@end
