//
//  postCell.m
//  GUP
//
//  Created by Ram Krishna on 18/12/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import "postCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NSString+Utils.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation postCell
@synthesize post_desc,post_image,user_image,username,likePost,commentPost,report,share,timestamp,bgView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:248.0/255.0 blue:247.0/255.0 alpha:1];
        bgView.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
        bgView.layer.borderWidth = 0.5f;
        bgView.layer.cornerRadius = 5;
        bgView.clearsContextBeforeDrawing = NO;
        [self addSubview:bgView];
        
        username = [[UILabel alloc] initWithFrame:CGRectZero];
        username.backgroundColor = [UIColor clearColor];
        username.opaque = YES;
        username.clearsContextBeforeDrawing = NO;
        username.numberOfLines=1;
        username.tag = 100;
        username.font = [UIFont fontWithName:@"Dosis-SemiBold" size:15.0f];
        username.textColor= [UIColor colorWithRed:37.0/255.0 green:42.0/255.0 blue:68.0/255.0 alpha:0.9];
        username.userInteractionEnabled = YES;
        [self addSubview:username];
        
       
        self.lastUpdatedTime = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lastUpdatedTime.backgroundColor = [UIColor clearColor];
        
        self.lastUpdatedTime.textAlignment = NSTextAlignmentLeft;
        self.lastUpdatedTime.opaque = YES;
        self.lastUpdatedTime.clearsContextBeforeDrawing = NO;
        self.lastUpdatedTime.numberOfLines=1;
        self.lastUpdatedTime.font = [UIFont fontWithName:@"Dosis-Regular" size:9.0f];
        self.lastUpdatedTime.textColor= UIColorFromRGB(0x696969);
        [self addSubview:self.lastUpdatedTime];
        
        post_desc = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        post_desc.backgroundColor = [UIColor clearColor];
        post_desc.delegate = self;
        post_desc.opaque = YES;
        post_desc.clearsContextBeforeDrawing = NO;
        post_desc.numberOfLines=100;
        post_desc.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        post_desc.font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f];
        post_desc.textColor= [UIColor colorWithRed:37.0/255.0 green:42.0/255.0 blue:68.0/255.0 alpha:1];
        [self addSubview:post_desc];
        
        user_image = [[UIImageView alloc] initWithFrame:CGRectZero];
        user_image.backgroundColor = [UIColor clearColor];
        user_image.opaque = YES;
        user_image.tag = 101;
        user_image.clearsContextBeforeDrawing = NO;
        user_image.layer.cornerRadius =15.0f;
        user_image.clipsToBounds = YES;
        user_image.userInteractionEnabled = YES;
        [self addSubview:user_image];
        
        
        UITapGestureRecognizer *userimagetap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openProfile:)];
        userimagetap.numberOfTapsRequired = 1;
        [user_image addGestureRecognizer:userimagetap];
        
        UITapGestureRecognizer *usernametap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openProfile:)];
        usernametap.numberOfTapsRequired = 1;
        [username addGestureRecognizer:usernametap];
        
        post_image = [[UIImageView alloc] init];
        post_image.backgroundColor = [UIColor clearColor];
        post_image.opaque = YES;
        post_image.clearsContextBeforeDrawing = NO;
        post_image.userInteractionEnabled = YES;
        [self addSubview:post_image];
        
        UITapGestureRecognizer *imagetap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImage:)];
        imagetap.numberOfTapsRequired = 1;
        [post_image addGestureRecognizer:imagetap];
        
        _page =[[UIPageControl alloc] init];
        _page.tag = 110;
        _page.backgroundColor = [UIColor clearColor];
