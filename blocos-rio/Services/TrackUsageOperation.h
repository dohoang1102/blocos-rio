//
//  Created by felipe on 18/01/12.
//
//


#import <Foundation/Foundation.h>


@interface TrackUsageOperation : NSOperation<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

- (id)initWithJSONData:(NSData *)jsonData;

@end