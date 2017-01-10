//
//  UserGroupTableViewCell.h
//  GUP
//
//  Created by Unicode Systems on 23/02/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol groupDelegate

-(void)openGroupInfo:(NSDictionary*)data;

@end


@interface UserGroupTableViewCell : UITableViewCell{
    UIImageView *pic,*separatopr;
    UILabel *nameLbl;
    UILabel *privateLbl;
    UIImageView *newChatIndecater,*muteImageView;
    UILabel *otherDetail;
    NSDictionary *cellDatas;
    BOOL flag;
}
@property (nonatomic, strong)  id<groupDelegate> gDelegate;

@property(nonatomic,retain) UIImageView *muteImageView;
-(void)plotCellData:(NSDictionary*)cellData;



@end
