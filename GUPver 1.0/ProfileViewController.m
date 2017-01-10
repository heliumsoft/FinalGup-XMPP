//
//  ProfileViewController.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "XMPPvCardTemp.h"

#import "ProfileViewController.h"
#import "SearchLocation.h"
#import "ChangePassword.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "JSON.h"

@interface ProfileViewController ()

@end


@implementation ProfileViewController
//@synthesize serverUrlString;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = NSLocalizedString(@"Profile", @"Profile");
        self.navigationItem.title = @" My Profile";
        //self.tabBarItem.image = [UIImage imageNamed:@"profile"];
        UIImage *selectedImage = [UIImage imageNamed:@"profile_blue"];
        UIImage *unselectedImage = [UIImage imageNamed:@"profile"];
        [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    reloadVariable =0;
    [self getProfileData];
    profileTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self initialiseView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self getProfileData];
    userNameTextField.text = getData[2];
    

        userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        userNameTextField.font = [UIFont fontWithName:@"Dosis-Bold" size:22.f];
        userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [userNameTextField setReturnKeyType:UIReturnKeyDone];
        userNameTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
        [userNameTextField setDelegate:self];
        
    
    [ accview setImage:nil];
    socialLogin=[[DatabaseManager getSharedInstance]recordExistOrNot:[NSString stringWithFormat:@"select * from master_table where social_login=1"]];
    if (socialLogin) {
        NSLog(@"socail%d",socialLogin);
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self getProfileData];
    // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[4]]];
    NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
    NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
    UIImage *profilePic = [UIImage imageWithData:pngData];
    if (profilePic) {
        profileImageView.image=profilePic;
    }
    else
    {
        profileImageView.image=[UIImage imageNamed:@"defaultProfile"];
    }
    
    
    
}
-(void)getProfileData
{
    DatabaseManager *getProfile;   //Get Profile Data From DATABASEMANAGER
    getProfile = [[DatabaseManager alloc] init];
    getData = [[NSMutableArray alloc]init];
    getData=[getProfile getProfileData];
    NSLog(@"profile data: %@",getData);
    
}

-(void)initialiseView
{
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    [profileTable setDelegate:self];
    [profileTable setDataSource:self];
    CALayer *imageLayer = profileImageView.layer;
    [imageLayer setCornerRadius:60];
    [imageLayer setBorderWidth:2];
    [imageLayer setBorderColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1].CGColor];
    [imageLayer setMasksToBounds:YES];
    
    NSLog(@"single press gesture");
    
    // Create and initialize a tap gesture
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    // Specify that the gesture must be a single tap
    tapRecognizer.numberOfTapsRequired = 1;
    // Add the tap gesture recognizer to the view
    [profileImageView addGestureRecognizer:tapRecognizer];
    
    
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
    
    
    if (!CGRectContainsPoint(aRect, TXFRAME.origin) && TXFRAME.origin.y>0) {
        
        CGPoint scrollPoint = CGPointMake(0.0, TXFRAME.origin.y-keyBdHeight);
        
        [mainScroll setContentOffset:scrollPoint animated:YES];
        
    }
    
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    mainScroll.contentInset = contentInsets;
    
    mainScroll.scrollIndicatorInsets = contentInsets;
    
    
    
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


- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"choose pic");
    NSString *option1 = @"Camera Shot";
    NSString *option2 = @"Gallery";
    NSString *option3 = @"Remove Photo";
    NSString *cancelTitle = @"Cancel";
    
    
    //if ([profileImageView.image isEqual:[UIImage imageNamed:@"defaultProfile.png"]] || [profileImageView.image isEqual:[UIImage imageNamed:@"profile_pic_default_300.jpg"]] || [profileImageView.image isEqual:[UIImage imageNamed:@"profile_pic_default_50.jpg"]])
    if ([getData[4]isEqualToString:@"profile_pic_default_300.jpg"]){
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      
                                      initWithTitle:@""
                                      
                                      delegate:self
                                      
                                      cancelButtonTitle:cancelTitle
                                      
                                      destructiveButtonTitle:Nil
                                      
                                      otherButtonTitles:option1, option2, nil];
        
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
        
        
    }
    
    else{
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      
                                      initWithTitle:@""
                                      
                                      delegate:self
                                      
                                      cancelButtonTitle:cancelTitle
                                      
                                      destructiveButtonTitle:Nil
                                      
                                      otherButtonTitles:option1, option2, option3, nil];
        
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
        
        
    }
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{    iPicker = [[UIImagePickerController alloc] init];
    
    [iPicker setDelegate:self];
    
    iPicker.allowsEditing = YES;
    
    //Get the name of the current pressed button
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    NSLog(@"button title:%i,%@",buttonIndex ,buttonTitle);
    
    if ([buttonTitle isEqualToString:@"Camera Shot"]) {
        
        NSLog(@"Other 1 pressed");
        
        {
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                
            {
                //[self.tabBarController.tabBar setHidden:YES];
                //[[UIApplication sharedApplication] setStatusBarHidden:YES];
                iPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:iPicker animated:YES completion:NULL];
                
            }
            
            else
                
            {
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Device has no camera"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil];
                
                [myAlertView show];
                
            }
            
            
            
        }
        
    }
    
    if ([buttonTitle isEqualToString:@"Gallery"]) {
        
        NSLog(@"Other 2 pressed");
        
        
        
        iPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [iPicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        
        [self presentViewController:iPicker animated:YES completion:NULL];
    }
    
    if ([buttonTitle isEqualToString:@"Remove Photo"]) {
        
        NSLog(@"Other 3 pressed");
        
        imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        [imageActivityIndicator setCenter:CGPointMake(80, 80)];
        [profileImageView addSubview:imageActivityIndicator];
        [imageActivityIndicator startAnimating];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSString *postData = [NSString stringWithFormat:@"user_id=%@",getData[0]];
        NSLog(@"$[%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/delete_profile_pic.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        deleteImageConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [deleteImageConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [deleteImageConn start];
        deleteImageResponse = [[NSMutableData alloc] init];
        //profileImageView.image=Nil;
        
        //[profileImageView setImage:[UIImage imageNamed:@"defaultProfile.png"]];
        //[self removeImage];
        
    }
    
    
    
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
        
    }
    
    
    
    
    
}
- (void)removeImage{
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[4]]];
    
    NSError *error = nil;
    if(![fileManager removeItemAtPath: imgPathRetrieve error:&error]) {
        NSLog(@"Delete failed:%@", error);
    } else {
        NSLog(@"image removed: %@", imgPathRetrieve);
    }
    
    /*   NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];*/
    /*   NSLog(@"Directory Contents:\n%@", [fileManager directoryContentsAtPath: appFolderPath]);*/
}

/*- (BOOL)prefersStatusBarHidden {
 return YES;
 }*/



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    chosenImage = [[UIImage alloc]init];
    chosenImage = info[UIImagePickerControllerEditedImage];
    imageData=UIImageJPEGRepresentation(chosenImage, 1);
    [iPicker dismissViewControllerAnimated:YES completion:NULL];
    // upload profile pic here
    
    imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [imageActivityIndicator setCenter:CGPointMake(80, 80)];
    [profileImageView addSubview:imageActivityIndicator];
    [imageActivityIndicator startAnimating];
    
    [self uploadDisplayPicToServer];
    
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    
    NSLog(@"imagePickerDidCancel");
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    
}




-(void)editProfile
{
    AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegateObj setTabBar];
    
}


#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectio{
    
    UIView *headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, profileTable.frame.size.width, 60)];
    
    UILabel *about = [[UILabel alloc] initWithFrame:CGRectMake(10,5, 300,20)];
    about.text =@"About Me";
    about.textAlignment = NSTextAlignmentCenter;
    about.font = [UIFont fontWithName:@"Dosis-Regular" size:18.0];
    about.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    [headerView addSubview:about];
    
    aboutme = [[UITextView alloc] initWithFrame:CGRectMake(10,25, 300, 40)];


    aboutme.text =getData[5];//    if ([aboutme respondsToSelector:@selector(setAttributedPlaceholder:)]) {
