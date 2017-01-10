//
//  commentCell.m
//  GUP
//
//  Created by Aprajita Singh on 28/02/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import "commentCell.h"
#import "appdelegate.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NSString+Utils.h"

@implementation commentCell
@synthesize border,user_image,username,messageText,extraInfo,postImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        border = [[UIView alloc] initWithFrame:CGRectZero];
        border.backgroundColor = [UIColor colorWithRed:58.0/255.0 green:56.0/255.0 blue:48.0/255.0 alpha:1];
        border.opaque = YES;
        border.clearsContextBeforeDrawing = NO;
        [self addSubview:border];
        
        username = [[UILabel alloc] initWithFrame:CGRectZero];
        username.backgroundColor = [UIColor clearColor];
        username.opaque = YES;
        username.clearsContextBeforeDrawing = NO;
        username.numberOfLines=1;
        username.font = [UIFont fontWithName:@"Dosis-Bold" size:13.0f];
        username.textColor= [UIColor colorWithRed:58.0/255.0 green:56.0/255.0 blue:48.0/255.0 alpha:1];
        username.userInteractionEnabled = YES;
        [self addSubview:username];
        
        
        self.status = [[UIImageView alloc] init];
        [self addSubview:self.status];

        user_image = [[UIImageView alloc] initWithFrame:CGRectZero];
        user_image.backgroundColor = [UIColor clearColor];
        user_image.opaque = YES;
        user_image.layer.borderColor =[UIColor colorWithRed:36.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1].CGColor;
        user_image.clearsContextBeforeDrawing = NO;
        user_image.layer.cornerRadius =20.0f;
        user_image.layer.borderWidth =1;
        user_image.clipsToBounds = YES;
        user_image.userInteractionEnabled = YES;
        [self addSubview:user_image];
        
        postImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        postImage.backgroundColor = [UIColor clearColor];
        postImage.opaque = YES;
        postImage.clearsContextBeforeDrawing = NO;
        postImage.clipsToBounds = YES;
        postImage.userInteractionEnabled = YES;
        [self addSubview:postImage];
        self.userInteractionEnabled = YES;
        postImage.userInteractionEnabled = YES;
       
        
        messageText = [[UILabel alloc] init];
        messageText.textColor = [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
        messageText.tag = 3;
        messageText.backgroundColor = [UIColor clearColor];
        [messageText setFont:[UIFont fontWithName:@"Dosis-Regular" size:12.0f]];
        [self addSubview:messageText];
        
        
        extraInfo = [[UILabel alloc] init];
        extraInfo.textColor = [UIColor colorWithRed:58.0f/255.0 green:56.0f/255.0 blue:48.0f/255.0 alpha:1];
        extraInfo.tag = 2;
        extraInfo.backgroundColor = [UIColor clearColor];
        [extraInfo setFont:[UIFont fontWithName:@"Dosis-Regular" size:10.0f]];
        [self addSubview:extraInfo];
        self.bgImage = [[UIImageView alloc] init];
        [self.contentView addSubview:self.bgImage];
        if([reuseIdentifier isEqualToString:@"AudioCellIdentifier"]){
            
          //  self.status = [[UIImageView alloc] init];
            //[self.contentView addSubview:self.status];
            //            self.contentView.backgroundColor = [UIColor yellowColor];
            self.play=[[UIButton alloc]init];
            [self.play setBackgroundColor:[UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0]];
            self.play.layer.cornerRadius=5;
            [self.play setFrame:CGRectMake(12, 12, 30, 30)];
            [self.play setImage:[UIImage imageNamed:@"9_av_play.png" ] forState:UIControlStateNormal];
            [self.play setImage:[UIImage imageNamed:@"9_av_pause.png"] forState:UIControlStateSelected];
            [self addSubview:self.play];
            self.bgImage.userInteractionEnabled = YES;
            
            if(_commentObject!=nil)
                [self.play addTarget:_commentObject action:@selector(playAudio:)  forControlEvents:UIControlEventTouchUpInside];
            else
               [self.play addTarget:_chatObject action:@selector(playAudio:)  forControlEvents:UIControlEventTouchUpInside];
            
        }else if([reuseIdentifier isEqualToString:@"VCardCellIdentifier"]){
            //self.status = [[UIImageView alloc] init];
            //[self.contentView addSubview:self.status];
            //            self.contentView.backgroundColor = [UIColor greenColor];
            self.vcardName=[[UILabel alloc]init];
            [self.vcardName setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
            self.vcardName.numberOfLines=2;
            [self.vcardName setTextAlignment:NSTextAlignmentCenter];
            [self.vcardName setBackgroundColor:[UIColor clearColor]];
            [self addSubview:self.vcardName];
            
            self.vcardBut=[[UIButton alloc]init];
            [self.vcardBut setBackgroundColor:[UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0]];
            self.vcardBut.layer.cornerRadius=5;
            
            
            if(_commentObject!=nil)
                [self.vcardBut addTarget:_commentObject action:@selector(vcardClicked:)  forControlEvents:UIControlEventTouchUpInside];
            else
                [self.vcardBut addTarget:_chatObject action:@selector(vcardClicked:)  forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.vcardBut];
            self.bgImage.userInteractionEnabled = YES;
        }
     
    }
    return self;
}
-(void)clearCell{
    
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

-(NSString*)RadhaCompatiableDecodingForString:(NSString*)str{
    
    return  [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];;
    
}
- (void)drawCell:(NSDictionary*)data withIndexPath:(NSIndexPath*)indexPath{

    
        self.username.text = [data objectForKey:@"SENDERNAME"];
   
        double miliTime = [[data objectForKey:@"TIME_STAMP"] doubleValue];
    
        self.extraInfo.text = [self dateStringFormate:miliTime];
    
    
                user_image.image = [UIImage imageNamed:@"defaultProfile"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *Filepath = [documentsDirectory stringByAppendingPathComponent:[data objectForKey:@"SENDER_IMAGE"]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if([filemgr fileExistsAtPath:Filepath] == YES){
        [user_image setImage:[UIImage imageWithContentsOfFile:Filepath]];
        [user_image setUserInteractionEnabled:YES];
    }else{
        
        // self.indicater.frame = CGRectMake((self.bgImage.frame.origin.x+self.bgImage.frame.size.width/2)-70, (self.bgImage.frame.origin.y+self.bgImage.frame.size.height/2)-70, 50, 50);
        //self.indicater.center = CGPointMake(self.bgImage.center.x-10, self.bgImage.center.y-15);
        //[self.indicater startAnimating];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,[data objectForKey:@"SENDER_IMAGE"]]]];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //[self.indicater removeFromSuperview];
                [user_image setImage:[UIImage imageWithData:imgData]] ;
                user_image.frame = CGRectMake(10,10, self.bgImage.frame.size.width-20, self.bgImage.frame.size.height-20);
                [imgData writeToFile:Filepath atomically:YES];
                [user_image setUserInteractionEnabled:YES];
                
            });
            
        });
        
    }

    
    if([[data objectForKey:@"MESSAGE_TYPE"] isEqual:@"image"]){
    
//        [postImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/chat_files/%@",gupappUrl,[data objectForKey:@"MESSAGE_FILENAME"]]] placeholderImage:nil completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
//            if (image) {
//                postImage.image = image;
//            }else{
//                postImage.image = nil;
//            }
//            
//        }];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *Filepath = [documentsDirectory stringByAppendingPathComponent:[data objectForKey:@"MESSAGE_FILENAME"]];
        [postImage setImage:nil];
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if([filemgr fileExistsAtPath:Filepath] == YES){
            [postImage setImage:[UIImage imageWithContentsOfFile:Filepath]];
            [postImage setUserInteractionEnabled:YES];
        }else{
            
           // self.indicater.frame = CGRectMake((self.bgImage.frame.origin.x+self.bgImage.frame.size.width/2)-70, (self.bgImage.frame.origin.y+self.bgImage.frame.size.height/2)-70, 50, 50);
//self.indicater.center = CGPointMake(self.bgImage.center.x-10, self.bgImage.center.y-15);
            //[self.indicater startAnimating];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/chat_files/%@",gupappUrl,[data objectForKey:@"MESSAGE_FILENAME"]]]];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //[self.indicater removeFromSuperview];
                    [postImage setImage:[UIImage imageWithData:imgData]] ;
                    postImage.frame = CGRectMake(10,10, self.bgImage.frame.size.width-20, self.bgImage.frame.size.height-20);
                    [imgData writeToFile:Filepath atomically:YES];
                    [postImage setUserInteractionEnabled:YES];
                    
                });
                
            });
            
        }
        
        self.tag = indexPath.section;
        postImage.tag = indexPath.row;
        
        if(_commentObject!=nil){
            UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:_commentObject action:@selector(singleTapGestureCaptured:)];
            singleTap.numberOfTapsRequired =1;
            [postImage addGestureRecognizer:singleTap];
        }else{
            UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:_chatObject action:@selector(singleTapGestureCaptured:)];
            singleTap.numberOfTapsRequired =1;
            [postImage addGestureRecognizer:singleTap];
        }
       
         extraInfo.frame = CGRectMake(70, 28, 200, 15);
        postImage.frame = CGRectMake(70,48, self.bounds.size.width-90, self.bounds.size.width-90);
        
    }else if([[data objectForKey:@"MESSAGE_TYPE"] isEqual:@"text"]){
        NSString *message= [data objectForKey:@"MESSAGE_TEXT"];
        message=[message UTFDecoded];
        message=[self RadhaCompatiableDecodingForString:message];
        message=[message stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        
        messageText.text = message;
         extraInfo.frame = CGRectMake(70, 28, 200, 15);
         CGSize size = [self calculateHeight:message];
        messageText.frame = CGRectMake(70, 40, self.bounds.size.width-80, size.height);
        
    }else if([[data objectForKey:@"MESSAGE_TYPE"] isEqual:@"audio"]){
        
        self.play.tag  = indexPath.row;
        
         if(_commentObject!=nil){
            
                if(_commentObject.playingAudio){
                    
                    if (_commentObject.currentlyPlayedAudio==indexPath.row){
                        
                        [self.play setSelected:1];
                    
                        
                    }
                }
                else
                    [self.play setSelected:0];
                
                     if(_commentObject.playingAudio)
                         if(self.playerstatus.tag==indexPath.row){
                             [self addSubview:_commentObject.audioPlayersAudioDuration];
                         [self addSubview:_commentObject.audioPlayersCurrentTime];
                         [self addSubview:self.playerstatus];
                     }
         }else{
             
             if(_chatObject.playingAudio){
                 
                 if (_chatObject.currentlyPlayedAudio==indexPath.row){
                     
                     [self.play setSelected:1];
                     
                     
                 }
             }
             else
                 [self.play setSelected:0];
             
             if(_chatObject.playingAudio)
                 if(self.playerstatus.tag==indexPath.row){
                     [self addSubview:_chatObject.audioPlayersAudioDuration];
                     [self addSubview:_chatObject.audioPlayersCurrentTime];
                     [self addSubview:self.playerstatus];
                 }         }
        
         extraInfo.frame = CGRectMake(70, 28, 200, 15);
         self.play.frame = CGRectMake(70,50,30,30);
    }else{
        self.vcardBut.frame = CGRectMake(70,50,34, 34);
        [self.vcardBut setImage:nil forState:UIControlStateNormal];
        NSString *Filepath;
        @try {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            Filepath = [documentsDirectory stringByAppendingPathComponent:[[[data objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ] objectAtIndex:2]];
            
        }@catch (NSException *exception) {
            Filepath=@"";
        }
         self.vcardBut.tag = indexPath.row;
        [self.vcardBut setImage:[UIImage imageWithContentsOfFile:Filepath] forState:UIControlStateNormal];
        [self.vcardName setText:[self getusernameforBody:[data objectForKey:@"MESSAGE_TEXT"]]];
        self.vcardName.frame = CGRectMake(self.vcardBut.frame.origin.x+39, 50, 90, 34);
        extraInfo.frame = CGRectMake(70, 28, 200, 15);
    }
   
    
    user_image.frame = CGRectMake(20, 10, 40, 40);
    username.frame = CGRectMake(70, 10, 180, 16);
   
    BOOL didsend=[[data objectForKey:@"MESSAGESTATUS"] boolValue];
    if (!didsend){
       
        
        [self.status setImage:[UIImage imageNamed:@"ic_pending"]];
        double CURRENTtimestamp = [[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
        double MSGtimestamp= [[data objectForKey:@"TIME_STAMP"] doubleValue];
        if ((CURRENTtimestamp- MSGtimestamp)<5000){
            [self.status setImage:[UIImage imageNamed:@"ic_clock"]];
        }
         self.status.frame = CGRectMake(self.bounds.size.width-30,20,10,10);
    }else{
        
        self.status.image =nil;
    }
   
    
    border.frame = CGRectMake(10, self.bounds.size.height-.5, self.bounds.size.width-20, .5);
 
}

-(NSString*)getusernameforBody:(NSString*)str{
    //NSLog(@"string %@",str);
    int noOfFoundcolon=0;
    
    for (int u=0; u<str.length; u++){
        //NSLog(@"chara %hhd",(char)[str characterAtIndex:u]);
        if ([str characterAtIndex:u]==':'){
            
            noOfFoundcolon++;
            if (noOfFoundcolon==5){
                //NSLog(@"str %@",[str substringFromIndex:u+1]);
                return [str substringFromIndex:u+1];
                
            }
        }
        
    }
    return @"";
}
-(CGSize)calculateHeight:(NSString*)data{
    
    CGFloat width = self.bounds.size.width-80;
    UIFont *font = [UIFont fontWithName:@"Dosis-Regular" size:12.0f];
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:data attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    if([data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0){
        size.width = size.width +25;
        size.height = size.height +15;
    }
    return size;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
