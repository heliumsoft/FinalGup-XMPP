//
//  ForgotPassword.m
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 11/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ForgotPassword.h"

#import "JSON.h"
#import "Login.h"
@interface ForgotPassword ()

@end

@implementation ForgotPassword

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
        emailID=[[UITextField alloc]init];
      self.title=@"Forgot Password";
    }
    return self;
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
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    mainScroll.contentInset = contentInsets;
    mainScroll.scrollIndicatorInsets = contentInsets;
    
}

-(void)submmit:(id)sender{
    if ([self validateEmail:emailID.text]){
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
        HUD.dimBackground = YES;
        HUD.labelText = @"Please Wait";
        
        NSString *email=[NSString stringWithFormat:@"%@",emailID.text];
        NSLog(@"emailID %@",emailID);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *postData = [NSString stringWithFormat:@"email_id=%@",email];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/forgot_password.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [connection1 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [connection1 start];
        eventsResponse = [[NSMutableData alloc] init];

    }else{
        UIAlertView *popAV=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Enter Valid E-mail ID" delegate:
                            nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [popAV show];
    }
    
}

- (CGRect) convertView:(UIView*)view{
    CGRect rect = view.frame;
    
    while(view.superview) {
        view = view.superview;
        rect.origin.x += view.frame.origin.x;
        rect.origin.y += view.frame.origin.y;
    }
    
    return rect;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    TXFRAME=[self convertView:textField];
    TXFRAME=CGRectMake(TXFRAME.origin.x, TXFRAME.origin.y+40, TXFRAME.size.width,TXFRAME.size.height);
    NSLog(@"frame x=%f y=%f wi=%f he=%f",TXFRAME.origin.x,TXFRAME.origin.y,TXFRAME.size.width,TXFRAME.size.height);

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [emailID resignFirstResponder];
    return YES;
}

-(void)SetEmailID:(NSString*)EmailIDS from:(id)inta{
    instance=inta;
    emailPassed =EmailIDS;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    // [self.navigationController.navigationBar setHidden:false];
  //  self.navigationItem.hidesBackButton=YES;
    
    submitbtn.layer.cornerRadius = 10.0f;
     self.navigationController.navigationBar.tintColor =[UIColor whiteColor];
    
    [submitbtn.titleLabel setFont:[UIFont fontWithName:@"Dosis-Bold" size:16]];
    
    mainScroll.scrollEnabled=true;
    [mainScroll setContentSize:CGSizeMake(mainScroll.frame.size.width, mainScroll.frame.size.height-64)];
    [self.navigationController.navigationBar setHidden:false];
    emailID.autocapitalizationType = UITextAutocapitalizationTypeNone;
     // Do any additional setup after loading the view from its nib.
    [emailID setText:emailPassed];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    emailID.clearButtonMode = UITextFieldViewModeWhileEditing;
    
     self.view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:249.0/255.0 alpha:1.0];
    /*CGSize deviceSize=[UIScreen mainScreen].bounds.size;
    NSLog(@"size w=%f h=%f ",deviceSize.width,deviceSize.height);
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];

    freezer=[[UIView alloc]initWithFrame:CGRectMake(0,0, deviceSize.width, deviceSize.height-44)];
    [freezer setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
    [freezer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    progress=[[UIActivityIndicatorView alloc]init ];
    [progress setCenter:freezer.center];
    [progress setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];*/
    NSLog(@"center x=%f y=%f ",self.view.center.x,self.view.center.y);
    emailID.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL) validateEmail: (NSString *) emailstring {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailstring];
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == connection1) {
        [eventsResponse setLength:0];
    }
    if (connection == connection2) {
        [emailResponce setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did recieve data");
    if (connection == connection1) {
        [eventsResponse appendData:data];
    }
    if (connection == connection2) {
        [emailResponce appendData:data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [HUD hide:YES];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@" finished loading");
    
    if (connection == connection1) {
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
        int status=[responce[@"status"] integerValue];
        
        NSString *errmsg=responce[@"error_message"];
        NSLog(@"error %@",errmsg);
        if ( status==1 ){
            UIAlertView *loginWarning=[[UIAlertView alloc]initWithTitle:Nil message:errmsg delegate:instance cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [loginWarning show];
            [instance updateLoginText:emailID.text];
            [self.navigationController popViewControllerAnimated:YES];
        }else if(status==0){
            UIAlertView *loginWarning=[[UIAlertView alloc]initWithTitle:Nil message:errmsg delegate:instance cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [loginWarning show];
        
        }else if (status==3){
            UIAlertView *verifyNoti=[[UIAlertView alloc]initWithTitle:Nil message:errmsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Resend Email", nil];
            [verifyNoti setTag:66];
            [verifyNoti show];

            
        }
        
        connection1=nil;
        [connection1 cancel];
        [HUD hide:YES];

    }
    if (connection == connection2) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:emailResponce encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        NSLog(@"vishals responce %@",responce);

        [HUD hide:YES];

    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==66){
        if (buttonIndex==1){
            /*
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:@"http://gupapp.com/Gup_demo/scripts/resend_verify.php"]];
            [request setHTTPMethod:@"POST"];
            NSMutableData *body = [NSMutableData data];
            NSString *boundary = @"---------------------------14737809831466499882746641449";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
            [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
            //  parameter username
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%i",[globleData userID]] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            // close form
            [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            // setting the body of the post to the reqeust
            [request setHTTPBody:body];
            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@" return %@",dict);
            NSLog(@"result %@",returnString);
            */
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.delegate = self;
            HUD.dimBackground = YES;
            HUD.labelText = @"Please Wait";
            
            NSString *email=[NSString stringWithFormat:@"%@",emailID.text];
            NSLog(@"emailID %@",emailID);
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *postData = [NSString stringWithFormat:@"email_id=%@",email];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/resend_verify_again.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            connection2 = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [connection2 scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [connection2 start];
            emailResponce = [[NSMutableData alloc] init];

            
        }
    }
    
    
    
}
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
        
        if (indexPath.row==0){
            [emailID setPlaceholder:@"Email Address"];
           // [emailID setTintColor:[UIColor blueColor]];
            [emailID setKeyboardType:UIKeyboardTypeEmailAddress];
            [emailID setAutocorrectionType:UITextAutocorrectionTypeDefault];
            [emailID setDelegate:self];
            
            [emailID setFont:[UIFont fontWithName:@"Dosis-Regular" size:15]];
            [emailID setTextColor:[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1.0]];
            [emailID setFrame:CGRectMake(10, 0, cell.contentView.frame.size.width-20,30)];
            emailID.textAlignment = UIControlContentVerticalAlignmentCenter;
            emailID.layer.cornerRadius =10.0f;
            emailID.layer.borderColor = [[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1.0]CGColor ];
            emailID.layer.borderWidth =1.0f;
            [emailID setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            if ([emailID respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                UIColor *color =  [UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1.0];;
                emailID.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address" attributes:@{NSForegroundColorAttributeName: color}];
            }
            
            emailID.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            
            emailID.autocapitalizationType = UITextAutocapitalizationTypeNone;
            emailID.clearButtonMode = UITextFieldViewModeWhileEditing;
            emailID.textAlignment = NSTextAlignmentCenter;
            cell.backgroundColor = [UIColor clearColor];
            emailID.backgroundColor = [UIColor clearColor];
       
            emailID.clearButtonMode = UITextFieldViewModeWhileEditing;
            [cell addSubview:emailID];
        }
           }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
