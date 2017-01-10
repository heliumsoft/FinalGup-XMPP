//
//  viewPrivateGroup.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "viewPrivateGroup.h"
#import "NSString+Utils.h"
#import "AppDelegate.h"
#import "JoinRequest.h"
#import "ManageMembers.h"
#import "CategoryList.h"
#import "DatabaseManager.h"
#import "JSON.h"
#import "ShareGroupInfo.h"
#import "SearchLocation.h"
#import "ViewMembers.h"
#import "ContactList.h"

@interface viewPrivateGroup (){
    //    UIActivityIndicatorView *spinner;
    NSInteger cellPath;
}

@end

@implementation viewPrivateGroup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"Group Name";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
@synthesize groupType,groupId,viewType;

- (void)viewDidLoad{
    
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self getGroupJoinRequestCount];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
   
    tapRecognizer.numberOfTapsRequired = 1;
    [groupImageView addGestureRecognizer:tapRecognizer];
    NSLog(@"group id%@ group type%@",groupId,groupType);
    [self refreshGroupInfo];
    
   
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_detail_android.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    memberConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [memberConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [memberConnection start];
    memberRsponce = [[NSMutableData alloc] init];
}
-(void)refreshGroupInfo{
    
    self.groupName.text = self.title;
    self.groupDesc.font = [UIFont fontWithName:@"Dosis-Regular" size:13];
    self.categoryInfo.font = [UIFont fontWithName:@"Dosis-SemiBold" size:16];
    self.createdInfo.font = [UIFont fontWithName:@"Dosis-Regular" size:11];
    self.totalMembers.font = [UIFont fontWithName:@"Dosis-SemiBold" size:15];
    self.typeInfo.font = [UIFont fontWithName:@"Dosis-SemiBold" size:15];
    self.sharelabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:15];
    self.groupName.font = [UIFont fontWithName:@"Dosis-SemiBold" size:18];
    self.inviteButton.titleLabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:16];
    self.pendinglabel.titleLabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:16];
    self.createdInfo.hidden = YES;
    self.pendinglabel.hidden = YES;
    self.pendingImage.hidden = YES;
    
    self.groupDesc.delegate = self;
    self.groupName.delegate = self;
    groupImageView.layer.cornerRadius = 25;
    groupImageView.clipsToBounds = YES;
    
    self.totalMembers.userInteractionEnabled = YES;
    self.sharelabel.userInteractionEnabled = YES;
    self.categoryInfo.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *titletap2= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCategory)];
    [self.categoryInfo addGestureRecognizer:titletap2];
    
    UITapGestureRecognizer *titletap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openGroupMember)];
    [self.totalMembers addGestureRecognizer:titletap1];
    
    UITapGestureRecognizer *titletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareGroupInfo)];
    [self.sharelabel addGestureRecognizer:titletap];
    
    // Do any additional setup after loading the view from its nib.
    NSString *checkIfExists;
    if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]){
        if([groupType isEqualToString:@"private#local"])
            self.typeInfo.text =@"Local";
        else
            self.typeInfo.text =@"Global";
        checkIfExists=[NSString stringWithFormat:@"select * from groups_private where group_server_id=%@",groupId];
    }else{
        if([groupType isEqualToString:@"public#local"])
            self.typeInfo.text =@"Local";
        else
            self.typeInfo.text =@"Global";
        checkIfExists=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groupId];
    }

    
    if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] || [groupType isEqualToString:@"private"]) {
        NSArray *getData = [[NSArray alloc]init];
        getData = [[DatabaseManager getSharedInstance]getPrivateGroupInfo:groupId];
        NSLog(@"data %@",getData);
        groupPic=getData[0];
        groupDesc=[getData[1]isEqual:[NSNull null]]?@"":getData[1];
        categoryName=getData[3];
        GName=getData[6];
        NSLog(@"group pic:%@,groupdesc:%@,category:%@",groupPic,groupDesc,categoryName);
        
    }else{
        NSArray *getData = [[NSArray alloc]init];
        getData = [[DatabaseManager getSharedInstance]getPublicGroupInfo:groupId];
        groupPic=getData[0];
        groupDesc=[getData[1]isEqual:[NSNull null]]?@"":getData[1];
        categoryName=getData[2];
        groupLocation=getData[4];
        GName=getData[7];
        NSLog(@"group pic:%@,groupdesc:%@,category:%@,group loc:%@",groupPic,groupDesc,categoryName,groupLocation);
        NSString *checkIfAlreadyAddAsFav;
        checkIfAlreadyAddAsFav=[NSString stringWithFormat:@"select * from groups_public where group_server_id=%@",groupId];
        BOOL addedFav=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfAlreadyAddAsFav];
        NSLog(@"bool added %d",addedFav);
    }
    self.title=GName;
    self.groupName.text = self.title;
    
    // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",groupPic]];
    NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
    NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
    UIImage *groupPicData = [UIImage imageWithData:pngData];
    if (groupPicData) {
        groupImageView.image=groupPicData;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,groupPic]]];
            groupImageView.image=[UIImage imageWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSLog(@"paths=%@",paths);
                NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",groupPic]];
                NSLog(@"group pic path=%@",groupPicPath);
                //Writing the image file
                [imgData writeToFile:groupPicPath atomically:YES];
                
                
            });
            
        });
        
        
    }else{
        imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        //[imageActivityIndicator setCenter:groupImageView.center];
        [imageActivityIndicator setCenter:CGPointMake(50.0,50.0)];
        imageActivityIndicator.color = [UIColor blackColor];
        [groupImageView addSubview:imageActivityIndicator];
        [imageActivityIndicator startAnimating];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,groupPic]]];
            groupImageView.image=[UIImage imageWithData:imgData];
            [imageActivityIndicator stopAnimating];
            [imageActivityIndicator removeFromSuperview];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSLog(@"paths=%@",paths);
                NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",groupPic]];
                NSLog(@"group pic path=%@",groupPicPath);
                //Writing the image file
                [imgData writeToFile:groupPicPath atomically:YES];
                
                
            });
            
        });
        
        //groupImageView.image=[UIImage imageNamed:@"defaultGroup"];
    }
    [self plotData];
}

