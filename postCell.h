//
//  postCell.h
//  GUP
//
//  Created by Ram Krishna on 18/12/14.
//  Copyright (c) 2014 genora. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@protocol imageGesture

-(void)leftImageAction:(UIImageView*)image;
-(void)rightImageAction:(UIImageView*)image;
-(void)cellHeightChange:(TTTAttributedLabel*)lbl;
-(void)readLessAction:(TTTAttributedLabel*)lbl;
-(void)commentButtonClick:(UIButton*)btn;
-(void)sharePost:(UIButton*)btn;
-(void)likePost:(UIButton*)btn;
-(void)repostPost:(UIButton*)btn;
-(void)likeLabelAction:(UIGestureRecognizer*)gesture;
-(void)commentLblAction:(UIGestureRecognizer*)gesture;
-(void)openImageInFullSize:(UIImageView*)image currentImageUrl:(NSString*)url;
-(void)openUserProfileImage:(UIImageView*)profileView;
@end



@interface postCell : UITableViewCell<TTTAttributedLabelDelegate>

@property(strong,nonatomic) UIView *bgView;
@property(strong,nonatomic) UIView *menuView;
@property(strong,nonatomic) TTTAttributedLabel *post_desc;
@property(strong,nonatomic) UIImageView *post_image;
@property(strong,nonatomic) UILabel *username;
@property(strong,nonatomic) UIImageView *user_image;
@property(strong,nonatomic) UILabel *timestamp;
@property(strong,nonatomic) UILabel *lastUpdatedTime;
@property(strong,nonatomic) UILabel *likeLbl;
@property(strong,nonatomic) UILabel *commentLbl;
@property(strong,nonatomic) UIButton *report;
@property(strong,nonatomic) UIButton *likePost;
@property(strong,nonatomic) UIButton *commentPost;
@property(strong,nonatomic) UIButton *share;
@property(strong,nonatomic) NSDictionary *cellData;
@property(strong,nonatomic) UIPageControl *page;
@property (nonatomic, strong)  id<imageGesture> imageDelegate;
@property(strong,nonatomic) UIActivityIndicatorView *spinner;
- (void)drawCell:(NSDictionary*)data;
-(void)clearCell;
@end
