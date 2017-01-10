//
//  CreateProfile.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "CreateProfile.h"
#import "NSString+Utils.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "SearchLocation.h"
#import "DatabaseManager.h"
#import "LandingPage.h"
@interface CreateProfile ()

@end

@implementation CreateProfile

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Create Profile";
        [self.navigationController setNavigationBarHidden:NO animated:NO];
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
    [cell.textLabel setText:locationName];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [loadingLocation stopAnimating];
    [loadingLocation removeFromSuperview];
    [locationManager stopUpdatingLocation];

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
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyBdHeight+60, 0.0);
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;
    
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyBdHeight;
    
    if (!CGRectContainsPoint(aRect, TXFRAME.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, TXFRAME.origin.y-keyBdHeight);
        [mainScroll setContentOffset:scrollPoint animated:YES];
    }
    
    
    
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
    
    if (status==kCLAuthorizationStatusDenied){
        
        NSLog(@"2%i",[CLLocationManager authorizationStatus]);
        [loadingLocation stopAnimating];
        [cell.textLabel setText:@"Location"];
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
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
         //   addressName = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",                           MAX(placemark.subThoroughfare,@""),MAX( placemark.thoroughfare,@""),                           MAX( placemark.postalCode,@""),MAX(placemark.locality,@""),                           MAX(placemark.administrativeArea,@""), MAX(placemark.country,@"")];
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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0,0, 0, 0);
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchLocation];
     appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.navigationItem.hidesBackButton=YES;
    [self.navigationController.navigationBar setHidden:false];
    NSLog(@"x=%f y=%f width=%f height=%f",mainScroll.frame.origin.x,mainScroll.frame.origin.y,mainScroll.frame.size.width,mainScroll.frame.size.height);
    nameVerification=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingLocation=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    //self.navigationController.navigationBarHidden = FALSE;
    // Do any additional setup after loading the view from its nib.
     userNameTextField=[[UITextField alloc]init];
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    mainScroll.scrollEnabled=true;
    mainScroll.showsVerticalScrollIndicator=true;
    NSLog(@"scroll frame %f %f %f %f",mainScroll.frame.origin.x,mainScroll.frame.origin.y,mainScroll.frame.size.width,mainScroll.frame.size.height);
    //mainScroll.layer.borderWidth=3.0f;
    [mainScroll setContentSize:CGSizeMake(mainScroll.frame.size.width,mainScroll.frame.size.height-64)];
  //  social_login_type=@"";
   // social_login_idl_login=0;
    PROFILEIMAGE.userInteractionEnabled = YES;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    tapRecognizer.numberOfTapsRequired = 1;
    
    [PROFILEIMAGE addGestureRecognizer:tapRecognizer];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    

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
-(void)dismissKeyboard {
    [userNameTextField resignFirstResponder];
}

- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"choose pic");
    NSString *option1 = @"Camera Shot";
    NSString *option2 = @"Gallery";
    NSString *option3 = @"Remove Photo";
    NSString *cancelTitle = @"Cancel";
    if ([PROFILEIMAGE.image isEqual:[UIImage imageNamed:@"defaultProfile.png"]])
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
{ Ipicker = [[UIImagePickerController alloc] init];
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
                
                
                
                Ipicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                [self presentViewController:Ipicker animated:YES completion:NULL];
            }
            else
            {
                
              //  UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:Nil                                                                      message:@"Device has no camera"                                                                     delegate:nil                                                            cancelButtonTitle:@"OK"                                                            otherButtonTitles: nil];
                
             //   [myAlertView show];
                
            }
            
        }
    }
    if ([buttonTitle isEqualToString:@"Gallery"]) {
        NSLog(@"Other 2 pressed");
        
           Ipicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [Ipicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        
        [self presentViewController:Ipicker animated:YES completion:NULL];
        
    }
    if ([buttonTitle isEqualToString:@"Remove Photo"]) {
        NSLog(@"Other 3 pressed");
        PROFILEIMAGE.image=Nil;
        [PROFILEIMAGE setImage:[UIImage imageNamed:@"defaultProfile.png"]];
    }
    
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
    }
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    PROFILEIMAGE.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)initCreatePofileWith:(NSString*)socialLoginType social_Login_ID:(NSString*)uniqueID
{NSLog(@"type %@ id %@",socialLoginType,uniqueID);
    social_login_type=[[NSString alloc]init];
    social_login_idl_login=[[NSString alloc]init];
    social_login_type=socialLoginType;
    social_login_idl_login=uniqueID;
}
-(BOOL)checkForFormCompletness
{BOOL FormComplete,usernameEmpty,locationEmpty;
    NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
    NSString *alertMsg=@"Please Enter";
    if([userNameTextField.text length]==0||[cell.textLabel.text length]==0)
    {if([userNameTextField.text length]==0)
        usernameEmpty=true;
        if ([[userNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0)
        {usernameEmpty=true;
            alertMsg=[alertMsg stringByAppendingString:@" Username ,"];
        }
        if ([[cell.textLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0)
        {locationEmpty=true;
            alertMsg=[alertMsg stringByAppendingString:@" Location ,"];
        }
               alertMsg=[alertMsg substringToIndex:[alertMsg length]-1];
        
       // alertMsg=[alertMsg stringByAppendingString:@" and Try Again"];
        
        FormComplete=false;
        UIAlertView *done=[[UIAlertView alloc]initWithTitle:Nil message:alertMsg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [done show];
    }
    else
    {FormComplete= true;
    }
    return FormComplete;
    
    
}

-(IBAction)openHomePage:(id)sender
{

    
        if ([self checkForFormCompletness])
    {
      
                if (usernameIsUnique)
                {
                    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    HUD.delegate = self;
                    HUD.dimBackground = YES;
                    HUD.labelText = @"Please Wait";
                    
                    //  NSString *str=[NSString stringWithFormat:@"%@registration.php",appdel.baseUrl];
                    //  NSString *urlString = [NSString stringWithFormat:@"%@",str];
                  //  NSData *imageData = UIImageJPEGRepresentation(PROFILEIMAGE.image, 0.9);
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/add_user.php",gupappUrl]]];
                    [request setHTTPMethod:@"POST"];
                    NSMutableData *body = [NSMutableData data];
                    NSString *boundary = @"---------------------------14737809831466499882746641449";
                    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
                    NSData *imageData;
                    if (![PROFILEIMAGE.image isEqual:[UIImage imageNamed:@"defaultProfile.png"] ]) {
                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Disposition: form-data; name=\"profile_pic\"; filename=\"a.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                        imageData = UIImageJPEGRepresentation(PROFILEIMAGE.image, 0.9);
                        [body appendData:[NSData dataWithData:imageData]];
                         [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    }

                   // [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                 //   [body appendData:[@"Content-Disposition: form-data; name=\"profile_pic\"; filename=\"a.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                 //   [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                   // [body appendData:[NSData dataWithData:imageData]];
                   
                   // &deviceToken=%@&deviceType=2
                    //  parameter username
                    // versionCode
                    NSLog(@"device Token %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"versionCode\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[appVersionString dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    

                    //  parameter username
                   // versionCode
                    
                    NSLog(@"device Token %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"]);
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"deviceToken\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    

                    //  parameter username
                    
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"deviceType\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[@"2" dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    

                    //  parameter username
                    
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[userNameTextField.text dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                   
                    //  parameter token
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"social_login_type\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[social_login_type dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    
                    // parameter method
                    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"social_login_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    [body appendData:[social_login_idl_login dataUsingEncoding:NSUTF8StringEncoding]];
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
                    
                    [body appendData:[[NSString stringWithFormat:@"1"] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    
                    
                    // close form
                    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    NSLog(@"%@",body);
                    // setting the body of the post to the reqeust
                    [request setHTTPBody:body];
                    
                    
                    //   NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                    // NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                    //    NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
                    //   NSLog(@"%@",dict);
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    /*
                     
                     
                     
                     NSString *name=[NSString stringWithFormat:@"%@",userNameTextField.text];
                     NSString *passwordTS=[NSString stringWithFormat:@"%@",passwordTextField.text];
                     NSString *emailTS=[NSString stringWithFormat:@"%@",emailIdTextField.text];
                     NSString *locationTS=[NSString stringWithFormat:@"%i",locationID];
                     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                     
                     //  NSString *url=[NSURL URLWithString:@"http://198.154.98.11/~gup/scripts/add_user.php"];
                     
                     NSString *postData = [NSString stringWithFormat:@"username=%@&password=%@&email=%@&location_id=%@&social_login=0",name,passwordTS,emailTS,locationTS];
                     NSLog(@"request %@",postData);
                     
                     [request setURL:[NSURL URLWithString:@"http://gupapp.com/Gup_demo/scripts/add_user.php"]];
                     
                     [request setHTTPMethod:@"POST"];
                     
                     [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                     
                     //set post data of request
                     
                     [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                     
                     //initialize a connection from request
                     */
                    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                    
                    [connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    
                    [connection1 start];
                    
                    SignUpResponse = [[NSMutableData alloc] init];
                    NSLog(@"type %@ id %@",social_login_type,social_login_idl_login);
                }
                else
                { UIAlertView *userName=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter Unique Display Name" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                    [userName show];
                                 }
                
            }
    
        

 //   AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   // [appDelegateObj setTabBar];

}


#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
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
    }
    
    switch(indexPath.row) {
        case 0: // Initialize cell 1
        {
            
            
            [userNameTextField setFrame:CGRectMake(15, 0, cell.frame.size.width-60, cell.frame.size.height)];
            userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            [userNameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            userNameTextField.placeholder=@"User Name";
            userNameTextField.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                        [userNameTextField setAutocorrectionType:UITextAutocorrectionTypeDefault];
            [userNameTextField setTag:0];
            userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
          //   userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [nameVerification setFrame:CGRectMake(0, 0, 30,30)];
            [cell addSubview:nameVerification];
            
            [userNameTextField setDelegate:self];
            [cell addSubview:userNameTextField];
        }
            
            break;
        case 1: // Initialize cell 2
        {
            [loadingLocation setBackgroundColor:[UIColor clearColor]];
            [loadingLocation setFrame:CGRectMake(form.frame.size.width-32,12 , 20,20)];
            
            [loadingLocation setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin];
            [cell addSubview:loadingLocation];
            
            
            
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            [cell.textLabel setText:@" "];
            
            NSLog(@"%hhd",[CLLocationManager locationServicesEnabled]);
            if([CLLocationManager locationServicesEnabled]){
                
                
                
                if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied) {
                    NSLog(@"2%i",[CLLocationManager authorizationStatus]);
                    
                    
                    [cell.textLabel setText:@"Location"];
                    [cell.textLabel setTextColor:[UIColor lightGrayColor]];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    
                }
                else
                {
                    
                    [loadingLocation startAnimating];
                    
                }
                
                
                
            }
            
            
            
        }
    }
    
    
    return cell;
    
    
    
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES ];
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

-(void)fetchLocation
{
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    locationManager.delegate = self;
    
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusNotDetermined && [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        // choose one request according to your business.
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
            [locationManager  requestWhenInUseAuthorization];
            //  [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Request authorization.. :)", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
        }
    }
    
    [locationManager startUpdatingLocation];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [userNameTextField resignFirstResponder];
    //[locationTextField resignFirstResponder];
  
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"did recieve response");
    
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@" finished loading");
    if (connection == connection1) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:SignUpResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        NSLog(@"vishals responce %@",responce);
        if ([responce[@"status"] integerValue])
        {   int userID=[responce[@"userid"]integerValue ];
            NSString *displayPic=[NSString stringWithFormat:@"profile_pic_%i_300",userID];
            NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
            UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
            NSString *locationName=cell.textLabel.text;
         //   NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"wallpaper1@2x.png"];
            
            NSLog(@"query %@",[NSString stringWithFormat:@"INSERT INTO master_table (id ,logged_in_user_id,verified, display_name,display_pic,social_login,social_login_type,social_login_id,location_id,location,status) VALUES(%i,%i,1,'%@','%@',1,'%@','%@',%i,'%@','online')",1,userID,[userNameTextField.text normalizeDatabaseElement],[displayPic normalizeDatabaseElement],social_login_type,[social_login_idl_login normalizeDatabaseElement],locationID,[locationName normalizeDatabaseElement]]);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:@"delete from master_table"];
            [[DatabaseManager getSharedInstance] saveDataInTableWithQuery:[NSString stringWithFormat:@"INSERT INTO master_table (id ,logged_in_user_id,verified, display_name,display_pic,social_login,social_login_type,social_login_id,location_id,location,last_logged_in,version_no,status) VALUES(%i,%i,1,'%@','%@',1,'%@','%@',%i,'%@','%@',%@,'online')",1,userID,[userNameTextField.text normalizeDatabaseElement],[displayPic normalizeDatabaseElement],social_login_type,[social_login_idl_login normalizeDatabaseElement],locationID,[locationName normalizeDatabaseElement],[NSString CurrentDate],appVersionString  ]];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            //NSLog(@"paths=%@",paths);
            NSString *profilePicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",displayPic] ];
            NSLog(@"profile pic path=%@",profilePicPath);
            
            //Writing the image file
            NSData *imageData = UIImageJPEGRepresentation(PROFILEIMAGE.image, 0.9);
            
            [imageData writeToFile:profilePicPath atomically:YES];
            
            NSString *username=[NSString stringWithFormat:@"user_%i",userID];
            NSString *jid=[username stringByAppendingString:(NSString*)jabberUrl];
            NSString *password=[NSString stringWithFormat:@"password_%i_user",userID];
            NSString *universalID=@"";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:jid forKey:@"Jid"];
            [defaults setObject:password forKey:@"Password"];
            [defaults synchronize];
            
            [[self appDelegate]registrationWithUserName:username password:password name:userNameTextField.text emailid:universalID];
            
//            AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            [appDelegateObj setTabBar];
            LandingPage *lp=[[LandingPage alloc]init];
            [self.navigationController pushViewController:lp animated:YES];
            
        }
        else
        {
            UIAlertView *signUpWarning=[[UIAlertView alloc]initWithTitle:Nil message:responce[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [signUpWarning show];
            
        }
        
        connection1=nil;
        [connection1 cancel];
        [HUD hide:YES];

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
      ///*  NSString *errormsg=*/responce[@"error_message"];
        [nameVerification stopAnimating];

        if ([userNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length!=0)
        {
        if (usernameIsUnique)
        {//[nameVerification stopAnimating];
            //  [nameVerification removeFromSuperview];
            NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            usernameIsUnique=true;
        }
        else
        {//[nameVerification stopAnimating];
            // [nameVerification removeFromSuperview];
            
           // UIAlertView *userName=[[UIAlertView alloc]initWithTitle:Nil message:errormsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
          //  [userName show];
            NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewCell *cell = [form cellForRowAtIndexPath:indexPath1];
            UIImageView *accview=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cancel.png" ]];
            [accview setFrame:CGRectMake(0, 0, 20, 20)];
            cell.accessoryView=accview;
            
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
                cell.textLabel.text=location;
                locationID=[tempdict[@"id"] integerValue];
                break;
            }
            
            
            
            
        }
        [loadingLocation stopAnimating];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        getLocation=nil;
        [getLocation cancel];
    }
    
    
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
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
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
-(void)textFieldDidEndEditing:(UITextField *)textField
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
        if (![userNameTextField.text isEqual:@""])
        {
            if (![textField.text isAlphaNumeric]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"Please enter alphabets or numbers only"   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                 [nameVerification stopAnimating];
                [textField setText:@""];
            }
            else
            {
            NSString *name=[NSString stringWithFormat:@"%@",userNameTextField.text];
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

@end