//        [_page setTintColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:34.0/255.0 alpha:1]];
        _page.pageIndicatorTintColor = [UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:34.0/255.0 alpha:1];
        [self addSubview:_page];
        
        UISwipeGestureRecognizer *leftSweep = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSweepAction:)];
        leftSweep.direction = UISwipeGestureRecognizerDirectionLeft;
        [post_image addGestureRecognizer:leftSweep];
        
        UISwipeGestureRecognizer *rightSweep = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSweepAction:)];
        rightSweep.direction = UISwipeGestureRecognizerDirectionRight;
        [post_image addGestureRecognizer:rightSweep];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _spinner.center = post_image.center;
        [_spinner setHidesWhenStopped:YES];
        [post_image addSubview:_spinner];
        
        self.menuView = [[UIView alloc] init];
        self.menuView.backgroundColor = [UIColor whiteColor];
        self.menuView.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
        self.menuView.layer.borderWidth = 0.0f;
        self.menuView.tag = 11;
        [self addSubview:self.menuView];
        
        likePost= [UIButton buttonWithType:UIButtonTypeCustom];
        likePost.tag = 1;
        [likePost addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [likePost setBackgroundImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
        likePost.backgroundColor = [UIColor clearColor];
        [self.menuView addSubview:likePost];
        
        _likeLbl = [[UILabel alloc] init];
        _likeLbl.textColor = [UIColor blackColor];
        _likeLbl.tag = 2;
        _likeLbl.backgroundColor = [UIColor clearColor];
        [_likeLbl setFont:[UIFont fontWithName:@"Dosis-Regular" size:12.0f]];
        //        _likeLbl.font = [UIFont boldSystemFontOfSize:10.0f];
        _likeLbl.text = @"Like";
        [self.menuView addSubview:_likeLbl];
        
        UITapGestureRecognizer *likeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeLblAction:)];
        likeTapGesture.numberOfTapsRequired = 1;
        _likeLbl.userInteractionEnabled = YES;
        [_likeLbl addGestureRecognizer:likeTapGesture];
        
        commentPost= [UIButton buttonWithType:UIButtonTypeCustom];
        [commentPost addTarget:self action:@selector(commentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        commentPost.tag = 3;
        [commentPost setBackgroundImage:[UIImage imageNamed:@"pcomment"] forState:UIControlStateNormal];
        commentPost.backgroundColor = [UIColor clearColor];
        [self.menuView addSubview:commentPost];
        
        _commentLbl = [[UILabel alloc] init];
        _commentLbl.textColor = [UIColor blackColor];
        _commentLbl.tag = 4;
        _commentLbl.backgroundColor = [UIColor clearColor];
        [_commentLbl setFont:[UIFont fontWithName:@"Dosis-Regular" size:12.0f]];
        //        _commentLbl.font = [UIFont boldSystemFontOfSize:10.0f];
        _commentLbl.text = @"Comment";
        [self.menuView addSubview:_commentLbl];
        
        
        UITapGestureRecognizer *commentTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentLblAction:)];
        commentTapGesture.numberOfTapsRequired = 1;
        _commentLbl.userInteractionEnabled = YES;
        [_commentLbl addGestureRecognizer:commentTapGesture];
        
        share = [UIButton buttonWithType:UIButtonTypeCustom];
        share.backgroundColor = [UIColor clearColor];
        [share addTarget:self action:@selector(shareBtnAction:) forControlEvents:UIControlEventTouchDown];
        [share setBackgroundImage:[UIImage imageNamed:@"pshare"] forState:UIControlStateNormal];
        [self.menuView addSubview:share];
        
        report= [UIButton buttonWithType:UIButtonTypeCustom];
        
        report.backgroundColor = [UIColor clearColor];
        report.tag = 15;
        [report addTarget:self action:@selector(repostBtnAction:) forControlEvents:UIControlEventTouchDown];
        [self.menuView addSubview:report];
        
    }
    return self;
}

-(void)clearCell{
    
}

