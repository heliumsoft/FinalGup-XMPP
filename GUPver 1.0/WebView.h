//
//  WebView.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 1/17/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface WebView : UIViewController<UIWebViewDelegate,MBProgressHUDDelegate>
{
    IBOutlet UIWebView *webView;
    MBProgressHUD *HUD;
}
@property (nonatomic, retain) NSString  *fromView;
@end
