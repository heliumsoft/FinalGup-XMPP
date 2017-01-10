//
//  ViewContactProfile.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 12/4/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ViewContactProfile.h"
#import "DatabaseManager.h"
#import "CategoryList.h"
#import "JSON.h"

@interface ViewContactProfile ()

@end

@implementation ViewContactProfile
@synthesize userId,triggeredFrom;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.navigationItem.title = @"Profile";
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    customView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    self.view.frame = [[UIScreen mainScreen] bounds];
    viewContactImageView.frame = CGRectMake(self.view.frame.size.width/2-60, viewContactImageView.frame.origin.y,viewContactImageView.frame.size.width, viewContactImageView.frame.size.height);
    viewContactImageView.layer.cornerRadius = 60;
    viewContactImageView.layer.borderWidth = 2;
    viewContactImageView.layer.borderColor = [UIColor clearColor].CGColor;
    viewContactImageView.clipsToBounds = YES;
    
    line.frame = CGRectMake(11, line.frame.origin.y, self.view.frame.size.width-22, line.frame.size.height);
    userNameLabel.frame = CGRectMake(self.view.frame.size.width/2 - userNameLabel.frame.size.width/2, userNameLabel.frame.origin.y, userNameLabel.frame.size.width-22, userNameLabel.frame.size.height);
    userNameLabel.center = CGPointMake(viewContactImageView.center.x, userNameLabel.center.y);
    aboutLbl.center = CGPointMake(userNameLabel.center.x, aboutLbl.center.y);
    adoutDiscriptionLbl.frame = CGRectMake(adoutDiscriptionLbl.frame.origin.x, adoutDiscriptionLbl.frame.origin.y,self.view.frame.size.width-22, adoutDiscriptionLbl.frame.size.height);
    
    NSString *checkIfExists=[NSString stringWithFormat:@"select * from contacts where user_id=%@",userId];
    BOOL existOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfExists];
    if (existOrNot) {
        NSLog(@"user%@",userId);
        getData = [[NSMutableArray alloc]init];
        getData = [[DatabaseManager getSharedInstance]getViewProfileData:userId];
        UIActivityIndicatorView *imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        imageActivityIndicator.frame = CGRectMake(65.0, 65.0, 30.0, 30.0);
        imageActivityIndicator.center = viewContactImageView.center;
        
        imageActivityIndicator.color = [UIColor blackColor];
        [viewContactImageView addSubview:imageActivityIndicator];
        [imageActivityIndicator startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,getData[2]]]];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                viewContactImageView.image = [UIImage imageWithData:imgData];
                [viewContactImageView.layer setBorderColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1].CGColor];
                
//                [imageActivityIndicator stopAnimating];
                [imageActivityIndicator removeFromSuperview];
                
            });
            
        });

        userNameLabel.text = getData[0];
        if([userNameLabel.text componentsSeparatedByString:@" "].count>1)
            aboutLbl.text = [NSString stringWithFormat:@"About %@",[[userNameLabel.text componentsSeparatedByString:@" "] firstObject]];
        else
            aboutLbl.text = [NSString stringWithFormat:@"About %@",userNameLabel.text];
            
        userLocationLabel.text = getData[1];
         self.title = [NSString stringWithFormat:@"%@'s Profile",getData[0]];
    }
    else
    {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.delegate = self;
        HUD.dimBackground = YES;
        HUD.labelText = @"Please Wait";
        NSLog(@"explore user%@",userId);
        [self refreshContactInfo];
        
    }
    
    
    
    
}



#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
           return 1;
    
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
    }
    
        cell.textLabel.text = @"View Groups Joined";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        //cell.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    
    
       return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 43;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /* if (tableView==notificationTable)
     {
     NSLog(@"selected news at %d",indexPath.row);
     NotificationDetailView *detailPage = [[NotificationDetailView alloc]init];
     detailPage.notificationId = [notificationIds objectAtIndex:indexPath.row];
     [self.navigationController pushViewController:detailPage animated:YES];
     }*/
    CategoryList *detailPage = [[CategoryList alloc]init];
    detailPage.title=[NSString stringWithFormat:@"%@'s Groups",userNameLabel.text];
    detailPage.userId = userId;
    detailPage.triggeredFrom = @"explore";
    detailPage.distinguishFactor= @"Groups";
    [self.navigationController pushViewController:detailPage animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refreshContactInfo
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *postData = [NSString stringWithFormat:@"user_id=%@",userId];
    NSLog(@"$[%@]",postData);
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/member_detail.php",gupappUrl]]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    contactDetailConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [contactDetailConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [contactDetailConn start];
    
    contactDetailResponse = [[NSMutableData alloc] init];
}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == contactDetailConn) {
        
        [contactDetailResponse setLength:0];
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == contactDetailConn) {
        
        [contactDetailResponse appendData:data];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == contactDetailConn) {
        
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == contactDetailConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:contactDetailResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        //[activityIndicator stopAnimating];
        //[activityIndicator setHidden:YES];
        //[freezer setHidden:YES];

        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        NSLog(@"results: %@", results);
        NSDictionary *userDetails=results[@"User_Details"];
        
        NSLog(@"user count %i",[userDetails count]);
        if ([userDetails count]==0 )
        {
            [HUD hide:YES];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                   
                                                             message:@"User not registered"
                                   
                                                            delegate:nil
                                   
                                                   cancelButtonTitle:@"OK"
                                   
                                                   otherButtonTitles:nil];
            [alert show];
        }
        else
        {
        
        NSLog(@"====EVENTS==3 %@",res);
        NSString *contactId = userDetails[@"id"];
        NSString *name = userDetails[@"display_name"];
        NSString *location = userDetails[@"location_name"];
        NSString *memberPic = userDetails[@"profile_pic"];
            
        NSLog(@"member id: %@",contactId);
        NSLog(@"name: %@",name);
        NSLog(@"location: %@",location);
        NSLog(@"display pic: %@",memberPic);
        //viewContactImageView.image = [UIImage imageNamed:memberPic];
            [HUD hide:YES];
        userNameLabel.text = name;
        userLocationLabel.text = location;
        self.title = [NSString stringWithFormat:@"%@'s Profile",name];
        
        
        //load images
        UIActivityIndicatorView *imageActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        imageActivityIndicator.frame = CGRectMake(75.0, 80.0, 30.0, 30.0);
     
         
        imageActivityIndicator.color = [UIColor blackColor];
        [viewContactImageView addSubview:imageActivityIndicator];
        [imageActivityIndicator startAnimating];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,memberPic]]];
                  

            dispatch_async(dispatch_get_main_queue(), ^{
                
                viewContactImageView.image = [UIImage imageWithData:imgData];
                [viewContactImageView.layer setBorderColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1].CGColor];
                
        [imageActivityIndicator stopAnimating];
        [imageActivityIndicator removeFromSuperview];

            });
            
        });
       
        }
        
    }
    contactDetailConn=nil;
    
    [contactDetailConn cancel];
}


@end
