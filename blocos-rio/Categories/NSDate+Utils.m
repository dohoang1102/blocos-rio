//    Copyright 2011 Felipe Cypriano
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

#import "NSDate+Utils.h"

@interface NSDate (UtilsPrivate)

- (NSString *)dateToStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

@end

@implementation NSDate (Utils)

static NSCalendar *calendar;
- (NSDate *)dateWithoutTime { 
    if (calendar == nil) {
        calendar = [[NSCalendar currentCalendar] retain];
    }
    NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

static NSDateFormatter *dateMediumFormatter;
- (NSString *)dateToMediumStyleString {
    if (dateMediumFormatter == nil) {
        dateMediumFormatter = [[NSDateFormatter alloc] init];
        dateMediumFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateMediumFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    return [dateMediumFormatter stringFromDate:self];
    //return [self dateToStringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)dateTimeToMediumStyleString {
    return [self dateToStringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)timeToString {
    return [self dateToStringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

#define kSecondInDay 86400
- (CGFloat)daysSince:(NSDate *)sinceDate {
    NSTimeInterval sinceDiff = [sinceDate timeIntervalSinceNow];
    NSTimeInterval selfDiff = [self timeIntervalSinceNow];
    NSTimeInterval dateDiff = selfDiff - sinceDiff;
    return dateDiff / kSecondInDay;
}

#pragma mark -
#pragma mark Private
static NSDateFormatter *dateFormatter;
- (NSString *)dateToStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle { 
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    dateFormatter.dateStyle = dateStyle;
    dateFormatter.timeStyle = timeStyle;
    NSString *convertida = [dateFormatter stringFromDate:self];
    return convertida;    
}; 

@end
