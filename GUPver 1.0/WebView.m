//
//  WebView.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 1/17/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import "WebView.h"
#import "AppDelegate.h"
@interface WebView ()

@end

@implementation WebView
@synthesize fromView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([fromView isEqualToString:@"help"]) {
            self.title = @"Help";
        }
        else if ([fromView isEqualToString:@"terms"])
        {
            self.title = @"Terms of Services";
        }
        else if ([fromView isEqualToString:@"privacypolicy"])
        {
            self.title = @"Privacy Policy";
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    [webView setDelegate:self];
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    NSString *webUrl;
    if ([fromView isEqualToString:@"help"]) {
        webUrl=[NSString stringWithFormat:@"http://www.gupapp.com/?page_id=73"];
    }
    else if ([fromView isEqualToString:@"terms"])
    {
       webUrl=[NSString stringWithFormat:@"%@/scripts/faq/terms.html",gupappUrl ];
    }
    else if ([fromView isEqualToString:@"privacypolicy"])
    {
       webUrl=[NSString stringWithFormat:@"%@/scripts/faq/privacy.html",gupappUrl];
    }
    
    NSLog(@"loading webview with url:%@",webUrl);
    NSURL *url = [NSURL URLWithString:webUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  
    webView.autoresizesSubviews = YES;
    webView.scalesPageToFit = YES;
    [webView loadRequest:requestObj];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [HUD hide:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [HUD hide:YES];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                     message:@"Network Issue.Please Try Again."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
