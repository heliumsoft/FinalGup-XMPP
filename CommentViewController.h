//
//  ChatScreen.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 10/29/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TURNSocket.h"
#import "ImageViewerGup.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "SMMessageDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "JSON.h"



@interface CommentViewController : UIViewController<UITextViewDelegate,UITabBarDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,SMMessageDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate,TURNSocketDelegate,UIScrollViewDelegate,imageViewDataSource,imageViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate,chatTableUpdate>{
    
    IBOutlet UIScrollView *mainScroll;
    IBOutlet UIButton *sendButton;
    IBOutlet UITableView *chatTable;
    IBOutlet UIView *accessoryView;
    IBOutlet UITabBar *accessoryTab;
    IBOutlet UILabel *date;
    NSString *myImage;
    IBOutlet UITextView *messageField;
    CGRect TXFRAME;
    int currentlyPlayedAudio;
    NSString *val;
    bool playingAudio,viewAllPinnedMessage,MenuControllerForTextViw;
    UIButton *cancelButton;
    NSArray *getData;
    IBOutlet UITabBarItem *record,*gallery,*camera,*vcard;
    NSIndexPath* indexPath1;
    UIView *loaderView;
    
    UIRefreshControl *pullRfrs;
    BOOL isMoreAvailable;
    
    UITextView *textView;
    
    UIButton *cameraButton;
    UIButton *galleryButton;
    UIButton *recordingButton;
    UIButton *contactButton;
    UIView *menuView;
    UIView *submenuView;
    UIImageView *userIcon;
    
    UIView *vc;
    UIButton *recorderButton;
    UILabel *titleLabel;
    //    UIView *navigationTitleView;
    UIView *frezzer;
    NSMutableArray *expandedMessageId;
    
    double differ;
    //4552chat demo
    // NSMutableArray *ChatMessages;
    NSString		*chatWithUser,*prevMonth,*prevYear,*prevDay;
    //	NSMutableArray	*messages;
    NSMutableArray *turnSockets;
    
    NSMutableArray *pinnedMessge;
    int CurrentlyPinnedMessage;
    NSUInteger  CurrentlyPinnedMessageRowIndex;
    //audio
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSTimer *timer,*audioLenght;
    NSInteger timerInseconds,milliseconds;
    UIView *freezer;
    UIView *progressViewBackground;
    NSURLConnection *uploadFile,*reportSpam/*,*downloadFile*/,*fetchHistory ,*fetchRefresh;
    NSMutableData *uploadFileResponce,*reportSpamResponce/*,*downloadFileResponce*/,*historyResponse,*refreshResponse;
    IBOutlet UIProgressView *uploadprogress;UISlider *playerstatus;UILabel *audioPlayersCurrentTime,*audioPlayersAudioDuration;
    UIImageView *imageViewForStatus;
    UILabel *uploadlable;
    NSData *fileToBeUploaded;
    NSString *fileToBeDownloaded;
    UIActivityIndicatorView *ai;
    NSString *myName,*receiverName,*chatWallpaper;
    id pr;
    NSString *messageIndex,*messageSelected,*messageToBeCopied,*messageType,*messageSentBy;
    NSInteger messageIdDeleted,referencedMessageIdDeleted;
    NSMutableArray *membersID;
    UILabel *contactNameLabel;
    UIButton *button;
    UIMenuController *menu ;
    MBProgressHUD *HUD;
    CGFloat chatBubbleWidth;
    NSString *myUserId;
    NSTimer *updater;
    NSString *name;
    NSArray *master_table;
    NSString *chatMessageType;
    NSArray *unreadMessage;
    __weak IBOutlet UIActivityIndicatorView *indecater;
    __weak IBOutlet UILabel *waitLbl;
    
    NSString *GroupId;
    
}

@property (weak, nonatomic) IBOutlet UIView *tabBarView;
-(void)freezerRemove;
-(void)freezerAnimate;
-(IBAction)playAudio:(id)sender;
-(IBAction)pauseAudio:(id)sender;
@property(strong,nonatomic)NSString *timeInMiliseconds;
@property(strong,nonatomic)NSString *from,*toJid,*postId;
@property(nonatomic,strong)NSString *vcardUserId;
@property (nonatomic, retain) NSString  *chatType;
@property(strong,nonatomic)NSString *groupType;
@property(strong,nonatomic) NSMutableArray *expandedMessageId;
@property(strong,nonatomic)NSString *chatTitle,*chatStatus;
@property(strong,nonatomic) UILabel *audioPlayersCurrentTime,*audioPlayersAudioDuration;
@property BOOL playingAudio;
@property int currentlyPlayedAudio;

//-(IBAction)viewGroupInfo:(id)sender;
-(IBAction)showAccessoryView:(id)sender;
-(void)sendRecordedClip:(id)sender;
-(void)cancelRecording:(id)sender;
-(void)holdToRecord:(id)sender;

//4552chat demo
@property (nonatomic,strong) NSArray *chatHistory,*month;
@property (nonatomic,retain) IBOutlet UITextView *messageField;
@property (nonatomic,retain) NSString *chatWithUser;
@property (nonatomic,retain) IBOutlet UITableView *chatTable;
@property (retain, nonatomic) IBOutlet UIView *indecaterView;

//-(void)initWithUser:(NSString*) userjid;
-(IBAction)sendMessage;
-(void)getMembersList;
-(void)sendVcardforUserID:(NSString*)userid user_email:(NSString*)user_email userName:(NSString*)user_name user_pic:(NSString*)user_pic user_status:(NSString*)user_status user_location:(NSString*)user_location;

-(IBAction)vcardClicked:(id)sender;
-(void)longPressw:(UILongPressGestureRecognizer *)recognizer;
-(void)sendMessageWithReceiversJid:(NSString*)jid message:(NSString*)messageBody type:(NSString*)messageTypes groupId:(NSString*)groupID;
//-(IBAction)retreiveHistory:(UIButton*)sender;
-(void)copyMessage:(id)sender;
-(void)deleteMessage:(id)sender;
-(void)forward:(id)sender;
-(void)reportSpam:(id)sender;
-(void)UpdateScreen;
-(void)scrollDown;
-(BOOL)checkForDate:(NSIndexPath*)indexPath timeinMilisecend:(NSString*)secends;
@end
