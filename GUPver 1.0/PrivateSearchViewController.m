//
//  PrivateSearchViewController.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "PrivateSearchViewController.h"

@interface PrivateSearchViewController ()

@end

@implementation PrivateSearchViewController

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
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSLog(@"in view did appear1");
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7)
    {
        self.searchDisplayController.searchBar.barTintColor = [UIColor colorWithRed:100.0/255.0 green:234.0/255.0 blue:224.0/255.0 alpha:1.0];
        
    }
    else
    {
        self.searchDisplayController.searchBar.tintColor = [UIColor colorWithRed:100.0/255.0 green:234.0/255.0 blue:224.0/255.0 alpha:1.0];
        
    }
    
}

#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    cell.imageView.image = [UIImage imageNamed:@"name"];
    cell.textLabel.text = @"Name";
    //cell.detailTextLabel.text =@"Created By:Admin";
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
    //cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.f];
    [cell setAccessoryType: UITableViewCellAccessoryDetailButton];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if (tableView==notificationTable)
     {
     NSLog(@"selected news at %d",indexPath.row);
     NotificationDetailView *detailPage = [[NotificationDetailView alloc]init];
     detailPage.notificationId = [notificationIds objectAtIndex:indexPath.row];
     [self.navigationController pushViewController:detailPage animated:YES];
     }*/
}

// To Display The Search Results
/*- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
 {
 NSPredicate *resultPredicate = [NSPredicate
 predicateWithFormat:@"SELF contains[cd] %@",
 searchText];
 
 searchResults = [groupsChatList filteredArrayUsingPredicate:resultPredicate];
 //searchThumbnails = [thumbnails filteredArrayUsingPredicate:resultPredicate];
 
 }
 
 -(BOOL)searchDisplayController:(UISearchDisplayController *)controller
 shouldReloadTableForSearchString:(NSString *)searchString
 {
 [self filterContentForSearchText:searchString
 scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
 objectAtIndex:[self.searchDisplayController.searchBar
 selectedScopeButtonIndex]]];
 
 return YES;
 }
 */



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
