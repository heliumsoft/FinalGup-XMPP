//
//  GroupsView.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "GroupsView.h"
#import "HomeTableCell.h"
#import "ChatScreen.h"

@interface GroupsView ()

@end

@implementation GroupsView
@synthesize managingViewController;

- (id)initWithParentViewController:(UIViewController *)aViewController {
    if (self = [super initWithNibName:@"GroupsView" bundle:nil]) {
        self.managingViewController = aViewController;
        //self.title = @"Italy";
    }
    return self;
}

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
    groupsChatList = [NSArray arrayWithObjects:@"Private Group 1", @"Private Group 2", @"Public Group 1", @"Private Group 3", @"Public Group 2", @"Public Group 3", @"Private Group 4", @"Public Group 4", nil];
    thumbnails = [NSArray arrayWithObjects:@"lock.png", @"lock.png", @"globe.png", @"lock.png", @"globe.png", @"globe.png", @"lock.png", @"globe.png", nil];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [groupsChatList count];
        
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"HomeTableCell";
    
    HomeTableCell *cell = (HomeTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.nameLabel.text = [groupsChatList objectAtIndex:indexPath.row];
    cell.profileImageView.image = [UIImage imageNamed:[thumbnails objectAtIndex:indexPath.row]];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected news at %d",indexPath.row);
    UIViewController * detailViewController = [[ChatScreen alloc] initWithNibName:@"ChatScreen" bundle:nil];
    [self.managingViewController.navigationController pushViewController:detailViewController animated:YES];
    //[detailViewController release];
    

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
