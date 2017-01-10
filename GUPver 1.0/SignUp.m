//
//  SignUp.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "SignUp.h"
#import "ChatScreen.h"
#import "SearchLocation.h"
#import "TermsAndServices.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "NSString+Utils.h"
#import "DatabaseManager.h"
#import "LandingPage.h"

@interface SignUp ()

@end



@implementation SignUp
@synthesize connection1,usernameUniqueCheck,getLocation,updateUser;
@synthesize SignUpResponse,usernameUniqueCheckResponse,getLoctionResponse,updateResponce;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Create Profile";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        
        
    }
    return self;
}
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}
-(void)updateLocationLable:(NSString *)locationName locationID:(NSInteger)locID;
{
    locationID=locID;
    NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
    [loc setText:locationName];
    
    [loadingLocation stopAnimating];
    [loadingLocation removeFromSuperview];
    [locationManager stopUpdatingLocation];
    [getLocation cancel];
    getLocation=nil;
    NSLog(@"%@",locationName);
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
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyBdHeight+60, 0.0);
//    mainScroll.contentInset = contentInsets;
//    mainScroll.scrollIndicatorInsets = contentInsets;
//    
//    
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= keyBdHeight;
//    
//    if (!CGRectContainsPoint(aRect, TXFRAME.origin) ) {
//        CGPoint scrollPoint = CGPointMake(0.0, TXFRAME.origin.y-keyBdHeight);
//        [mainScroll setContentOffset:scrollPoint animated:NO];
//    }
//    
    
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%hhd",[CLLocationManager locationServicesEnabled]);
    NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
    
        
        
        if (status==kCLAuthorizationStatusDenied) {
            NSLog(@"2%i",[CLLocationManager authorizationStatus]);
            
            [loadingLocation stopAnimating];
            [loc setText:@"Location"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
        }
        
        
        
  

}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            addressName = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                           MAX(placemark.subThoroughfare,@""),MAX( placemark.thoroughfare,@""),
                           MAX( placemark.postalCode,@""),MAX(placemark.locality,@""),
                           MAX(placemark.administrativeArea,@""),
                           MAX(placemark.country,@"")];
            Longitude=newLocation.coordinate.longitude;
            Latitude=newLocation.coordinate.latitude;
            
            NSLog(@"CCLOC LONGI =%f Lati =%f ",Longitude,Latitude);
                     [locationManager stopUpdatingLocation];
            NSString *latitudeL=[NSString stringWithFormat:@"%f",Latitude];
            NSString *longitudeL=[NSString stringWithFormat:@"%f",Longitude];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            
            //  NSString *url=[NSURL URLWithString:@"http://198.154.98.11/~gup/scripts/add_user.php"];
            
            NSString *postData = [NSString stringWithFormat:@"latitude=%@&longitude=%@&type=1",latitudeL,longitudeL];
            NSLog(@"request %@",postData);
            
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/check_location.php",gupappUrl]]];
            
            [request setHTTPMethod:@"POST"];
            
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            
            //set post data of request
            
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            
            //initialize a connection from request
            
            getLocation = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            
            [getLocation scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            
            [getLocation start];
            
            getLoctionResponse = [[NSMutableData alloc] init];

            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0,0, 0, 0);
