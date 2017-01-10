//
//  GroupsView.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTableCell.h"

@interface GroupsView : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>
{
    NSArray *groupsChatList;
    NSArray *searchResults;
    NSArray *thumbnails;
    IBOutlet UITableView *groupsTable;
    UIViewController * managingViewController;
}

@property (nonatomic, retain) UIViewController  * managingViewController;

- (id)initWithParentViewController:(UIViewController *)aViewController;


@end
