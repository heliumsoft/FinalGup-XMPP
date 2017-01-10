//
//  userContactCell.m
//  GUP
//
//  Created by Aprajita Singh on 02/03/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import "userContactCell.h"
#import "AppDelegate.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation userContactCell
@synthesize user_image,username,extraInfo,border;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
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
       
        
        user_image = [[UIImageView alloc] initWithFrame:CGRectZero];
        user_image.backgroundColor = [UIColor clearColor];
        user_image.opaque = YES;
        user_image.clearsContextBeforeDrawing = NO;
        user_image.layer.cornerRadius =23.0f;
        user_image.clipsToBounds = YES;
        user_image.userInteractionEnabled = YES;
        [self addSubview:user_image];
        
       
        
        extraInfo = [[UILabel alloc] init];
        extraInfo.textColor = [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
        extraInfo.tag = 2;
        extraInfo.backgroundColor = [UIColor clearColor];
        [extraInfo setFont:[UIFont fontWithName:@"Dosis-Regular" size:10.0f]];
        [self addSubview:extraInfo];
        

    }
    return self;
}

- (void)drawCell:(NSDictionary*)data withIndex:(NSInteger)rows{
    
        self.username.text = [data objectForKey:@"name"];
    
    
        [user_image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,[data objectForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                user_image.image = image;
            }else{
                user_image.image = [UIImage imageNamed:@"defaultProfile"];
            }
            
        }];
            
            
            self.extraInfo.text = data[@"location"];
            
            user_image.layer.cornerRadius =30;
            
   
    user_image.frame = CGRectMake(20, 10, 60, 60);
    username.frame = CGRectMake(100, 10, 180, 22);
    extraInfo.frame = CGRectMake(100, 32, 200, 15);
    border.frame = CGRectMake(10, 79, self.bounds.size.width-20, 1);
    
   }



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
