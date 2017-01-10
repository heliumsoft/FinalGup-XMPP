//
//  SMChatDelegate.h
//  jabberClient
//
//  Created by cesarerocchi on 7/16/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SMChatDelegate


- (void)buddyStatusUpdated;
- (void)buddyWentOffline:(NSString *)buddyName;
- (void)didDisconnect;
-(void)newContactMessageRe;
-(void)newGroupMessageRe;

@end
