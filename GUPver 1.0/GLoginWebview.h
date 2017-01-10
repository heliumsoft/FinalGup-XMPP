//
//  GLoginWebview.h
//  socialLogin
//
//  Created by Deepesh_Genora on 5/8/14.
//  Copyright (c) 2014 Deepesh_Genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface GLoginWebview : UIViewController<UIWebViewDelegate,MBProgressHUDDelegate>
{    IBOutlet UIWebView *webview;
    NSMutableData *receivedData,*userData;
    NSURLConnection *getUserData,*theConnection;
     MBProgressHUD *HUD;
    NSString *user_id;
}
@property(nonatomic,strong)id Caller;
@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) NSString *isLogin;
@property (assign, nonatomic) Boolean isReader;
@end
