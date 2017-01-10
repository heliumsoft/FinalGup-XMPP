//
//  UserGroupTableViewCell.m
//  GUP
//
//  Created by Unicode Systems on 23/02/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import "UserGroupTableViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
@implementation UserGroupTableViewCell
@synthesize muteImageView;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){
        
        if([reuseIdentifier isEqualToString:@"UserCell"]){
            pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
            pic.backgroundColor = [UIColor clearColor];
            pic.opaque = YES;
            pic.clearsContextBeforeDrawing = NO;
            pic.layer.cornerRadius = 25;
            pic.clipsToBounds = YES;
            [self.contentView addSubview:pic];
            
            nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(pic.frame.origin.x+pic.frame.size.width+10, 10, 190, 20)];
            nameLbl.backgroundColor = [UIColor clearColor];
            nameLbl.opaque = YES;
            nameLbl.clearsContextBeforeDrawing = NO;
            nameLbl.numberOfLines=1;
            nameLbl.font = [UIFont fontWithName:@"Dosis-Bold" size:18.0f];
            nameLbl.textColor= [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
            [self.contentView addSubview:nameLbl];
            
            
            otherDetail = [[UILabel alloc] initWithFrame:CGRectMake(nameLbl.frame.origin.x, nameLbl.frame.origin.y+nameLbl.frame.size.height, 100, 13)];
            otherDetail.backgroundColor = [UIColor clearColor];
            otherDetail.opaque = YES;
            otherDetail.clearsContextBeforeDrawing = NO;
            otherDetail.numberOfLines=1;
            otherDetail.font = [UIFont fontWithName:@"Dosis-Regular" size:10.0f];
            otherDetail.textColor= [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
            [self.contentView addSubview:otherDetail];
            
          
            
            newChatIndecater = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-50, nameLbl.frame.origin.y, 20, 20)];
            newChatIndecater.backgroundColor = [UIColor clearColor];
            newChatIndecater.image = [UIImage imageNamed:@"chatindecater"];
            newChatIndecater.opaque = YES;
            newChatIndecater.hidden =YES;
            newChatIndecater.clearsContextBeforeDrawing = NO;
            newChatIndecater.clipsToBounds = YES;
            [self.contentView addSubview:newChatIndecater];
            
            muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(newChatIndecater.frame.origin.x, newChatIndecater.frame.origin.y+newChatIndecater.frame.size.height+5, 20, 20)];
            muteImageView.backgroundColor = [UIColor clearColor];
            muteImageView.opaque = YES;
            muteImageView.clearsContextBeforeDrawing = NO;
            muteImageView.clipsToBounds = YES;
            [self.contentView addSubview:muteImageView];
            
            separatopr = [[UIImageView alloc] initWithFrame:CGRectZero];
            separatopr.backgroundColor = [UIColor grayColor];
            separatopr.opaque = YES;
            separatopr.clearsContextBeforeDrawing = NO;
            separatopr.clipsToBounds = YES;
            [self.contentView addSubview:separatopr];
        }
        
        if([reuseIdentifier isEqualToString:@"GroupCell"]){
            pic = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
            pic.backgroundColor = [UIColor clearColor];
            pic.opaque = YES;
            pic.clearsContextBeforeDrawing = NO;
            pic.layer.cornerRadius = 18;
            pic.clipsToBounds = YES;
            [self.contentView addSubview:pic];
            
            pic.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openGroupView)];
            [pic addGestureRecognizer:tap1];
            
            nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(pic.frame.origin.x+pic.frame.size.width+10, 10, 190, 20)];
            nameLbl.backgroundColor = [UIColor clearColor];
            nameLbl.opaque = YES;
            nameLbl.clearsContextBeforeDrawing = NO;
            nameLbl.numberOfLines=1;
            nameLbl.font = [UIFont fontWithName:@"Dosis-Bold" size:18.0f];
            nameLbl.textColor= [UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1];
            [self.contentView addSubview:nameLbl];
            
            nameLbl.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openGroupView)];
            [nameLbl addGestureRecognizer:tap2];
            
            otherDetail = [[UILabel alloc] initWithFrame:CGRectMake(nameLbl.frame.origin.x, nameLbl.frame.origin.y+nameLbl.frame.size.height, 180, 13)];
            otherDetail.backgroundColor = [UIColor clearColor];
            otherDetail.opaque = YES;
            otherDetail.clearsContextBeforeDrawing = NO;
            otherDetail.numberOfLines=1;
            otherDetail.font = [UIFont fontWithName:@"Dosis-Regular" size:10.0f];
            otherDetail.textColor= [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
            [self.contentView addSubview:otherDetail];
            
            privateLbl = [[UILabel alloc] initWithFrame:CGRectMake(otherDetail.frame.origin.x, otherDetail.frame.origin.y+otherDetail.frame.size.height, 100, 20)];
            privateLbl.backgroundColor = [UIColor clearColor];
            privateLbl.opaque = YES;
            privateLbl.clearsContextBeforeDrawing = NO;
            privateLbl.numberOfLines=1;
            privateLbl.font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f];
            privateLbl.textColor= [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
            [self.contentView addSubview:privateLbl];
            
            newChatIndecater = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-50, nameLbl.frame.origin.y, 20, 20)];
            newChatIndecater.backgroundColor = [UIColor clearColor];
            newChatIndecater.opaque = YES;
            newChatIndecater.image = [UIImage imageNamed:@"chatindecater"];
            newChatIndecater.clearsContextBeforeDrawing = NO;
            newChatIndecater.clipsToBounds = YES;
            newChatIndecater.hidden =YES;
            [self.contentView addSubview:newChatIndecater];
            
            muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(newChatIndecater.frame.origin.x, newChatIndecater.frame.origin.y+newChatIndecater.frame.size.height+5, 20, 20)];
            muteImageView.backgroundColor = [UIColor clearColor];
            muteImageView.opaque = YES;
            muteImageView.clearsContextBeforeDrawing = NO;
            muteImageView.clipsToBounds = YES;
            [self.contentView addSubview:muteImageView];
            
            separatopr = [[UIImageView alloc] init];
            separatopr.backgroundColor = [UIColor grayColor];
            separatopr.opaque = YES;
            separatopr.clearsContextBeforeDrawing = NO;
            separatopr.clipsToBounds = YES;
            [self.contentView addSubview:separatopr];
        }
        
    }
    
    return self;
}

