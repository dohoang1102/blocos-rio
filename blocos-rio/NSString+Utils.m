//
//  NSString+Utils.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 13/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import "NSString+Utils.h"


@implementation NSString (Utils)

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
