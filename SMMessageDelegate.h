//
//  SMMessageDelegate.h
//  jabberClient
//
//  Created by cesarerocchi on 8/2/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SMMessageDelegate

- (void)newMessageReceived;
-(void)updateTitleStatus;
-(void)getMembersList;
-(void)freezerRemove;
-(void)freezerAnimate;
-(void)UpdateScreen;
-(void)postUpdate:(NSString*)postid messageID:(NSString*)msgid groupID:(NSString*)group;
//-(void)reloadPost;
-(void)scrollDown;

@end
