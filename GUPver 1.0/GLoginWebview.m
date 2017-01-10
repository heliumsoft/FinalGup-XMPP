//
//  GLoginWebview.m
//  socialLogin
//
//  Created by Deepesh_Genora on 5/8/14.
//  Copyright (c) 2014 Deepesh_Genora. All rights reserved.
//

#import "GLoginWebview.h"
#import "Login.h"
#import "JSON.h"
NSString *client_id = @"103493323195-u87e4500fsrgkbqismoueasj44vblodo.apps.googleusercontent.com";;
NSString *secret = @"yhvpAT0T7QWlfMBZ7gt-Xra9";
NSString *callbakc =  @"http://localhost";;
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile+https://www.google.com/reader/api/0/subscription";
NSString *visibleactions = @"http://schemas.google.com/AddActivity";
@interface GLoginWebview ()

@end

@implementation GLoginWebview
@synthesize webview,isLogin,isReader,Caller;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
-(void)viewWillAppear:(BOOL)animated
{self.title=@"Google Login";
    [self.navigationController.navigationBar setHidden:false];
}
-(void)viewWillDisappear:(BOOL)animated
{[self.navigationController.navigationBar setHidden:true];
     if (user_id!=nil)
         [Caller freezerAnimate];
}
-(void)viewDidDisappear:(BOOL)animated
{//[Caller freezerAnimate];
    if (user_id!=nil)
    [Caller performSelector:@selector(gmailLoginOnGupWithUserId:) withObject:user_id ];
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{[self freezerAnimate];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{[self freezerRemove];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    user_id=nil;
    // Do any additional setup after loading the view from its nib.
    NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=%@&redirect_uri=%@&scope=%@&data-requestvisibleactions=%@",client_id,callbakc,scope,visibleactions];
    webview.autoresizesSubviews = YES;
    webview.scalesPageToFit = YES;
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //    [indicator startAnimating];
    NSLog(@"response %@",[[request URL] host]);
    NSLog(@"furthur responce %@",[[request URL] query]);
    if ([[[request URL] host] isEqualToString:@"localhost"]) {
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                verifier = [keyValue objectAtIndex:1];
                NSLog(@"verifier %@",verifier);
                break;
            }
            if ([key isEqualToString:@"error"] )
            {
                if ([keyValue objectAtIndex:1])
                [self.navigationController popViewControllerAnimated:YES ];
            }
        }
        
        if (verifier) {
            NSString *data = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code", verifier,client_id,secret,callbakc];
            NSString *url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/token"];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            receivedData = [[NSMutableData alloc] init];
            
        } else {
            // ERROR!
        }
        
        [webView removeFromSuperview];
        
        return NO;
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(connection==theConnection)
        [receivedData appendData:data];
    else if (connection==getUserData)
        [userData appendData:data];
    NSLog(@"verifier %@",receivedData);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"%@", error]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection==getUserData){
        NSString *response = [[NSString alloc] initWithData:userData encoding:NSASCIIStringEncoding];
        SBJSON *jResponse = [[SBJSON alloc]init];
        NSDictionary *userGoogleData = [jResponse objectWithString:response];
         [self freezerRemove];
        if ([userGoogleData objectForKey:@"user_id"]){
            NSLog(@"my user ID %@",[userGoogleData objectForKey:@"user_id"]);
            [self.navigationController popViewControllerAnimated:YES];
            user_id=[userGoogleData objectForKey:@"user_id"];
           
        }else{
            NSLog(@"kon re tu ");
            NSLog(@"error %@",[userGoogleData objectForKey:@"error"]);
            user_id=nil;
        }
        
    }else if(connection==theConnection){
        
        NSString *response = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
        SBJSON *jResponse = [[SBJSON alloc]init];
        NSDictionary *tokenData = [jResponse objectWithString:response];
        //  WebServiceSocket *dconnection = [[WebServiceSocket alloc] init];
        //   dconnection.delegate = self;
        
       // NSString *pdata = [NSString stringWithFormat:@"type=3&token=%@&secret=123&login=%@", [tokenData objectForKey:@"refresh_token"], self.isLogin];
        //  NSString *pdata = [NSString stringWithFormat:@"type=3&token=%@&secret=123&login=%@",[tokenData accessToken.secret,self.isLogin];
        //  [dconnection fetch:1 withPostdata:pdata withGetData:@"" isSilent:NO];
        if ([tokenData objectForKey:@"access_token"])
        {[self getUserIdFromAccessTocken:[tokenData objectForKey:@"access_token"]];
        }
        
       
    }
}

-(void)getUserIdFromAccessTocken:(NSString*)accessToken{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url=[NSString stringWithFormat:@"https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=%@",accessToken];
    NSLog(@"Url final=%@",url);
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    getUserData = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [getUserData scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [getUserData start];
    userData = [[NSMutableData alloc] init];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
