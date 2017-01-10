//
//  ContactTableCell.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 12/2/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ContactTableCell.h"

@implementation ContactTableCell


@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize imageView = _imageView;


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
