//
//  NSDate+Utils.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import "NSDate+Utils.h"

@interface NSDate (UtilsPrivate)

- (NSString *)dateToStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

@end

@implementation NSDate (Utils)

- (NSDate *)dateWithoutTime { 
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSString *)dateToMediumStyleString {
    return [self dateToStringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)dateTimeToMediumStyleString {
    return [self dateToStringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)timeToString {
    return [self dateToStringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

#pragma mark -
#pragma mark Private
- (NSString *)dateToStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle { 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = dateStyle;
    dateFormatter.timeStyle = timeStyle;
    NSString *convertida = [dateFormatter stringFromDate:self];
    [dateFormatter release];
    return convertida;    
}; 

@end
