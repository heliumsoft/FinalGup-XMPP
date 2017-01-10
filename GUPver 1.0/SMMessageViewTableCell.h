//
//  SMMessageViewTableCell.h
//  shan
//
//  Created by Deepesh_Genora on 12/16/13.
//  Copyright (c) 2013 Deepesh_Genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JabberMessageContainer.h"
#import "CommentViewController.h"
@interface SMMessageViewTableCell : UITableViewCell<TTTAttributedLabelDelegate>{
    
    UITextView *messageContentView;
    UILongPressGestureRecognizer *recognizer;
    UITapGestureRecognizer *singleTap;
}
@property(nonatomic,weak)CommentViewController *commentObject;
@property(nonatomic,strong)UILabel *sender;
@property(nonatomic,strong)UILabel *date;
@property(nonatomic,strong)UILabel *username;
@property(nonatomic,strong)UILabel *vcardName;
@property(nonatomic,strong)UILabel *TimeLabel;
@property(nonatomic,strong)TTTAttributedLabel *messageContentView;
@property(nonatomic,strong)UIImageView *bgImageView;
@property(nonatomic,strong)UIImageView *pinned;
@property(nonatomic,strong)UIImageView *status;
@property(nonatomic,strong)UIImageView *bgImage;
@property(nonatomic,strong)UIImageView *image;
@property(nonatomic,strong)UIButton *details;
@property(nonatomic,strong)UIButton *play;
@property(nonatomic,strong)UISlider *playerstatus;
@property(nonatomic,strong)UIButton *vcardBut;
@property(nonatomic,strong)UIActivityIndicatorView *indicater;
@property BOOL mycell;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forViewController:(CommentViewController*)viewController;
-(void)drawCell:(NSDictionary*)dictonary withIndexPath:(NSIndexPath*)indexPath;
@end
