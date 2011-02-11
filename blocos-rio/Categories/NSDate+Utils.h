//
//  NSDate+Utils.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (Utils)

- (NSDate *)dateWithoutTime;
- (NSString *)dateToMediumStyleString;
- (NSString *)dateTimeToMediumStyleString;

@end
