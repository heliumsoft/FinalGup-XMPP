//
//  AppDelegate.h
//  GUPver 1.0
//
//  Created by genora o-n1 10/28/13.
//  Copyright (c) 2013 genora. All rights reserved.
//
//198.154.98.11
//85.159.208.146
#import <UIKit/UIKit.h>
#import "XMPPAutoPing.h"
#import "Login.h"
#import "NSString+Utils.h"
#import "Reachability.h"
#import "JSON.h"
#import "XMPPFramework.h"
#import <CoreData/CoreData.h>
#import "SMChatDelegate.h"
#import "SMMessageDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
static const NSString *jabberUrl = @"vps.gigapros.com"/*@"127.0.0.1"*/;
static const NSString *gupappUrl = @"http://198.154.98.11/~gup/Gup_demo";
//static const NSString *gupappUrl = @"http://85.159.208.146/Gup_demo";
//static const NSString *groupJabberUrl = @"gup.vps.gigapros.com";
static const NSString *groupJabberUrl = @"gup.vps.gigapros.com";

//static const NSString *gupHostName = @"85.159.208.146";
static const NSString *gupHostName = @"198.154.98.11";

@protocol chatTableUpdate <NSObject>

-(void)reloadTable:(NSString*)group_id;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,XMPPRosterDelegate,XMPPStreamDelegate,UIAlertViewDelegate,XMPPPingDelegate,XMPPAutoTimeDelegate,XMPPReconnectDelegate,XMPPMUCDelegate,XMPPRoomDelegate>
{
    

    //Project SHAN4552
     XMPPPing *xmppping;
     XMPPStream *xmppStream;
     XMPPReconnect *xmppReconnect;
     XMPPRoster *xmppRoster;
     XMPPRosterCoreDataStorage *xmppRosterStorage;
     XMPPvCardCoreDataStorage *xmppvCardStorage;
     XMPPvCardTempModule *xmppvCardTempModule;
     XMPPvCardAvatarModule *xmppvCardAvatarModule;
     XMPPCapabilities *xmppCapabilities;
     XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
     XMPPAutoPing *xmppAutoPing;
    UIImageView *imgTab,*imghome,*imgContact,*imgtTW,*imgShare,*imgSettings;
//    XMPPRoom *xmppRoom;
//    XMPPRoomCoreDataStorage *roomMemoryStorage;
     NSString *password,*username,*Rpassword,*emailid,*name,*accountType,*DeviceToken,*MyUserImg;
    
     BOOL allowSelfSignedCertificates;
     BOOL allowSSLHostNameMismatch;
     NSArray *ver;
     BOOL isXmppConnected;
     BOOL isThisRegistration;
     NSURLConnection *contactDetailConn,*loginDetailsConn,*groupInfoConn,*updateUser,*getdeviceToken,*getUTCtime;
     NSMutableData *contactDetailResponse,*loginDetails,*groupInfoResponse,*updateResponce,*getDeviceTokenResponc,*getUTCtimeResponce;
     NSTimer *triggerer;
     UIApplication *app;
    // __block UIBackgroundTaskIdentifier bgTask;
     UIBackgroundTaskIdentifier _bgTask;
     NSInteger timeInBACKGROUND;
     double previousTimeDifferance;
   
     XMPPAutoTime *xmppAutoTime;
     BOOL isnetFluctuating;
    
//project SHAN4552 end's
}
//project SHAN4552
- (void) CurrentDate;
//-(void)get_UTC_Time;
-(void)removeFriendWithJid:(NSString*)jid;
-(BOOL)connect;
-(void)disconnect;
-(void)addFriendWithJid:(NSString*)jid nickName:(NSString*)nickName;

-(BOOL)registrationWithUserName:(NSString*)usernameR password:(NSString*)passwordR name:(NSString*)nameR emailid:(NSString*)emailIdR;
@property(strong,nonatomic)Reachability* reachability,*gupappReachability,*localWifiReachability,*ipReachability;
@property(nonatomic,strong) UILocalNotification *localNotification;
@property(nonatomic,strong) id <chatTableUpdate> chatTableUpdate;
@property(assign,nonatomic) BOOL backgroundFlag;
@property(assign,nonatomic) int chatUserId;

@property (nonatomic, strong, readonly) NSArray *ver;
@property(nonatomic,strong) NSString *groupCounter,*MyUserName;
@property (nonatomic, strong) NSMutableArray *ArrayUsersIDs;
@property(nonatomic,strong)XMPPPing *xmppping;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) XMPPAutoPing *xmppAutoPing;
@property BOOL listFlag;
@property(strong,nonatomic)    NSString *userStatus,*user_name;
@property (strong,nonatomic)NSString *currentUser,*myUserID,*myjid;
@property(strong,nonatomic)NSError *gpError;
- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

@property(strong,nonatomic) UINavigationController *rootviewController;


@property (nonatomic, assign) id  _chatDelegate;
@property (nonatomic, strong) id  _messageDelegate;

//project SHAN4552 end's
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property(strong,nonatomic) Login *rootViewControllerL;

@property(strong,nonatomic) UIViewController *viewController1;
@property (strong, nonatomic) FBSession *session;
@property ( nonatomic, readwrite) BOOL isUSER;
@property (nonatomic, assign) BOOL hasInet;
-(void)setTabBar;
-(void)setLoginView;
- (void)goOnline;
- (void)goOffline;
-(void)updateProfile;

-(void)goAway;
-(void)setXmpp;
-(void)pushLoginScreen;
-(void)sendMessageWithMessageData:(NSDictionary*)messageData;
-(void)groupUpdate:(NSString*)groupId;
//-(BOOL)checkNetworkConnection;
-(void)clearChatHistoryForGroup:(NSString*)selectedGroup;
-(void)composeMessageWithAttributes:(NSDictionary*)attr andElements:(NSDictionary*)element body:(NSString*)bodystr;
-(NSString*)PutMessageInStorage:(NSString*)message ofMessageType:(NSString*)type;
-(BOOL)PutLinkOfMessageInStorageForType:(NSString*)form withMessageData:(NSDictionary*)messageComponents;

-(NSString*)CheckIfMessageExist:(NSString*)message ofMessageType:(NSString*)type;
-(BOOL)CheckIfMessageIsDuplicateFrom:(NSString*)sender ofMessageTime:(NSString*)timestamp isGroupMsg:(BOOL)isGroup
;
#pragma chat service
-(void)sendAcknoledgmentPacketId:(NSString*)messageId isGroupAcknoledgment:(BOOL)grpAck;
-(void)storeMessageInDatabaseForBody:(NSString*)body forMessageType:(NSString*)msgType messageTo:(NSString*)to groupId:(NSString*)groupID isGroup:(BOOL)isGroup forTimeInterval:(NSString*)timeInMiliseconds senderName:(NSString*)Sname postid:(NSString*)idpost isRead:(NSString*)read  withImage:(NSString*)senderimage;
-(NSString*)getLinkedIdOfMessageID:(NSString*)messageID forTimestamp:(NSString*)timestamp senderID:(NSString*)senderID recieversID:(NSString*)recieversid chattype:(NSString*)chatType;

@end
