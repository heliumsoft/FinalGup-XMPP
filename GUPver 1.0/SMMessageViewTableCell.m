//
//  SMMessageViewTableCell.m
//  shan
//
//  Created by Deepesh_Genora on 12/16/13.
//  Copyright (c) 2013 Deepesh_Genora. All rights reserved.
//

#import "SMMessageViewTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Utils.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"


@implementation SMMessageViewTableCell
@synthesize sender=_sender,TimeLabel=_TimeLabel,messageContentView=_messageContentView,pinned=_pinned,status=_status,date=_date,details=_details;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forViewController:(CommentViewController*)viewController
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    
    
    if (self) {
        
        self.commentObject=viewController;
        self.bgImage = [[UIImageView alloc] init];
        [self.contentView addSubview:self.bgImage];
        
        self.sender = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 15)];
        self.sender.textAlignment = NSTextAlignmentLeft;
        [self.sender setBackgroundColor:[UIColor whiteColor]];
        self.sender.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        self.sender.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.sender];
        
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
//            self.contentView.backgroundColor = [UIColor redColor];
            
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
//                        self.contentView.backgroundColor = [UIColor purpleColor];
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
//            self.contentView.backgroundColor = [UIColor yellowColor];
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
//            self.contentView.backgroundColor = [UIColor greenColor];
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
        self.sender.hidden = YES;
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
            
            [self.messageContentView setFrame:CGRectMake(self.contentView.frame.size.width - size.width - 20,15,size.width,size.height)];
            [self.bgImage setFrame:CGRectMake(self.messageContentView.frame.origin.x - 10,self.messageContentView.frame.origin.y-5,size.width+20,size.height+15)];
            [self.details setFrame:CGRectMake(self.bgImage.frame.origin.x + self.bgImage.frame.size.width-30,self.bgImage.frame.origin.y + self.bgImage.frame.size.height-35, 20, 20)];
            
        }
        if([self.reuseIdentifier isEqualToString:@"ImageCellIdentifier"]){

            [self.bgImage setFrame:CGRectMake(self.contentView.frame.size.width-190,15,180,160)];
            
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
            [self.bgImage setFrame:CGRectMake(self.contentView.frame.size.width-150,15,140,60)];
        }
        
        if([self.reuseIdentifier isEqualToString:@"AudioCellIdentifier"]){
            self.play.tag  = indexPath.row;
            [self.bgImage setFrame:CGRectMake(self.contentView.frame.size.width-64 ,15,54,54)];
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
        BOOL didsend=[[dictonary objectForKey:@"MESSAGESTATUS"] boolValue];
        if (didsend){
                    [self.status setImage:[UIImage imageNamed:@"ic_delivered"]];
                }else{
            
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
        self.sender.hidden = NO;
        self.sender.text = [dictonary objectForKey:@"SENDERNAME"];
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
            
            
            [self.messageContentView setFrame:CGRectMake(paddValue,self.sender.frame.origin.y+self.sender.frame.size.height, size.width, size.height+7)];
            [self.bgImage setFrame:CGRectMake(self.messageContentView.frame.origin.x - 10,self.messageContentView.frame.origin.y,size.width+20,size.height+15)];
            [self.details setFrame:CGRectMake(self.bgImage.frame.origin.x + self.bgImage.frame.size.width-30,self.bgImage.frame.origin.y + self.bgImage.frame.size.height-37, 20, 20)];
            
         }
        
        if([self.reuseIdentifier isEqualToString:@"ImageCellIdentifier"]){

            [self.bgImage setFrame:CGRectMake(self.sender.frame.origin.x,25,180,160)];
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
            [self.bgImage setFrame:CGRectMake(self.sender.frame.origin.x,self.sender.frame.origin.y+self.sender.frame.size.height-5,140,60)];
        }
        if([self.reuseIdentifier isEqualToString:@"AudioCellIdentifier"]){
            
            [self.bgImage setFrame:CGRectMake(self.sender.frame.origin.x ,self.sender.frame.origin.y+self.sender.frame.size.height-5,54,54)];
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

//NSDictionary *msg = (NSDictionary *) [chatHistory objectAtIndex:indexPath.row];
//static NSString *CellIdentifier = @"MessageCellIdentifier";
//SMMessageViewTableCell *cell = (SMMessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//if (cell == nil) {
//    cell = [[SMMessageViewTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    
//}
//else{
//    cell = nil;
//    cell = [[SMMessageViewTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//}
//
//CGRect cellWidth=cell.contentView.frame;
//cellWidth.size.width=tableView.frame.size.width;
//[cell setFrame:cellWidth];
//[cell.contentView setFrame:cellWidth];
//
////    if ([[[self appDelegate].ver  objectAtIndex:0] intValue] >= 7)
////        cell.messageContentView.contentInset = UIEdgeInsetsMake(-7.0,0.0,-18.0f,0.0);
////    else{
////        cell.messageContentView.contentInset = UIEdgeInsetsMake (-7.0,0.0,-18.0f,0.0);
////    }
//
//
//if (CurrentlyPinnedMessageRowIndex==indexPath.row){
//    cell.backgroundColor= [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1];
//}else{
//    cell.backgroundColor=[UIColor clearColor];
//}
//BOOL didsend=[[msg objectForKey:@"MESSAGESTATUS"]boolValue ];
//
//NSString *sender = [msg objectForKey:@"USER_ID"];
//NSString *msgID;
//if ([chatType isEqualToString:@"personal"])
//msgID=[msg objectForKey:@"CHAT_PERSONAL.ID"];
//else
//msgID=[msg objectForKey:@"CHAT_GROUP.ID"];
//NSInteger pinMessage=[[msg objectForKey:@"PINNED"]boolValue ];
//NSString *message = [[msg objectForKey:@"MESSAGE_TEXT"] isEqual:[NSNull null]]?@"":[msg objectForKey:@"MESSAGE_TEXT"];
//
////    NSError *error = NULL;
////    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"//" options:NSRegularExpressionCaseInsensitive error:&error];
////    NSUInteger numberOfMatches = [regex numberOfMatchesInString:message options:0 range:NSMakeRange(0, [message length])];
////    NSLog(@"Found %i",numberOfMatches);
//
//message=[message UTFDecoded];
//message=[self RadhaCompatiableDecodingForString:message];
//message=[message stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
//
//[cell.details setHidden:YES];
//NSString *time = [msg objectForKey:@"RECEIVED_TIME"];
//time=  [time getDateTimeFromUTCTimeInterval];
//if ([time componentsSeparatedByString:@" "].count!=2){
//    time=[NSString DateTime];
//}
//
//if ([[msg objectForKey:@"MESSAGE_TYPE"] isEqual:@"text"]){
//    [cell.messageContentView setHidden:NO];
//    
//    if (message.length>250){
//        if (![expandedMessageId containsObject:msgID]){
//            message=[message substringToIndex:250];
//            [cell.bgImageView setUserInteractionEnabled:YES];
//            [cell.details setTag:[msgID integerValue]];
//            [cell.details setSelected:1 ];
//            [cell.details setHidden:NO];
//            [cell.details addTarget:self action:@selector(expandMessage:) forControlEvents:UIControlEventTouchUpInside ];
//        }else{
//            [cell.details setTag:[msgID integerValue]];
//            [cell.bgImageView setUserInteractionEnabled:YES];
//            [cell.details setHidden:NO];
//            [cell.details setSelected:0];
//            [cell.details addTarget:self action:@selector(expandMessage:) forControlEvents:UIControlEventTouchUpInside ];
//        }
//    }
//    
//    cell.messageContentView.text=message;
//}
//else
//cell.messageContentView.text = @"";
//
//CGSize  textSize = { chatBubbleWidth, 10000.0 };
//CGSize size =/*[self getSizeOfLableForText:message withfont:[UIFont fontWithName:@"HelveticaNeue" size:16] constrainedToSize:textSize];*/
//[message  sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:16] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
////NSLog(@"size wi=%f hi=%f",size.width,size.height);
//size.height+=4;
//size.width += (padding);
//
////cell.messageContentView.layer.borderWidth=3.0f;
//cell.accessoryType = UITableViewCellAccessoryNone;
////cell.userInteractionEnabled = NO;
//[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//UIImage *bgImage = nil;
//if (![sender isEqualToString:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]){ // left aligned
//    
//    
//    
//    if ([chatType isEqualToString:@"personal"]){
//        NSArray *ctHistory=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select user_name from contacts where user_id=%@",sender]];
//        receiverName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_NAME" ForRowIndex:0 givenOutput:ctHistory];
//    }else{
//        //            NSArray *notificatioData=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select user_name from contacts where user_id=%@",sender]];
//        //            receiverName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"USER_NAME" ForRowIndex:0 givenOutput:notificatioData ];
//        //            NSArray *ctHistory=[[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"select contact_name from group_members where contact_id=%@ ",sender]];
//        //            receiverName=[[DatabaseManager getSharedInstance]DatabaseRowParserRetrieveColumnFromColumnName:@"CONTACT_NAME" ForRowIndex:0 givenOutput:ctHistory] ;
//        receiverName = [msg objectForKey:@"SENDERNAME"];
//    }
//    
//    bgImage = [[UIImage imageNamed:@"gray_bubble.png"] stretchableImageWithLeftCapWidth:15  topCapHeight:15];
//    int upperTab=12;
//    if (![chatType isEqualToString:@"personal"]){
//        upperTab+=12;
//    }else
//        [cell.sender setHidden:YES ];
//    int paddValue;
//    if ( [[[self appDelegate].ver objectAtIndex:0] intValue] >= 7)
//        paddValue=padding;
//    else
//        paddValue=0;
//    //  if ( [[[self appDelegate].ver objectAtIndex:0] intValue] >= 7)
//    [cell.messageContentView setFrame:CGRectMake(paddValue, padding/2+upperTab, size.width, size.height+7)];
//    
//    [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
//                                          cell.messageContentView.frame.origin.y - padding/2,
//                                          size.width+padding,
//                                          size.height+padding-5)];
//    
//    [cell.TimeLabel setFrame:CGRectMake(paddValue,cell.bgImageView.frame.origin.y+cell.bgImageView.frame.size.height , cell.frame.size.width-10-2*padding, 13)];
//    [cell.TimeLabel setTextAlignment:NSTextAlignmentLeft];
//    
//    [cell.sender setTextAlignment:NSTextAlignmentLeft];
//    [cell.sender setText:receiverName];
//    [cell.sender setFrame:CGRectMake(paddValue, 13, cell.contentView.frame.size.width, 12)];
//    [cell.pinned setFrame:CGRectMake(cell.contentView.frame.size.width-padding,CGRectGetMidY(cell.bgImageView.frame), 20, 20)];
//    //NSLog(@"pinned %i ",[[msg objectForKey:@"PINNED"]boolValue ]);
//    [cell.pinned setHidden:!pinMessage];
//    
//    
//} else {
//    
//    bgImage = [[UIImage imageNamed:@"BlueBubble_right.png"]stretchableImageWithLeftCapWidth:15  topCapHeight:15];
//    // if ( [[[self appDelegate].ver objectAtIndex:0] intValue] >= 7)
//    [cell.messageContentView setFrame:CGRectMake(cell.contentView.frame.size.width - size.width - padding,
//                                                 padding/2+12,
//                                                 size.width,
//                                                 size.height+7)];
//    // else
//    //     [cell.messageContentView setFrame:CGRectMake(cell.contentView.frame.size.width - size.width ,                                                         padding/2+12,                                                         size.width,                                                         size.height+7)];
//    
//    [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
//                                          cell.messageContentView.frame.origin.y - padding/2,
//                                          size.width+padding,
//                                          size.height+padding-5)];
//    
//    [cell.TimeLabel setFrame:CGRectMake(padding,cell.bgImageView.frame.origin.y+cell.bgImageView.frame.size.height , cell.frame.size.width-2*padding-10, 13)];
//    [cell.TimeLabel setTextAlignment:NSTextAlignmentRight];
//    [cell.sender setTextAlignment:NSTextAlignmentRight];
//    [cell.sender setHidden:YES ];
//    [cell.sender setText:@""];
//    [cell.sender setFrame:CGRectMake(cell.contentView.frame.origin.x, 13,CGRectGetMidY(cell.bgImageView.frame), 12)];
//    [cell.pinned setFrame:CGRectMake(padding, cell.frame.size.height/2-10, 20, 20)];
//    //NSLog(@"pinned %i ",[[msg objectForKey:@"PINNED"]boolValue ]);
//    [cell.pinned setHidden:!pinMessage];
//    
//    
//}
//CGRect bgviewframe=cell.messageContentView.frame;
//[cell.details setFrame:CGRectMake(bgviewframe.size.width-20, bgviewframe.size.height-15, 20, 20)];
////cell.layer.borderWidth=1;
//[cell.messageContentView setCenter: cell.bgImageView.center];
////  cell.messageContentView.layer.borderWidth=5;
//if ([[msg objectForKey:@"MESSAGE_TYPE"] isEqual:@"image"]){
//    if (![sender isEqualToString:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]) {
//        [cell.bgImageView setFrame:CGRectMake(cell.bgImageView.frame.origin.x,24,                                           180,                                           160)];
//        [cell.TimeLabel setTextAlignment:NSTextAlignmentLeft];
//    }else{
//        [cell.bgImageView setFrame:CGRectMake(cell.contentView.frame.size.width - 180 - padding/2,
//                                              12,
//                                              180,
//                                              160)];
//        [cell.TimeLabel setTextAlignment:NSTextAlignmentRight];
//        
//    }
//    //  [cell.pinned setCenter:CGPointMake(cell.pinned.frame.origin.x,CGRectGetMidY(cell.bgImageView.frame))];
//    // [cell.messageContentView setHidden:YES];
//    [cell.TimeLabel setFrame:CGRectMake(padding,cell.bgImageView.frame.origin.y+cell.bgImageView.frame.size.height , cell.frame.size.width-10-2*padding, 13)];
//    UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 160, 140)];
//    
//    NSFileManager *filemgr = [NSFileManager defaultManager];
//    NSString *Filepath=[self CachesPath:[msg objectForKey:@"MESSAGE_FILENAME"]];
//    if ([filemgr fileExistsAtPath: Filepath ] == YES)
//    {
//        [image setImage:[UIImage imageWithContentsOfFile:Filepath]];
//        [image setUserInteractionEnabled:YES];
//    }else{
//        [image setUserInteractionEnabled:NO];
//        ai=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(65, 55, 30, 30)];
//        // [ai setCenter:image.center];
//        [ai startAnimating];
//        [image addSubview:ai];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/chat_files/%@",gupappUrl,[msg objectForKey:@"MESSAGE_FILENAME"]]]];
//            
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [ai stopAnimating];
//                [ai removeFromSuperview];
//                [image setImage:[UIImage imageWithData:imgData]] ;
//                [imgData writeToFile:Filepath atomically:YES];
//                [image setUserInteractionEnabled:YES];
//            });
//            
//        });
//        
//        //http://198.154.98.11/Gup_demo/scripts/media/images/chat_files/
//    }
//    image.tag=indexPath.row;
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
//    [image addGestureRecognizer:singleTap];
//    // [image setMultipleTouchEnabled:YES];
//    //[image setUserInteractionEnabled:YES];
//    [cell.bgImageView setUserInteractionEnabled:YES];
//    // [image setImage:[msg objectForKey:@"MESSAGE_FILENAME"]];
//    [cell.bgImageView addSubview:image];
//}
//if ([[msg objectForKey:@"MESSAGE_TYPE"] isEqual:@"audio"]){
//    UIButton *play=[[UIButton alloc]initWithFrame:CGRectMake(10,10 ,34, 34)];
//    CGRect playFrame=play.frame;
//    if (![sender isEqualToString:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]) {
//        [cell.bgImageView setFrame:CGRectMake(cell.bgImageView.frame.origin.x,24,54,54)];
//        [cell.TimeLabel setTextAlignment:NSTextAlignmentLeft];
//        playFrame.origin.x+=2.5;
//        
//    }else{
//        [cell.bgImageView setFrame:CGRectMake(cell.contentView.frame.size.width - 54 - padding/2  ,
//                                              12,
//                                              54,
//                                              54)];
//        [cell.TimeLabel setTextAlignment:NSTextAlignmentRight];
//        playFrame.origin.x-=2.5;
//        
//    }
//    [play setFrame:playFrame];
//    //   [cell.pinned setCenter:CGPointMake(cell.pinned.frame.origin.x,CGRectGetMidY(cell.bgImageView.frame))];
//    [cell.messageContentView setHidden:YES];
//    [cell.TimeLabel setFrame:CGRectMake(padding,cell.bgImageView.frame.origin.y+cell.bgImageView.frame.size.height , cell.frame.size.width-10-2*padding, 13)];
//    [cell.bgImageView setUserInteractionEnabled:YES ];
//    // NSString *audiopath=[self documentsPath:[msg objectForKey:@"MESSAGE_FILENAME"]];
//    
//    [play setBackgroundColor:[UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0]];
//    [play setTag:indexPath.row];
//    play.layer.cornerRadius=5;
//    [play.imageView setFrame:CGRectMake(20, 0, 30, 30)];
//    [play setImage:[UIImage imageNamed:@"9_av_play.png" ] forState:UIControlStateNormal];
//    [play setImage:[UIImage imageNamed:@"9_av_pause.png"] forState:UIControlStateSelected];
//    if(playingAudio){
//        if (currentlyPlayedAudio==indexPath.row){
//            [play setSelected:1];
//            CGRect bgimageViewframe=cell.bgImageView.frame;
//            bgimageViewframe.size.width+=126;
//            if(cell.bgImageView.center.x>cell.contentView.frame.size.width/2)
//                bgimageViewframe.origin.x-=126;
//            [cell.bgImageView setFrame:bgimageViewframe];
//            
//        }
//    }
//    else
//        [play setSelected:0];
//    //play.imageView.layer.borderWidth=5;
//    
//    [play addTarget:self action:@selector(playAudio:)  forControlEvents:UIControlEventTouchUpInside];
//    [cell.bgImageView addSubview:play];
//    //UIButton *pause=[[UIButton alloc]initWithFrame:CGRectMake(10,10 ,50, 50)];
//    // [pause setBackgroundColor:[UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0]];
//    //  [pause setTag:indexPath.row];
//    //  pause.layer.cornerRadius=5;
//    //  [pause.imageView setFrame:CGRectMake(20, 0, 30, 30)];
//    // [pause setImage:[UIImage imageNamed:@"9_av_pause.png"] forState:UIControlStateNormal];
//    
//    // [pause addTarget:self action:@selector(pauseAudio:)  forControlEvents:UIControlEventTouchUpInside];
//    //  [cell.bgImageView addSubview:pause];
//    /* if (playerstatus==nil)
//     {playerstatus =[[UISlider alloc]initWithFrame:CGRectMake(30,26,160 , 34)];
//     
//     }
//     [playerstatus setMinimumValue:0];
//     [playerstatus setMaximumValue:1];
//     // [playerstatus setValue:0.5];
//     [playerstatus setTintColor:[UIColor blueColor]];
//     [playerstatus addTarget:self action:@selector(slideDidChange:) forControlEvents:UIControlEventValueChanged];
//     
//     [uploadprogress setProgressViewStyle:UIProgressViewStyleBar];
//     [cell.bgImageView addSubview:playerstatus];
//     
//     
//     [playerstatus setHidden:YES];
//     */
//    if(playingAudio)
//        if(playerstatus.tag==indexPath.row){
//            [cell.bgImageView addSubview:audioPlayersAudioDuration];
//            [cell.bgImageView addSubview:audioPlayersCurrentTime];
//            [cell.bgImageView addSubview:playerstatus];
//        }
//}
//if ([[msg objectForKey:@"MESSAGE_TYPE"] isEqual:@"vcard"]){
//    
//    UILabel *username=[[UILabel alloc]initWithFrame:CGRectMake(54, 10, 115, 34)];
//    [username setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
//    username.numberOfLines=2;
//    [username setTextAlignment:NSTextAlignmentCenter];
//    [username setBackgroundColor:[UIColor clearColor]];
//    [username setText:[self getusernameforBody:[msg objectForKey:@"MESSAGE_TEXT"]]];//[[[[msg objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ] objectAtIndex:5]stringByReplacingOccurrencesOfString:@"''" withString:@"'"]];
//    
//    [username sizeToFit];
//    
//    // username.layer.borderWidth=0.5;
//    [cell.bgImageView addSubview:username];
//    //NSLog(@"widthj %f \n wi %f",username.frame.size.width,54+username.frame.size.width+10);
//    if (![sender isEqualToString:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]) {
//        [cell.bgImageView setFrame:CGRectMake(cell.bgImageView.frame.origin.x,24,54+username.frame.size.width+10,54)];
//        [cell.TimeLabel setTextAlignment:NSTextAlignmentLeft];
//    }else{
//        [cell.bgImageView setFrame:CGRectMake(cell.contentView.frame.size.width - (54+username.frame.size.width+10) - padding/2,
//                                              12,
//                                              54+username.frame.size.width+10,
//                                              54)];
//        [cell.TimeLabel setTextAlignment:NSTextAlignmentRight];
//        
//    }
//    CGPoint centerpoint=username.center;
//    centerpoint.y=cell.bgImageView.frame.size.height/2;
//    centerpoint.x-=5;
//    [username setCenter:centerpoint];
//    //  [cell.pinned setCenter:CGPointMake(cell.pinned.frame.origin.x,CGRectGetMidY(cell.bgImageView.frame))];
//    [cell.messageContentView setHidden:YES];
//    [cell.TimeLabel setFrame:CGRectMake(padding,cell.bgImageView.frame.origin.y+cell.bgImageView.frame.size.height , cell.frame.size.width-10-2*padding, 13)];
//    [cell.bgImageView setUserInteractionEnabled:YES ];
//    
//    // NSString *audiopath=[self documentsPath:[msg objectForKey:@"MESSAGE_FILENAME"]];
//    UIButton *vcardBut=[[UIButton alloc]initWithFrame:CGRectMake(10,10,34, 34)];
//    
//    [vcardBut setBackgroundColor:[UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:250.0/255.0 alpha:1.0]];
//    [vcardBut setTag:indexPath.row];
//    vcardBut.layer.cornerRadius=5;
//    NSFileManager *filemgr = [NSFileManager defaultManager];
//    NSString *Filepath;
//    @try { Filepath=[self CachesPath:[[[msg objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ] objectAtIndex:2]];
//    }
//    @catch (NSException *exception) {
//        Filepath=@"";
//    }
//    
//    if ([filemgr fileExistsAtPath: Filepath ] == YES)
//    {//NSLog(@"its there");
//        
//        //[image setImage:[UIImage imageWithContentsOfFile:Filepath]];
//        [vcardBut setImage:[UIImage imageWithContentsOfFile:Filepath] forState:UIControlStateNormal];
//    }else{
//        [vcardBut setImage:[UIImage imageNamed:@"contact@2x.png"] forState:UIControlStateNormal];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSString *filename;
//            @try { filename=[[[msg objectForKey:@"MESSAGE_TEXT"] componentsSeparatedByString:@":"] objectAtIndex:2];
//            }
//            @catch (NSException *exception) {
//                filename=@"";
//            }
//            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/profile_pics/%@",gupappUrl,filename]]];
//            
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [ai stopAnimating];
//                [ai removeFromSuperview];
//                //NSLog(@"data %@",imgData);
//                [vcardBut setImage:[UIImage imageWithData:imgData] forState:UIControlStateNormal];
//                
//                // [image setImage:[UIImage imageWithData:imgData]] ;
//                [imgData writeToFile:Filepath atomically:YES];
//            });
//            
//        });
//        
//        
//    }
//    
//    
//    [vcardBut addTarget:self action:@selector(vcardClicked:)  forControlEvents:UIControlEventTouchUpInside];
//    [cell.bgImageView addSubview:vcardBut];
//    // //NSLog(@"username %@",[[[msg objectForKey:@"MESSAGE_TEXT"]componentsSeparatedByString:@":" ] objectAtIndex:5]);
//    
//}
//
//cell.bgImageView.image = bgImage;
///* NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
// [dateFormatter setDateFormat:@"HH:mm"];
// NSDate *dt=[dateFormatter dateFromString:time ];
// //NSLog(@"dt %@ ",dt);
// 
// //NSLog(@"date %@\n date obj %@",[NSDate date].description,[NSDate date]);
// NSDateFormatter *format = [[NSDateFormatter alloc] init];
// [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
// NSDate *now = [[NSDate alloc] init];
// 
// NSString *dateString = [format stringFromDate:now];
// //NSLog(@"date %@",dateString);
// NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
// 
// [inFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
// 
// NSDate *parsed = [inFormat dateFromString:dateString];
// //NSLog(@"date %@\n|time{%@}|",[inFormat stringFromDate:parsed],time);
// */
//[cell.pinned setCenter:CGPointMake(cell.pinned.frame.origin.x,CGRectGetMidY(cell.bgImageView.frame))];
////NSLog(@"time %@ \n %@",time,[NSString stringWithFormat:@"%02d:%02d", (int)((int)(player.duration)) / 60, (int)((int)(player.duration)) % 60]);
//
//NSArray *dateTime=[time componentsSeparatedByString:@" "];
////NSLog(@"date %@",dateTime);
//NSArray *dateComponents=[[dateTime objectAtIndex:0] componentsSeparatedByString:@"-"];
////NSLog(@"date %@",dateComponents);
//
//NSString *dateValue=@"";
//
//dateValue=[dateValue stringByAppendingString:[dateComponents objectAtIndex:2]];
//dateValue=[dateValue stringByAppendingString:[NSString stringWithFormat:@"-%@",[month objectAtIndex:[[dateComponents objectAtIndex:1] integerValue]-1]]];
//if (![[dateComponents objectAtIndex:0]isEqual:[NSString CurrentYear]])
//{
//    dateValue=[dateValue stringByAppendingString:[NSString stringWithFormat:@"-%@",[dateComponents objectAtIndex:0]]];
//}
//
//
//[self getPreviousTimeStampAtIndex:indexPath.row-1];
////NSLog(@"prev y=%@ m=%@ d=%@ \n cur y=%@ m=%@ d=%@",prevDay,prevMonth,prevYear ,[dateComponents objectAtIndex:2] ,[dateComponents objectAtIndex:1],[dateComponents objectAtIndex:0]);
//if (![prevDay isEqual:[dateComponents objectAtIndex:2]]||![prevMonth isEqual:[dateComponents objectAtIndex:1]]||![prevYear isEqual:[dateComponents objectAtIndex:0]] ) {
//    [cell.date setHidden:NO];
//}
//else
//{[cell.date setHidden:YES];
//    
//}
//
//
//NSString *timeValue=[dateTime objectAtIndex:1];
////NSLog(@"time val %@",dateValue);
//[cell.date setCenter:CGPointMake(cell.contentView.frame.size.width/2,6.5)];
//[cell.date setText:dateValue];
//
//
//
//cell.TimeLabel.text =  [timeValue substringToIndex:5];
//// cell.messageContentView.userInteractionEnabled=NO;
////    if(![msg[@"READ"] boolValue])
////    { if([chatType isEqual:@"group"])
////        [ [DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_group set read=1 where id=%@",msg[@"CHAT_GROUP.ID"]]];
////    else
////        [ [DatabaseManager getSharedInstance]executeQueryWithQuery:[NSString stringWithFormat:@"update chat_personal set read=1 where id=%@",msg[@"CHAT_PERSONAL.ID"]]];
////    }
//if (![sender isEqualToString:[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]) {
//    [cell.status setHidden:YES];
//    [cell.status setFrame:CGRectMake(/*CGRectGetMaxX(cell.bgImageView.frame)*/55,/*CGRectGetMidY(cell.bgImageView.frame)-5*/cell.TimeLabel.frame.origin.y+1.5, 10, 10)];
//    
//    // [cell.status setImage:[UIImage imageNamed:didsend?@"ic_delivered":@"ic_pending"]];
//}
//else
//{
//    [cell.status setHidden:NO];
//    [cell.status setFrame:CGRectMake(CGRectGetMaxX(cell.TimeLabel.frame)+5,/* CGRectGetMidY(cell.bgImageView.frame)-5*/cell.TimeLabel.frame.origin.y+1.5, 10, 10)];
//    if (didsend)
//    {
//        [cell.status setImage:[UIImage imageNamed:@"ic_delivered"]];
//    }
//    else{
//        
//        [cell.status setImage:[UIImage imageNamed:@"ic_pending"]];
//        double    CURRENTtimestamp = [[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate] doubleValue];
//        double MSGtimestamp= [[msg objectForKey:@"TIME_STAMP"] doubleValue];
//        if ((CURRENTtimestamp- MSGtimestamp)<5000)
//        {[cell.status setImage:[UIImage imageNamed:@"ic_clock"]];
//        }
//        
//    }
//    
//    
//}
//// cell.TimeLabel.layer.borderWidth=1;
////cell.status.layer.borderWidth=1;
////cell.messageContentView.text=@"http://198.154.98.11:9090";
//cell.messageContentView.dataDetectorTypes = UIDataDetectorTypeAll;
//
////    if ([cell.messageContentView respondsToSelector:@selector(setSelectable:)])
////        [cell.messageContentView  setSelectable:YES];
////cell.messageContentView.delegate = self;
////    cell.messageContentView.editable = NO;
//if([[[self appDelegate].ver objectAtIndex:0]integerValue ]>=7)
//{
//    [cell.messageContentView setTintColor:[UIColor blueColor]];
//}
//UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressw:)];
//[recognizer setDelegate:self];
//[cell.messageContentView addGestureRecognizer:recognizer];
//UILongPressGestureRecognizer *recognizer1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressw:)];
//[recognizer1 setDelegate:self];
//[cell addGestureRecognizer:recognizer1];
//return cell;
//}
@end
