//
//  Created by felipe on 18/01/12.
//
//


#import "TrackUsageOperation.h"

#define APP_KEY @"blocos-de-rua"

#ifdef DEBUG
  #define TRACK_HOST @"http://localhost:3000"
#else
  #define TRACK_HOST @"http://api.felipecypriano.com/app-analytics"
#endif


@interface TrackUsageOperation ()
- (void)done;
@end

@implementation TrackUsageOperation {
    NSData *operationData;
    NSURLConnection *connection_;
    BOOL executing_, finished_;
}

- (id)initWithJSONData:(NSData *)jsonData {
    self = [super init];
    if (self) {
        operationData = [jsonData retain];
    }
    return self;
}

- (void)cancelAndReleaseConnection {
    if (connection_) {
        [connection_ cancel];
        [connection_ release];
        connection_ = nil;
    }
}

- (void)dealloc {
    [self cancelAndReleaseConnection];
    [operationData release];
    operationData = nil;
    [super dealloc];
}

- (void)start {
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self start];
        });
        return;
    }

    if (finished_ || [self isCancelled]) {
        [self done];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    executing_ = YES;
    [self didChangeValueForKey:@"isExecuting"];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/apps/%@/operations.json", TRACK_HOST, APP_KEY]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = operationData;
    [request setValue:[NSString stringWithFormat:@"%d", [operationData length]] forHTTPHeaderField:@"Content-Length"];

    connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)done {
    [self cancelAndReleaseConnection];

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    executing_ = NO;
    finished_ = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark -
#pragma mark NSOperation Overrides

- (BOOL)isExecuting {
    return executing_;
}

- (BOOL)isFinished {
    return finished_;
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark -
#pragma mark NSURLConnectionDelegate and DataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([self isCancelled]) {
        [self done];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self done];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    DLog(@"%@", error);
    [self done];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;

}


@end