//
//  globleData.h
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 11/25/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <Foundation/Foundation.h>
//static NSInteger email_verified,noOfDays;

@interface globleData : NSObject
{}
@property(readwrite, assign, nonatomic) NSInteger email_verified,noOfDays;
+(globleData*)getSharedInstance;
+ (int)userID ;
+ (void)setuserID:(int)newuserID ;
+ (NSString*)userPass ;
+ (void)setuserPass:(NSString*)newuserID;
+ (BOOL)textFieldHidden;
+ (void)setTextFieldHidden:(BOOL)istextFieldHidden ;
@end
