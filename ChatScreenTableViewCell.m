//
//  SMMessageViewTableCell.m
//  shan
//
//  Created by Deepesh_Genora on 12/16/13.
//  Copyright (c) 2013 Deepesh_Genora. All rights reserved.
//

#import "ChatScreenTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Utils.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"


@implementation ChatScreenTableViewCell
@synthesize sender=_sender,TimeLabel=_TimeLabel,messageContentView=_messageContentView,pinned=_pinned,status=_status,date=_date,details=_details;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forViewController:(ChatScreen*)viewController
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    
    
    if (self) {
        
        self.commentObject=viewController;
        self.bgImage = [[UIImageView alloc] init];
        [self.contentView addSubview:self.bgImage];
        
        self.date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 12)];
        self.date.textAlignment = NSTextAlignmentCenter;
        [self.date setBackgroundColor:[UIColor clearColor]];
        self.date.layer.cornerRadius=5;
        self.date.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        self.date.textColor = [UIColor lightGrayColor];
        [self.date setHidden:YES];
        [self.contentView addSubview:self.date];
        
        self.TimeLabel = [[UILabel alloc] init];
        self.TimeLabel.textAlignment = NSTextAlignmentLeft;
        self.TimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        [self.TimeLabel setBackgroundColor:[UIColor clearColor]];
        self.TimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.TimeLabel];
        
        
        
        if([reuseIdentifier isEqualToString:@"MessageCellIdentifier"]){
            
            self.status = [[UIImageView alloc] init];
            [self.contentView addSubview:self.status];
            
            self.details=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.details setFrame:CGRectMake(0, 0, 15, 15)];
            [self.details setTintColor:[UIColor redColor]];
            [self.details setImage:[UIImage imageNamed:@"plus_"] forState:UIControlStateSelected];
            [self.details setImage:[UIImage imageNamed:@"minus"] forState:UIControlStateNormal];
            [self.details setHidden:YES];
            [self.contentView addSubview:self.details];