//        UIColor *color = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
//        aboutme.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Write something about yourself.." attributes:@{NSForegroundColorAttributeName: color}];
//    }
    [aboutme setAutocorrectionType:UITextAutocorrectionTypeDefault];
    aboutme.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //   [emailIdTextField setBackgroundColor:[UIColor greenColor]];
    [aboutme setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    aboutme.textAlignment =NSTextAlignmentLeft;
    [aboutme setDelegate:self];
    aboutme.font = [UIFont fontWithName:@"Dosis-Regular" size:13.f];
    aboutme.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    UIView *border =[[UIView alloc] initWithFrame:CGRectMake(0, 69, profileTable.frame.size.width, 1)];
    border.backgroundColor = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    border.layer.shadowColor =[UIColor grayColor].CGColor;
    border.layer.shadowOffset = CGSizeMake(5, 5);
    border.layer.shadowRadius =5;
    
    [headerView addSubview:border];
    [headerView addSubview:aboutme];
    
    return headerView;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        if (socialLogin)
            return 2;
        else
            return  3;
        else
            return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    UIImageView *iconView = [[UIImageView alloc]initWithFrame:CGRectMake(10,10,28,28)];
    [cell addSubview:iconView];
    cell.backgroundColor = [UIColor clearColor];
    
    
    UILabel *loc = [[UILabel alloc] initWithFrame: CGRectMake(43, 10, cell.frame.size.width-60,28)];
    
    [cell addSubview:loc];
    loc.font = [UIFont fontWithName:@"Dosis-Regular" size:16.0];
    loc.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    
    if(indexPath.row ==1){
        Location = [[UILabel alloc] initWithFrame: CGRectMake(43, 10, cell.frame.size.width-60,28)];
        
        [cell addSubview:Location];
        Location.font = [UIFont fontWithName:@"Dosis-Regular" size:16.0];
        Location.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];

    }
    
    if(indexPath.row>0){
        iconView.frame = CGRectMake(10,10,28,28);
        loc.frame = CGRectMake(43, 10, cell.frame.size.width-60,28);
    }else{
        iconView.frame = CGRectMake(10,0,28,28);
         loc.frame = CGRectMake(43, 0, cell.frame.size.width-60,28);
    }
    //    cell.contentView.layer.borderWidth=3;
    // cell.accessoryView.layer.borderWidth=2;
    if (reloadVariable == 1) {
        [self getProfileData];
        
    }
    if(indexPath.section == 0)
    {
        switch(indexPath.row) {
            
            case 0: // Initialize cell 2
            {
                iconView.image = [UIImage imageNamed:@"email.png"];
                if ([getData[1]isEqualToString:@"FACEBOOK"]) {
                    loc.text = @"Facebook";
                }
                else if ([getData[1]isEqualToString:@"GOOGLEPLUS"])
                {
                    loc.text = @"Google +";
                }
                else if ([getData[1]isEqualToString:@"TWITTER"])
                {
                    loc.text = @"Twitter";
                }
                else
                {
                    loc.text = getData[1];
                }
                
            }
                break;
            case 1: // Initialize cell 3
            {
                iconView.image = [UIImage imageNamed:@"locationlogo"];
                //cell.textLabel.text = @"Boston, USA";
                Location.text = getData[3];
               
            }
                break;
                
            case 2: // Initialize cell 4
            {if (!socialLogin)
            {
                iconView.image = [UIImage imageNamed:@"password"];
                loc.text = @"Change Password";
              
            }
            }
                break;
                
        }
        
    }
    return cell;
    
}
-(void)updateLocationLable:(NSString*)newLocation locationID:(NSInteger)locID;
{
    locationID=locID;
    selectedLocation=newLocation;
    NSLog(@"location ID %i",locationID);
    Location.text = newLocation;
    
    
    // location server update
    [self locationServerUpdate];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row==0)
        return 30;
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0)
    {
        if(indexPath.row == 2) {
            ChangePassword *changePasswordPage = [[ChangePassword alloc]init];
            changePasswordPage.userId=getData[0];
            
            [self.navigationController pushViewController:changePasswordPage animated:YES];
        }
        if (indexPath.row==1)
        {
            SearchLocation *object=[[SearchLocation alloc]init];
            [object wontToChangeLocationFrom:self];
            [self.navigationController pushViewController:object animated:NO];
        }
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField
{[uniquenessCheckConn cancel];
    [activityIndicator stopAnimating];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    TXFRAME=[self convertView:textField];
    
    TXFRAME=CGRectMake(TXFRAME.origin.x, TXFRAME.origin.y+40, TXFRAME.size.width,TXFRAME.size.height);
    
    NSLog(@"frame x=%f y=%f wi=%f he=%f",TXFRAME.origin.x,TXFRAME.origin.y,TXFRAME.size.width,TXFRAME.size.height);
    
    oldUserName=userNameTextField.text;
    savedImage= accview.image;
    NSLog(@"saved image: %@",savedImage);
    [ accview setImage:nil];
    accview=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    [accview setFrame:CGRectMake(userNameTextField.frame.origin.x+userNameTextField.frame.size.width, userNameTextField.frame.origin.y, 20, 20)];
    [self.view addSubview:accview];
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSLog(@"text field did end editing");
    [textField resignFirstResponder];
    NSLog(@"oldusername = %@ newusername = %@",oldUserName,userNameTextField.text);
    
    
    if (![oldUserName isEqualToString:userNameTextField.text]) {
        
        // server script checking for username uniqueness
        if (![textField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length==0){
            
            if (![textField.text isAlphaNumeric]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"Please enter alphabets or numbers only"   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [textField setText:getData[2]];
            }else{
                activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
                
                [accview addSubview: activityIndicator];
                
                [activityIndicator startAnimating];
                [self uniquenessCheckForUserName];
                
                
                //                NSXMLElement *vCard = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
                
                
                
            }
            
            
        }
        else
            textField.text=oldUserName;
    }else{
        accview=[[UIImageView alloc]initWithImage:savedImage];
       
       
        [accview setFrame:CGRectMake(userNameTextField.frame.origin.x+userNameTextField.frame.size.width, userNameTextField.frame.origin.y, 30, 30)];
        
        [self.view addSubview:accview];
    }
    
    
    /*CGRect viewFrame = self.view.frame;
     
     viewFrame.origin.y += animatedDistance;
     
     [UIView beginAnimations:nil context:NULL];
     
     [UIView setAnimationBeginsFromCurrentState:YES];
     
     [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
     
     [self.view setFrame:viewFrame];
     
     [UIView commitAnimations];
     //userNameTextField.text = getData[1];*/
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"should change characters in range");
    
    
    //  if ( ![string canBeConvertedToEncoding:NSASCIIStringEncoding])
    //      return NO;
    return  YES;
    
    
    //You code here...
    // return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)uniquenessCheckForUserName
{
    if ([userNameTextField .text stringByReplacingOccurrencesOfString:@" " withString:@""].length==0)
    {
        [activityIndicator stopAnimating];
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter user name"   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [alert show];
         reloadVariable =1;
         [profileTable reloadData];*/
    }
    else
    {
        NSString *userName=[NSString stringWithFormat:@"%@",userNameTextField.text];
        NSString *postData = [NSString stringWithFormat:@"user_id=%@&username=%@",getData[0],userName];
        NSLog(@"$[%@]",postData);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        //NSString *postData = [NSString stringWithFormat:@"username=%@",userName];
        //NSLog(@"$[username=%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/check_username.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        uniquenessCheckConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [uniquenessCheckConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [uniquenessCheckConn start];
        eventsResponse = [[NSMutableData alloc] init];
    }
    
}
-(void)locationServerUpdate
{
    NSLog(@"You have clicked submit%i%@",locationID,getData[0]);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@&location_id=%i",getData[0],locationID];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_location.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    updateLocationConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [updateLocationConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [updateLocationConn start];
    updateLocationResponse = [[NSMutableData alloc] init];
    
}

-(void)aboutMeUpdate
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@&about_us=%@",getData[0],aboutme.text];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_aboutus.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    updateAbout = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [updateAbout scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [updateAbout start];
    updateResponse = [[NSMutableData alloc] init];
    
}


//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == uniquenessCheckConn) {
        
        [eventsResponse setLength:0];
        
    }
    if (connection == updateLocationConn) {
        NSLog(@"1");
        [updateLocationResponse setLength:0];
    }
    if (connection == uploadProfilePicConn) {
        NSLog(@"1");
        [uploadProfilePicResponse setLength:0];
    }
    if (connection == deleteImageConn) {
        
        [deleteImageResponse setLength:0];
        
    }
    if (connection == updateAbout) {
        
        [updateResponse setLength:0];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == uniquenessCheckConn) {
        
        [eventsResponse appendData:data];
        
    }
    if (connection == updateLocationConn) {
        
        NSLog(@"2");
        [updateLocationResponse appendData:data];
    }
    if (connection == uploadProfilePicConn) {
        
        NSLog(@"2");
        [uploadProfilePicResponse appendData:data];
    }
    if (connection == deleteImageConn) {
        
        [deleteImageResponse appendData:data];
        
    }
    
    if (connection == updateAbout) {
        
        [updateResponse appendData:data];
        
    }

    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == uniquenessCheckConn) {
        [activityIndicator stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    if (connection == updateLocationConn) {
        NSLog(@"not updated");
        // DBManager Class to update Profile variable
        DatabaseManager *profileUpdateVariable;
        profileUpdateVariable = [[DatabaseManager alloc] init];
        [profileUpdateVariable setUpdateProfileVariable:1 userLoggedInId:getData[0]];
    }
    if (connection == uploadProfilePicConn) {
        [imageActivityIndicator stopAnimating];
        [imageActivityIndicator removeFromSuperview];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    if (connection == deleteImageConn) {
        [imageActivityIndicator stopAnimating];
        [imageActivityIndicator removeFromSuperview];
    }
    
}/*
  -(void)fetchIDS
  {contactIDs=[[NSMutableArray alloc]init];
  NSArray *output =  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select user_id from contacts where deleted=0"];
  for (int i=0; i<[output count]; i++)
  {NSString *idVal=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_ID" ForRowIndex:i givenOutput:output];
  NSLog(@"str %@",idVal);
  if (![idVal isEqual:[NSNull null]])
  {
  [contactIDs addObject:idVal];
  }
  }
  NSLog(@"id array %@",contactIDs);
  }*/

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    int status=0;
    if (connection == uniquenessCheckConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:eventsResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        NSLog(@"vishals responce %@",responce);
        status= [responce[@"status"] integerValue];
        NSString *error_Message=responce[@"error_message"];
        
        NSLog(@"{'response':{'status:%i,'error_message:%@,'}}",status,error_Message);
        [activityIndicator stopAnimating];
        
        if ([userNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length!=0)
        {
            if (status==1)
                
            {
                
                userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                accview=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tick" ]];
                
                [accview setFrame:CGRectMake(userNameTextField.frame.origin.x+userNameTextField.frame.size.width, userNameTextField.frame.origin.y, 30, 30)];
                
                [self.view addSubview:accview];
                
                [self appDelegate].MyUserName=userNameTextField.text ;
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update  master_table set display_name = '%@' where logged_in_user_id = '%@' ",[userNameTextField.text normalizeDatabaseElement],getData[0]]];
                
                NSString *updateMembers=[NSString stringWithFormat:@"update  group_members set contact_name ='%@' where contact_id = '%@'",[userNameTextField.text normalizeDatabaseElement],getData[0]];
                
                NSLog(@"query %@",updateMembers);
                
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateMembers];
                
                dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
                dispatch_async(queue, ^{
                    
                    
                    XMPPvCardTemp *myVcardTemp = [[self appDelegate].xmppvCardTempModule myvCardTemp];
                    
                    [myVcardTemp setName:userNameTextField.text];
                    
                    //                    [myVcardTemp setPhoto:imageData];
                    
                    [[self appDelegate].xmppvCardTempModule updateMyvCardTemp:myVcardTemp];
                    
                });
                
                
                
            }else{
                
                userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                accview=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cancel" ]];
                
                
                [accview setFrame:CGRectMake(userNameTextField.frame.origin.x+userNameTextField.frame.size.width, userNameTextField.frame.origin.y, 30, 30)];
                
                [self.view addSubview:accview];
                /*UIAlertView *loginWarning=[[UIAlertView alloc]initWithTitle:@"Warning" message:responce[@"error_message"] delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
                 
                 [loginWarning show];*/
                //userNameTextField.text=@"";
                //[profileTable reloadData];
                
                
            }
            
        }
        uniquenessCheckConn=nil;
        
        [uniquenessCheckConn cancel];
        
    }
    if (connection == updateLocationConn) {
        NSString *str = [[NSMutableString alloc] initWithData:updateLocationResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        NSLog(@"responce %@",responce);
        status= [responce[@"status"] integerValue];
        NSString *error_Message=responce[@"error_message"];
        NSLog(@"{'response':{'status:%i,'error_message:%@,'}}",status,error_Message);
        if (status==1){
            NSLog(@"updated");
            // DBManager Class to insert/update Profile Data
            DatabaseManager *locationUpdate;
            locationUpdate = [[DatabaseManager alloc] init];
            [locationUpdate updateLocation:selectedLocation locationId:locationID userLoggedInId:getData[0]];
            
        }else{
            NSLog(@"not updated");
            // DBManager Class to update Profile variable
            DatabaseManager *profileUpdateVariable;
            profileUpdateVariable = [[DatabaseManager alloc] init];
            [profileUpdateVariable setUpdateProfileVariable:1 userLoggedInId:getData[0]];
            
            
        }
        
        updateLocationConn=nil;
        [updateLocationConn cancel];
        
    }
    if (connection == updateAbout) {
        NSString *str = [[NSMutableString alloc] initWithData:updateResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        NSLog(@"responce %@",responce);
        status= [responce[@"status"] integerValue];
        NSString *error_Message=responce[@"error_message"];
        NSLog(@"{'response':{'status:%i,'error_message:%@,'}}",status,error_Message);
        
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"UPDATE master_table set about_us='%@'",aboutme.text]];
     
        
     
        [self getProfileData];
        
        [profileTable reloadData];
        updateResponse=nil;
        [updateAbout cancel];
        
    }
    if (connection == uploadProfilePicConn) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:uploadProfilePicResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@" result %@",res);
        NSDictionary *response= res[@"response"];
        NSLog(@"response %@",response);
        status = [response[@"status"] integerValue];
        NSString *error = response[@"error"];
        NSString *picName = response[@"profile_pic"];
        NSLog(@"status = %i error =  %@ profile pic= %@",status,error,response[@"profile_pic"]);
        if (status ==1){
            
            profileImageView.image = chosenImage;
            
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"UPDATE master_table set display_pic='%@'",picName]];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSLog(@"paths=%@",paths);
            NSString *profilePicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",picName]];
            NSLog(@"profile pic path=%@",profilePicPath);
            
            //Writing the image file
            [imageData writeToFile:profilePicPath atomically:YES];
            [imageActivityIndicator stopAnimating];
            [imageActivityIndicator removeFromSuperview];
            [self getProfileData];
            
        }else{
            
            [imageActivityIndicator stopAnimating];
            [imageActivityIndicator removeFromSuperview];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
        
    }
    
    if (connection == deleteImageConn) {
        
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:deleteImageResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@" result %@",res);
        NSDictionary *response= res[@"response"];
        NSLog(@"response %@",response);
        status = [response[@"status"] integerValue];
        NSString *error = response[@"error"];
        NSLog(@"status = %i error =  %@",status,error);
        if (status ==1){
            
            profileImageView.image=Nil;
            [profileImageView setImage:[UIImage imageNamed:@"defaultProfile.png"]];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSLog(@"paths=%@",paths);
            [[DatabaseManager getSharedInstance]executeQueryWithQuery:@"UPDATE master_table set display_pic='profile_pic_default_300.jpg'"];
            NSString *profilePicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",@"profile_pic_default_300.jpg"]];
            NSLog(@"profile pic path=%@",profilePicPath);
            imageData=UIImageJPEGRepresentation(profileImageView.image, 1);
            //Writing the image file
            [imageData writeToFile:profilePicPath atomically:YES];
            [imageActivityIndicator stopAnimating];
            [imageActivityIndicator removeFromSuperview];
            [self getProfileData];
        }
        else
        {
            [imageActivityIndicator stopAnimating];
            [imageActivityIndicator removeFromSuperview];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        
        
    }
    
    if (status==1)
    {//if(contactIDs==nil)
        //  [self fetchIDS];
        [[self appDelegate]updateProfile];
        /*for (int j=0;j<[contactIDs count] ; j++)
         {
         NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
         [attributeDic setValue:@"chat" forKey:@"type"];
         [attributeDic setValue:[[contactIDs objectAtIndex:j] JID]forKey:@"to"];
         [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
         [attributeDic setValue:@"0" forKey:@"isResend"];
         NSString *body=[NSString stringWithFormat:@"notifications from "];
         NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
         [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID] forKey:@"from_user_id"];
         [elementDic setValue:@"text" forKey:@"message_type"];
         [elementDic setValue:@"1" forKey:@"contactUpdate"];
         
         [elementDic setValue:@"0" forKey:@"isgroup"];
         //  NSLog(@"gid %@",groupId);
         // [elementDic setValue:[NSString stringWithFormat:@"%@",groupId ] forKey:@"groupID"];
         [elementDic setValue:body forKey:@"body"];
         
         [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
         }*/
    }
    
    
}

-(void)uploadDisplayPicToServer
{
    //NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"first.png"], 90);
    
    
    
    NSString *urlString =[NSString stringWithFormat:@"%@/scripts/update_profile_pic.php",gupappUrl]; // URL of upload script.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    /*
     NSString *boundary = @"---------------------------14737809831466499882746641449";
     NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
     [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
     */
    
    NSMutableData *body = [NSMutableData data];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"profile_pic\"; filename=\"a.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //  parameter username
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[getData[0] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    // NSError *oo;
    uploadProfilePicConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [uploadProfilePicConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [uploadProfilePicConn start];
    uploadProfilePicResponse = [[NSMutableData alloc] init];
    /*
     NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&oo];
     NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
     NSLog(@"returnString: %@ \n error=%@", returnString,oo);
     *///
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [userNameTextField resignFirstResponder];
}


@end
