//
//  commentCell.h
//  GUP
//
//  Created by Aprajita Singh on 28/02/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentViewController.h"
#import "ChatScreen.h"

@interface commentCell : UITableViewCell


@property(strong,nonatomic) UILabel *username;
@property(strong,nonatomic) UIImageView *user_image;
@property(strong,nonatomic) UIImageView *postImage;
@property(strong,nonatomic) UILabel *extraInfo;
@property(strong,nonatomic) UILabel *messageText;
@property(strong,nonatomic) UIView *border;
@property(nonatomic,strong)UIButton *details;
@property(nonatomic,strong)UIButton *play;
@property(nonatomic,strong)UIImageView *pinned;
@property(nonatomic,strong)UIImageView *status;
@property(nonatomic,strong)UISlider *playerstatus;
@property(nonatomic,strong)UIImageView *bgImage;
@property(nonatomic,strong)UIButton *vcardBut;
@property(nonatomic,strong)UILabel *vcardName;
@property(nonatomic,weak) CommentViewController *commentObject;
@property(nonatomic,weak) ChatScreen *chatObject;

- (void)drawCell:(NSDictionary*)data withIndexPath:(NSIndexPath*)indexPath;
-(void)clearCell;
@end
