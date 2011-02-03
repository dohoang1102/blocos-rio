//
//  BlocosService.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 02/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlocosService.h"

#define kUrlToUpdate @"http://dl.dropbox.com/u/8159675/blocodroid/blocos.zip"

@implementation BlocosService

- (void)dealloc {
    [zipData release];
    [errorOnHTTPRequest release];
    [super dealloc];
}

- (void)updateBlocosData {
    NSURL *url = [NSURL URLWithString:kUrlToUpdate];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *conn = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    if (conn) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response { 
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    // HTTP status code, qualquer entre 200 e 299 é OK
    if ([httpResponse statusCode]/100 == 2) {
        if (zipData != nil) {
            [zipData release];
        }
        zipData = [[NSMutableData data] retain];
        [zipData setLength:0]; 
    } else {
        NSLog(@"HTTP Error: %d", [httpResponse statusCode]);
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error", @"Erro na resposta do servidor.")
                                                             forKey:NSLocalizedDescriptionKey];
        if (errorOnHTTPRequest != nil) {
            [errorOnHTTPRequest release];
        }
        errorOnHTTPRequest =  [[NSError alloc] initWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
    }    
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [zipData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn { 
    if (errorOnHTTPRequest == nil) {
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:@"blocos.zip"];
        if ([zipData writeToFile:filePath atomically:YES]) {
            
        } else {
            // TODO tratar erro ao salvar o zip
        }

        // pegar o xml
        // fazer o parse do xml
        // atualizar o banco
    } else {
        [self connection:conn didFailWithError:errorOnHTTPRequest];
        [errorOnHTTPRequest release];
        errorOnHTTPRequest = nil;
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    
}

@end
