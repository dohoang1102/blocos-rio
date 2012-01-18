//    Copyright 2012 Felipe Cypriano
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

#import "TrackingService.h"
#import "TrackUsageOperation.h"


@interface TrackingService ()
- (NSData *)paramsToPostOperationWithUsageKey:(NSString *)usageKey;

@end

@implementation TrackingService {
    NSOperationQueue *operationQueue;
}

- (id)init {
    self = [super init];
    if (self) {
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)trackUsageWithKey:(NSString *)usageKey {
    NSData *usage = [self paramsToPostOperationWithUsageKey:usageKey];
    TrackUsageOperation *operation = [[TrackUsageOperation alloc] initWithJSONData:usage];
    [operationQueue addOperation:operation];
    [operation release];
}

- (void)trackUsageWithTarget:(id)target selector:(SEL)selector {
    NSString *targetClassName = [[target class] description];
    NSString *usageKey = [NSString stringWithFormat:@"[%@ %@]", targetClassName, NSStringFromSelector(selector)];
    [self trackUsageWithKey:usageKey];
}

- (void)dealloc {
    [operationQueue cancelAllOperations];
    [operationQueue release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (NSData *)paramsToPostOperationWithUsageKey:(NSString *)usageKey {
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSMutableDictionary *operation = [NSMutableDictionary dictionary];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [operation setObject:appVersion forKey:@"app_version"];
    [operation setObject:[currentDevice model] forKey:@"device"];
    [operation setObject:[currentDevice systemName] forKey:@"operating_system"];
    [operation setObject:[currentDevice systemVersion] forKey:@"operating_system_version"];
    [operation setObject:usageKey forKey:@"usage_key"];
    [operation setObject:[UIAppDelegate userUUID] forKey:@"user_uuid"];

    NSDictionary *params = [NSDictionary dictionaryWithObject:operation forKey:@"operation"];
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    ZAssert(error == nil, @"Couldn't create JSON param: %@", error);
    return json;
}

@end
