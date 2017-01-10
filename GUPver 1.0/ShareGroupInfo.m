//
//  ShareGroupInfo.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/19/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ShareGroupInfo.h"
#import "AppDelegate.h"
#import "PostListing.h"
#import "ChatScreen.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
static NSString * const kClientId =@"1049791696445.apps.googleusercontent.com";


@interface ShareGroupInfo ()

@end

@implementation ShareGroupInfo
@synthesize signInButton,groupType,mc;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Share";
    }
    return self;
}
@synthesize groupId,groupName,hideUnhideSkipDoneButton;
-(void)tap{
    id<GPPNativeShareBuilder> shareBuilder= (id<GPPNativeShareBuilder>) [[GPPShare sharedInstance] nativeShareDialog];
    
    NSLog(@"basic data %@",groupName);
    
    if(self.postText.length>0 || self.imageURl.count!=0){
        for (NSString *url in self.imageURl) {
            [shareBuilder attachImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]];
        }
        
        NSString *shareText =[NSString stringWithFormat:@"Check out Gup post \"%@\" in the group \"%@\".",self.postText,self.groupName];
        
        int like=[self.noOfLikes intValue];
        if(like>5)
           shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It received %@ likes.",self.noOfLikes]];
        
        int comments = [self.noOfComments intValue];
        if(comments >5)
           shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It was commented on %@ times.",self.noOfComments]];
        
       shareText = [shareText stringByAppendingString:@"Download Gup at http://gupapp.com for a unique topic based group chat experience."];
        
        [shareBuilder setPrefillText:shareText];
//        self.postText = @"";
//        self.imageURl = nil;
        
    }else{
        [shareBuilder setPrefillText:[NSString stringWithFormat:@"I found this cool new group called %@ in GUP. Visit http://gupapp.com to download. Then search for the group and join"/*@"I have created a new group %@ in Gup. Should be fun. Wanna join?"*/,groupName]];
    }
    //    NSLog(@"share url %@",urlToBeShared);
    
    // [shareBuilder attachImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",ImageToBeShared]]];
    
    [shareBuilder open];
    
}
-(void)viewWillAppear:(BOOL)animated{
   
    
    if(self.postText || self.imageURl.count!=0){

        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(dismiss)];
        
    }
}

