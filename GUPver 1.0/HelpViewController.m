//
//  HelpViewController.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/18/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "HelpViewController.h"
#import "Login.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
      //  self.navigationItem.title = @"Help";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view sendSubviewToBack:scrollView];
   // scrollView.layer.borderWidth=5;
    
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"snap"]];
 //   scrollView.layer.borderWidth=2;
    lastSlide=0;
    
    
    images=[NSArray arrayWithObjects:@"snap_4",@"snap_3",@"snap_5",@"snap_1",@"snap_2", nil];
    heading=[NSArray arrayWithObjects:@"Welcome to GUP",@"Easy Sign up",@"Quick explore option",@"Create your own Group",@"You are all set" ,nil];
    details=[NSArray arrayWithObjects:@"\n\nGUP lets you discover and join local and global chats around you on a broad array of topics. You can chat about sports, shopping, politics, music, movies, love, school or just chat with your friends one-on-one. Or why not make some new friends based on your interests!",@"\n\nSign up using your email or facebook/Google plus/twitter login. Select a username you like and your best mug shot. Don't forget to select your location for finding local groups around you.",@"\n\nUse the Explore  option under Menu to find groups and users. You can either search for groups and users or you can browse through the categories to find groups you may like.",@"\n\nCan't find what you are looking for? Why not create your own group and invite your friends to join? You can create public groups (anyone can join) or private groups (you choose who joins), which are either local (only visible to people in your city) or global.",@"\n\nIt's that easy!!! Now you can chat in groups or one-on-one, share pictures, voice messages, etc. We hope you enjoy using GUP. We would appreciate all feedback (praises and bricks alike!!). If you like what you see, then please do spread the word.", nil];
     CGSize deviceSize=[UIScreen mainScreen].bounds.size;
    for (int i = 0; i < images.count; i++) {
        
        CGRect frame;
        
        frame.origin.y = 125;
        
        frame.size.height=deviceSize.height-57-125;
        frame.size.width = frame.size.height*0.8533;
        frame.origin.x = deviceSize.width * i+(deviceSize.width -frame.size.width);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
       ///  [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        imageView.image = [UIImage imageNamed:[images objectAtIndex:i]];
     //   imageView.layer.borderWidth=1;
     //   imageView.layer.borderWidth=2;
        [scrollView addSubview:imageView];
        UITextView *detailsLab=[[UITextView alloc]initWithFrame:CGRectMake(deviceSize.width * i+10, deviceSize.height-57-15-150
                                                                 , 170, 150)];
      //  detailsLab.contentInset = UIEdgeInsetsMake(-9.0,20.0,-18.0f,0.0);
        [detailsLab setEditable:NO];
      //  detailsLab.scrollEnabled=NO;
        UIFont *ArialFont11 = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        NSDictionary *arialdict11 = [NSDictionary dictionaryWithObject: ArialFont11 forKey:NSFontAttributeName];
        
        NSMutableAttributedString *AattrString11 = [[NSMutableAttributedString alloc] initWithString:[heading objectAtIndex:i] attributes: arialdict11];
        
        
        
        UIFont *VerdanaFont11 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
        NSDictionary *veradnadict11 = [NSDictionary dictionaryWithObject:VerdanaFont11 forKey:NSFontAttributeName];
        NSMutableAttributedString *VattrString11 = [[NSMutableAttributedString alloc]initWithString:[details objectAtIndex:i] attributes:veradnadict11];
        //[VattrString11 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:(NSMakeRange(0, 1))];
        
        [AattrString11 appendAttributedString:VattrString11];
        
        [detailsLab setAttributedText:AattrString11];
        [detailsLab setTextAlignment:NSTextAlignmentCenter ];
       // [detailsLab setEditable:NO];
       // [detailsLab setUserInteractionEnabled:NO];
       // [detailsLab setNumberOfLines:20];
        NSLog(@"text %@",AattrString11);
        [scrollView addSubview:detailsLab];
        [detailsLab setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
        NSLog(@" h=%f w=%f",deviceSize.height,deviceSize.width);
      //  [imageView setCenter:CGPointMake(scrollView.frame.size.width * i+160, deviceSize.height/2)];
           NSLog(@" h=%f w=%f",imageView.frame.size.height,imageView.frame.size.width);
    }
    
    scrollView.contentSize = CGSizeMake(deviceSize.width * images.count,self.view.frame.size.height-64);
    
    pageControlBeingUsed=NO;
    
}
- (void)removeImage:(NSString*)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    
    NSError *error = nil;
    if(![fileManager removeItemAtPath: defaultDBPath error:&error]) {
        NSLog(@"Delete failed:%@", error);
    } else {
        NSLog(@"image removed: %@", defaultDBPath);
    }
    
   // NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];
 //   NSLog(@"Directory Contents:\n%@", [fileManager directoryContentsAtPath: appFolderPath]);
}
-(IBAction)buttonAction:(id)sender
{
    for (int i = 0; i < images.count; i++)
    {
        [self removeImage:[[images objectAtIndex:i] stringByAppendingString:@".png"]];
        [self removeImage:[[images objectAtIndex:i] stringByAppendingString:@"@2x.png"]];
    }
    UIRemoteNotificationType types;
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        types = (UIRemoteNotificationType)[[[UIApplication sharedApplication] currentUserNotificationSettings] valueForKey:@"types"];
    }
   #else
        types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
   #endif
    [self.navigationController popViewControllerAnimated:YES];
    if (types == UIRemoteNotificationTypeNone)
    {
        NSLog
        (@"User doesn't want to receive push-notifications");
       // NSString *    `msg = @"Please press ON to enable Push Notification";
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Some of the features won't function as desired. To enjoy all features enable push notification in the settings" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        
//        [alert show];
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
    lastSlide++;
    if (lastSlide==4) {
        NSLog(@"last slide=%i",lastSlide);
        [button setTitle:@"Done" forState:UIControlStateNormal];
    }
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = scrollView.frame.size.width * pageControl.currentPage;
    frame.origin.y = 30;
    frame.size = scrollView.frame.size;
    [scrollView scrollRectToVisible:frame animated:YES];
    pageControlBeingUsed = YES;
}

/*- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}*/

-(void)viewWillAppear:(BOOL)animated{
   //  self.tabBarController.tabBar.hidden = YES;
   // [self.navigationController setNavigationBarHidden:YES animated:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