- (IBAction)Addmember:(id)sender{
    
    ContactList *openContactList = [[ContactList alloc]init];
    //openContactList.memberID=memberId;
    openContactList.hideUnhideSkipDoneButton=@"hide";
    openContactList.groupStatus = groupType;
    openContactList.groupId = groupId;
    openContactList.groupName = groupName;
    openContactList.viewType=viewType;
    [self.navigationController pushViewController:openContactList animated:NO];
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
     [self plotData];
    groupJoinCount = [[DatabaseManager getSharedInstance]fetchGroupJoinRequestCount:groupId];
    totalMembersCount = [[DatabaseManager getSharedInstance]countGroupMembers:groupId];
    NSLog(@"total members: %d",totalMembersCount);
    
    self.totalMembers.text = [NSString stringWithFormat:@"%d members",totalMembersCount];
    
}

-(void)plotData{
    
    if ([self.groupDesc.text isEqualToString:@""]) {
//descTextField.placeholder = @"Enter Description";
     }
    else
    {
        self.groupDesc.text = groupDesc;
    }
        
    if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
        self.groupName.userInteractionEnabled= YES;
        self.groupDesc.userInteractionEnabled= NO;
    }
    else if([groupType isEqualToString:@"public#local"]||[groupType isEqualToString:@"public#global"] ||[groupType isEqualToString:@"public"])
    {
        self.groupName.userInteractionEnabled= NO;
        self.groupDesc.userInteractionEnabled= NO;
    }
    
    
    self.categoryInfo.text=[NSString stringWithFormat:@"Category: %@",categoryName];
    
    
        if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
            //if([[NSUserDefaults standardUserDefaults] objectForKey:@"preMember"])
                //self.totalMembers.text =[NSString stringWithFormat:@"%@ members",[[NSUserDefaults standardUserDefaults] objectForKey:@"preMember"]];
           
          
        }
    
    
        if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
           
            if (!(groupJoinCount==0)) {
                [self.pendingImage setHidden:NO];
                [self.pendinglabel setHidden:NO];
                self.pendinglabel.titleLabel.text=[NSString stringWithFormat:@"%d Pending Join Request",groupJoinCount];
                
                
            }
            else
            {
                [self.pendingImage setHidden:YES];
                [self.pendinglabel setHidden:YES];
                
            }
            
            
            
        }
    
    self.locationLbl.titleLabel.text = [NSString stringWithFormat:@"%@",groupLocation];
    
    
}


