//
//  ChangePassword.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/6/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ChangePassword.h"
#import "JSON.h"
#import "NSString+Utils.h"
#import "globleData.h"
#import "DatabaseManager.h"
#import "AppDelegate.h"
@interface ChangePassword ()

@end

@implementation ChangePassword
@synthesize userId,currentPassword;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.navigationItem.title = @"Change Password";
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:false];
   //  self.navigationItem.hidesBackButton=YES;
      if([globleData textFieldHidden])
      {currentPassword.hidden=true;
        currentPassword.text=   [globleData userPass];
          [globleData setTextFieldHidden:false];
           self.navigationItem.hidesBackButton=YES;
    }
    else
    {currentPassword.hidden=false;
        currentPassword.text=@"";
    }
    //currentPassword.hidden=true;
    NSLog(@"%@ globl %@",currentPassword.text,[globleData userPass]);
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    currentPassword.secureTextEntry=YES;
    newPassword.secureTextEntry=YES;
    confirmPassword.secureTextEntry=YES;
    [currentPassword.layer setBorderColor:[UIColor colorWithRed:138/255.0 green:155/255.0 blue:160/255.0 alpha:1].CGColor];
    [newPassword.layer setBorderColor:[UIColor colorWithRed:138/255.0 green:155/255.0 blue:160/255.0 alpha:1].CGColor];
    [confirmPassword.layer setBorderColor:[UIColor colorWithRed:138/255.0 green:155/255.0 blue:160/255.0 alpha:1].CGColor];
     currentPassword.layer.cornerRadius =8.0f;
     newPassword.layer.cornerRadius =8.0f;
     confirmPassword.layer.cornerRadius =8.0f;
    
    if ([confirmPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
        confirmPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{NSForegroundColorAttributeName: color}];
    }

    if ([newPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
        newPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"New Password" attributes:@{NSForegroundColorAttributeName: color}];
    }

    if ([currentPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
        currentPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Old Password" attributes:@{NSForegroundColorAttributeName: color}];
    }

    currentPassword.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    newPassword.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    confirmPassword.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    
    confirmPassword.font = [UIFont fontWithName:@"Dosis-Regular" size:18.0];
     currentPassword.font = [UIFont fontWithName:@"Dosis-Regular" size:18.0];
     newPassword.font = [UIFont fontWithName:@"Dosis-Regular" size:18.0];
    
    currentPassword.layer.borderWidth =1.0f;
    newPassword.layer.borderWidth =1.0f;
    confirmPassword.layer.borderWidth =1.0f;
    
    UIBarButtonItem *donebtn =[[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(checkPasswordMatch)];
    [donebtn setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255/255.0 green:207/255.0 blue:13/255.0 alpha:1], NSForegroundColorAttributeName,[UIFont fontWithName:@"Dosis-Bold" size:20.0],NSFontAttributeName,nil]
                          forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = donebtn;
    
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [currentPassword resignFirstResponder];
    [newPassword resignFirstResponder];
    [confirmPassword resignFirstResponder];
    return YES;
}