//    mainScroll.contentInset = contentInsets;
//    mainScroll.scrollIndicatorInsets = contentInsets;
    
}
-(IBAction)dissmisal:(UIButton*)sender1
{
    
    [self.parentViewController.view setUserInteractionEnabled:YES];
    [sender1.superview removeFromSuperview];
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
        if (![[data objectForKey:@"location"] boolValue]) {
            
            [data setObject:[NSNumber numberWithInt:true] forKey:@"location"];
            CGSize deviceSize=[UIScreen mainScreen].bounds.size;
            UIImageView *Back=[[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            UIImage *backimage=[UIImage imageNamed:@"location"];
            [Back setImage:[backimage stretchableImageWithLeftCapWidth:backimage.size.width topCapHeight:0]];
            //  [self.view addSubview:Back];
            //   [self.view sendSubviewToBack:Back];
            [Back setUserInteractionEnabled:YES];
            UIButton *dismiss=[[UIButton alloc]initWithFrame:CGRectMake(deviceSize.width-110, 32, 100, 30)];
            [dismiss setTitle:@"Done" forState:UIControlStateNormal];
            [dismiss setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:178.0/255.0 blue:55.0/255.0 alpha:1 ]];
            [dismiss setUserInteractionEnabled:YES];
               [dismiss addTarget:self action:@selector(dissmisal:) forControlEvents:UIControlEventTouchUpInside];
          //  UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self                                                                                        action:@selector(dissmisal:)];
            
           // swipe.direction = UISwipeGestureRecognizerDirectionLeft;
          //  [dismiss addGestureRecognizer:swipe];
            [Back addSubview:dismiss];
            
            NSLog(@"self %@ \n back %@ \n backback %@ \n backbackback %@",self,self.parentViewController,self.parentViewController.parentViewController,self.parentViewController.parentViewController.parentViewController);
            //[self.parentViewController.parentViewController.view setUserInteractionEnabled:NO];
            [self.parentViewController.view addSubview:Back];
            [self.parentViewController.view bringSubviewToFront:Back ];
            
            NSLog(@"hiii");
        }
        [data writeToFile: path atomically:YES];
        NSLog(@"data %@",data);
        NSLog(@"data %@",data);
    }
    else
    {
        
          data = [[NSMutableDictionary alloc] init];
         [data setObject:[NSNumber numberWithInt:false] forKey:@"Location"];
         [data setObject:[NSNumber numberWithInt:true] forKey:@"IsSuccesfullRun"];
       // [data setObject:[NSNumber numberWithInt:false] forKey:@"ChatScreen"];
         [data setObject:[NSNumber numberWithInt:false] forKey:@"HomeScreen"];
         [data setObject:[NSNumber numberWithInt:false] forKey:@"CreateGroup"];
         [data setObject:[NSNumber numberWithInt:false] forKey:@"Explore"];
        
        [data writeToFile: path atomically:YES];
        
        
    }
    
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self plistSpooler];
    [self fetchLocation];
    username.delegate = self;
    if ([username respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1.0];
        username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"User Name" attributes:@{NSForegroundColorAttributeName: color}];
    }
    [username setFont:[UIFont fontWithName:@"Dosis-Bold" size:18]];
    form.backgroundColor = [UIColor clearColor];
    form.separatorStyle = UITableViewCellSeparatorStyleNone;
     appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        [self.navigationController.navigationBar setHidden:false];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:249.0/255.0 alpha:1.0];
    
    self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    mainScroll.scrollEnabled=true;
    signUptable.showsVerticalScrollIndicator=false;
    mainScroll.showsVerticalScrollIndicator=false;
    [mainScroll setContentSize:CGSizeMake(mainScroll.frame.size.width, mainScroll.frame.size.height-64)];
    emailIdTextField=[[UITextField alloc]init];
    passwordTextField=[[UITextField alloc]init];
    loc=[[UILabel alloc]init];
    nameVerification=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
     loadingLocation=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    usernameIsUnique=FALSE;
 addressName=@"Curren Location";
    UserImage.userInteractionEnabled = YES;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    tapRecognizer.numberOfTapsRequired = 1;
    
    [UserImage addGestureRecognizer:tapRecognizer];
  /*    CALayer *imageLayer = UserImage.layer;
    [imageLayer setCornerRadius:50];
    [imageLayer setBorderWidth:2];
    [imageLayer setBorderColor:[UIColor whiteColor].CGColor];
    [imageLayer setMasksToBounds:YES];
   
*/
    if ([UserImage.image isEqual:[UIImage imageNamed:@"defaultProfile.png"]])
         {
    NSLog(@"is");
         }UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    CGSize deviceSize=[UIScreen mainScreen].bounds.size;
    NSLog(@"size w=%f h=%f ",deviceSize.width,deviceSize.height);
    
   /* freezer=[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, deviceSize.width, deviceSize.height)];
    [freezer setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
    [freezer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    progress=[[UIActivityIndicatorView alloc]init ];
    [progress setCenter:freezer.center];
    [progress setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    NSLog(@"center x=%f y=%f ",self.view.center.x,self.view.center.y);*/

}

- (NSString *) getFileName:(UIImageView *)imgView{
    
    NSString *imgName = [imgView image].accessibilityIdentifier;
    
    NSLog(@"%@",imgName);
    
    return imgName;
    
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:form]) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    
    [self.view endEditing:YES];
   /* UIEdgeInsets contentInsets = UIEdgeInsetsMake(0,0, 0, 0);
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;*/
    NSLog(@"choose pic");
    NSString *option1 = @"Camera Shot";
    NSString *option2 = @"Gallery";
    NSString *option3 = @"Remove Photo";
    NSString *cancelTitle = @"Cancel";
    if ([UserImage.image isEqual:[UIImage imageNamed:@"defaultProfile.png"]])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@""
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:Nil
                                      otherButtonTitles:option1, option2, nil];
        [actionSheet  showInView:self.view];
    }
    else{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@""
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:Nil
                                  otherButtonTitles:option1, option2, option3, nil];
    [actionSheet  showInView:self.view];
    }
    // SetProfilePic *changeProfilePic = [[SetProfilePic alloc]init];
    // changeProfilePic.userId=getData[0];
    //[self.navigationController pushViewController:changeProfilePic animated:YES];
}
// action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   

    Ipicker = [[UIImagePickerController alloc] init];
    
    [Ipicker setDelegate:self];
    Ipicker.allowsEditing = YES;
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"button title:%i,%@",buttonIndex ,buttonTitle);
    if ([buttonTitle isEqualToString:@"Camera Shot"]) {
        NSLog(@"Other 1 pressed");
                    {
                        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                        {

                            if ([Ipicker respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                                
                                [[UIApplication sharedApplication] setStatusBarHidden:YES];
                            }
                           
       
        Ipicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        
                          

      [self presentViewController:Ipicker animated:YES completion:NULL];
            }
            else
            {
                
            //    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:Nil                                                                      message:@"Device has no Camera"                                                                     delegate:nil                                                            cancelButtonTitle:@"OK"                                                            otherButtonTitles: nil];
                
              //  [myAlertView show];
                
            }
        
                    }
    }
    if ([buttonTitle isEqualToString:@"Gallery"]) {
        NSLog(@"Other 2 pressed");
       
        ;;   Ipicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [Ipicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        
        [self presentViewController:Ipicker animated:YES completion:NULL];
        
    }
    if ([buttonTitle isEqualToString:@"Remove Photo"]) {
        NSLog(@"Other 3 pressed");
        UserImage.image=Nil;
        [UserImage setImage:[UIImage imageNamed:@"defaultProfile.png"]];
    }
    
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    }
    

}
-(BOOL)prefersStatusBarHidden
{return NO;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UserImage.image = chosenImage;
   
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
 
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
 
}

