//
//  CreatePrivateGroup.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/31/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "CreatePrivateGroup.h"

@interface CreatePrivateGroup ()

@end

@implementation CreatePrivateGroup

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Private Group";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
}

#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return  2;
    if (section == 1)
        return  2;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    if (cell == nil) {
        
         cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    if(indexPath.section == 0)
    {
        switch(indexPath.row) {
            case 0: // Initialize cell 1
            {
                cell.textLabel.text = @"Group Name";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            }
                break;
            case 1: // Initialize cell 2
            {
                cell.textLabel.text = @"Description";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
            }
                break;
        }
    }
    else if(indexPath.section == 1)
    {
        switch(indexPath.row) {
            case 0: // Initialize cell 1
            {
                
                cell.textLabel.text = @"Select Category";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
                
                break;
            case 1: // Initialize cell 2
            {
                
                cell.textLabel.text = @"Add Members";
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
                break;
                
        }
    }
    else
    {
        cell.textLabel.text = @"Invite";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
    }
    
    return cell;
    
    
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /* if (tableView==notificationTable)
     {
     NSLog(@"selected news at %d",indexPath.row);
     NotificationDetailView *detailPage = [[NotificationDetailView alloc]init];
     detailPage.notificationId = [notificationIds objectAtIndex:indexPath.row];
     [self.navigationController pushViewController:detailPage animated:YES];
     }*/
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
