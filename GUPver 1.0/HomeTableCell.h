//
//  HomeTableCell.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic,strong)IBOutlet UIImageView *status;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic,weak) IBOutlet UIImageView *badgeImageView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UIImageView *muteImageView;
@property (nonatomic, weak) IBOutlet UILabel *badgeLabel;


@end