//                        self.contentView.backgroundColor = [UIColor redColor];
            
            self.messageContentView = [[TTTAttributedLabel alloc] init];
            self.messageContentView.backgroundColor = [UIColor clearColor];
            self.messageContentView.numberOfLines = 0;
            self.messageContentView.delegate = self;
            self.messageContentView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
            self.contentView.userInteractionEnabled = YES;
            self.messageContentView.userInteractionEnabled = YES;
            [self.contentView addSubview:self.messageContentView];
            
            recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:_commentObject action:@selector(longPressw:)];
            [recognizer setDelegate:_commentObject];
            [self.messageContentView addGestureRecognizer:recognizer];
            
            for (UIGestureRecognizer *recognizer1 in self.messageContentView.gestureRecognizers) {
                if ([recognizer1 isKindOfClass:[UILongPressGestureRecognizer class]]){
                    recognizer1.enabled = NO;
                }
            }
            
        }else if([reuseIdentifier isEqualToString:@"ImageCellIdentifier"]){
//                                   self.contentView.backgroundColor = [UIColor purpleColor];
            self.status = [[UIImageView alloc] init];
            [self.contentView addSubview:self.status];
            self.image = [[UIImageView alloc] init];
            [self.bgImage setUserInteractionEnabled:YES];
            [self.bgImage addSubview:self.image];
            self.indicater = [[UIActivityIndicatorView alloc] init];
            [self.bgImage addSubview:self.indicater];
            
            singleTap = [[UITapGestureRecognizer alloc] initWithTarget:_commentObject action:@selector(singleTapGestureCaptured:)];
            [self.image addGestureRecognizer:singleTap];
            
            
        }else if([reuseIdentifier isEqualToString:@"AudioCellIdentifier"]){
            
            self.status = [[UIImageView alloc] init];
            [self.contentView addSubview:self.status];
//                        self.contentView.backgroundColor = [UIColor yellowColor];
            self.play=[[UIButton alloc]init];
            [self.play setBackgroundColor:[UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0]];
            self.play.layer.cornerRadius=5;
            [self.play setFrame:CGRectMake(12, 12, 30, 30)];
            [self.play setImage:[UIImage imageNamed:@"9_av_play.png" ] forState:UIControlStateNormal];
            [self.play setImage:[UIImage imageNamed:@"9_av_pause.png"] forState:UIControlStateSelected];
            [self.bgImage addSubview:self.play];
            self.bgImage.userInteractionEnabled = YES;
            
            [self.play addTarget:_commentObject action:@selector(playAudio:)  forControlEvents:UIControlEventTouchUpInside];
            
        }else if([reuseIdentifier isEqualToString:@"VCardCellIdentifier"]){
            self.status = [[UIImageView alloc] init];
            [self.contentView addSubview:self.status];
//                        self.contentView.backgroundColor = [UIColor greenColor];
            self.vcardName=[[UILabel alloc]init];
            [self.vcardName setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
            self.vcardName.numberOfLines=2;
            [self.vcardName setTextAlignment:NSTextAlignmentCenter];
            [self.vcardName setBackgroundColor:[UIColor clearColor]];
            [self.bgImage addSubview:self.vcardName];
            
            self.vcardBut=[[UIButton alloc]init];
            [self.vcardBut setBackgroundColor:[UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0]];
            self.vcardBut.layer.cornerRadius=5;
            [self.vcardBut addTarget:_commentObject action:@selector(vcardClicked:)  forControlEvents:UIControlEventTouchUpInside];
            [self.bgImage addSubview:self.vcardBut];
            self.bgImage.userInteractionEnabled = YES;
        }
        
        self.pinned=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.pinned.hidden = YES;
        [self.pinned setImage:[UIImage imageNamed:@"2xpin_grey.png"]];
        
        self.status=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
        [self.contentView  addSubview:self.status];
        
    }
    return self;
}


