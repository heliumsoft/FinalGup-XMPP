//
//  globleData.m
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 11/25/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "globleData.h"
static globleData *sharedInstance = nil;
static NSInteger userid;
static NSString *password;
static BOOL textFieldHidden;
@implementation globleData
{
}
@synthesize email_verified,noOfDays;
+(globleData*)getSharedInstance{
   
    
    @synchronized(self)
    {
        if(sharedInstance==nil)
        {
            
            sharedInstance= [globleData new];
        }
    }
    return sharedInstance;
}
+ (NSInteger)userID {
    return userid;
}
+ (void)setuserID:(NSInteger)newuserID {
    userid = newuserID;
}
+ (NSString*)userPass {
    return password;
}
+ (void)setuserPass:(NSString*)newuserID {
    password = newuserID;
}
+ (BOOL)textFieldHidden {
    return textFieldHidden;
}
+ (void)setTextFieldHidden:(BOOL)istextFieldHidden {
    textFieldHidden = istextFieldHidden;
}
@end
