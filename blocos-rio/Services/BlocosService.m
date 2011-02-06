//
//  BlocosService.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 02/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlocosService.h"
#import "ZipArchive.h"

#define kUrlToUpdate @"http://dl.dropbox.com/u/8159675/blocodroid/blocos.zip"

@interface BlocosService (Private)
- (void)unzipAndUpdate:(NSString *)zipFile;
@end

@implementation BlocosService

- (void)dealloc {
    [zipData release];
    [errorOnHTTPRequest release];
    [blocosXMLDelegate release];
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

#pragma mark -
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
            [self unzipAndUpdate:filePath];
        } else {
            // TODO tratar erro ao salvar o zip
        }

    } else {
        [self connection:conn didFailWithError:errorOnHTTPRequest];
        [errorOnHTTPRequest release];
        errorOnHTTPRequest = nil;
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    
}


#pragma mark -
#pragma mark Private methods

- (void)unzipAndUpdate:(NSString *)zipFile {
    ZipArchive *zip = [[ZipArchive alloc] init];
    zip.delegate = self;
    
    [zip UnzipOpenFile:zipFile];
    
    NSString *unzipPath = [NSTemporaryDirectory() stringByAppendingString:@"blocos"];
    if ([zip UnzipFileTo:unzipPath overWrite:YES]) {
        
        if (blocosXMLDelegate == nil) {
            blocosXMLDelegate = [[BlocosXMLParserDelegate alloc] init];
        }
        
        NSURL *xml = [NSURL fileURLWithPath:[unzipPath stringByAppendingString:@"/blocos-2011.xml"]];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:xml];
        parser.delegate = blocosXMLDelegate;
        parser.shouldResolveExternalEntities = NO;
        [parser parse];
        [parser release];
        
        // pegar os dados do blocosXMLDelegate e atualizar o banco
    } else {
        // TODO informar do erro ao descompactar
    }
    
    [zip UnzipCloseFile];
}

-(void) ErrorMessage:(NSString*) msg {
    NSLog(@"ZipArchive error message %@", msg);
}

@end