-(void)drawCell:(NSDictionary*)dictonary withIndexPath:(NSIndexPath*)indexPath{
    NSString *time = [dictonary objectForKey:@"TIME_STAMP"];
    time=  [time getDateTimeFromUTCTimeInterval];
    if ([time componentsSeparatedByString:@" "].count!=2){
        time=[NSString DateTime];
    }
    NSArray *dateTime=[time componentsSeparatedByString:@" "];
    NSArray *dateComponents=[[dateTime objectAtIndex:0] componentsSeparatedByString:@"-"];
    NSString *dateValue=@"";
    dateValue=[dateValue stringByAppendingString:[dateComponents objectAtIndex:2]];
    dateValue=[dateValue stringByAppendingString:[NSString stringWithFormat:@"-%@",[_commentObject.month objectAtIndex:[[dateComponents objectAtIndex:1] integerValue]-1]]];
    
    [self.date setCenter:CGPointMake(self.contentView.frame.size.width/2,6.5)];
    [self.date setText:dateValue];
    
    if ([_commentObject checkForDate:indexPath timeinMilisecend:[dictonary objectForKey:@"TIME_STAMP"]] || indexPath.row == 0) {
        [self.date setHidden:NO];
    }else{
        [self.date setHidden:YES];
        
    }
    
    if(self.mycell){
        self.status.hidden = NO;
        self.bgImage.image = [[UIImage imageNamed:@"BlueBubble_right.png"]stretchableImageWithLeftCapWidth:15  topCapHeight:15];
        if([self.reuseIdentifier isEqualToString:@"MessageCellIdentifier"]){
            
            NSString *message = [[dictonary objectForKey:@"MESSAGE_TEXT"] isEqual:[NSNull null]]?@"":[dictonary objectForKey:@"MESSAGE_TEXT"];
            message=[message UTFDecoded];
            message=[self RadhaCompatiableDecodingForString:message];
            message=[message stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            
            if ([[dictonary objectForKey:@"MESSAGE_TYPE"] isEqual:@"text"]){
                [self.messageContentView setHidden:NO];
                
                recognizer.enabled=YES;
                
                if (message.length>250){
                    if (![_commentObject.expandedMessageId containsObject:[dictonary valueForKey:@"MESSAGE_ID"]]){
                        message=[message substringToIndex:250];
                        [self.bgImage setUserInteractionEnabled:YES];
                        [self.details setTag:[[dictonary valueForKey:@"MESSAGE_ID"] integerValue]];
                        [self.details setSelected:1 ];
                        [self.details setHidden:NO];
                        [self.details addTarget:_commentObject action:@selector(expandMessage:) forControlEvents:UIControlEventTouchUpInside ];
                        [self.contentView bringSubviewToFront:self.details];
                    }else{
                        
                        [self.details setTag:[[dictonary valueForKey:@"MESSAGE_ID"] integerValue]];
                        [self.bgImage setUserInteractionEnabled:YES];
                        [self.details setHidden:NO];
                        [self.details setSelected:0];
                        [self.details addTarget:_commentObject action:@selector(expandMessage:) forControlEvents:UIControlEventTouchUpInside ];
                        
                    }
                }else {
                    [self.details setHidden:YES];
                }
            }
            self.messageContentView.text=message;
            CGSize deviceSize=[UIScreen mainScreen].bounds.size;
            CGFloat chatBubbleWidth=deviceSize.width*0.5625;
            CGSize  textSize = { chatBubbleWidth, 10000.0 };
            [message  sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
            CGSize size = [message  sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
            size.height+=4;
            size.width += 20.0;
            int paddValue;
            if ( [[[self appDelegate].ver objectAtIndex:0] intValue] >= 7)
                paddValue=20.0;
            else
                paddValue=0;
            
            [self.messageContentView setFrame:CGRectMake(self.contentView.frame.size.width - size.width - 20,10,size.width,size.height)];
            [self.bgImage setFrame:CGRectMake(self.messageContentView.frame.origin.x - 10,self.messageContentView.frame.origin.y-5,size.width+20,size.height+15)];
            [self.details setFrame:CGRectMake(self.bgImage.frame.origin.x + self.bgImage.frame.size.width-30,self.bgImage.frame.origin.y + self.bgImage.frame.size.height-35, 20, 20)];
            
        }
        if([self.reuseIdentifier isEqualToString:@"ImageCellIdentifier"]){
            
            [self.bgImage setFrame:CGRectMake(self.contentView.frame.size.width-190,10,180,160)];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *Filepath = [documentsDirectory stringByAppendingPathComponent:[dictonary objectForKey:@"MESSAGE_FILENAME"]];
            [self.image setImage:nil];
            NSFileManager *filemgr = [NSFileManager defaultManager];
            if([filemgr fileExistsAtPath:Filepath] == YES){
                [self.image setImage:[UIImage imageWithContentsOfFile:Filepath]];
                [self.image setUserInteractionEnabled:YES];
            }
            self.image.frame = CGRectMake(10,10, self.bgImage.frame.size.width-20, self.bgImage.frame.size.height-20);
            self.image.tag = indexPath.row;
            
        }
        
        
        if([self.reuseIdentifier isEqualToString:@"VCardCellIdentifier"]){
            
            self.vcardBut.frame = CGRectMake(10,10,34, 34);
            [self.vcardBut setImage:nil forState:UIControlStateNormal];
            NSString *Filepath;
            @try {
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                Filepath = [documentsDirectory stringByAppendingPathComponent:[[[dictonary objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ] objectAtIndex:2]];
                
            }@catch (NSException *exception) {
                Filepath=@"";
            }
            
            [self.vcardBut setImage:[UIImage imageWithContentsOfFile:Filepath] forState:UIControlStateNormal];
            [self.vcardName setText:[self getusernameforBody:[dictonary objectForKey:@"MESSAGE_TEXT"]]];
            self.vcardName.frame = CGRectMake(self.vcardBut.frame.origin.x+39, 10, 90, 34);
            [self.bgImage setFrame:CGRectMake(self.contentView.frame.size.width-150,10,140,60)];
        }
        
        if([self.reuseIdentifier isEqualToString:@"AudioCellIdentifier"]){
            self.play.tag  = indexPath.row;
            [self.bgImage setFrame:CGRectMake(self.contentView.frame.size.width-64 ,10,54,54)];
            if(_commentObject.playingAudio){
                
                if (_commentObject.currentlyPlayedAudio==indexPath.row){
                    
                    [self.play setSelected:1];
                    CGRect bgimageViewframe=self.bgImage.frame;
                    bgimageViewframe.size.width+=126;
                    if(self.bgImage.center.x>self.contentView.frame.size.width/2)
                        bgimageViewframe.origin.x-=126;
                    [self.bgImage setFrame:bgimageViewframe];
                    
                }
            }
            else
                [self.play setSelected:0];
            
            
            if(_commentObject.playingAudio)
                if(self.playerstatus.tag==indexPath.row){
                    [self.bgImage addSubview:_commentObject.audioPlayersAudioDuration];
                    [self.bgImage addSubview:_commentObject.audioPlayersCurrentTime];
                    [self.bgImage addSubview:self.playerstatus];
                }
            
        }
        self.TimeLabel.text = [self miliSecendToTime:[dictonary objectForKey:@"TIME_STAMP"]];
        self.TimeLabel.frame = CGRectMake(self.bgImage.frame.origin.x+self.bgImage.frame.size.width-40, self.bgImage.frame.origin.y+self.bgImage.frame.size.height, 28, 10);
        int didsend=[[dictonary objectForKey:@"MESSAGESTATUS"] intValue];
        if (didsend == 1){
            [self.status setImage:[UIImage imageNamed:@"ic_delivered"]];
        }else if(didsend == 2){
        
            [self.status setImage:[UIImage imageNamed:@"dtick_grey16"]];
        }
        else{
            
            [self.status setImage:[UIImage imageNamed:@"ic_pending"]];
            double CURRENTtimestamp = [[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
            double MSGtimestamp= [[dictonary objectForKey:@"TIME_STAMP"] doubleValue];
            if ((CURRENTtimestamp- MSGtimestamp)<5000){
                [self.status setImage:[UIImage imageNamed:@"ic_clock"]];
            }
            
        }
        self.status.frame = CGRectMake(self.TimeLabel.frame.origin.x + self.TimeLabel.frame.size.width , self.TimeLabel.frame.origin.y , 10 , 10);
    }else{
        self.status.hidden = YES;
        
        self.bgImage.image = [[UIImage imageNamed:@"gray_bubble.png"]stretchableImageWithLeftCapWidth:15  topCapHeight:15];
        if([self.reuseIdentifier isEqualToString:@"MessageCellIdentifier"]){
            NSString *message = [[dictonary objectForKey:@"MESSAGE_TEXT"] isEqual:[NSNull null]]?@"":[dictonary objectForKey:@"MESSAGE_TEXT"];
            message=[message UTFDecoded];
            message=[self RadhaCompatiableDecodingForString:message];
            message=[message stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            
            if ([[dictonary objectForKey:@"MESSAGE_TYPE"] isEqual:@"text"]){
                [self.messageContentView setHidden:NO];
                
                recognizer.enabled=YES;
                if (message.length>250){
                    if (![_commentObject.expandedMessageId containsObject:[dictonary valueForKey:@"MESSAGE_ID"]]){
                        message=[message substringToIndex:250];
                        [self.bgImage setUserInteractionEnabled:YES];
                        [self.details setTag:[[dictonary valueForKey:@"MESSAGE_ID"] integerValue]];
                        [self.details setSelected:1 ];
                        [self.details setHidden:NO];
                        [self.details addTarget:_commentObject action:@selector(expandMessage:) forControlEvents:UIControlEventTouchUpInside ];
                        [self.contentView bringSubviewToFront:self.details];
                    }else{
                        
                        [self.details setTag:[[dictonary valueForKey:@"MESSAGE_ID"] integerValue]];
                        [self.bgImage setUserInteractionEnabled:YES];
                        [self.details setHidden:NO];
                        [self.details setSelected:0];
                        [self.details addTarget:_commentObject action:@selector(expandMessage:) forControlEvents:UIControlEventTouchUpInside ];
                        
                    }
                }else {
                    [self.details setHidden:YES];
                }
            }
            
            self.messageContentView.text=message;
            CGSize deviceSize=[UIScreen mainScreen].bounds.size;
            CGFloat chatBubbleWidth=deviceSize.width*0.5625;
            CGSize  textSize = { chatBubbleWidth, 10000.0 };
            [message  sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
            CGSize size = [message  sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
            size.height+=4;
            size.width += 20.0;
            int paddValue;
            if ( [[[self appDelegate].ver objectAtIndex:0] intValue] >= 7)
                paddValue=20.0;
            else
                paddValue=0;
            
            
            [self.messageContentView setFrame:CGRectMake(paddValue,10, size.width, size.height+7)];
            [self.bgImage setFrame:CGRectMake(self.messageContentView.frame.origin.x - 10,self.messageContentView.frame.origin.y,size.width+20,size.height+15)];
            [self.details setFrame:CGRectMake(self.bgImage.frame.origin.x + self.bgImage.frame.size.width-30,self.bgImage.frame.origin.y + self.bgImage.frame.size.height-37, 20, 20)];
            
        }
        
        if([self.reuseIdentifier isEqualToString:@"ImageCellIdentifier"]){
            
            [self.bgImage setFrame:CGRectMake(10,10,180,160)];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *Filepath = [documentsDirectory stringByAppendingPathComponent:[dictonary objectForKey:@"MESSAGE_FILENAME"]];
            NSFileManager *filemgr = [NSFileManager defaultManager];
            self.image.tag = indexPath.row;
            [self.image setImage:nil];
            if([filemgr fileExistsAtPath:Filepath] == YES){
                [self.image setImage:[UIImage imageWithContentsOfFile:Filepath]];
                self.image.frame = CGRectMake(10,10, self.bgImage.frame.size.width-20, self.bgImage.frame.size.height-20);
                [self.image setUserInteractionEnabled:YES];
                
            }else{
                
                self.indicater.frame = CGRectMake((self.bgImage.frame.origin.x+self.bgImage.frame.size.width/2)-70, (self.bgImage.frame.origin.y+self.bgImage.frame.size.height/2)-70, 50, 50);
                self.indicater.center = CGPointMake(self.bgImage.center.x-10, self.bgImage.center.y-15);
                [self.indicater startAnimating];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/chat_files/%@",gupappUrl,[dictonary objectForKey:@"MESSAGE_FILENAME"]]]];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.indicater removeFromSuperview];
                        [self.image setImage:[UIImage imageWithData:imgData]] ;
                        self.image.frame = CGRectMake(10,10, self.bgImage.frame.size.width-20, self.bgImage.frame.size.height-20);
                        [imgData writeToFile:Filepath atomically:YES];
                        [self.image setUserInteractionEnabled:YES];
                        
                    });
                    
                });
                
            }
        }
        
        if([self.reuseIdentifier isEqualToString:@"VCardCellIdentifier"]){
            
            self.vcardBut.frame = CGRectMake(10,10,34, 34);
            NSString *Filepath;
            @try {
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                Filepath = [documentsDirectory stringByAppendingPathComponent:[[[dictonary objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ] objectAtIndex:2]];
                
            }@catch (NSException *exception) {
                Filepath=@"";
            }
            NSFileManager *filemgr = [NSFileManager defaultManager];
            [self.vcardBut setImage:nil forState:UIControlStateNormal];
            if([filemgr fileExistsAtPath:Filepath] == YES){
                [self.vcardBut setImage:[UIImage imageWithContentsOfFile:Filepath] forState:UIControlStateNormal];
                
            }else{
                
                self.indicater.frame = CGRectMake((self.bgImage.frame.origin.x+self.bgImage.frame.size.width/2)-70, (self.bgImage.frame.origin.y+self.bgImage.frame.size.height/2)-70, 50, 50);
                self.indicater.center = self.bgImage.center;
                [self.indicater startAnimating];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/chat_files/%@",gupappUrl,[[[dictonary objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ] objectAtIndex:2]]]];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        [self.vcardBut setImage:[UIImage imageWithData:imgData] forState:UIControlStateNormal];
                        [imgData writeToFile:Filepath atomically:YES];
                        
                        
                    });
                    
                });
                
            }
            self.vcardBut.tag = indexPath.row;
            
            [self.vcardName setText:[self getusernameforBody:[dictonary objectForKey:@"MESSAGE_TEXT"]]];
            self.vcardName.frame = CGRectMake(self.vcardBut.frame.origin.x+39, 10, 85, 34);
            [self.bgImage setFrame:CGRectMake(10,10,140,60)];
        }
        if([self.reuseIdentifier isEqualToString:@"AudioCellIdentifier"]){
            
            [self.bgImage setFrame:CGRectMake(10 ,10,54,54)];
            self.play.tag  = indexPath.row;
            if(_commentObject.playingAudio){
                
                if (_commentObject.currentlyPlayedAudio==indexPath.row){
                    
                    [self.play setSelected:1];
                    CGRect bgimageViewframe=self.bgImage.frame;
                    bgimageViewframe.size.width+=126;
                    if(self.bgImage.center.x>self.contentView.frame.size.width/2)
                        bgimageViewframe.origin.x-=126;
                    [self.bgImage setFrame:bgimageViewframe];
                    
                }
            }
            else
                [self.play setSelected:0];
            
            
            if(_commentObject.playingAudio)
                if(self.playerstatus.tag==indexPath.row){
                    [self.bgImage addSubview:_commentObject.audioPlayersAudioDuration];
                    [self.bgImage addSubview:_commentObject.audioPlayersCurrentTime];
                    [self.bgImage addSubview:self.playerstatus];
                }
            
            
        }
        self.TimeLabel.text = [self miliSecendToTime:[dictonary objectForKey:@"TIME_STAMP"]];
        self.TimeLabel.frame = CGRectMake(self.bgImage.frame.origin.x+10, self.bgImage.frame.origin.y+self.bgImage.frame.size.height, 28, 10);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(AppDelegate*)appDelegate{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

-(NSString*)RadhaCompatiableDecodingForString:(NSString*)str{
    
    return  [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];;
    
}

//-(void)expandMessage:(UIButton*)button{
//
//}

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


-(NSString*)miliSecendToTime:(NSString*)miliSecend{
    //    miliSecend =  [miliSecend getDateTimeFromUTCTimeInterval];
    //    if ([miliSecend componentsSeparatedByString:@" "].count!=2){
    //        miliSecend=[NSString DateTime];
    //    }
    //
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"HH:mm"];
    //    NSDate *dt=[dateFormatter dateFromString:miliSecend];
    NSString *time = miliSecend;
    time=  [time getDateTimeFromUTCTimeInterval];
    if ([time componentsSeparatedByString:@" "].count!=2){
        time=[NSString DateTime];
    }
    NSArray *dateTime=[time componentsSeparatedByString:@" "];
    NSString *timeValue=[dateTime objectAtIndex:1];
    NSString *str =  [timeValue substringToIndex:5];
    return str;
}

@end
