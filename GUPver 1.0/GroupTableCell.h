//
//  GroupTableCell.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 12/2/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupTableCell : UITableViewCell


@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailTextLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic,weak) UIButton *ckeckBox;
@property (nonatomic,weak) UIButton *moreButton;

//@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@end