- (void)drawCell:(NSDictionary*)data{
    self.cellData = data;
    if ([[data objectForKey:@"imageCount"] intValue]==0) {
        post_image.hidden=YES;
        _page.hidden = YES;
        NSString *cText;
        if([[data objectForKey:@"islike"] intValue]==0 || ! [data objectForKey:@"islike"]){
            [likePost setBackgroundImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
        }else{
            [likePost setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        }
        NSString *imgPathRetrieve = [data objectForKey:@"user_image"];
        [user_image sd_setImageWithURL:[NSURL URLWithString:imgPathRetrieve] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                user_image.image = image;
            }else{
                user_image.image = [UIImage imageNamed:@"defaultProfile"];
            }
            
        }];
        
        if([[data objectForKey:@"is_report"] intValue]==0){
            [report setBackgroundImage:[UIImage imageNamed:@"report"] forState:UIControlStateNormal];
            report.userInteractionEnabled = YES;
        }else{
            [report setBackgroundImage:[UIImage imageNamed:@"reported"] forState:UIControlStateNormal];
            report.userInteractionEnabled = NO;
        }
        
        username.text = [data objectForKey:@"user_name"];
        double miliTime = [[data objectForKey:@"time"] doubleValue];
        self.lastUpdatedTime.text = [self dateStringFormate:miliTime];
        
        
        user_image.frame = CGRectMake(20, 10, 30, 30);
        username.frame =  CGRectMake(60, 10, 200,20);
        NSString *totalLikes = [data objectForKey:@"total_likes"];
        
        if([totalLikes intValue] == 0)
            _likeLbl.userInteractionEnabled = NO;
        else
            _likeLbl.userInteractionEnabled = YES;
        
        NSString *totalComments = [data objectForKey:@"total_comments"];
        NSString *disString = [data objectForKey:@"description"];
        _likeLbl.text = [NSString stringWithFormat:@"%@ Likes",totalLikes];
        _commentLbl.text = [NSString stringWithFormat:@"%@ Comments",totalComments];
        disString=[disString UTFDecoded];
        if(!disString){
            disString = [data objectForKey:@"description"];
        }
        disString=[self RadhaCompatiableDecodingForString:disString];
        disString=[disString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        
        if ([[self reuseIdentifier] isEqualToString:@"loadMoreCell"]) {
            
            post_desc.text=[NSString stringWithFormat:@"%@   Less",disString];
            NSRange range = [post_desc.text rangeOfString:@"Less"];
            [post_desc addLinkToURL:[NSURL URLWithString:@"action://readless"] withRange:range];
            
            CGSize size = [self calculateHeight:disString];
            cText = post_desc.text;
            bgView.frame = CGRectMake(10, 0, self.frame.size.width-20, 140 + (size.height-35));
            //            post_desc.frame = CGRectMake(20, user_image.frame.origin.y+user_image.frame.size.height+10, 280, [self calculateHeight:post_desc.text].height);
            
            
        }else{
            
            bgView.frame = CGRectMake(10, 0, self.frame.size.width-20, self.frame.size.height);
            
            
            NSString *text = [NSString stringWithFormat:@"%@...%@",disString,@"More"];
            CGSize size = [self calculateHeight:text];
            if (size.height > 75.0) {
                NSArray *newLineStrArray = [disString componentsSeparatedByString:@"\n"];
                if(newLineStrArray.count>5){
                    cText = [self newLineStringFormat:newLineStrArray];
                }else{
                    if(text.length>=210)
                        cText = [NSString stringWithFormat:@"%@...%@",[disString substringWithRange:NSMakeRange(0, (disString.length<200)?disString.length:200)],@"More"];
                    else
                        cText = disString;
                }
                post_desc.text=[NSString stringWithFormat:@"%@",cText];
                
                NSString *pattern = @"(More)";
                NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
                __block NSMutableArray *tempRangeArray = [NSMutableArray array];
                NSRange range = NSMakeRange(0,[post_desc.text length]);
                [expression enumerateMatchesInString:post_desc.text options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    NSRange californiaRange = [result rangeAtIndex:0];
                    [tempRangeArray addObject:[NSValue valueWithRange:californiaRange]];
                    
                }];
                [post_desc addLinkToURL:[NSURL URLWithString:@"action://readmore"] withRange:[[tempRangeArray lastObject] rangeValue]];
                
            }else{
                cText = disString;
                post_desc.text= cText;
                
            }
            
        }
        self.menuView.frame = CGRectMake(11, bgView.frame.size.height-40, bgView.frame.size.width-2, 39);
        self.lastUpdatedTime.frame = CGRectMake(username.frame.origin.x, username.frame.origin.y+username.frame.size.height-5, 120,20);
        
        post_desc.frame = CGRectMake(20, user_image.frame.origin.y+user_image.frame.size.height+10, bgView.frame.size.width-20, [self calculateHeight:cText].height);
        
        int diff = (bgView.frame.size.width-288)/3;
        
        likePost.frame = CGRectMake(self.menuView.frame.origin.x-10, 5, 32, 32);
        _likeLbl.frame = CGRectMake(likePost.frame.origin.x + likePost.frame.size.width, 5, 70, 30);
        commentPost.frame = CGRectMake(_likeLbl.frame.origin.x+60+diff, 5, 32, 32);
        _commentLbl.frame = CGRectMake(commentPost.frame.origin.x + 32, 5, 90, 30);
        share.frame = CGRectMake(_commentLbl.frame.origin.x+90+diff, 5, 32, 32);
        report.frame = CGRectMake(share.frame.origin.x+32+diff, 5, 32, 32);
        
    }else{
        
        post_image.hidden=NO;
        _page.hidden=NO;
        NSString *cText;
        NSString *imgPathRetrieve = [data objectForKey:@"user_image"];
        if([[data objectForKey:@"islike"] intValue]==0){
            [likePost setBackgroundImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
        }else{
            [likePost setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        }
        [user_image sd_setImageWithURL:[NSURL URLWithString:imgPathRetrieve] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                user_image.image = image;
            }else{
                user_image.image = [UIImage imageNamed:@"defaultProfile"];
            }
            
        }];
        
        
        if([[data objectForKey:@"is_report"] intValue]==0){
            [report setBackgroundImage:[UIImage imageNamed:@"report"] forState:UIControlStateNormal];
            report.userInteractionEnabled = YES;
        }else{
            [report setBackgroundImage:[UIImage imageNamed:@"reported"] forState:UIControlStateNormal];
            report.userInteractionEnabled = NO;
        }
        
        username.text = [data objectForKey:@"user_name"];
        double miliTime = [[data objectForKey:@"time"] doubleValue];
        self.lastUpdatedTime.text = [self dateStringFormate:miliTime];
        _page.numberOfPages = [[data objectForKey:@"imageCount"] intValue];
        
        int ind = [[data objectForKey:@"index"] integerValue];
        NSString *postImagePath ;
        if(ind == 0)
            postImagePath = [[data objectForKey:[NSString stringWithFormat:@"image_1"]] objectForKey:@"image_url"];
        else
            postImagePath = [[data objectForKey:[NSString stringWithFormat:@"image_%d",ind]] objectForKey:@"image_url"];
        
        
        post_image.layer.borderColor =[UIColor clearColor].CGColor;
        post_image.layer.borderWidth =0.5f;
        
        if([[data objectForKey:@"total_likes"] intValue] == 0)
            _likeLbl.userInteractionEnabled = NO;
        else
            _likeLbl.userInteractionEnabled = YES;
        
        _likeLbl.text = [NSString stringWithFormat:@"%@ Likes",[data objectForKey:@"total_likes"]];
        _commentLbl.text = [NSString stringWithFormat:@"%@ Comments",[data objectForKey:@"total_comments"]];
        post_image.contentMode = UIViewContentModeScaleAspectFit;
        post_image.clipsToBounds = YES;
        _spinner.center = CGPointMake(post_image.center.x-15, post_image.center.y-45);
        
        _page.backgroundColor = [UIColor redColor];
        _page.currentPage = ind-1;
        user_image.frame = CGRectMake(20, 10, 30, 30);
        username.frame =  CGRectMake(60, 10, 200,20);
        [_spinner startAnimating];
        [post_image sd_setImageWithURL:[NSURL URLWithString:postImagePath] placeholderImage:[UIImage imageNamed:@"imageplaceholder"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            if (image) {
                post_image.image = image;
            }else{
                post_image.image = [UIImage imageNamed:@"imageplaceholder"];
            }
            [_spinner stopAnimating];
            
        }];
        
        NSString *disString = [data objectForKey:@"description"];
        disString=[disString UTFDecoded];
        if(!disString){
            disString = [[data objectForKey:@"description"] stringByDecodingXMLEntities];
            disString = [data objectForKey:@"description"];
            
        }
        disString=[self RadhaCompatiableDecodingForString:disString];
        disString=[disString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        
        if ([[self reuseIdentifier] isEqualToString:@"loadMoreCell"]) {
            
            post_desc.text=[NSString stringWithFormat:@"%@   Less",disString];
            NSRange range = [post_desc.text rangeOfString:@"Less"];
            [post_desc addLinkToURL:[NSURL URLWithString:@"action://readless"] withRange:range];
            
            CGSize size = [self calculateHeight:disString];
            bgView.frame = CGRectMake(10, 0, self.frame.size.width-20, 340 + (size.height-35));
            cText = post_desc.text;
            //            post_desc.frame = CGRectMake(20, _page.frame.origin.y+_page.frame.size.height+10, 280, [self calculateHeight:post_desc.text].height);
            //            self.menuView.frame = CGRectMake(10, bgView.frame.size.height-40, bgView.frame.size.width, 40);
            
        }else{
            bgView.frame = CGRectMake(10, 0, self.frame.size.width-20, self.frame.size.height);
            NSString *text = [NSString stringWithFormat:@"%@...%@",disString,@"More"];
            CGSize size = [self calculateHeight:text];
            if (size.height > 75.0) {
                
                NSArray *newLineStrArray = [disString componentsSeparatedByString:@"\n"];
                
                if(newLineStrArray.count>5){
                    cText = [self newLineStringFormat:newLineStrArray];
                    post_desc.text= cText;
                    NSRange range = [post_desc.text rangeOfString:@"More"];
                    [post_desc addLinkToURL:[NSURL URLWithString:@"action://readmore"] withRange:range];
                    
                }else{
                    if(text.length>=210){
                        cText = [NSString stringWithFormat:@"%@...%@",[disString substringWithRange:NSMakeRange(0,(disString.length<200)?disString.length:200)],@"More"];
                        post_desc.text=[NSString stringWithFormat:@"%@",cText];
                        NSRange range = [post_desc.text rangeOfString:@"More"];
                        [post_desc addLinkToURL:[NSURL URLWithString:@"action://readmore"] withRange:range];
                        
                    }
                    else
                        cText = disString;
                    
                }
                
            }else{
                cText = disString;
                post_desc.text= cText;
                
            }
            
        }
        self.lastUpdatedTime.frame = CGRectMake(username.frame.origin.x, username.frame.origin.y+username.frame.size.height-5, 120,20);
        post_image.frame = CGRectMake(bgView.frame.origin.x+bgView.frame.size.width/2-140, 50, 280, 200);
        _page.center =CGPointMake(post_image.center.x-15, post_image.frame.origin.y + post_image.frame.size.height + 10);
        
        post_desc.frame = CGRectMake(20, _page.frame.origin.y+_page.frame.size.height+10, bgView.frame.size.width-20, [self calculateHeight:cText].height);
//        post_desc.backgroundColor = [UIColor redColor];
        
        self.menuView.frame = CGRectMake(11, bgView.frame.size.height-40, bgView.frame.size.width-2, 39);
        
        int diff = (bgView.frame.size.width-288)/3;
        
        likePost.frame = CGRectMake(self.menuView.frame.origin.x-10, 5, 32, 32);
        _likeLbl.frame = CGRectMake(likePost.frame.origin.x + likePost.frame.size.width, 5, 70, 30);
        commentPost.frame = CGRectMake(_likeLbl.frame.origin.x+60+diff, 5, 32, 32);
        _commentLbl.frame = CGRectMake(commentPost.frame.origin.x + 32, 5, 90, 30);
        share.frame = CGRectMake(_commentLbl.frame.origin.x+90+diff, 5, 32, 32);
        report.frame = CGRectMake(share.frame.origin.x+32+diff, 5, 32, 32);
    }
    
    post_desc.dataDetectorTypes = UIDataDetectorTypeAll;
}




-(void)leftSweepAction:(UIGestureRecognizer*)gesture{
    UIImageView *image = (UIImageView*)[gesture view];
    [self.imageDelegate leftImageAction:image];
    
}

-(void)rightSweepAction:(UIGestureRecognizer*)gesture{
    UIImageView *image = (UIImageView*)[gesture view];
    [self.imageDelegate rightImageAction:image];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}



- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    if ([[url scheme] hasPrefix:@"action"]) {
        if ([[url host] hasPrefix:@"readmore"]) {
            [self.imageDelegate cellHeightChange:label];
        }else if ([[url host] hasPrefix:@"readless"]){
            [self.imageDelegate readLessAction:label];
        }
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url absoluteString]]];
    }
}