-(void)dismiss{
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)viewDidLoad{
    
    isIpad= [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGoogleUserID = YES;
    signIn.shouldFetchGooglePlusUser = YES;
   
    signIn.clientID = kClientId;
    signIn.scopes = [NSArray arrayWithObjects: kGTLAuthScopePlusLogin, // defined in GTLPlusConstants.h
                     nil];
    signIn.delegate = self;
    [signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    
    NSLog(@"group id=%@ groupName=%@",groupId,groupName);
    [super viewDidLoad];
    if ([hideUnhideSkipDoneButton isEqualToString:@"hide"]) {
        self.navigationItem.hidesBackButton = NO;
    }
    else
    {
        
        doneButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1] forState:UIControlStateNormal];
        doneButton.titleLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:20];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        
        [table setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-140)];
        self.navigationItem.hidesBackButton = YES;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
}
-(void)refreshInterfaceBasedOnSignIn
{
    if ([[GPPSignIn sharedInstance] authentication]) {
        [self tap];
        
    } else {
        
    }
}
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth error: (NSError *) error
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

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
      return 6;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
   
    
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
        
        
    }
    
    
    return cell;
    return cell;
    
    
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0)
    {
        [self performSelector:@selector(showSMS) withObject:nil afterDelay:0.5 ];
        
        
    }else if(indexPath.row==1){
        
        
         [self showEmail];
        
        
    }else if(indexPath.row==2){
        
        @try {
            SLComposeViewController *FacebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            if(self.postText.length>0 || self.imageURl.count!=0){
                for (NSString *url in self.imageURl) {
                    NSLog(@"%i",[FacebookSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]]);
                }
                self.postText=[self.postText UTFDecoded];
                self.postText=[self RadhaCompatiableDecodingForString:self.postText];
                self.postText=[self.postText stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                NSString *shareText =[NSString stringWithFormat:@"Check out Gup post \"%@\" in the group \"%@\".",self.postText,self.groupName];
                int like=[self.noOfLikes intValue];
                if(like>5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It received %@ likes.",self.noOfLikes]];
                
                int comments = [self.noOfComments intValue];
                if(comments >5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It was commented on %@ times.",self.noOfComments]];
                
                shareText = [shareText stringByAppendingString:@"Download Gup at http://gupapp.com for a unique topic based group chat experience."];
                
                [FacebookSheet setInitialText:shareText];
                [self presentViewController:FacebookSheet animated:YES completion:nil];
                //                            self.postText = @"";
                //                            self.imageURl = nil;
                
            }else{
                [FacebookSheet setInitialText:[NSString stringWithFormat:@"I found this cool new group called %@ in GUP. Visit http://gupapp.com to download. Then search for the group and join",groupName]];
                [self presentViewController:FacebookSheet animated:YES completion:nil];
            }
        }@catch (NSException *exception) {
            UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"%@",exception] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
            [noti show];
        }
        
        
        
    }else if(indexPath.row==3){
        
        if(self.postText.length>0 || self.imageURl.count>0){
            
            if(self.imageURl.count>0){
                UIImage     * iconImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.imageURl firstObject]]]];
                NSString    * savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.wai"];
                
                [UIImageJPEGRepresentation(iconImage, 1.0) writeToFile:savePath atomically:YES];
                
                _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
                _documentInteractionController.UTI = @"net.whatsapp.image";
                _documentInteractionController.delegate = self;
                [_documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated: YES];
            }else  if (self.postText.length>0) {
                //                            self.postText = @"";
                self.postText=[self.postText UTFDecoded];
                self.postText=[self RadhaCompatiableDecodingForString:self.postText];
                self.postText=[self.postText stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                NSString *shareText =[NSString stringWithFormat:@"Check out Gup post \"%@\" in the group \"%@\".",self.postText,self.groupName];
                int like=[self.noOfLikes intValue];
                if(like>5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It received %@ likes.",self.noOfLikes]];
                
                int comments = [self.noOfComments intValue];
                if(comments >5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It was commented on %@ times.",self.noOfComments]];
                
                shareText = [shareText stringByAppendingString:@"Download Gup at http://gupapp.com for a unique topic based group chat experience."];
                NSURL *whatsappURL = [NSURL URLWithString:[self encodeURIComponent:[NSString stringWithFormat:@"whatsapp://send?text=%@",shareText]]];
                NSLog(@"%@",whatsappURL);
                if([[UIApplication sharedApplication] canOpenURL:whatsappURL]){
                    [[UIApplication sharedApplication]openURL:whatsappURL];
                }
                
                //                            self.postText = @"";
                //                            self.imageURl = nil;
            }
        }else{
            NSLog(@"watsapp");
            NSURL *whatsappURL = [NSURL URLWithString:[self encodeURIComponent:[NSString stringWithFormat:@"whatsapp://send?text=I found this cool new group called %@ in GUP. Visit http://gupapp.com to download. Then search for the group and join\n",groupName]]];
            NSLog(@"%@",whatsappURL);
            
            NSLog(@"%@",whatsappURL);
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication]openURL: whatsappURL];
                
            }else{
                UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:@"Please install Whatsapp on your phone" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil ];
                [noti show];
            }
        }
        
    }
    else if(indexPath.row==4){
        
        [signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];

    }
    else if(indexPath.row==5){
        
        @try {
            SLComposeViewController *TwitterSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            if(self.postText.length>0 || self.imageURl.count!=0){
                self.postText=[self.postText UTFDecoded];
                self.postText=[self RadhaCompatiableDecodingForString:self.postText];
                self.postText=[self.postText stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                NSString *shareText =[NSString stringWithFormat:@"Check out Gup post \"%@\" in the group \"%@\".",self.postText,self.groupName];
                int like=[self.noOfLikes intValue];
                if(like>5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It received %@ likes.",self.noOfLikes]];
                
                int comments = [self.noOfComments intValue];
                if(comments >5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It was commented on %@ times.",self.noOfComments]];
                
                shareText = [shareText stringByAppendingString:@"Download Gup at http://gupapp.com for a unique topic based group chat experience."];
                [TwitterSheet setInitialText:[NSString stringWithFormat:@"%@ ",shareText]];
                for (NSString *url in self.imageURl) {
                    [TwitterSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]];
                }
                [self presentViewController:TwitterSheet animated:YES completion:nil];
                //                            self.postText = @"";
                //                            self.imageURl = nil;
            }else{
                [TwitterSheet setInitialText:[NSString stringWithFormat:@"I found this cool new group called %@ in GUP. Visit http://gupapp.com to download. Then search for the group and join"/*@"I have created a new group %@ in Gup. Should be fun. Wanna join?"*/,groupName]];
                // [TwitterSheet addURL:[NSURL URLWithString:urlToBeShared]];
                // NSLog(@"website%@",urlToBeShared);
                // [TwitterSheet addImage:[UIImage imageNamed:ImageToBeShared]];
                [self presentViewController:TwitterSheet animated:YES completion:nil];
                
            }
        }
        /*else
         {UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:@"Please make sure you are login to Twitter Account on your device" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
         [noti show];
         }*/
        @catch (NSException *exception) {
            UIAlertView *noti=[[UIAlertView alloc]initWithTitle:Nil message:[NSString stringWithFormat:@"%@",exception] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil ];
            [noti show];
        }
        
        
        
        
    }
    
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    
}

-(NSString*)RadhaCompatiableDecodingForString:(NSString*)str{
    
    return  [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
}
- (NSString *)encodeURIComponent:(NSString *)string
{
    NSString *s = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return s;
}

#pragma Messaging delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:Nil message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    table.userInteractionEnabled=YES;
}

- (void)showSMS{
    NSLog(@"a");
    table.userInteractionEnabled=NO;
    @try {
        NSLog(@"1");
        if(![MFMessageComposeViewController canSendText]) {
            NSLog(@"2");
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:Nil message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }else {
            messageController = [[MFMessageComposeViewController alloc] init];
            
            NSLog(@"3");
            // NSArray *recipents = @[@"12345678", @"72345524"];
            NSString *message ;
            if(self.postText){
                self.postText=[self.postText UTFDecoded];
                self.postText=[self RadhaCompatiableDecodingForString:self.postText];
                self.postText=[self.postText stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                NSString *shareText =[NSString stringWithFormat:@"Check out Gup post \"%@\" in the group \"%@\".",self.postText,self.groupName];
                int like=[self.noOfLikes intValue];
                if(like>5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It received %@ likes.",self.noOfLikes]];
                
                int comments = [self.noOfComments intValue];
                if(comments >5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It was commented on %@ times.",self.noOfComments]];
                
                shareText = [shareText stringByAppendingString:@"Download Gup at http://gupapp.com for a unique topic based group chat experience."];
                
                message =shareText;
            } else
                message = [NSString stringWithFormat:@"I found this cool new group called %@ in GUP. Visit http://gupapp.com to download. Then search for the group and join"/*@"I have created a new group %@ in Gup. Should be fun. Wanna join?"*/,groupName];
            int i=1;
            for (NSString *imageUrl in self.imageURl){
                NSData *date = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                [messageController addAttachmentData:date typeIdentifier:@"img" filename:[NSString stringWithFormat:@"image_%d",i++]];
//                [messageController addAttachmentURL:[NSURL URLWithString:imageUrl] withAlternateFilename:[NSString stringWithFormat:@"image_%d",i++]];
            }
            
            NSLog(@"4");
            messageController.messageComposeDelegate = self;
            // [messageController setRecipients:recipents];
            [messageController setBody:message];
            
            // Present message view controller on screen
            NSLog(@"5");
            [self presentViewController:messageController animated:YES completion:nil];
                NSLog(@"6");
            }
        }
    
    @catch (NSException *exception){
        NSLog(@"7");
        NSLog(@"exception found %@",exception);
    }
}

#pragma Mailing delegates
- (void)showEmail
{
    // Email Subject
    
    mc = [[MFMailComposeViewController alloc] init];
   
    if ([MFMailComposeViewController canSendMail]) {
        mc.mailComposeDelegate = self;
       
        if(self.postText || self.imageURl.count!=0){
            [mc setSubject:@"Post Share"];
            if(self.postText){
                self.postText=[self.postText UTFDecoded];
                self.postText=[self RadhaCompatiableDecodingForString:self.postText];
                self.postText=[self.postText stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                NSString *shareText =[NSString stringWithFormat:@"Check out Gup post \"%@\" in the group \"%@\".",self.postText,self.groupName];
                int like=[self.noOfLikes intValue];
                if(like>5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It received %@ likes.",self.noOfLikes]];
                
                int comments = [self.noOfComments intValue];
                if(comments >5)
                    shareText = [shareText stringByAppendingString:[NSString stringWithFormat:@"It was commented on %@ times.",self.noOfComments]];
                
                shareText = [shareText stringByAppendingString:@"Download Gup at http://gupapp.com for a unique topic based group chat experience."];
                [mc setMessageBody:[NSString stringWithFormat:@"%@",shareText] isHTML:NO];
            }
            for (NSString *imageUrl in self.imageURl) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                [mc addAttachmentData:data mimeType:[self contentTypeForImageData:data] fileName:@"image"];
            }
            
        }else{
             [mc setSubject:@"Join this group"];
            [mc setMessageBody:[NSString stringWithFormat:@"I found this cool new group called %@ in GUP. Visit http://gupapp.com to download. Then search for the group and join",groupName] isHTML:NO];
            
        }
        // Present mail view controller on screen unicode_98
        [self presentViewController:mc animated:YES completion:NULL];
    }
    
    
}

- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
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



- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(IBAction)skip:(id)sender{
    
    messageController=nil;
    mc=nil;
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (int o=[allViewControllers count]-1; o>0; o--) {
        [allViewControllers removeObjectAtIndex:o];
    }
    NSLog(@"%@",allViewControllers);
    //  self.navigationController.viewControllers = allViewControllers;
    
//    ChatScreen *chatScreenPage = [[ChatScreen alloc]init];
//    chatScreenPage.chatType = @"group";
//    chatScreenPage.toJid = _groupJID;
//    chatScreenPage.chatTitle=groupName;
//    [chatScreenPage initWithUser:[NSString stringWithFormat:@"user_%@@%@",groupId,(NSString*)jabberUrl]];
//    chatScreenPage.groupType=groupType;
//    [self appDelegate].isUSER=0;
//    [allViewControllers addObject:chatScreenPage];
    
    PostListing *detailPage = [[PostListing alloc]init];
    detailPage.chatTitle=groupName;
    detailPage.groupId = groupId;
    detailPage.groupName = groupName;
    detailPage.groupType=groupType;
    [self appDelegate].isUSER=0;
//    [self.navigationController pushViewController:detailPage animated:YES];
    [allViewControllers addObject:detailPage];
    
    
    self.navigationController.viewControllers = allViewControllers;
    // [self appDelegate].isUSER=0;
    //[ self.navigationController pushViewController:chatScreenPage animated:YES];
    //[[self appDelegate].viewController1.navigationController pushViewController:chatScreenPage animated:YES];
}
-(IBAction)done:(id)sender{
    messageController=nil;
    mc=nil;
    // [UINavigationBar appearanceWhenContainedIn:[self.navigationController class], nil].titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (int o=[allViewControllers count]-1; o>0; o--) {
        [allViewControllers removeObjectAtIndex:o];
    }
    NSLog(@"%@",allViewControllers);
//    ChatScreen *chatScreenPage = [[ChatScreen alloc]init];
//    chatScreenPage.chatType = @"group";
//    chatScreenPage.chatTitle=groupName;
//    chatScreenPage.toJid = _groupJID;
//    [chatScreenPage initWithUser:[NSString stringWithFormat:@"user_%@@%@",groupId,(NSString*)jabberUrl]];
//    chatScreenPage.groupType=groupType;
//    [self appDelegate].isUSER=0;
//    [allViewControllers addObject:chatScreenPage];
//    self.navigationController.viewControllers = allViewControllers;
    
    
    PostListing *detailPage = [[PostListing alloc]init];
    detailPage.chatTitle=groupName;
    detailPage.groupId = groupId;
    detailPage.groupName = groupName;
    detailPage.groupType=groupType;
    [self appDelegate].isUSER=0;
    //    [self.navigationController pushViewController:detailPage animated:YES];
    [allViewControllers addObject:detailPage];
    
    
    self.navigationController.viewControllers = allViewControllers;

    
    
    
    //[ self.navigationController pushViewController:chatScreenPage animated:YES];
    //  [[self appDelegate].viewController1.navigationController pushViewController:chatScreenPage animated:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
