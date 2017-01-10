//
//  NSString+Date.h
//  JabberClient
//
//  Created by cesarerocchi on 9/12/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Utils)

+ (NSString *) getCurrentTime;
- (NSString *) substituteEmoticons;
-(NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end;
- (NSString *)UTFEncoded;

- (NSString *)UTFDecoded;
+(NSString*)CurrentDate;
//+(NSString*)CurrentTime;
+(NSString*)DateTime;
+(NSString*)CurrentDay;

+(NSString*)CurrentMonth;
+(NSString*)CurrentYear;

-(NSString*)userID;
-(NSString*)JID;
-(NSString*)normalizeDatabaseElement;
- (NSString*)textToHtml;
- (NSString*)htmlToText ;
-(NSString*)getTimeIntervalFromStringDate;
-(NSString*)getDateTimeFromTimeInterval;
-(NSString*)getDateTimeFromUTCTimeInterval;
+(NSString *)getCurrentUTCFormateDate;
-(NSString*)getTimeIntervalFromUTCStringDate;
- (NSString *)stringByDecodingXMLEntities;
- (BOOL) isAlphaNumeric;
//-(NSDate*)getDateFromString;
//-(NSString*)getTimeIntervalFromDate;
@end
