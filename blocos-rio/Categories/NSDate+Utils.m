//
//  NSDate+Utils.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import "NSDate+Utils.h"


@implementation NSDate (Utils)

- (NSDate *)dateWithoutTime { 
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSString *)dateToMediumStyleString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    NSString *convertida = [dateFormatter stringFromDate:self];
    [dateFormatter release];
    return convertida;    
}

- (NSString *)dateTimeToMediumStyleString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    NSString *convertida = [dateFormatter stringFromDate:self];
    [dateFormatter release];
    return convertida;    
}

@end