- (void) keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"hei %f wi %f",kbSize.height,kbSize.width);
    float keyBdHeight;
    if (kbSize.height<kbSize.width){
        keyBdHeight=kbSize.height;
    }else{
        keyBdHeight=kbSize.width;
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyBdHeight+60, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyBdHeight;
    if (!CGRectContainsPoint(aRect, TXFRAME.origin) && TXFRAME.origin.y>0) {
        CGPoint scrollPoint = CGPointMake(0.0, TXFRAME.origin.y-keyBdHeight);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
    
}

- (void) keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
}
- (IBAction)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    // if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"]) {
    NSLog(@"choose pic");
    NSString *option1 = @"Camera Shot";
    NSString *option2 = @"Gallery";
    NSString *option3 = @"Remove Photo";
    NSString *cancelTitle = @"Cancel";
    
    //if ([groupImageView.image isEqual:[UIImage imageNamed:@"defaultGroup.png"]] || [groupImageView.image isEqual:[UIImage imageNamed:@"group_pic_default_50.jpg"]] || [groupImageView.image isEqual:[UIImage imageNamed:@"group_pic_default_300.jpg"]])
    if ([groupPic isEqualToString:@"group_pic_default_300.jpg"]){
        
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
    // }
    
    // SetProfilePic *changeProfilePic = [[SetProfilePic alloc]init];
    // changeProfilePic.userId=getData[0];
    //[self.navigationController pushViewController:changeProfilePic animated:YES];
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
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@""
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
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
        HUD.dimBackground = YES;
        HUD.labelText = @"Please Wait";
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
        NSLog(@"$[%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/delete_group_pic.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        deleteImageConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [deleteImageConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [deleteImageConn start];
        deleteImageResponse = [[NSMutableData alloc] init];
        
        //groupImageView.image=Nil;
        
        //[groupImageView setImage:[UIImage imageNamed:@"defaultGroup.png"]];
        
    }
    
    
    
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        
        NSLog(@"Cancel pressed --> Cancel ActionSheet");
        
    }
    
    
    
    
    
}

