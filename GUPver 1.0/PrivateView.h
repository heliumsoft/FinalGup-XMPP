//
//  PrivateView.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivateView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *privateChatList,*thumbnails;
    NSArray *searchResults;
    IBOutlet UITableView *privateTable;
}

@end
