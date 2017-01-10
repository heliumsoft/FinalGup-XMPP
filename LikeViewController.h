//
//  LikeViewController.h
//  GUP
//
//  Created by Unicode Systems on 06/01/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTableCell.h"

@interface LikeViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *likeTable;
    NSMutableArray *likeData;
    
}

@property(strong,nonatomic)NSString *postid;
@end
