//
//  ShareViewController.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ShareViewController.h"
#import <Social/Social.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
static NSString *urlToBeShared=@"";

static NSString *ContentToBeShared=@"Found this cool new app called Gup for location based public and private group chats. Visit http://gupapp.com to download";//@"Found this cool new app called Gup where you can participate in one on one and public group chats. Check our for yourself";Found this cool new app called Gup where you can participate in one on one and public group chats and it's location based. Visit http://gupapp.com to download
static NSString *ImageToBeShared = @"Gup LOGO.png";
static NSString * const kClientId = @"1049791696445.apps.googleusercontent.com";

@interface ShareViewController ()

@end

@implementation ShareViewController
@synthesize signInButton,mc;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       self.navigationItem.title = @"Invite Friends";
//       UIImage *selectedImage = [UIImage imageNamed:@"shareActive"];
//       UIImage *unselectedImage = [UIImage imageNamed:@"shareTab"];
//       [self.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
     //  self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    return self;
}
-(void)tap{
    
    id<GPPNativeShareBuilder> shareBuilder= (id<GPPNativeShareBuilder>) [[GPPShare sharedInstance] nativeShareDialog];
    NSLog(@"basic data %@",ContentToBeShared);
    NSLog(@"share url %@",urlToBeShared);
    [shareBuilder setPrefillText:[NSString stringWithFormat:@"%@ \n \n  %@",ContentToBeShared,urlToBeShared]];
   // [shareBuilder attachImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",ImageToBeShared]]];
    [shareBuilder open];
    
}
- (void)viewDidLoad{
    
    [super viewDidLoad];
    isIpad= [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserID = YES;
    signIn.shouldFetchGooglePlusUser = YES;
    // signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    signIn.scopes = [NSArray arrayWithObjects: kGTLAuthScopePlusLogin, // defined in GTLPlusConstants.h
                     nil];
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    //[self refreshInterfaceBasedOnSignIn];
    [signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];

    
    [self initialiseView];
}
-(void)refreshInterfaceBasedOnSignIn{
    
    if ([[GPPSignIn sharedInstance] authentication]) {
    
        [self tap];
        // The user is signed in.
        // self.signInButton.hidden = YES;
        // Perform other actions here, such as showing a sign-out button
        
    } else {
        //   self.signInButton.hidden = NO;
        // Perform other actions here
    }
}
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        // Do some error handling here.
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
    if (error) {
        // Do some error handling here.
    } else {
        //  _labelFirstName.text = [NSString stringWithFormat:@"Hello %@  ", signIn.authentication.userEmail];
        NSLog(@"user id  ==++= %@", signIn.userID);
        NSLog(@"google plus user ==++= %@", signIn.googlePlusUser);
        
        NSLog(@"user email  === %@", signIn.authentication.userEmail);
        
        [self refreshInterfaceBasedOnSignIn];
    }

}
- (void)finishedSharingWithError:(NSError *)error {
    if (!error) {
        NSLog(@"Shared succesfully");
    } else if(error.code == kGPPErrorShareboxCanceled) {
        NSLog(@"User cancelled share");
    } else {
        NSLog(@"Unknown share error: %@", [error localizedDescription]);
    }
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
}

-(void)initialiseView
{
    
    [shareTable setDelegate:self];
    [shareTable setDataSource:self];
}
#pragma Mailing delegates
- (void)showEmail
{
    @try {
        // Email Subject
        
        mc= [[MFMailComposeViewController alloc] init];
        if ([MFMailComposeViewController canSendMail])
        {mc.mailComposeDelegate = self;
            [mc setSubject:@"Check It Now"];
            [mc setMessageBody:[NSString stringWithFormat:@"%@ \n %@",ContentToBeShared,urlToBeShared] isHTML:NO];
            //  NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"%@",ImageToBeShared]]);
            //  [mc addAttachmentData:imageData mimeType:@"image/png" fileName:@"MyImageName"];
            
            //[mc setToRecipients:];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            //[self presentModalViewController:mc animated:YES];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"exception found %@",exception);
    }
    
    }
   
      

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma Messaging delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:Nil message:@"Failed to Send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    shareTable.userInteractionEnabled=YES;
}
- (void)showSMS:(NSString*)file {
    shareTable.userInteractionEnabled=NO;
    @try {
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:Nil message:@"Your Device doesn't Support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        else
        {
        // NSArray *recipents = @[@"12345678", @"72345524"];
        NSString *message = [NSString stringWithFormat:@" \n %@ \n %@",/* file,*/ContentToBeShared,urlToBeShared];
        
        messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        // [messageController setRecipients:recipents];
        [messageController setBody:message];
        
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
        }
        }
    @catch (NSException *exception)
    {
        NSLog(@"exception found %@",exception);
        }
  
}

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
        return 7;
    
