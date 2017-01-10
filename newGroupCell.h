//
//  newGroupCell.h
//  GUP
//
//  Created by Aprajita Singh on 20/02/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "appdelegate.h"
#import "TTTAttributedLabel.h"

@protocol groupDelegate

-(void)expandCellHeight:(UIButton*)btn  withIndex:(NSInteger)row;
-(void)groupSelected:(UIButton*)btn  withIndex:(NSInteger)row;
-(BOOL)checkifSelected:(NSInteger)row;
-(BOOL)checkiffull:(NSInteger)row;
@end

@interface newGroupCell : UITableViewCell<TTTAttributedLabelDelegate>{
    BOOL checked;
}
@property (nonatomic, strong)  id<groupDelegate> groupDelegate;
@property(strong,nonatomic) UILabel *username;
@property(strong,nonatomic) UIImageView *user_image;
@property(strong,nonatomic) UILabel *extraInfo;
@property(strong,nonatomic) TTTAttributedLabel *post_desc;
@property(strong,nonatomic) UIButton *selectButton;
@property(strong,nonatomic) UIButton *expand;
@property(strong,nonatomic) UIView *border;
@property(assign,nonatomic) NSInteger row;
- (void)drawCell:(NSDictionary*)data withIndex:(NSInteger)row;
-(void)clearCell;

@end
