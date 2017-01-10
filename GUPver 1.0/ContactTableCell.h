//
//  ContactTableCell.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 12/2/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailTextLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *statusImage;
@property (strong, nonatomic) IBOutlet UIImageView *ProfileImageView;
@property (strong, nonatomic) IBOutlet UILabel *DetailLabel;

@end
