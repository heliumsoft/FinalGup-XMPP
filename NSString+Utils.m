//
//  NSString+Date.m
//  JabberClient
//
//  Created by cesarerocchi on 9/12/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "NSString+Utils.h"
#import "AppDelegate.h"


@implementation NSString (Utils)

+ (NSString *) getCurrentTime {

	NSDate *nowUTC = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	return [dateFormatter stringFromDate:nowUTC];
	
}
-(NSString*)userID
{
    @try
    {
      return  [[[[self componentsSeparatedByString:@"@"] objectAtIndex:0] componentsSeparatedByString:@"_"] objectAtIndex:1];
    }
    @catch (NSException *e)
    {
        //NSLog(@"found exception %@",e);
        return @"";
    }
    
}

-(NSString*)JID
{
    @try
    {
        return  [NSString stringWithFormat:@"user_%@@%@",self,jabberUrl];
    }
    @catch (NSException *e)
    {
        //NSLog(@"found exception %@",e);
        return @"";
    }
    
}
-(NSString*)normalizeDatabaseElement
{
    @try
    {
        return  [self stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
    @catch (NSException *e)
    {
        //NSLog(@"found exception %@",e);
        return @"";
    }
    
}
- (NSString *) substituteEmoticons {
	
	//See http://www.easyapns.com/iphone-emoji-alerts for a list of emoticons available
	
	NSString *res = [self stringByReplacingOccurrencesOfString:@":)" withString:@"\ue415"];	
	res = [res stringByReplacingOccurrencesOfString:@":(" withString:@"\ue403"];
	res = [res stringByReplacingOccurrencesOfString:@";-)" withString:@"\ue405"];
	res = [res stringByReplacingOccurrencesOfString:@":-x" withString:@"\ue418"];
	
	return res;
	
}
-(NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end {
    NSRange startRange = [self rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [self length] - targetRange.location;
        NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [self substringWithRange:targetRange];
        }
    }
    return nil;
}
- (NSString *)UTFEncoded {
    
  //  if (![self canBeConvertedToEncoding:NSASCIIStringEncoding]) {
    @try
    {

        return [[NSString alloc] initWithData:[self dataUsingEncoding:NSNonLossyASCIIStringEncoding] encoding:NSASCIIStringEncoding];
    }
 //   }
    @catch (NSException *e)
    {
        //NSLog(@"exception %@",e);
    return self;
    }
    
}

- (NSString *)UTFDecoded {
    NSLog(@"%@",[self dataUsingEncoding:NSASCIIStringEncoding]);
//    NSLog(@"%@",)
    
    return [[NSString alloc] initWithData:[self dataUsingEncoding:NSASCIIStringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    
}

- (NSString *)stringByDecodingXMLEntities{
    NSUInteger myLength = [self length];
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
    
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return self;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
    
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];
    
    [scanner setCharactersToBeSkipped:nil];
    
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
    
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            
            if (gotNumber) {
                [result appendFormat:@"%C", (unichar)charCode];
                
                [scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";
                
                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
                
                
                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];
                
                //[scanner scanUpToString:@";" intoString:&unknownEntity];
                //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
                
            }
            
        }
        else {
            NSString *amp;
            
            [scanner scanString:@"&" intoString:&amp];  //an isolated & symbol
            [result appendString:amp];
            
            /*
             NSString *unknownEntity = @"";
             [scanner scanUpToString:@";" intoString:&unknownEntity];
             NSString *semicolon = @"";
             [scanner scanString:@";" intoString:&semicolon];
             [result appendFormat:@"%@%@", unknownEntity, semicolon];
             NSLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
             */
        }
        
    }
    while (![scanner isAtEnd]);
    
finish:
    return result;
}

+(NSString*)CurrentDate
{ NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter  setDateFormat:@"dd/MM/YYYY"];
    return [dateFormatter stringFromDate:[NSDate date]];

}
+(NSString*)CurrentDay
{return [[[self CurrentDate] componentsSeparatedByString:@"/"] objectAtIndex:0];
}
+(NSString*)CurrentMonth
{return [[[self CurrentDate] componentsSeparatedByString:@"/"] objectAtIndex:1];
}
+(NSString*)CurrentYear
{
    return [[[self CurrentDate] componentsSeparatedByString:@"/"] objectAtIndex:2];
}
+(NSString*)CurrentTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"hh:mm"];
     //  [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
   return [dateFormatter stringFromDate:[NSDate date]];

}
+(NSString*)DateTime
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
   
   return [format stringFromDate:[NSDate date]];
   
    
}
- (NSString*)textToHtml
{
    NSString *htmlString =self;
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<"  withString:@"("];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@">"  withString:@")"];
   
    return htmlString;
}
- (NSString*)htmlToText {
    NSString *htmlString=self;
    htmlString = [self stringByReplacingOccurrencesOfString:@"("  withString:@"<"];
    htmlString = [self stringByReplacingOccurrencesOfString:@")"  withString:@">"];
   
    return htmlString;
}
-(NSString*)getTimeIntervalFromStringDate{
//    NSLog(@"str daty %@",self);
    NSDateFormatter *dateTimeFormat = [[NSDateFormatter alloc] init];
    [dateTimeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
     NSDate *dateFromStringValu = [[NSDate alloc] init];

    
    dateFromStringValu = [dateTimeFormat dateFromString:self];
    //NSLog(@"date in str formate %@ ",dateFromStringValu);
    double timeInMilis = [dateFromStringValu timeIntervalSince1970];
     //NSLog(@"time %f",timeInMilis);
    timeInMilis*=1000;
    
    //NSLog(@"time %@",[NSString stringWithFormat:@"%.0f",timeInMilis]);
    return [NSString stringWithFormat:@"%.0f",timeInMilis];
}
-(NSString*)getDateTimeFromTimeInterval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]/1000];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    //NSLog(@"formattedDateString: %@", formattedDateString);
    if (([formattedDateString stringByReplacingOccurrencesOfString:@" " withString:@""].length==0)||formattedDateString==nil)
    {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        return [format stringFromDate:[NSDate date]];
    }
    
    return formattedDateString;
}

///new
+(NSString *)getCurrentUTCFormateDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    //NSLog(@" interval %@",[dateString getTimeIntervalFromStringDate]);
    return dateString;
}
- (BOOL) isAlphaNumeric
{
    NSCharacterSet *unwantedCharacters =
    [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_ "] invertedSet];
    
    return ([self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound) ? YES : NO;
}
-(NSString*)getDateTimeFromUTCTimeInterval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
     NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    NSString *date = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:[NSDate dateWithTimeIntervalSince1970:[self doubleValue]/1000]]];
    return date;
}
-(NSString*)getTimeIntervalFromUTCStringDate
{
    NSLog(@"str daty %@",self);
    NSDateFormatter *dateTimeFormat = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateTimeFormat setTimeZone:timeZone];
    [dateTimeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    NSDate *dateFromStringValu = [[NSDate alloc] init];
    
    
    dateFromStringValu = [dateTimeFormat dateFromString:self];
    //NSLog(@"date in str formate %@ ",dateFromStringValu);
    double timeInMilis = [dateFromStringValu timeIntervalSince1970];
    //  NSLog(@"time %f",[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue]);
    timeInMilis*=1000;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"])
    {
        
        timeInMilis=timeInMilis-[[[NSUserDefaults standardUserDefaults]objectForKey:@"TimeDifferance"] doubleValue];
    }
    //NSLog(@"time %@",[NSString stringWithFormat:@"%.0f",timeInMilis]);
    return [NSString stringWithFormat:@"%.0f",timeInMilis];
}

@end