-(void)fetchLocation
{
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    locationManager.delegate = self;
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusNotDetermined && [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
            [locationManager  requestWhenInUseAuthorization];
        } else {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
        }
    }
    
    [locationManager startUpdatingLocation];
}




- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"did recieve response");
    if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
     //   NSLog(@"error codes %ld" , (long)[(NSHTTPURLResponse*) response statusCode]);
     // NSLog(@"error codes :- \n            HTTP Status Codes \n         200 OK \n         400 Bad Request \n         401 Unauthorized (bad username or password) \n         403 Forbidden \n         404 Not Found\n         502 Bad Gateway\n         503 Service Unavailable "        );
    }
  
    if (connection == connection1) {
        [SignUpResponse setLength:0];
    }
    if (connection==usernameUniqueCheck)
    {
        [usernameUniqueCheckResponse setLength:0];
    }
    if (connection==getLocation)
    {
        [getLoctionResponse setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did recieve data");
   
    if (connection == connection1) {
        [SignUpResponse appendData:data];
    }
    if (connection==usernameUniqueCheck) {
        [usernameUniqueCheckResponse appendData:data];
    }
    if (connection==getLocation)
    {
        [getLoctionResponse appendData:data];
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
       if (connection == connection1) {
           [HUD hide:YES];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [passwordTextField setText:@""];
    [confirmPasswordTextField setText:@""];

    

}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@" finished loading");
    
      if (connection == connection1) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:SignUpResponse encoding:NSASCIIStringEncoding];
       // NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
       
        NSDictionary *responce= res[@"response"];
       
          if ([responce objectForKey:@"status"])
          {
              NSLog(@"====EVENTS==3 result %@",res);
           NSLog(@"vishals responce %@",responce);
              if ([responce[@"status"] integerValue])
          { NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select email from master_table where id =1"];
              if ([output count]!=0) {
                  NSString *emailID= [[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"EMAIL" ForRowIndex:0 givenOutput:output];
                  if(![emailIdTextField.text isEqualToString:emailID])
                  {
                      [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from master_table "];
                      [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from blocked_user "];
                      [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_group "];
                      [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_message "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_personal "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from contacts "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_category "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_join_request "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_members "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_private "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_public "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from notify_settings "];
                       [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_invitations "];
                  }
                  
              }
              
              

                  UIAlertView *MatchAlert=[[UIAlertView alloc]initWithTitle:Nil message:responce[@"error"] delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
              [MatchAlert setTag:44];
              [MatchAlert show];
              int userID=[responce[@"userid"]integerValue ];
            //  NSString *displayPic=[NSString stringWithFormat:@"profile_pic_%i_300.jpg",userID];
               NSString *displayPic=[responce objectForKey:@"profile_pic"]!=[NSNull null]?[responce objectForKey:@"profile_pic"]:[NSString stringWithFormat:@"profile_pic_%i_300.jpg",userID];
              NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
              NSString *locationName=loc.text;
    // NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"wallpaper1@2x.png"];
              NSLog(@"query %@",[NSString stringWithFormat:@"INSERT INTO master_table (id, logged_in_user_id,email, password,verified, display_name, display_pic,social_login,location_id,location,last_logged_in,status) VALUES(%i,%i,'%@','%@',%i,'%@','%@',0,%i,'%@','%@','online')",1,userID,emailIdTextField.text,[passwordTextField.text normalizeDatabaseElement],0,[username.text normalizeDatabaseElement],displayPic,locationID,[locationName normalizeDatabaseElement] ,[NSString CurrentDate]]);
              [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:@"delete from master_table"];
              [[DatabaseManager getSharedInstance] saveDataInTableWithQuery:[NSString stringWithFormat:@"INSERT INTO master_table (id, logged_in_user_id,email, password,verified, display_name, display_pic,social_login,location_id,location,last_logged_in,version_no,status,about_us) VALUES(%i,%i,'%@','%@',%i,'%@','%@',0,%i,'%@','%@',%@,'online','%@')",1,userID,emailIdTextField.text,[passwordTextField.text normalizeDatabaseElement],0,[username.text normalizeDatabaseElement],displayPic,locationID,[locationName normalizeDatabaseElement],[NSString CurrentDate],appVersionString,aboutme.text ]];
              NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
              NSLog(@"paths=%@",paths);
              NSString *profilePicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",displayPic] ];
              NSLog(@"profile pic path=%@",profilePicPath);
              
              //Writing the image file
              NSData *imageData = UIImageJPEGRepresentation(UserImage.image, 0.9);
              
              [imageData writeToFile:profilePicPath atomically:YES];
              

                 NSString *usernames=[NSString stringWithFormat:@"user_%i",userID];
                 NSString *jid=[usernames stringByAppendingString:(NSString*)jabberUrl];
                 NSString *password=[NSString stringWithFormat:@"password_%i_user",userID];
                 NSString *universalID=emailIdTextField.text;
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setObject:jid forKey:@"Jid"];
                 [defaults setObject:password forKey:@"Password"];
                 [defaults synchronize];
                  
                      [[self appDelegate]registrationWithUserName:usernames password:password name:username.text emailid:universalID];
              NSString *groupId=responce[@"group_id"];
              ChatScreen *chatScreen = [[ChatScreen alloc]init];
              chatScreen.chatType = @"group";
              chatScreen.chatTitle=[@"GLOBAL" normalizeDatabaseElement];
              [chatScreen initWithUser:[NSString stringWithFormat:@"user_%d@%@",[groupId integerValue],(NSString*)jabberUrl]];
              
              chatScreen.groupType=@"GLOBLE" ;
              if ([chatScreen.chatHistory count]==0)
                  [chatScreen retreiveHistory:nil];
            [self appDelegate].currentUser=@"";


             // AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             // [appDelegateObj setTabBar];
              
              LandingPage *lp=[[LandingPage alloc]init];
              lp.registrationID = [NSString stringWithFormat:@"%d",userID];
              [self.navigationController pushViewController:lp animated:YES];

          
          }
          else
          {
              UIAlertView *signUpWarning=[[UIAlertView alloc]initWithTitle:Nil message:responce[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
              [signUpWarning show];
              [passwordTextField setText:@""];
              [confirmPasswordTextField setText:@""];

              
          }
          
        connection1=nil;
        [connection1 cancel];
          [HUD hide:YES];
          }
          else
          {
              NSLog(@"Shan4552");
              [self redirection];
          }
    }
    if (connection == usernameUniqueCheck) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:usernameUniqueCheckResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        NSLog(@"vishals responce %@",responce);
        usernameIsUnique =[responce[@"status"]integerValue];
       //4552 NSString *errormsg=responce[@"error_message"];
        [nameVerification stopAnimating];

        if ([username.text stringByReplacingOccurrencesOfString:@" " withString:@""].length!=0)
        {
        if (usernameIsUnique)
        {//[nameVerification stopAnimating];
          //  [nameVerification removeFromSuperview];
//            NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:0 inSection:0];
//            UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
//            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            usernameIsUnique=true;
        }
        else
        {//[nameVerification stopAnimating];
           // [nameVerification removeFromSuperview];

           
//            NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:0 inSection:0];
//            UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
//            UIImageView *accview=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cancel.png" ]];
//            [accview setFrame:CGRectMake(0, 0, 20, 20)];
//                        cell.accessoryView=accview;
        
        }
        }
        usernameUniqueCheck=nil;
        [usernameUniqueCheck cancel];
    }
    if (connection == getLocation) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:getLoctionResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSLog(@"====EVENTS==3 result %@",res);
        locations=[[NSArray alloc]init];
        locations= res[@"response"];
        NSLog(@"vishals responce %@",locations);
        NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
        if ([locations count]!=0)
        {
            for (  NSDictionary *tempdict in locations)
            {
               NSLog(@"%@ dsd%@",tempdict,tempdict[@"location_name"]);
                    location=tempdict[@"location_name"];
                    loc.text=location;
                locationID=[tempdict[@"id"] integerValue];
                    break;
            }
          
         
           

        }
        [loadingLocation stopAnimating];
          [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        //[loadingLocation stopAnimating];
       // [loadingLocation removeFromSuperview];
        [locationManager stopUpdatingLocation];
        [getLocation cancel];
        getLocation=nil;
       // getLocation=nil;
      //  [getLocation cancel];
    }

    
}

- (BOOL) validateEmail: (NSString *) emailstring {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailstring];
}

-(BOOL)checkForFormCompletness
{BOOL FormComplete,usernameEmpty,locationEmpty,emailIdEmpty,passwordEmpty;
    NSString *alertMsg=@"Please enter ";
    if([[username.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0||[[loc.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0||[[loc.text stringByReplacingOccurrencesOfString:@" " withString:@""]  isEqual:@"Location"]||[[emailIdTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0||[[passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0)
    {
        

    
    if([[username.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0)
    usernameEmpty=true;
      if ([[username.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0)
      {usernameEmpty=true;
          alertMsg=[alertMsg stringByAppendingString:@" username ,"];
       }
    if ([[loc.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0||[[loc.text stringByReplacingOccurrencesOfString:@" " withString:@""]  isEqual:@"Location"] )
    {locationEmpty=true;
     alertMsg=[alertMsg stringByAppendingString:@" location ,"];
    }
    if ([[emailIdTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0)
    {
        emailIdEmpty=true;
         alertMsg=[alertMsg stringByAppendingString:@" emailID ,"];
    }
    if([[passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0)
    {passwordEmpty=true;
         alertMsg=[alertMsg stringByAppendingString:@" password ,"];
    }
   
    alertMsg=[alertMsg substringToIndex:[alertMsg length]-1];
    
    alertMsg=[alertMsg stringByAppendingString:@" and then try again"];
    
    FormComplete=false;
    UIAlertView *done=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter All Fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [done show];
        [passwordTextField setText:@""];
        [confirmPasswordTextField setText:@""];

}
else
{FormComplete= true;
}
    return FormComplete;
    
    
}
-(void)redirection
{  [self.view endEditing:YES];
    BOOL validEmailID=[self validateEmail:[NSString stringWithFormat:@"%@",emailIdTextField.text]];
    if ([self checkForFormCompletness])
    {
        if (validEmailID)
        {NSLog(@"P=%@ CP=%@",passwordTextField.text,confirmPasswordTextField.text);
            if ([passwordTextField.text length]>5&&[passwordTextField.text length]<16) {
                
                
                    if (usernameIsUnique)
                    {
                       
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                        
                     NSString *postData = [NSString stringWithFormat:@"about_us=%@deviceToken=%@&deviceType=2&username=%@&email=%@&password=%@&location_id=%@&social_login=0",aboutme.text,[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"],username.text,emailIdTextField.text,passwordTextField.text,[NSString stringWithFormat:@"%i",locationID ]];
                      //  NSLog(@" post data %@",postData);
                        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_user_rec.php",gupappUrl]]];
                        [request setHTTPMethod:@"POST"];
                        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                       // connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                        
//                        eventsResponse = [[NSMutableData alloc] init];
//
//                        
//                        
//                        
//                        
//                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//                        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_user.php",gupappUrl]]];
//                        [request setHTTPMethod:@"POST"];
//                        [request setTimeoutInterval:300];
//                        NSMutableData *body = [NSMutableData data];
//                        NSString *boundary = @"---------------------------14737809831466499882746641449";
//                        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
//                        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
//                        
//                        
//                        NSData *imageData;
//                        if (![UserImage.image isEqual:[UIImage imageNamed:@"defaultProfile.png"] ]) {
//                            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                            [body appendData:[@"Content-Disposition: form-data; name=\"profile_pic\"; filename=\"a.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                            imageData = UIImageJPEGRepresentation(UserImage.image, 0.9);
//                            [body appendData:[NSData dataWithData:imageData]];
//                            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                        }
//                        //else
//                        //  {
//                        
//                        //  }
//                        
//                        //  parameter Device token
//                        
//                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"deviceToken\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        [body appendData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        //  parameter Device type
//                        
//                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"deviceType\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        [body appendData:[@"2" dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        
//                        //  parameter username
//                        
//                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        [body appendData:[userNameTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        
//                        //  parameter token
//                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        [body appendData:[emailIdTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        
//                        // parameter method
//                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        [body appendData:[passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        
//                        //parameter method
//                        NSLog(@"%i",locationID);
//                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"location_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        [body appendData:[[NSString stringWithFormat:@"%i",locationID ] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                        //parameter method
//                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"social_login\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        [body appendData:[[NSString stringWithFormat:@"0"] dataUsingEncoding:NSUTF8StringEncoding]];
//                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        
//                        
//                        // close form
//                        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                        
//                        
//                        // setting the body of the post to the reqeust
//                        [request setHTTPBody:body];
//                        
//                        
//                        //   NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//                        // NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//                        //    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
//                        //   NSLog(@"%@",dict);
//                        
//                        
//                        
//                        
//                        
//                        
//                        
//                        
//                        
                        
                        
                        connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                        
                        [connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                        
                        [connection1 start];
                        
                        SignUpResponse = [[NSMutableData alloc] init];
                    }
                    else
                    { UIAlertView *userName=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter Unique Display Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [userName show];
                        [passwordTextField setText:@""];
                        [confirmPasswordTextField setText:@""];
                    }
                    
              
            }
            else
            {
                
                UIAlertView *popAV=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter Password within 6-15 Characters" delegate:
                                    nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                [popAV show];
                [passwordTextField setText:@""];
                [confirmPasswordTextField setText:@""];
                
            }
            
        } else
        {
            UIAlertView *popAV=[[UIAlertView alloc]initWithTitle:Nil message:@"Invalid E-mail ID" delegate:
                                nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [popAV show];
            [passwordTextField setText:@""];
            [confirmPasswordTextField setText:@""];
            
        }
    }
    //4552  AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //4552  [appDelegateObj setTabBar];
}
-(IBAction)openTabbar:(id)sender
{  [self.view endEditing:YES];
    BOOL validEmailID=[self validateEmail:[NSString stringWithFormat:@"%@",emailIdTextField.text]];
    if ([self checkForFormCompletness])
    {
        if (validEmailID)
        {NSLog(@"P=%@ CP=%@",passwordTextField.text,confirmPasswordTextField.text);
            if ([passwordTextField.text length]>5&&[passwordTextField.text length]<16) {
            
            
                if (usernameIsUnique)
                {
                    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    HUD.delegate = self;
                    HUD.dimBackground = YES;
                    HUD.labelText = @"Please Wait";
               
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_user.php",gupappUrl]]];
                    [request setHTTPMethod:@"POST"];
                    [request setTimeoutInterval:300];
                    NSMutableData *body = [NSMutableData data];
                    NSString *boundary = @"---------------------------14737809831466499882746641449";
                    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
                    
                    
                    NSData *imageData;
                    if (![UserImage.image isEqual:[UIImage imageNamed:@"defaultProfile.png"] ]) {
                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Disposition: form-data; name=\"profile_pic\"; filename=\"a.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        imageData = UIImageJPEGRepresentation(UserImage.image, 0.9);
                         [body appendData:[NSData dataWithData:imageData]];
                         [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    //else
                  //  {
                   
                  //  }
                    //  parameter Device token
                    // &versionCode=%@
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"versionCode\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[appVersionString dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    

                    //  parameter Device token
                   // &versionCode=%@
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"deviceToken\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                  
//                    
//                    //  parameter about token
//                    // &versionCode=%@
//                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"about_us\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//                    
//                    [body appendData:[aboutme.text dataUsingEncoding:NSUTF8StringEncoding]];
//                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//                    
                    
                    //  parameter Device type
                    
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"deviceType\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[@"2" dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    

                    //  parameter username
                    
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[username.text dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    
                    //  parameter token
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[emailIdTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    
                    // parameter method
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    
                    //parameter method
                    NSLog(@"%i",locationID);
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"location_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[[NSString stringWithFormat:@"%i",locationID ] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    //parameter method
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"social_login\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[[NSString stringWithFormat:@"0"] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    
                    
                    // close form
                    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    
                    // setting the body of the post to the reqeust
                    [request setHTTPBody:body];
                    
                    
                    //   NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                    // NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                    //    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
                    //   NSLog(@"%@",dict);
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
              
                    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                    
                    [connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    
                    [connection1 start];
                    
                    SignUpResponse = [[NSMutableData alloc] init];
                }
                else
                { UIAlertView *userName=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter Unique Display Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [userName show];
                    [passwordTextField setText:@""];
                    [confirmPasswordTextField setText:@""];
                }
                
            
           
            }
            else
            {
                
                UIAlertView *popAV=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter Password within 6-15 Characters" delegate:
                                    nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                [popAV show];
                [passwordTextField setText:@""];
                [confirmPasswordTextField setText:@""];

            }
            
        } else
        {
            UIAlertView *popAV=[[UIAlertView alloc]initWithTitle:Nil message:@"Invalid E-mail ID" delegate:
                                nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [popAV show];
            [passwordTextField setText:@""];
            [confirmPasswordTextField setText:@""];

        }
    }
  //4552  AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  //4552  [appDelegateObj setTabBar];
}



#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 61;
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([aboutme.text isEqualToString:@"Write something about yourself.."]) {
        aboutme.text = @"";
    }
    
    return YES;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectio{
    
    UIView *headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, form.frame.size.width, 60)];
    
    UILabel *about = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300,20)];
    about.text =@"About Me";
    about.font = [UIFont fontWithName:@"Dosis-SemiBold" size:18.0];
    about.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    [headerView addSubview:about];
    
    aboutme = [[UITextView alloc] initWithFrame:CGRectMake(10,20, 300, 40)];
    aboutme.backgroundColor =[UIColor clearColor];
    aboutme.text=@"Write something about yourself..";
    if ([aboutme respondsToSelector:@selector(setAttributedPlaceholder:)]) {
      //  UIColor *color = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
      //  aboutme.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Write something about yourself.." attributes:@{NSForegroundColorAttributeName: color}];
    }
   // aboutme.clearButtonMode = UITextFieldViewModeWhileEditing;
    [aboutme setAutocorrectionType:UITextAutocorrectionTypeDefault];
    aboutme.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //   [emailIdTextField setBackgroundColor:[UIColor greenColor]];
    [aboutme setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
   // aboutme.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    aboutme.textAlignment =NSTextAlignmentLeft;
    [aboutme setDelegate:self];
    aboutme.font = [UIFont fontWithName:@"Dosis-Regular" size:13.f];
    aboutme.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
     UIView *border =[[UIView alloc] initWithFrame:CGRectMake(0, 60, form.frame.size.width, 1)];
    border.backgroundColor = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    border.layer.shadowColor =[UIColor grayColor].CGColor;
    border.layer.shadowOffset = CGSizeMake(5, 5);
    border.layer.shadowRadius =5;
    
    [headerView addSubview:border];
    [headerView addSubview:aboutme];
    
    return headerView;
    
}
-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
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
        UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(10,5,28,28)];
        [cell addSubview:iconView];
        cell.backgroundColor = [UIColor clearColor];
    switch(indexPath.row) {
       case 1: // Initialize cell 2
        {
            [loadingLocation setBackgroundColor:[UIColor clearColor]];
            [loadingLocation setFrame:CGRectMake(form.frame.size.width-32,15 , 20,20)];
            
            [loadingLocation setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin];
            [cell addSubview:loadingLocation];
            
            loc = [[UILabel alloc] initWithFrame: CGRectMake(54, 0, cell.frame.size.width-60, cell.frame.size.height)];
            loc.text =@"Location";
           
            [cell addSubview:loc];
            loc.font = [UIFont fontWithName:@"Dosis-Regular" size:16.0];
            loc.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
            iconView.image =[UIImage imageNamed:@"locationlogo"];
            
                       NSLog(@"%hhd",[CLLocationManager locationServicesEnabled]);
            if([CLLocationManager locationServicesEnabled]){
                
                
                
                if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied) {
                    NSLog(@"2%i",[CLLocationManager authorizationStatus]);
                    
                    
                    [loc setText:@"Location"];
                    [loc setTextColor:[UIColor lightGrayColor]];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    
                }
                else
                {
                    
                    [loadingLocation startAnimating];
                 
                }
                
                
                
            }
           

        }
            break;
        case 0: // Initialize cell 3
        {iconView.image =[UIImage imageNamed:@"email"];
            
            [emailIdTextField setFrame:CGRectMake(54, 0, cell.frame.size.width-60, cell.frame.size.height)];
            emailIdTextField.placeholder=@"Email Address";
            [emailIdTextField setTag:1];
             [emailIdTextField setKeyboardType:UIKeyboardTypeEmailAddress];
            emailIdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
             [emailIdTextField setAutocorrectionType:UITextAutocorrectionTypeDefault];
            emailIdTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
         //   [emailIdTextField setBackgroundColor:[UIColor greenColor]];
            [emailIdTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            emailIdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [emailIdTextField setDelegate:self];
            [cell addSubview:emailIdTextField];
            
            emailIdTextField.font = [UIFont fontWithName:@"Dosis-Regular" size:16.0];
            emailIdTextField.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
            if ([emailIdTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                UIColor *color = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
                emailIdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
            }
            
        }
            break;
        case 2: // Initialize cell 4
        {iconView.image =[UIImage imageNamed:@"password"];
            [ passwordTextField setFrame:CGRectMake(50, 0, cell.frame.size.width-60, cell.frame.size.height)];
            passwordTextField.placeholder=@"Password";
            passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
             passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            [passwordTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [passwordTextField setTag:2];
            [passwordTextField setAutocorrectionType:UITextAutocorrectionTypeDefault];
            passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
           // [passwordTextField setBackgroundColor:[UIColor greenColor]];
            
             passwordTextField.font = [UIFont fontWithName:@"Dosis-Regular" size:16.0];
             passwordTextField.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];

            [passwordTextField setDelegate:self];
            [passwordTextField setSecureTextEntry:YES];
            [cell addSubview:passwordTextField];
            if ([passwordTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                UIColor *color = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
                passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
            }
        }
            break;
//        case 3: // Initialize cell 5
//        {cell.imageView.image =[UIImage imageNamed:@"password"];
//            [confirmPasswordTextField setFrame:CGRectMake(15, 0, cell.frame.size.width-20, cell.frame.size.height)];
//            confirmPasswordTextField.placeholder=@"Confirm Password";
//            [confirmPasswordTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//            [confirmPasswordTextField setTag:3];
//            confirmPasswordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//             confirmPasswordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//            confirmPasswordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//            [confirmPasswordTextField setAutocorrectionType:UITextAutocorrectionTypeDefault];
//          //  [confirmPasswordTextField setBackgroundColor:[UIColor greenColor]];
//            confirmPasswordTextField.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
//            [confirmPasswordTextField setDelegate:self];
//            [confirmPasswordTextField setSecureTextEntry:YES];
//            [cell addSubview:confirmPasswordTextField];
//            
//        }
//            break;
            
    }
    }
    else
    {/*
    switch(indexPath.row) {
        case 0: // Initialize cell 1
        {
            userNameTextField.placeholder=@"User ma";
            
        }
            
            break;
        case 1: // Initialize cell 2
        {
            
            locationLable.text=@"dfededrededed";
            
            
        }
            break;
        case 2: // Initialize cell 3
        {
           
            emailIdTextField.placeholder=@"Email eded";
            
        }
            break;
        case 3: // Initialize cell 4
        {
            
            passwordTextField.placeholder=@"Passwedeord";
            
        }
            break;
        case 4: // Initialize cell 5
        {
            confirmPasswordTextField.placeholder=@"Confirm Passedeword";
            
        }
            break;
            
    }*/
    }
    
    return cell;
    
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /* if (tableView==notificationTable)
     {
     NSLog(@"selected news at %d",indexPath.row);
     NotificationDetailView *detailPage = [[NotificationDetailView alloc]init];
     detailPage.notificationId = [notificationIds objectAtIndex:indexPath.row];
     [self.navigationController pushViewController:detailPage animated:YES];
     }*/
    if (tableView==form&&indexPath.row==1)
    {
        SearchLocation *search=[[SearchLocation alloc]init];
        [search setinitialContent:locations:self];
      //  [search wontToChangeLocation];
        [self.navigationController pushViewController:search animated:NO];
    
    }
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [username resignFirstResponder];
    [aboutme resignFirstResponder];
    [emailIdTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [confirmPasswordTextField resignFirstResponder];
    return YES;
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
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
   
   
  //  if ( ![string canBeConvertedToEncoding:NSASCIIStringEncoding])
    //    return NO;
    return  YES;
    

}
-(BOOL)textFieldShouldClear:(UITextField *)textField
{[usernameUniqueCheck cancel];
    [nameVerification stopAnimating];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    TXFRAME=[self convertView:textField];
      TXFRAME=CGRectMake(TXFRAME.origin.x, TXFRAME.origin.y+40, TXFRAME.size.width,TXFRAME.size.height);
    NSLog(@"frame x=%f y=%f wi=%f he=%f",TXFRAME.origin.x,TXFRAME.origin.y,TXFRAME.size.width,TXFRAME.size.height);

   /* TXFRAME =textField.frame;
    CGRect tableFrame=textField.superview.superview.frame;
    TXFRAME=CGRectMake(TXFRAME.origin.x+tableFrame.origin.x, TXFRAME.origin.y+tableFrame.origin.y, TXFRAME.size.width+tableFrame.size.width,TXFRAME.size.height+tableFrame.size.height);
    NSLog(@"frame x=%f y=%f wi=%f he=%f",TXFRAME.origin.x,TXFRAME.origin.y,TXFRAME.size.width,TXFRAME.size.height);
    NSLog(@"frame x=%f y=%f wi=%f he=%f",tableFrame.origin.x,tableFrame.origin.y,tableFrame.size.width,tableFrame.size.height);*/
    /*
    CGRect textFieldRect =[self.view.window convertRect:textField.bounds fromView:textField];
    
    CGRect viewRect =[self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    
    CGFloat numerator =midline - viewRect.origin.y- MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
    CGFloat denominator =(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)* viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    heightFraction+=0.2;
    
    if (heightFraction < 0.0)
        
    {
        
        heightFraction = 0.0;
        
    }
    
    else if (heightFraction > 1.0)
        
    {
        
        heightFraction = 1.0;
        
    }
    
    UIInterfaceOrientation orientation =
    
    [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        
        orientation == UIInterfaceOrientationPortraitUpsideDown)
        
    {
        
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        
    }
    
    else
        
    {
        
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
        
    }
    
    CGRect viewFrame = self.view.frame;
    
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
 */
   
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if(textField.tag== 0)
    {NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
        cell.accessoryView=nil;
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [nameVerification setBackgroundColor:[UIColor clearColor]];
        [nameVerification setFrame:CGRectMake(cell.frame.size.width-32,12 ,20 , 20)];
        [nameVerification startAnimating];
        [nameVerification setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
        usernameIsUnique=false;

        if (![username.text isEqual:@""])
        {
            if (![textField.text isAlphaNumeric]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"Please enter alphabets or numbers only"   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
               [nameVerification stopAnimating];
                [textField setText:@""];
            }
            else
            {
        NSString *name=[NSString stringWithFormat:@"%@",username.text];
               NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        //  NSString *url=[NSURL URLWithString:@"http://198.154.98.11/~gup/scripts/add_user.php"];
        
        NSString *postData = [NSString stringWithFormat:@"username=%@",name];
        NSLog(@"request %@",postData);
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/check_username.php",gupappUrl]]];
        
        [request setHTTPMethod:@"POST"];
        
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        //set post data of request
        
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        
        //initialize a connection from request
        
        usernameUniqueCheck = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        
        [usernameUniqueCheck scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        [usernameUniqueCheck start];
        
        usernameUniqueCheckResponse = [[NSMutableData alloc] init];
            }
        }
        else
        {
            [nameVerification stopAnimating];
        }
    }
    
    
 
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{if(alertView.tag==33)
{
    passwordTextField.text=@"";
    confirmPasswordTextField.text=@"";
    
}
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