-(CGSize)calculateHeight:(NSString*)data{
    
    CGFloat width = 280;
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:data attributes:@{NSFontAttributeName: font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    size.width = size.width +25;
    size.height = size.height +25;
    return size;
}

-(NSString*)RadhaCompatiableDecodingForString:(NSString*)str{
    
    return  [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
}

-(NSString*)dateStringFormate:(double)miliSecends{
    NSString *date;
    
    NSDate* sourceDate = [NSDate dateWithTimeIntervalSince1970:miliSecends/1000];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSLog(@"%@",destinationDate);
    
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:sourceDate];
    
    NSDateComponents *currentDateComponents = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    
    
    if([dateComponents year] == [currentDateComponents year] && [dateComponents month] == [currentDateComponents month] && [dateComponents day] == [currentDateComponents day]){
        date = [NSString stringWithFormat:@"%@:%@",([dateComponents hour]<10)?[NSString stringWithFormat:@"0%d",[dateComponents hour]]:[NSString stringWithFormat:@"%d",[dateComponents hour]],([dateComponents minute]<10)?[NSString stringWithFormat:@"0%d",[dateComponents minute]]:[NSString stringWithFormat:@"%d",[dateComponents minute]]];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMM YYYY"];
        NSString *date1 = [dateFormatter stringFromDate:destinationDate];
        
        date = [NSString stringWithFormat:@"%@ %@:%@",date1,([dateComponents hour]<10)?[NSString stringWithFormat:@"0%d",[dateComponents hour]]:[NSString stringWithFormat:@"%d",[dateComponents hour]],([dateComponents minute]<10)?[NSString stringWithFormat:@"0%d",[dateComponents minute]]:[NSString stringWithFormat:@"%d",[dateComponents minute]]];
    }
    return  date;
}

-(void)commentBtnAction:(UIButton*)btn{
    [self.imageDelegate commentButtonClick:btn];
}


-(void)shareBtnAction:(UIButton*)btn{
    [self.imageDelegate sharePost:btn];
}

-(void)likeButtonAction:(UIButton*)btn{
    [self.imageDelegate likePost:btn];
}

-(void)likeLblAction:(UIGestureRecognizer*)gesture{
    [self.imageDelegate likeLabelAction:gesture];
    
}
-(void)commentLblAction:(UIGestureRecognizer*)gesture{
    [self.imageDelegate commentLblAction:gesture];
}
-(void)repostBtnAction:(UIButton*)btn{
    [self.imageDelegate repostPost:btn];
}

-(void)openProfile:(UIGestureRecognizer*)gesture{
    
    [self.imageDelegate openUserProfileImage:(UIImageView*)gesture.view];
}


-(void)openImage:(UIGestureRecognizer*)gesture{
    int ind = [[self.cellData objectForKey:@"index"] integerValue];
    NSString *postImagePath ;
    if(ind == 0)
        postImagePath = [[self.cellData objectForKey:[NSString stringWithFormat:@"image_1"]] objectForKey:@"image_url"];
    else
        postImagePath = [[self.cellData objectForKey:[NSString stringWithFormat:@"image_%d",ind]] objectForKey:@"image_url"];
    [self.imageDelegate openImageInFullSize:(UIImageView*)[gesture view] currentImageUrl:postImagePath];
}

-(NSString*)newLineStringFormat:(NSArray*)atrArray{
    NSString *cText =@"";
    int i=1;
    for (NSString *first in atrArray) {
        
        if(cText.length + first.length>210 || i == 5){
            cText = [NSString stringWithFormat:@"%@\n%@...%@",cText,[first substringWithRange:NSMakeRange(0, (first.length<40)?first.length:40)],@"More"];
            break;
        }else{
            i=i+first.length/47;
            if (first.length%47!=0 || first.length==0) {
                i=i+1;
            }
            cText = [NSString stringWithFormat:@"%@\n%@",cText,first];
            
        }
        
    }
    
    return cText;
}

@end
