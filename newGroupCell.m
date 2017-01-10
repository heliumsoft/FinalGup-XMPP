//
//  newGroupCell.m
//  GUP
//
//  Created by Aprajita Singh on 20/02/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import "newGroupCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NSString+Utils.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@implementation newGroupCell

@synthesize post_desc,user_image,username,expand,extraInfo,selectButton,border;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        border = [[UIView alloc] initWithFrame:CGRectZero];
        border.backgroundColor = [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:0.9];
        border.opaque = YES;
        border.clearsContextBeforeDrawing = NO;
        [self addSubview:border];
        
        username = [[UILabel alloc] initWithFrame:CGRectZero];
        username.backgroundColor = [UIColor clearColor];
        username.opaque = YES;
        username.clearsContextBeforeDrawing = NO;
        username.numberOfLines=1;
        username.font = [UIFont fontWithName:@"Dosis-Bold" size:18.0f];
        username.textColor= [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
        username.userInteractionEnabled = YES;
        [self addSubview:username];
               
        post_desc = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        post_desc.backgroundColor = [UIColor clearColor];
        post_desc.delegate = self;
        post_desc.opaque = YES;
        post_desc.clearsContextBeforeDrawing = NO;
        post_desc.numberOfLines=4;
        post_desc.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        post_desc.font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f];
        post_desc.textColor= [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
        [self addSubview:post_desc];
        
        user_image = [[UIImageView alloc] initWithFrame:CGRectZero];
        user_image.backgroundColor = [UIColor clearColor];
        user_image.opaque = YES;
        user_image.clearsContextBeforeDrawing = NO;
        user_image.layer.cornerRadius =23.0f;
        user_image.clipsToBounds = YES;
        user_image.userInteractionEnabled = YES;
        [self addSubview:user_image];
        
        selectButton= [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.tag = 3;
        [selectButton addTarget:self action:@selector(selectGroup:) forControlEvents:UIControlEventTouchUpInside];
        [selectButton setBackgroundImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        selectButton.backgroundColor = [UIColor clearColor];
        [self addSubview:selectButton];
        
        extraInfo = [[UILabel alloc] init];
        extraInfo.textColor = [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
        extraInfo.tag = 2;
        extraInfo.backgroundColor = [UIColor clearColor];
        [extraInfo setFont:[UIFont fontWithName:@"Dosis-Regular" size:10.0f]];
        [self addSubview:extraInfo];
        
        expand= [UIButton buttonWithType:UIButtonTypeCustom];
        [expand addTarget:self action:@selector(readFullView:) forControlEvents:UIControlEventTouchUpInside];
        expand.tag = 3;
        [expand setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        expand.backgroundColor = [UIColor clearColor];
        [self addSubview:expand];
        
        
    }
    return self;
}

-(void)clearCell{
    
}

//UIImageView *iconImage= [[UIImageView alloc]initWithFrame:CGRectMake(18, 18, 18, 18)];
////iconImage.image = [UIImage imageNamed:@"globe"];
//
//if ([[[searchData objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"private#local"]){
//    iconImage.image =[UIImage imageNamed:@"private_local"];
//}else if([[[searchData objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"private#global"]){
//    iconImage.image =[UIImage imageNamed:@"private_global"];
//}else if ([[[searchData objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"public#local"]){
//    iconImage.image =[UIImage imageNamed:@"pin15"];
//}else if ([[[searchData objectAtIndex:indexPath.row] objectForKey:@"type"] isEqualToString:@"public#global"]){
//    iconImage.image =[UIImage imageNamed:@"globe15"];
//}else{
//    iconImage.image = [UIImage imageNamed:nil];
//}
//[cell.imageView addSubview:iconImage];
//
//cell.textLabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:17.f];
//cell.textLabel.textColor = [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
//cell.textLabel.text = [[searchData objectAtIndex:indexPath.row] objectForKey:@"name"];
//
//cell.detailTextLabel.text = [[searchData objectAtIndex:indexPath.row] objectForKey:@"description"];
//cell.detailTextLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:11.f];
//
//if ( [[[self appDelegate].ver objectAtIndex:0] intValue] >= 7 )
//[cell setAccessoryType: UITableViewCellAccessoryDetailButton];
//else
//[cell setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];
//

- (void)drawCell:(NSDictionary*)data withIndex:(NSInteger)rows{
    
    self.row = rows;
    
    if([data objectForKey:@"cell_type"]){
        
        self.username.text = [data objectForKey:@"name"];
        
        if([[data objectForKey:@"is_exist"] intValue])
            selectButton.hidden = YES;
        else
            selectButton.hidden = NO;
        
        if ([[data objectForKey:@"type"] isEqualToString:@"private#local"]||[[data objectForKey:@"type"] isEqualToString:@"private#global"]||[[data objectForKey:@"type"] isEqualToString:@"public#local"]||[[data objectForKey:@"type"] isEqualToString:@"public#global"]) {
            
            [user_image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,[data objectForKey:@"thumbnail"]]] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                if (image) {
                    user_image.image = image;
                }else{
                    user_image.image = [UIImage imageNamed:@"defaultProfile"];
                }
                
            }];
            
            NSString *xtra = [NSString stringWithFormat:@"%@ Members | %@",[data objectForKey:@"member_count"],[data objectForKey:@"type"]];
            self.extraInfo.text = xtra;
            self.post_desc.text = [data objectForKey:@"description"];

            
        }else{
            
            [user_image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,[data objectForKey:@"thumbnail"]]] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                if (image) {
                    user_image.image = image;
                }else{
                    user_image.image = [UIImage imageNamed:@"defaultProfile"];
                }
                
            }];
            
            
            self.extraInfo.text = data[@"bottom_display"];
            
            user_image.layer.cornerRadius =30;
            
        }
        
    }else{

        self.username.text = [data objectForKey:@"group_name"];
        NSString *xtra;
        if([data objectForKey:@"total_member"]!=NULL)
            xtra = [NSString stringWithFormat:@"%@ Members | %@",[data objectForKey:@"total_member"],[data objectForKey:@"type"]];
        else
            xtra = [NSString stringWithFormat:@"%@ Members | %@",[data objectForKey:@"total_members"],[data objectForKey:@"type"]];
        self.extraInfo.text = xtra;
        self.post_desc.text = [data objectForKey:@"description"];
        
        [user_image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,[data objectForKey:@"display_pic_50"]]] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                user_image.image = image;
            }else{
                user_image.image = [UIImage imageNamed:@"defaultProfile"];
            }
            
        }];
    }
    user_image.frame = CGRectMake(20, 10, 60, 60);
    username.frame = CGRectMake(100, 10, 180, 22);
    extraInfo.frame = CGRectMake(100, 32, 200, 15);
    
     if([self.groupDelegate checkiffull:self.row]){
         post_desc.frame  = CGRectMake(100, 50, 200, [[data objectForKey:@"height"] floatValue]);
         expand.frame = CGRectMake(0,0,0,0);
    }else{
         if([[data objectForKey:@"height"] floatValue]>42){
             expand.frame = CGRectMake(self.frame.size.width-20, 65, 10, 10);
         }else{
             expand.frame = CGRectMake(0,0,0,0);
         }
    post_desc.frame  = CGRectMake(100, 50, 200, 30);
     }
    selectButton.frame = CGRectMake(self.frame.size.width-40, 5, 30, 30);
    if([self.groupDelegate checkifSelected:self.row]){
        [selectButton setBackgroundImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    }else{
        [selectButton setBackgroundImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    }
    
    if([[data objectForKey:@"is_exist"] intValue])
        selectButton.hidden = YES;
    else
        selectButton.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

-(void)selectGroup:(UIButton*)btn{
    
    [self.groupDelegate groupSelected:btn withIndex:self.row];
}
-(void)readFullView:(UIButton*)btn{
    
    //[self.groupDelegate expandCellHeight:btn withIndex:self.row];
}

@end
