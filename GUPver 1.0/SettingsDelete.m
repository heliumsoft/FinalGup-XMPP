//
//  SettingsDelete.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 1/20/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import "SettingsDelete.h"
#import "DatabaseManager.h"
#import "JSON.h"
#import "AppDelegate.h"

@interface SettingsDelete ()

@end

@implementation SettingsDelete

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
         
         
         
                                                 selector:@selector(keyboardWillShow:)
         
         
         
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        
        
        
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
         
         
         
                                                 selector:@selector(keyboardWillHide:)
         
         
         
                                                     name:UIKeyboardWillHideNotification object:nil];
    }

    
    return self;
}
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    scrollView.contentInset = contentInsets;
    
    scrollView.scrollIndicatorInsets = contentInsets;
    
    
    
    
    
    CGRect aRect = self.view.frame;
    
    aRect.size.height -= keyBdHeight;
    
    
    if (!CGRectContainsPoint(aRect, TXFRAME.origin) ) {
        
        CGPoint scrollPoint = CGPointMake(0.0, TXFRAME.origin.y-keyBdHeight);
        
        [scrollView setContentOffset:scrollPoint animated:YES];
        
    }
    
    
}

- (void) keyboardWillHide:(NSNotification *)notification {
    
    
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    scrollView.contentInset = contentInsets;
    
    scrollView.scrollIndicatorInsets = contentInsets;
    
    
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
    TXFRAME=[self convertView:textField];
    
    TXFRAME=CGRectMake(TXFRAME.origin.x, TXFRAME.origin.y+40, TXFRAME.size.width,TXFRAME.size.height);
    
    NSLog(@"frame x=%f y=%f wi=%f he=%f",TXFRAME.origin.x,TXFRAME.origin.y,TXFRAME.size.width,TXFRAME.size.height);
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    TXFRAME=[self convertView:textView];
    TXFRAME=CGRectMake(TXFRAME.origin.x, TXFRAME.origin.y+80, TXFRAME.size.width, TXFRAME.size.height);
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

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    else
    {
         return [self isAcceptableTextLength:textView.text.length + text.length - range.length];
    }
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
    topView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    bottomView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    self.navigationItem.title = @"Delete Account";
    [password setSecureTextEntry:TRUE];
    scrollView.scrollEnabled=true;
    scrollView.showsVerticalScrollIndicator=true;
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width,430)];
    NSArray *socialLogin=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select social_login  from  master_table"]];
    socialLoginVariable=[[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"SOCIAL_LOGIN" ForRowIndex:0 givenOutput:socialLogin]integerValue ];
    NSLog(@"array %@ integer %i",socialLogin,socialLoginVariable);
    if (socialLoginVariable==1) {
        label.text=@"Enter Username";
        password.placeholder=@"Username";
    }
    
}

- (BOOL)isAcceptableTextLength:(NSUInteger)length {
    return length <= 150;
}

/*- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    return [self isAcceptableTextLength:textView.text.length + string.length - range.length];
}*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
   // [groupDescTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSLog(@"text field did end editing");
    [textField resignFirstResponder];
}
-(IBAction)deleteAccount:(id)sender
{    if (socialLoginVariable==0) {
   
        if ([password.text isEqualToString:@""]) {
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Password is Mandatory" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
   
        else{
            [self deleteAccountFunction];
        }
        
    }
    else
    { NSArray *output=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:@"select display_name from master_table where id=1"];
        NSString *userName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"DISPLAY_NAME" ForRowIndex:0 givenOutput:output];

        if ([[password.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Username is Mandatory" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else if (![password.text isEqual:userName])
        {UIAlertView *alert=[[UIAlertView alloc]initWithTitle:Nil message:@"Invalid Username" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
        else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Delete Account Confirmation" message:@"Are you sure you want to delete your account?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.tag=11;
        [alert show];
        }
    }
    

    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==11) {
        if (buttonIndex==1) {
            [self deleteAccountFunction];
        }
        
    }
}
-(void)deleteAccountFunction
{
   /* NSLog(@"password %@\n reason %@ ",password.text,reasonForDeletion.text);
    NSString *userId =[[DatabaseManager getSharedInstance]getAppUserID];
    NSString *checkIfAdminOfGroup;
    checkIfAdminOfGroup=[NSString stringWithFormat:@"SELECT * FROM group_members where contact_id=%@ and is_admin=1",userId];
    BOOL isAdmin=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfAdminOfGroup];
    NSLog(@"Query=%@ isadmin=%d user id=%@",checkIfAdminOfGroup,isAdmin,userId);
    
    if (isAdmin)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Cannot leave group" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else{*/
     NSString *userId =[[DatabaseManager getSharedInstance]getAppUserID];
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
        HUD.dimBackground = YES;
        HUD.labelText = @"Please Wait";
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSLog(@"user id:%@",userId);
        NSString *postData;
        if (socialLoginVariable==0) {
        postData = [NSString stringWithFormat:@"user_id=%@&password=%@&delete_reason=%@",userId,password.text,reasonForDeletion.text];
        }
        else{
        postData = [NSString stringWithFormat:@"user_id=%@&display_name=%@&delete_reason=%@&flag=%i",userId,password.text,reasonForDeletion.text,1];
            
        }
        NSLog(@"postdata%@",postData);
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/delete_account.php",gupappUrl]]];
        
        [request setHTTPMethod:@"POST"];
        
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        
        deleteConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        
        [deleteConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        [deleteConn start];
        
        deleteData = [[NSMutableData alloc] init];
        
        
   // }
}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == deleteConn) {
        
        [deleteData setLength:0];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == deleteConn) {
        
        [deleteData appendData:data];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == deleteConn) {
        
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:deleteData encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:str];
        NSDictionary *responce= res[@"response"];
        int status= [responce[@"status"] integerValue];
        
       
        [HUD hide:YES];
        if (status==0)
            
        {
            AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [[self appDelegate]disconnect];
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from master_table "];
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from blocked_user "];
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_group "];
            [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_message "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from chat_personal "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from contacts "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_category "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_join_request "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_members "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_private "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from groups_public "];  [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from notify_settings "];
          [[DatabaseManager getSharedInstance]deleteDataWithQuery:@"delete from group_invitations "];  
            //AppDelegate *appDelegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            // [appDelegateObj setLoginView];
            
            [appDelegateObj setLoginView];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:responce[@"error_message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
          
        }
        
        else
        {
            UIAlertView *deleteFailure=[[UIAlertView alloc]initWithTitle:@"" message:responce[@"error_message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [deleteFailure show];
            [password setText:@""];
            
        }
        
        
        deleteConn=nil;
        
        [deleteConn cancel];
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
