//
//  userContactCell.h
//  GUP
//
//  Created by Aprajita Singh on 02/03/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userContactCell : UITableViewCell
@property(strong,nonatomic) UILabel *username;
@property(strong,nonatomic) UIImageView *user_image;
@property(strong,nonatomic) UILabel *extraInfo;
@property(strong,nonatomic) UIView *border;
- (void)drawCell:(NSDictionary*)data withIndex:(NSInteger)rows;
@end