//    if (section == 0)
//        return isIpad?1:2;
//    if (section == 1)
//        return isIpad?3:4;
//    else
//        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView *iconView;
    UILabel* loc;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        iconView = [[UIImageView alloc]initWithFrame:CGRectMake(12,5,30,30)];
        [cell addSubview:iconView];
        cell.backgroundColor = [UIColor clearColor];
        
        loc = [[UILabel alloc] initWithFrame: CGRectMake(54, 0, cell.frame.size.width-60, cell.frame.size.height)];
        loc.font = [UIFont fontWithName:@"Dosis-SemiBold" size:17.f];
        loc.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
        [cell addSubview:loc];
    }
        if(indexPath.row == 0)
    {
        
                iconView.image = [UIImage imageNamed:@"sms"];
                loc.text = @"SMS";
        
    }else  if(indexPath.row == 1)
    {

            iconView.image = [UIImage imageNamed:@"mail"];
                loc.text = @"Mail";
    }
    else if(indexPath.row == 2)
    {
                iconView.image = [UIImage imageNamed:@"facebook"];
                loc.text = @"Facebook";
    }else if(indexPath.row==3){
                iconView.image = [UIImage imageNamed:@"watsapp"];
                loc.text = @"WhatsApp";
    }else if(indexPath.row==4){
           signInButton=[[GPPSignInButton alloc]init];
                iconView.image = [UIImage imageNamed:@"google"];
                loc.text = @"Google Plus";
    }else if(indexPath.row==5){
        
               iconView.image = [UIImage imageNamed:@"twitter"];
                loc.text = @"Twitter";
        
        
    }else if(indexPath.row==6){
    

                iconView.image = [UIImage imageNamed:@"rate"];
                loc.text = @"Rate/Review Us";
    }

    
    return cell;
    
    
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
            [self showSMS:ImageToBeShared];
            
      
    }else if(indexPath.row==1){
        
       
            [self showEmail];
       
        
    }else if(indexPath.row==2){
  
            SLComposeViewController *FacebookSheet = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeFacebook];

         //  if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook ])
        //{
            @try {
                
                
            [FacebookSheet setInitialText:ContentToBeShared];
            [FacebookSheet addURL:[NSURL URLWithString:urlToBeShared]];
            NSLog(@"website%@",urlToBeShared);
                FacebookSheet.editing=NO;
           // [FacebookSheet addImage:[UIImage imageNamed:ImageToBeShared]];
            [self.navigationController presentViewController:FacebookSheet animated:YES completion:^{
                [self.navigationController popToRootViewControllerAnimated:YES];
                FacebookSheet.editing=NO;
                
            }];

            
            
//        }
  //      else
      //  {[self.navigationController presentViewController:FacebookSheet animated:NO completion:^{            [self.navigationController popToRootViewControllerAnimated:YES];
            
        //}];
            }
           
            @catch (NSException *exception) {
                                UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"%@",exception] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
            [noti show];
            }
        
        
            
            
            
        }else if(indexPath.row==3){
        
            NSLog(@"%@",[self encodeImage]);
            NSURL *whatsappURL = [NSURL URLWithString:[self encodeURIComponent:[NSString stringWithFormat:@"whatsapp://send?text=%@\n%@",ContentToBeShared,urlToBeShared]]];
            NSLog(@"%@",whatsappURL);
            NSLog(@"%@",whatsappURL);
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication]openURL: whatsappURL];
          
            }
            else
            {UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:@"Please Install Whatsapp on Your Phone" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil ];
                [noti show];
            }
         
        }
     else if(indexPath.row==4){
       
            [signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
        else if(indexPath.row==5){
        
          //  if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter ])
            //{
             @try {
                SLComposeViewController *TwitterSheet = [SLComposeViewController
                                                         composeViewControllerForServiceType:SLServiceTypeTwitter];
                [TwitterSheet setInitialText:ContentToBeShared];
                [TwitterSheet addURL:[NSURL URLWithString:urlToBeShared]];
                NSLog(@"website%@",urlToBeShared);
           //     [TwitterSheet addImage:[UIImage imageNamed:ImageToBeShared]];
                [self presentViewController:TwitterSheet animated:YES completion:nil];
            }
            //else
          /*  {
                UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:@"Please make sure you are login to Twitter Account on your device" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
                [noti show];
            }*/
                 @catch (NSException *exception) {
                     UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"%@",exception] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
                     [noti show];
                 }


        }
    
   else if(indexPath.row==6){
       NSString *appId = [[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] componentsSeparatedByString:@"."] lastObject];
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id863991482"]];
    }

   
}
- (NSString *)encodeURIComponent:(NSString *)string
{
    NSString *s = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return s;
}
-(NSString*)encodeImage
{NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:ImageToBeShared]);
    NSString *imageString = [NSString stringWithFormat:@"%@", [imageData base64Encoding]];
    NSLog(@"%@",imageString);
    return imageString;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
