//
//  SettingsAlert.m
//  GUPver 1.0
//
//  Created by genora on 11/5/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "SettingsAlert.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "NSString+Utils.h"
@interface SettingsAlert ()

@end

@implementation SettingsAlert

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    self.navigationItem.title = @"Alerts";
    alertTable.separatorStyle =UITableViewCellSeparatorStyleNone;
    
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSString *groupchat=[[NSUserDefaults standardUserDefaults]valueForKey:@"groupChat"];
    NSLog(@"app delegate group chat: %@\n",groupchat);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Table View Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView  *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30.0)];
    view.backgroundColor=[UIColor whiteColor];
    UILabel *label =[[UILabel alloc] init];
    label.font=[UIFont fontWithName:@"Dosis-Regular" size:18.0];
    label.textColor=[UIColor  colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0];
    
    
    if(section==0)
    {
        
        [label setFrame:CGRectMake(15, 0, 250, 30.0)];
        label.text=@"Notifications";
    }
    else
    {
        label.text=@"Alert type";
        [label setFrame:CGRectMake(15, 0, 250, 30.0)];
    }
    
    
    
    
    
    
    [view addSubview:label];
    
    return  view;
    

    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIButton *image ;
    UIView*  line;

    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    if((indexPath.section==0&&indexPath.row==0)|| (indexPath.section==1&&indexPath.row==0))
    {
        line=[[UIView alloc]init];
        [line setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+((indexPath.section==0)?5:4.0), cell.frame.size.width, 0.50)];
        line.backgroundColor=[UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:0.9];
        [cell addSubview:line];
        
    }
    
    
    line=[[UIView alloc]initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+cell.frame.size.height-3.0, cell.frame.size.width, 0.50)];
    line.backgroundColor=[UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:0.9];
    [cell addSubview:line];
    
    cell.textLabel.textColor = [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:0.9];
    
    
    switch (indexPath.section) {
        case 0:
            switch(indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"Group Chat";
                    cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
                    groupChat = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [groupChat addTarget: self action: @selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"groupChat"]isEqualToString:@"1"]) {
                        [groupChat setOn:TRUE];
                    }
                    else
                    {
                        [groupChat setOn:FALSE];
                    }
                    cell.accessoryView = groupChat;
                }
                    break;
                case 1:
                {
                    cell.textLabel.text = @"Personal Chat";
                    cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
                    personalChat = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [personalChat addTarget: self action: @selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"personalChat"]isEqualToString:@"1"]) {
                        [personalChat setOn:TRUE];
                    }
                    else
                    {
                        [personalChat setOn:FALSE];
                    }
                    
                    cell.accessoryView = personalChat;
                }
                    break;
            }
            
            break;
        case 1:
            switch(indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"Vibration";
                    cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
                    vibration = [[UISwitch alloc] initWithFrame:CGRectZero];
                    [vibration addTarget: self action: @selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"vibration"]isEqualToString:@"1"]) {
                        [vibration setOn:TRUE];
                    }
                    else
                    {
                        [vibration setOn:FALSE];
                    }
                    
                    cell.accessoryView = vibration;
                }
                    break;
                case 1:
                {
                    cell.textLabel.text = @"Sound";
cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
                    sound= [[UISwitch alloc] initWithFrame:CGRectZero];
                    [sound addTarget: self action: @selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"sound"]isEqualToString:@"1"]) {
                        [sound setOn:TRUE];
                    }
                    else
                    {
                        [sound setOn:FALSE];
                    }
                    cell.accessoryView = sound;
                }
                    break;
            }
            break;
        default:
            break;
    }
    
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)switchAction:(id)sender
{[self freezerAnimate];
    if (sender == groupChat) {
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *postData = [NSString stringWithFormat:@"user_id=%@&group_chat=%d",[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID],[[[NSUserDefaults standardUserDefaults] stringForKey:@"groupChat"] boolValue]];
        NSLog(@"$[%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_settings.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        alertGroupSetting = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [alertGroupSetting scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [alertGroupSetting start];
        alertGroupSettingData = [[NSMutableData alloc] init];
        
    }
    if (sender == personalChat) {
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *postData = [NSString stringWithFormat:@"user_id=%@&personal_chat=%d",[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID],[[[NSUserDefaults standardUserDefaults] stringForKey:@"personalChat"] boolValue]];
        NSLog(@"$[%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_settings.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        alertPersonalSetting = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [alertPersonalSetting scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [alertPersonalSetting start];
        alertPersonalSettingData = [[NSMutableData alloc] init];
        
    }
    if (sender == vibration) {
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *postData = [NSString stringWithFormat:@"user_id=%@&vibration=%d",[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID],[[[NSUserDefaults standardUserDefaults] stringForKey:@"vibration"] boolValue]];
        NSLog(@"$[%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_settings.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        alertViberationSetting = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [alertViberationSetting scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [alertViberationSetting start];
        alertViberationGroupSettingData = [[NSMutableData alloc] init];
        
    }
    if (sender == sound) {
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *postData = [NSString stringWithFormat:@"user_id=%@&sound=%d",[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID],[[[NSUserDefaults standardUserDefaults] stringForKey:@"sound"] boolValue]];
        NSLog(@"$[%@]",postData);
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/update_settings.php",gupappUrl]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        alertSoundSetting = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [alertSoundSetting scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [alertSoundSetting start];
        alertSoundSettingData = [[NSMutableData alloc] init];
        
    }
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
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == alertGroupSetting) {
        
        [alertGroupSettingData setLength:0];
        
    }
    if (connection == alertPersonalSetting) {
        
        [alertPersonalSettingData setLength:0];
        
    }
    if (connection == alertSoundSetting) {
        
        [alertSoundSettingData setLength:0];
        
    }
    if (connection==alertViberationSetting) {
        [alertViberationGroupSettingData setLength:0];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == alertGroupSetting) {
        
        [alertGroupSettingData appendData:data];
        
    }
    if (connection == alertPersonalSetting) {
        
        [alertPersonalSettingData appendData:data];
        
    }
    if (connection == alertSoundSetting) {
        
        [alertSoundSettingData appendData:data];
        
    }
    if (connection == alertViberationSetting) {
        
        [alertViberationGroupSettingData appendData:data];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{[self freezerRemove];
    if (connection==alertPersonalSetting)
        [personalChat setSelected:!personalChat.state];
    if (connection==alertGroupSetting)
        [personalChat setSelected:!groupChat.state];
    if (connection==alertSoundSetting)
        [personalChat setSelected:!sound.state];
    if (connection==alertViberationSetting)
        [personalChat setSelected:!vibration.state];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    if (connection==alertPersonalSetting)
    {  NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:alertPersonalSettingData encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        //[activityIndicator stopAnimating];
        //[activityIndicator setHidden:YES];
        //[freezer setHidden:YES];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        if (results[@"status"]) {
            
            
            NSLog(@"results: %@", results);
            if (personalChat.on)
            {
                NSLog(@"On");
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"personalChat"];
            }
            else
            {
                NSLog(@"Off");
                [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"personalChat"];
            }
        }
    }
    if (connection==alertGroupSetting)
    {  NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:alertGroupSettingData encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        //[activityIndicator stopAnimating];
        //[activityIndicator setHidden:YES];
        //[freezer setHidden:YES];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        if (results[@"status"]) {
            
            
            NSLog(@"results: %@", results);
            if (groupChat.on)
            {
                NSLog(@"On");
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"groupChat"];
            }
            else
            {
                NSLog(@"Off");
                [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"groupChat"];
            }
        }
    }
    if (connection==alertSoundSetting)
    {  NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:alertSoundSettingData encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        //[activityIndicator stopAnimating];
        //[activityIndicator setHidden:YES];
        //[freezer setHidden:YES];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        if (results[@"status"]) {
            
            
            NSLog(@"results: %@", results);
            
            if (sound.on)
            {
                NSLog(@"On");
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"sound"];
            }
            else
            {
                NSLog(@"Off");
                [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"sound"];
            }
        }
    }
    if (connection==alertViberationSetting)
    {  NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:alertViberationGroupSettingData encoding:NSASCIIStringEncoding];
        
        NSLog(@"Response:%@",str);
        //[activityIndicator stopAnimating];
        //[activityIndicator setHidden:YES];
        //[freezer setHidden:YES];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSDictionary *results = res[@"response"];
        if (results[@"status"]) {
            
            
            NSLog(@"results: %@", results);
            if (vibration.on)
            {
                NSLog(@"On");
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"vibration"];
            }
            else
            {
                NSLog(@"Off");
                [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"vibration"];
            }
        }
    }
    [self freezerRemove];
}


@end