-(void)checkPasswordMatch
{[self.view endEditing:YES];
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
  //  NSString *passwordRegex = @"^{6,15}$";
  //  NSString *passwordRegex =@"^(?=.{6,15}$)(?=.*[0-9])(?=.*[a-zA-Z]).*$";
    NSString *passwordRegex =@"^.{6,15}$";
    NSRegularExpression *passwordregEx = [[NSRegularExpression alloc] initWithPattern:passwordRegex options:NSRegularExpressionCaseInsensitive error:nil];
   
    NSString *strForCheck=newPassword.text==nil?@"":newPassword.text;
    NSLog(@"new pass text %@",strForCheck);
    NSUInteger passwordRegExMatches = [passwordregEx numberOfMatchesInString:strForCheck options:0 range:NSMakeRange(0, [newPassword.text length])];
   
    NSString *currentPasswordString=currentPassword.text;
    NSString *newPasswordString=newPassword.text;
    NSString *confirmPasswordString=confirmPassword.text;
    if([currentPasswordString length]==0)
    {
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"Please Enter Your Current Password."  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alert setTag:0];
        [alert show];
        if(currentPassword.hidden!=true)
        [currentPassword setText:@""];
        [newPassword setText:@""];
        [confirmPassword setText:@""];
        
    }
    else if([newPasswordString length]==0)
    {
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"Please Enter Your New Password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alert setTag:0];
        [alert show];
        if(currentPassword.hidden!=true)
        [currentPassword setText:@""];
        [newPassword setText:@""];
        [confirmPassword setText:@""];
        
    }
    else if([confirmPasswordString length]==0)
    {
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"Please Enter Confirm Password"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alert setTag:0];
        [alert show];
        if(currentPassword.hidden!=true)
        [currentPassword setText:@""];
        [newPassword setText:@""];
        [confirmPassword setText:@""];
        
    }
    
    
    
    
    else if(![newPassword.text isEqualToString:confirmPassword.text])
    {
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"Passwords do not match"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //[alert setTag:0];
        [alert show];
        if(currentPassword.hidden!=true)
        [currentPassword setText:@""];
        [newPassword setText:@""];
        [confirmPassword setText:@""];
        
        
    }
    else if (passwordRegExMatches==0)
    {
        [HUD hide:YES];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:Nil
                                                         message:@"Enter password  within 6-15 characters"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
        if(currentPassword.hidden!=true)
        [currentPassword setText:@""];
        [newPassword setText:@""];
        [confirmPassword setText:@""];
    }

    else
    {
        NSLog(@"in else");
        [self changePassword];
    }
    
}

-(void)changePassword
{
    NSLog(@"You have clicked submit%@%@%@",currentPassword.text,newPassword.text,confirmPassword.text);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *postData = [NSString stringWithFormat:@"id=%@&old_password=%@&new_password=%@",userId,currentPassword.text,newPassword.text];
    NSLog(@"$[changepasswordString%@]",postData);
    if ([currentPassword isHidden])
    {
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/reset_password.php",gupappUrl]]];
        
    }
    else
    {
       [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_password.php",gupappUrl]]];
    }
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    changePasswordConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [changePasswordConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [changePasswordConn start];
    
    changePasswordResponse = [[NSMutableData alloc] init];
    
}

    

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == changePasswordConn) {
        
        [changePasswordResponse setLength:0];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == changePasswordConn) {
        
        [changePasswordResponse appendData:data];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == changePasswordConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:changePasswordResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        
        
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        
        NSLog(@"====EVENTS==1");
        
        NSDictionary *res= [jsonparser objectWithString:str];
        
        NSLog(@"====EVENTS==2");
        
        
        NSLog(@"====EVENTS==3 result %@",res);
        
        NSDictionary *responce= res[@"response"];
        
        NSLog(@"vishals responce %@",responce);
        
        
        
        int status= [responce[@"status"] integerValue];
        
        NSString *error_Message=responce[@"error_message"];
        
        NSLog(@"{'response':{'status:%i,'error_message:%@,'}}",status,error_Message);
        
        if (status==1)
            
        {
            [HUD hide:YES];
            UIAlertView *loginWarning=[[UIAlertView alloc]initWithTitle:Nil message:responce[@"error_message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [loginWarning show];

            
        }
        
        else
        {
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"update  master_table set password = '%@' where logged_in_user_id = '%@' ",[newPassword.text normalizeDatabaseElement],userId]];
            [HUD hide:YES];
            NSLog(@"Password changed successfully");
            UIAlertView *loginWarning=[[UIAlertView alloc]initWithTitle:Nil message:@"Password changed successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [loginWarning show];
            //[self.navigationController popViewControllerAnimated:YES ];
            if ([currentPassword isHidden])
            {
            
            AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegateObj setTabBar];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        
            
        }
        
        
        changePasswordConn=nil;
        
        [changePasswordConn cancel];
        
    }
    
}

@end
