//
//  BackgroundTaskChat.h
//  GUP
//
//  Created by Deepesh_Genora on 5/22/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundTaskChat : NSObject
{
    NSURLConnection *fetchHistory;
    NSMutableData *historyResponse;
}
@property(strong,nonatomic)NSString *chatType,*chatWithUserID;
-(void)retreiveHistory;
@end
