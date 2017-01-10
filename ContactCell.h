//
//  ContactCell.h
//  GUP
//
//  Created by Deepesh_Genora on 7/2/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *NameLabel;
@property (strong, nonatomic) IBOutlet UILabel *DetailLabel;
@property (strong, nonatomic) IBOutlet UIImageView *ProfileImageView;
@property (strong, nonatomic) IBOutlet UIImageView *StatusImage;

@end
