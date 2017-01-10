//
//  HomeTableCell.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "HomeTableCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation HomeTableCell
@synthesize nameLabel = _nameLabel;
@synthesize detailLabel = _detailLabel;
@synthesize badgeImageView = _badgeImageView;
@synthesize timeLabel = _timeLabel;
@synthesize profileImageView = _profileImageView;
//@synthesize  status=_status;
//@synthesize  muteImageView=_muteImageView;
//@synthesize badgeLabel=_badgeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
   
    
    
    
    // Configure the view for the selected state
}

@end