-(void)openGroupView{
    
    [self.gDelegate openGroupInfo:cellDatas];
}

-(void)plotCellData:(NSDictionary*)cellData{
    
    cellDatas= cellData;
    
    if([[cellData objectForKey:@"read"] intValue]>0)
        newChatIndecater.hidden = NO;
    else
        newChatIndecater.hidden = YES;
    
    if([self.reuseIdentifier isEqualToString:@"UserCell"]){
        nameLbl.text = [cellData objectForKey:@"user_name"];
        otherDetail.text = [cellData objectForKey:@"location"];
        NSString *imageurl = [NSString stringWithFormat:@"http://198.154.98.11/~gup/Gup_demo/scripts/media/images/profile_pics/%@",[cellData objectForKey:@"user_pic"]];
        [pic sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                pic.image = image;
            }else{
                pic.image = [UIImage imageNamed:@"defaultProfile"];
            }
            
        }];
    }
    
    if([self.reuseIdentifier isEqualToString:@"GroupCell"]){
        if([[cellData objectForKey:@"read"] intValue]>0)
            newChatIndecater.hidden = NO;
        else
            newChatIndecater.hidden = YES;
        nameLbl.text = [cellData objectForKey:@"group_name"];
        
        NSString *extra=@"";
        
        if([[cellData objectForKey:@"group_type"] isEqualToString:@"private#global"] || [[cellData objectForKey:@"group_type"] isEqualToString:@"private#local"]){
            extra = @"private";
        }else{
            extra=@"public";
        }
        
        NSString *loca;
        if([[cellData objectForKey:@"location"] isEqualToString:@""])
             loca = @"global";
        else
            loca = [cellData objectForKey:@"location"];
        
        otherDetail.text = [NSString stringWithFormat:@"%@ members | %@ | %@",[cellData objectForKey:@"total_members"],loca,extra];
        NSString *imageurl = [NSString stringWithFormat:@"http://198.154.98.11/~gup/Gup_demo/scripts/media/images/group_pics/%@",[cellData objectForKey:@"group_pic"]];
        [pic sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                pic.image = image;
            }else{
                pic.image = [UIImage imageNamed:@"defaultProfile"];
            }
            
        }];
        if ([[cellData objectForKey:@"mute_notification"] isEqualToString:@"1"]) {
            muteImageView.image =[UIImage imageNamed:@"mute"];
             muteImageView.hidden =NO;
        }else{
            muteImageView.image =[UIImage imageNamed:@"mute"];
            muteImageView.hidden =YES;
        }
        if ([[cellData objectForKey:@"flag"] isEqualToString:@"1"]){
            privateLbl.text = @"Pending Approval!!!";
        }else{
             privateLbl.text = @"";
        }
    }
    separatopr.frame = CGRectMake(self.contentView.frame.origin.x+10, 69, self.contentView.frame.size.width-20,1);
}

@end
