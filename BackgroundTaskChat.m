//
//  BackgroundTaskChat.m
//  GUP
//
//  Created by Deepesh_Genora on 5/22/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import "BackgroundTaskChat.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "JSON.h"
@implementation BackgroundTaskChat
@synthesize chatType,chatWithUserID;
- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(void)retreiveHistory
{NSString *timestamp;
   
    timestamp=[NSString getCurrentUTCFormateDate];
        timestamp=[timestamp getTimeIntervalFromUTCStringDate];
    
    NSLog(@"time interval %@",timestamp);
    NSLog(@"date time %@",[timestamp getDateTimeFromTimeInterval]);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *postData = [NSString stringWithFormat:@"time_stamp=%@&",timestamp];
        if ([chatType isEqual:@"personal"])
        {  NSLog(@"my id %@",[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]);
            postData=  [postData stringByAppendingString:[NSString stringWithFormat:@"to_id=%@&from_id=%@",chatWithUserID ,[[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID]]];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/recover_contact_chat.php",gupappUrl]]];
        }
        else
        {
            postData=   [postData stringByAppendingString:[NSString stringWithFormat:@"group_id=%@",chatWithUserID]];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/recover_group_chat.php",gupappUrl]]];
            
        }
        
        NSLog(@"posta data %@",postData);
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
        fetchHistory = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [fetchHistory scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [fetchHistory start];
        historyResponse = [[NSMutableData alloc] init];
        
        
    
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    
    
   
    if (connection==fetchHistory)
    {
        NSLog(@"2");
        [historyResponse setLength:0];
        
    }
   
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
         if (connection ==fetchHistory) {
        [historyResponse appendData:data];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (connection==fetchHistory)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[error localizedDescription]   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
  }

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
        if(connection==fetchHistory)
    {  NSLog(@"====EVENTS");
        
        NSString *str = [[NSMutableString alloc] initWithData:historyResponse encoding:NSASCIIStringEncoding];
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSLog(@"====EVENTS==3 result %@",res);
        NSDictionary *responce= res[@"response"];
        NSLog(@"====EVENTS==4 result %@",responce);
        if ([responce[@"status"] boolValue])
        {
            NSArray *history=[responce objectForKey:@"data"];
            NSLog(@"hist %@",history);
            NSString *MYUSERID =  [[[NSUserDefaults standardUserDefaults] stringForKey:@"Jid"] userID];
            NSLog(@"MY USER  %@",MYUSERID);
            
            for (int i=0; i<[history count]; i++)
            {
                NSString *message=[history objectAtIndex:i];
                if (message !=nil)
                {
                    NSString *gupMessage=message;//[message stringBetweenString:@"(gup xmlns=\"urn:xmpp:gupmessage\")" andString:@"(/gup)"];
                    NSLog(@"gup message %@",gupMessage);
                    NSString *BODY=[gupMessage stringBetweenString:@"(body)" andString:@"(/body)"];
                    NSLog(@"BODY %@",BODY);
                    
                    
                    NSString *FROMUSERID,*TIMEVALUE,*MESSAGEKIND,*GROUPID,*SENDERSUSERID,*RECEIVERSUSERID;
                    NSString *ISGROUP=[gupMessage stringBetweenString:@"(isgroup)" andString:@"(/isgroup)"];
                    FROMUSERID=[gupMessage stringBetweenString:@"(from_user_id)" andString:@"(/from_user_id)"];
                    NSLog(@"FROM USER ID %@",FROMUSERID);
                    TIMEVALUE=[gupMessage stringBetweenString:@"(TimeStamp)" andString:@"(/TimeStamp)"];
                    MESSAGEKIND=[gupMessage stringBetweenString:@"(message_type)" andString:@"(/message_type)"];
                    
                    //  TIMEVALUE=[TIMEVALUE getDateTimeFromTimeInterval];
                    
                    if ([ISGROUP isEqual:@"1"])
                    {
                        
                        GROUPID=[gupMessage stringBetweenString:@"(groupID)" andString:@"(/groupID)"];
                        NSString *messageid= [[self appDelegate]PutMessageInStorage:BODY ofMessageType:MESSAGEKIND];
                        NSMutableDictionary *ComposedMessaage=[[NSMutableDictionary alloc]init];
                        [ComposedMessaage setValue:FROMUSERID forKey:@"sendersUserID"];
                        // [ComposedMessaage setValue:MYUSERID forKey:@"receiveruserID"];
                        [ComposedMessaage setValue:TIMEVALUE forKey:@"timestamp"];
                        [ComposedMessaage setValue:GROUPID  forKey:@"groupID"];
                        [ComposedMessaage setValue:messageid forKey:@"messageid"];
                        [ComposedMessaage setValue:@"1" forKey:@"messageStatus"];
                        
                        [[self appDelegate]PutLinkOfMessageInStorageForType:@"group" withMessageData:ComposedMessaage];
                    }
                    else
                    {
                        SENDERSUSERID=[FROMUSERID isEqual:MYUSERID ]?MYUSERID:chatWithUserID;
                        RECEIVERSUSERID=[FROMUSERID isEqual:MYUSERID ]?chatWithUserID :MYUSERID;
                        NSLog(@"SEN %@ ,REC =%@",SENDERSUSERID,RECEIVERSUSERID);
                        NSString *messageid= [[self appDelegate]PutMessageInStorage:BODY ofMessageType:MESSAGEKIND];
                        NSMutableDictionary *ComposedMessaage=[[NSMutableDictionary alloc]init];
                        [ComposedMessaage setValue:SENDERSUSERID forKey:@"sendersUserID"];
                        [ComposedMessaage setValue:RECEIVERSUSERID forKey:@"receiveruserID"];
                        //   [ComposedMessaage setValue:GROUPID  forKey:@"groupID"];
                        [ComposedMessaage setValue:TIMEVALUE forKey:@"timestamp"];
                        [ComposedMessaage setValue:messageid forKey:@"messageid"];
                        [ComposedMessaage setValue:@"1" forKey:@"messageStatus"];
                        
                        [[self appDelegate]PutLinkOfMessageInStorageForType:@"personal" withMessageData:ComposedMessaage];
                        
                        
                    }
                    
                }
                
            }
            
            
        }
        else
        { NSArray *history=[responce objectForKey:@"data"];
            NSLog(@"hist %@",history);
            
            if ([history count]==0)
            {
            }            }
            NSLog(@"Try again");
        }
        
    
    
   
}

@end