/*- (BOOL)prefersStatusBarHidden {
 return YES;
 }*/



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //chosenImage=[[UIImage alloc]init];
    chosenImage= info[UIImagePickerControllerEditedImage];
    
    //groupImageView.image = chosenImage;
    imageData=UIImageJPEGRepresentation(chosenImage, 1);
    [iPicker dismissViewControllerAnimated:YES completion:NULL];
    
    imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageActivityIndicator.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [imageActivityIndicator setCenter:CGPointMake(50, 50)];
    imageActivityIndicator.color = [UIColor blackColor];
    [groupImageView addSubview:imageActivityIndicator];
    [imageActivityIndicator startAnimating];
    // upload profile pic here
    [self uploadDisplayPicToServer];
    
    
    
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    
    NSLog(@"imagePickerDidCancel");
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    
}
-(void)uploadDisplayPicToServer
{
    NSString *urlString =[NSString stringWithFormat:@"%@/scripts/edit_group_pic.php",gupappUrl]; // URL of upload script.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSMutableData *body = [NSMutableData data];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Disposition: form-data; name=\"group_pic\"; filename=\"a.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[NSData dataWithData:imageData]];
    
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    //  parameter username
    
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"group_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    [body appendData:[groupId dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // close form
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    
    [request setHTTPBody:body];
    
    // NSError *oo;
    uploadGroupPicConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [uploadGroupPicConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [uploadGroupPicConn start];
    
    uploadGroupPicResponse = [[NSMutableData alloc] init];
    
    
    
    
}



- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    TXFRAME=[self convertView:textField];
    
    TXFRAME=CGRectMake(TXFRAME.origin.x, TXFRAME.origin.y+40, TXFRAME.size.width,TXFRAME.size.height);
    
    NSLog(@"frame x=%f y=%f wi=%f he=%f",TXFRAME.origin.x,TXFRAME.origin.y,TXFRAME.size.width,TXFRAME.size.height);
    
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

-(void)changeCategory{
    CategoryList *openCategoryList = [[CategoryList alloc]init];
    openCategoryList.title =@"Category";
    [openCategoryList wantToChangeCategoryFrom:self];
    [self.navigationController pushViewController:openCategoryList animated:YES];
}/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1)
    {
        if (indexPath.row == 1) {
           
        }
        else if(indexPath.row==2)
        {
            if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"])
            {
                NSLog(@"group type:%@,group id:%@",groupType,groupId);
               
            }
            else
            {
                //location
  
            }
            
        }
    }
    
    else  if(indexPath.section==2)
    {
        if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"])
        {
            if (!(groupJoinCount==0)) {
                JoinRequest *joinRequest = [[JoinRequest alloc]init];
                joinRequest.groupId=groupId;
                NSLog(@"gname %@",GName);
                joinRequest.groupName=GName;
                [self.navigationController pushViewController:joinRequest animated:YES];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There are no Group Join Request."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [alert show];
                
            }
        }
        
        else
        {
            //members
            ViewMembers *membersPage = [[ViewMembers alloc]init];
            membersPage.groupId = groupId;
            membersPage.groupType=groupType;
            membersPage.groupName=GName;
            membersPage.viewType=viewType;
            [self.navigationController pushViewController:membersPage animated:YES];
        }
        
    }
    
}*/
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    
    //  if ( ![string canBeConvertedToEncoding:NSASCIIStringEncoding])
    //    return NO;
    
    
    
    
    if (textField == self.groupName) {
        NSUInteger newLength = [self.groupName.text length] + [string length] - range.length;
        return (newLength > 28) ? NO : YES;
        
    }
    if (textField == self.groupDesc) {
        NSUInteger newLength = [self.groupDesc.text length] + [string length] - range.length;
        return (newLength > 100) ? NO : YES;
    }
    else{
        return YES;
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"text field did end editing");
    [textField resignFirstResponder];
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    
    
    if (textField ==self.groupDesc) {
        
        // update description
       
            groupDesc=self.groupDesc.text;
            NSLog(@"1");
            NSString *postData= [NSString stringWithFormat:@"group_id=%@&group_description=%@",groupId,groupDesc];
            NSLog(@"$[%@]",postData);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/edit_group_description.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            updateDescriptionConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [updateDescriptionConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [updateDescriptionConn start];
            updateDescriptionResponse = [[NSMutableData alloc] init];
            
      
        
    }else if(textField == self.groupName){
        // update name
        if ([self.groupName.text isEqualToString:@""]){
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter group name"   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self plotData];
            
        }else{
            
            if (![GName isEqualToString:self.groupName.text]){
                
                    NSLog(@"after edit name%@ old group name%@",self.groupName.text,groupName);
                    NSString *postData= [NSString stringWithFormat:@"group_id=%@&group_name=%@",groupId,self.groupName.text];
                    NSLog(@"$[%@]",postData);
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/edit_group_name.php",gupappUrl]]];
                    [request setHTTPMethod:@"POST"];
                    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
                    updateNameConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
                    [updateNameConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    [updateNameConn start];
                    updateNameResponse = [[NSMutableData alloc] init];
               
                
            }else{
                
                [HUD hide:YES];
                
            }
            
        }
        
    }
    
}


//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == updateDescriptionConn) {
        [updateDescriptionResponse setLength:0];
    }
    if (connection == editCategoryConn) {
        [editCategoryResponse setLength:0];
    }
    if (connection == uploadGroupPicConn) {
        [uploadGroupPicResponse setLength:0];
    }
    if (connection == updateNameConn) {
        [updateNameResponse setLength:0];
    }
    if (connection == editLocationConn) {
        [editLocationResponse setLength:0];
    }
    if (connection == deleteImageConn) {
        [deleteImageResponse setLength:0];
    }
    if (connection == getGroupJoinRequestCountConn) {
        [getGroupJoinRequestCountResponse setLength:0];
    }
    if (connection == leaveGroupConn) {
        [leaveGroupResponse setLength:0];
    }
    if (connection == memberConnection) {
        [memberRsponce setLength:0];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == updateDescriptionConn) {
        [updateDescriptionResponse appendData:data];
    }
    if (connection == editCategoryConn) {
        [editCategoryResponse appendData:data];
    }
    if (connection == uploadGroupPicConn) {
        [uploadGroupPicResponse appendData:data];
    }
    if (connection == updateNameConn) {
        [updateNameResponse appendData:data];
    }
    if (connection == editLocationConn) {
        [editLocationResponse appendData:data];
    }
    if (connection == deleteImageConn) {
        [deleteImageResponse appendData:data];
    }
    if (connection == getGroupJoinRequestCountConn) {
        [getGroupJoinRequestCountResponse appendData:data];
    }
    if (connection == leaveGroupConn) {
        [leaveGroupResponse appendData:data];
    }
    if (connection == memberConnection) {
        [memberRsponce appendData:data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    //[activityIndicator stopAnimating];
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection != deleteImageConn){
        NSDictionary *response;
        if (connection == updateDescriptionConn) {
            
            NSLog(@"====EVENTS");
            
            NSString *str = [[NSMutableString alloc] initWithData:updateDescriptionResponse encoding:NSASCIIStringEncoding];
            
            NSLog(@"Response:%@",str);
            SBJSON *jsonparser=[[SBJSON alloc]init];
            
            NSDictionary *res= [jsonparser objectWithString:str];
            
            NSLog(@" result %@",res);
            
            response= res[@"response"];
            
            NSLog(@"response %@",response);
            NSString *status = response[@"status"];
            NSString *error = response[@"error"];
            NSLog(@"status = %@ error =  %@",status,error);
            if ([status isEqualToString:@"0"]){
                
                NSString *query;
                if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
                    query=[NSString stringWithFormat:@"update groups_private set group_description = '%@' where group_server_id = '%@'",[groupDesc normalizeDatabaseElement],groupId];
                }
                else
                {
                    query=[NSString stringWithFormat:@"update groups_public set group_description ='%@' where group_server_id = '%@'",[groupDesc normalizeDatabaseElement],groupId];
                }
                
                
                NSLog(@"sub query %@",query);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
                
                //[self loadMembers];
                //[manageMembersTable reloadData];
                //[self.navigationController popViewControllerAnimated:NO];
                //[self.navigationController popViewControllerAnimated:NO];
                //[self.navigationController popToRootViewControllerAnimated:NO];
                [HUD hide:YES];
            }
            else
            {
                [HUD hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            
            updateDescriptionConn=nil;
            
            [updateDescriptionConn cancel];
            
        }
        if (connection == editCategoryConn) {
            
            NSLog(@"====EVENTS");
            
            NSString *str = [[NSMutableString alloc] initWithData:editCategoryResponse encoding:NSASCIIStringEncoding];
            
            NSLog(@"Response:%@",str);
            SBJSON *jsonparser=[[SBJSON alloc]init];
            
            NSDictionary *res= [jsonparser objectWithString:str];
            
            NSLog(@" result %@",res);
            
            response= res[@"response"];
            
            NSLog(@"response %@",response);
            NSString *status = response[@"status"];
            NSString *error = response[@"error"];
            NSLog(@"status = %@ error =  %@",status,error);
            if ([status isEqualToString:@"0"]){
                NSString *query;
                if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
                    query=[NSString stringWithFormat:@"update groups_private set category_id = '%@' , category_name ='%@' where group_server_id = '%@'",categoryID,categoryName,groupId];
                }
                else
                {
                    query=[NSString stringWithFormat:@"update groups_public set category_name ='%@' where group_server_id = '%@'",categoryName,groupId];
                }
                
                
                NSLog(@"sub query %@",query);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
                
                //[self loadMembers];
                //[manageMembersTable reloadData];
                //[self.navigationController popViewControllerAnimated:NO];
                //[self.navigationController popViewControllerAnimated:NO];
                //[self.navigationController popToRootViewControllerAnimated:NO];
                [HUD hide:YES];
                [self plotData];
            }
            else
            {
                [HUD hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            
            
            editCategoryConn=nil;
            
            [editCategoryConn cancel];
            
        }
        
        if (connection == uploadGroupPicConn) {
            
            NSLog(@"====EVENTS");
            
            NSString *str = [[NSMutableString alloc] initWithData:uploadGroupPicResponse encoding:NSASCIIStringEncoding];
            
            NSLog(@"Response:%@",str);
            SBJSON *jsonparser=[[SBJSON alloc]init];
            
            NSDictionary *res= [jsonparser objectWithString:str];
            
            NSLog(@" result %@",res);
            
            response= res[@"response"];
            
            NSLog(@"response %@",response);
            NSString *status = response[@"status"];
            NSString *error = response[@"error"];
            NSLog(@"status = %@ error =  %@",status,error);
            groupPic = response[@"group_pic"];
            if ([status isEqualToString:@"0"])
            {
                groupImageView.image = chosenImage;
                [imageActivityIndicator stopAnimating];
                [imageActivityIndicator removeFromSuperview];
                if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update groups_private set group_pic ='%@' where group_server_id = '%@'",groupPic,groupId]];
                }
                else
                {
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update groups_public set group_pic ='%@' where group_server_id = '%@'",groupPic,groupId]];
                }
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSLog(@"paths=%@",paths);
                NSString *profilePicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",groupPic]];
                NSLog(@"profile pic path=%@",profilePicPath);
                imageData=UIImageJPEGRepresentation(groupImageView.image, 1);
                //Writing the image file
                [imageData writeToFile:profilePicPath atomically:YES];
                
            }
            else
            {
                [imageActivityIndicator stopAnimating];
                [imageActivityIndicator removeFromSuperview];
            }
            
            uploadGroupPicConn=nil;
            
            [uploadGroupPicConn cancel];
        }
        
        
        if (connection == updateNameConn) {
            
            NSLog(@"====EVENTS");
            
            NSString *str = [[NSMutableString alloc] initWithData:updateNameResponse encoding:NSASCIIStringEncoding];
            
            NSLog(@"Response:%@",str);
            SBJSON *jsonparser=[[SBJSON alloc]init];
            NSDictionary *res= [jsonparser objectWithString:str];
            NSLog(@" result %@",res);
            response= res[@"response"];
            
            NSLog(@"response %@",response);
            NSString *status = response[@"status"];
            NSString *error = response[@"error"];
            NSLog(@"status = %@ error =  %@",status,error);
            if ([status isEqualToString:@"0"]){
                self.title=self.groupName.text;
                //groupName=nameTextField.text;
                NSString *query;
                if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
                    query=[NSString stringWithFormat:@"update groups_private set group_name = '%@' where group_server_id = '%@'",[self.groupName.text normalizeDatabaseElement],groupId];
                }else{
                    query=[NSString stringWithFormat:@"update groups_public set group_name ='%@' where group_server_id = '%@'",[self.groupName.text normalizeDatabaseElement],groupId];
                }
                
                
                NSLog(@"sub query %@",query);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
                
                //[self loadMembers];
                //[manageMembersTable reloadData];
                //[self.navigationController popViewControllerAnimated:NO];
                //[self.navigationController popViewControllerAnimated:NO];
                //[self.navigationController popToRootViewControllerAnimated:NO];
                [HUD hide:YES];
            }else{
                [HUD hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            
            updateNameConn=nil;
            
            [updateNameConn cancel];
            
        }
        
        if (connection == editLocationConn) {
            
            NSLog(@"====EVENTS");
            NSString *str = [[NSMutableString alloc] initWithData:editLocationResponse encoding:NSASCIIStringEncoding];
            NSLog(@"Response:%@",str);
            SBJSON *jsonparser=[[SBJSON alloc]init];
            NSDictionary *res= [jsonparser objectWithString:str];
            NSLog(@" result %@",res);
            response= res[@"response"];
            NSLog(@"response %@",response);
            NSString *status = response[@"status"];
            NSString *error = response[@"error"];
            NSLog(@"status = %@ error =  %@",status,error);
            if ([status isEqualToString:@"0"]){
                NSString *query;
                query=[NSString stringWithFormat:@"update groups_public set location_name ='%@' where group_server_id = '%@'",groupLocation,groupId];
                NSLog(@"sub query %@",query);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
                [HUD hide:YES];
            }else{
                [HUD hide:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            
            
            editLocationConn=nil;
            
            [editLocationConn cancel];
            
        }
        if (response!=nil&&![response[@"status"] boolValue])
        {
            NSArray *members=[self getMembersListGroupId:[groupId integerValue]];
            for (int j=0; j<[members count]; j++)
            {
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                NSLog(@"%@",members[j]);
                [attributeDic setValue:[[members objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"notifications from %@",groupName];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                
                [elementDic setValue:@"1" forKey:@"isgroup"];
                [elementDic setValue:groupId forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
        }
    }
    if (connection==deleteImageConn)  {
        
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:deleteImageResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@" result %@",res);
        NSDictionary *response= res[@"response"];
        NSLog(@"response %@",response);
        NSString *status = response[@"status"];
        NSString *error = response[@"error"];
        groupPic = @"group_pic_default_300.jpg";
        NSLog(@"status = %@ error =  %@",status,error);
        if ([status isEqualToString:@"1"]){
            [HUD hide:YES];
            groupImageView.image=Nil;
            [groupImageView setImage:[UIImage imageNamed:@"defaultGroup.png"]];
            if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update groups_private set group_pic ='group_pic_default_300.jpg' where group_server_id = '%@'",groupId]];
            }else{
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update groups_public set group_pic ='group_pic_default_300.jpg' where group_server_id = '%@'",groupId]];
            }
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSLog(@"paths=%@",paths);
            NSString *groupPicPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",groupPic]];
            NSLog(@"group pic path=%@",groupPicPath);
            imageData=UIImageJPEGRepresentation(groupImageView.image, 1);
            //Writing the image file
            [imageData writeToFile:groupPicPath atomically:YES];
        }else{
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        
        if ([response[@"status"] boolValue]){
            NSArray *members=[self getMembersListGroupId:[groupId integerValue]];
            for (int j=0; j<[members count]; j++){
                NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
                [attributeDic setValue:@"chat" forKey:@"type"];
                [attributeDic setValue:[[members objectAtIndex:j] JID] forKey:@"to"];
                [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
                [attributeDic setValue:@"0" forKey:@"isResend"];
                NSString *body=[NSString stringWithFormat:@"notifications from %@",groupName];
                NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
                // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
                [elementDic setValue:@"text" forKey:@"message_type"];
                [elementDic setValue:@"1" forKey:@"grpUpdate"];
                
                [elementDic setValue:@"1" forKey:@"isgroup"];
                [elementDic setValue:groupId forKey:@"groupID"];
                [elementDic setValue:body forKey:@"body"];
                [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
            }
        }
        
    }
    
    if (connection == getGroupJoinRequestCountConn) {
        NSString *str = [[NSMutableString alloc] initWithData:getGroupJoinRequestCountResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        //Response:{"response":{"status":"0","count":0,"error_message":""}}
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responseString= res[@"response"];
        int status = [responseString[@"status"] integerValue];
        int count = [responseString[@"count"] integerValue];
        if (status==0) {
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update groups_private set group_join_request_count=%d where group_server_id=%@",count,groupId]];
            //
            if (!count==0) {
                groupJoinCount = [[DatabaseManager getSharedInstance]fetchGroupJoinRequestCount:groupId];
                [self plotData];
                
            }
        }
        
    }
    if (connection == leaveGroupConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:leaveGroupResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        
        NSDictionary *result = res[@"response"];
        NSLog(@"result: %@", result);
        NSString *leaveStatus = result[@"status"];
        NSLog(@"status: %@", leaveStatus);
        NSString *error=result[@"Error"];
        NSLog(@"error: %@", error);
        [HUD hide:YES];
        if ([leaveStatus isEqualToString:@"0"]){
            NSString *deleteQuery=[NSString stringWithFormat:@"delete from groups_public where group_server_id='%@'",groupId];
            NSLog(@"query %@",deleteQuery);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteQuery];
            /* NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%@ and contact_id!=%@",groupId,[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]];
             NSMutableArray    *membersID=[[NSMutableArray alloc]init];
             for (int i=0; i<[tempmembersID count];i++)
             {//if(![[tempmembersID objectAtIndex:i]isEqual:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]])
             [membersID addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
             }
             
             NSLog(@"membersID %@",membersID);
             
             //4552
             for (int j=0; j<[membersID count]; j++)
             {NSLog(@"%@ %@",membersID,membersID[j]);
             NSMutableDictionary *attributeDic=[[NSMutableDictionary alloc]init];
             [attributeDic setValue:@"chat" forKey:@"type"];
             [attributeDic setValue:[[membersID objectAtIndex:j] JID] forKey:@"to"];
             [attributeDic setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] forKey:@"from"];
             [attributeDic setValue:@"0" forKey:@"isResend"];
             NSString *body=[NSString stringWithFormat:@"Your request to join %@ has been accepted",self.title ];
             NSMutableDictionary *elementDic=[[NSMutableDictionary alloc]init];
             // [elementDic setValue:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] JID] forKey:@"from_user_id"];
             [elementDic setValue:@"text" forKey:@"message_type"];
             [elementDic setValue:@"1" forKey:@"grpUpdate"];
             [elementDic setValue:@"0" forKey:@"show_notification"];
             [elementDic setValue:@"1" forKey:@"isgroup"];
             NSLog(@"gid %@",groupId);
             [elementDic setValue:groupId forKey:@"groupID"];
             [elementDic setValue:body forKey:@"body"];
             
             [[self appDelegate]composeMessageWithAttributes:attributeDic andElements:elementDic body:body];
             }
             
             */
            NSString *deleteMembers=[NSString stringWithFormat:@"delete from group_members where group_id='%@'",groupId];
            NSLog(@"query %@",deleteMembers);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:deleteMembers];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        leaveGroupConn=nil;
        [leaveGroupConn cancel];
    }
    
    if (connection == memberConnection) {
        
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:memberRsponce encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        
        NSDictionary *result = res[@"response"];
        NSLog(@"result: %@", result);
        NSString *leaveStatus = result[@"status"];
        NSLog(@"status: %@", leaveStatus);
        NSString *error=result[@"Error"];
        NSLog(@"error: %@", error);
        if ([leaveStatus isEqualToString:@"0"]) {
            NSDictionary *groupdDetail = result[@"Group_Details"];
            NSString *membercount = groupdDetail[@"member_count"];
            NSLog(@"%@",membercount);
            if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"]) {
                
                self.totalMembers.text = [NSString stringWithFormat:@"%@ members",membercount];

            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        leaveGroupConn=nil;
        //        [spinner startAnimating];
        //        [spinner removeFromSuperview];
        [leaveGroupConn cancel];
    }
    
}

- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(NSArray*)getMembersListGroupId:(int)GID
{NSMutableArray *temparray;
    NSArray *tempmembersID=  [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_id from group_members where group_id=%i and deleted=0",GID]];
    temparray=[[NSMutableArray alloc]init];
    for (int i=0; i<[tempmembersID count];i++)
    {
        [temparray addObject:[[tempmembersID objectAtIndex:i] objectForKey:@"CONTACT_ID"]] ;
    }
    NSLog(@"membersID %@",temparray);
    return temparray;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.groupName resignFirstResponder];
    [self.groupDesc resignFirstResponder];
    return YES;
}

-(void)updateCategory:(NSString*)newCategory categoryId:(NSString*)catId
{
    categoryID=catId;
    NSLog(@"category ID in update category%@",categoryID);
    categoryName = newCategory;
    
    NSLog(@"group cate in update category:%@",categoryName);
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    NSLog(@"group id:%@, category id:%@",groupId,categoryID);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@&category_id=%@",groupId,categoryID];
    NSLog(@"$[edit category%@]",postData);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/edit_group_category.php",gupappUrl]]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    editCategoryConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [editCategoryConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [editCategoryConn start];
    
    editCategoryResponse = [[NSMutableData alloc] init];
    //[viewPrivateGroupTable reloadData];
}

-(IBAction)shareGroupInfo:(id)sender
{
    ShareGroupInfo *shareGroupInfoPage = [[ShareGroupInfo alloc]init];
    shareGroupInfoPage.groupId = groupId;
    shareGroupInfoPage.groupName = self.title;
    shareGroupInfoPage.hideUnhideSkipDoneButton = @"hide";
    [self.navigationController pushViewController:shareGroupInfoPage animated:YES];
}
-(void)shareGroupInfo
{
    ShareGroupInfo *shareGroupInfoPage = [[ShareGroupInfo alloc]init];
    shareGroupInfoPage.groupId = groupId;
    shareGroupInfoPage.groupName = self.title;
    shareGroupInfoPage.hideUnhideSkipDoneButton = @"hide";
    [self.navigationController pushViewController:shareGroupInfoPage animated:YES];
}
-(void)updateLocationLable:(NSString*)newLocation locationID:(NSInteger)locID;
{int locationID=locID;
    NSLog(@"location ID %i",locationID);
    groupLocation=newLocation;
    NSLog(@"loc name %@",groupLocation);
   // NSIndexPath *cellindex=[NSIndexPath indexPathForRow:2 inSection:1];
//    UITableViewCell *tempcell=[viewPrivateGroupTable cellForRowAtIndexPath:cellindex];
//    [tempcell.textLabel setText:newLocation];
    //data update on server as well as the local
    self.locationLbl.titleLabel.text = newLocation;
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    NSLog(@"group id:%@, location id:%d",groupId,locationID);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@&location_id=%d",groupId,locationID];
    NSLog(@"$[edit location%@]",postData);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/edit_group_location.php",gupappUrl]]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    editLocationConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [editLocationConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [editLocationConn start];
    
    editLocationResponse = [[NSMutableData alloc] init];
    
}

-(void)getGroupJoinRequestCount
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"group_id=%@",groupId];
    NSLog(@"$[get group join request count %@]",postData);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/group_join_request_count.php",gupappUrl]]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    getGroupJoinRequestCountConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [getGroupJoinRequestCountConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [getGroupJoinRequestCountConn start];
    
    getGroupJoinRequestCountResponse = [[NSMutableData alloc] init];
    
    
}

-(IBAction)leaveGroup:(id)sender
{
    NSString *appUserId = [[DatabaseManager getSharedInstance]getAppUserID];
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
   
        NSLog(@"You have clicked submit leave%@%@",groupId,appUserId);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSString *postData = [NSString stringWithFormat:@"group_id=%@&user_id=%@",groupId,appUserId];
        NSLog(@"$[%@]",postData);
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/leave_group.php",gupappUrl]]];
        
        [request setHTTPMethod:@"POST"];
        
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        
        leaveGroupConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        
        [leaveGroupConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        [leaveGroupConn start];
        
        leaveGroupResponse = [[NSMutableData alloc] init];
}


- (IBAction)pendingGroups:(id)sender {
    if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"])
    {
        if (!(groupJoinCount==0)) {
            JoinRequest *joinRequest = [[JoinRequest alloc]init];
            joinRequest.groupId=groupId;
            NSLog(@"gname %@",GName);
            joinRequest.groupName=GName;
            [self.navigationController pushViewController:joinRequest animated:YES];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There are no Group Join Request."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
            
        }
    }

}

-(void)openGroupMember{
    if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"])
    {
        ManageMembers *manageMembersPage = [[ManageMembers alloc]init];
        manageMembersPage.groupName=GName;
        manageMembersPage.groupType=groupType;
        manageMembersPage.groupId = groupId;
        [self.navigationController pushViewController:manageMembersPage animated:YES];
    }
    
    else
    {
        //members
        ViewMembers *membersPage = [[ViewMembers alloc]init];
        membersPage.groupId = groupId;
        membersPage.groupType=groupType;
        membersPage.groupName=GName;
        membersPage.viewType=viewType;
        [self.navigationController pushViewController:membersPage animated:YES];
    }
}

- (IBAction)manageMembers:(id)sender {
    if ([groupType isEqualToString:@"private#local"]||[groupType isEqualToString:@"private#global"] ||[groupType isEqualToString:@"private"])
    {
        ManageMembers *manageMembersPage = [[ManageMembers alloc]init];
        manageMembersPage.groupName=GName;
        manageMembersPage.groupType=groupType;
        manageMembersPage.groupId = groupId;
        [self.navigationController pushViewController:manageMembersPage animated:YES];
    }
    
    else
    {
        //members
        ViewMembers *membersPage = [[ViewMembers alloc]init];
        membersPage.groupId = groupId;
        membersPage.groupType=groupType;
        membersPage.groupName=GName;
        membersPage.viewType=viewType;
        [self.navigationController pushViewController:membersPage animated:YES];
    }
   
}
- (IBAction)changeLocation:(id)sender {
    
    SearchLocation *object=[[SearchLocation alloc]init];
    [object wontToChangeLocationFrom:self];
    [self.navigationController pushViewController:object animated:NO];
}
@end
