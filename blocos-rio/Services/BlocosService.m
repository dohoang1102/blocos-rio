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

#import "BlocosService.h"
#import "ZipArchive.h"

#define kUrlToUpdate @"http://dl.dropbox.com/u/8159675/blocodroid/blocos.zip"

@interface BlocosService (Private)
- (void)unzipAndUpdate:(NSString *)zipFile;
- (void)saveBlocosRawArray:(NSArray *)blocosRawArray;
- (BlocosXMLParserDelegate *)blocoXmlParserDelegate;
@end

@implementation BlocosService

@synthesize managedObjectContext;

+ (NSURL *)blocosXmlUrl {
    NSString *documents = [[AppDelegate sharedDelegate] applicationDocumentsDirectoryString];
    return [NSURL fileURLWithPath:[documents stringByAppendingString:@"/blocos.xml"]];
}

- (void)updateBlocosDataWithLocalXml {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[BlocosService blocosXmlUrl]];
    parser.delegate = [self blocoXmlParserDelegate];
    parser.shouldResolveExternalEntities = NO;
    [parser parse];
    [parser release];
    
    if ([self blocoXmlParserDelegate].parseError == nil) {
        [self saveBlocosRawArray:[[self blocoXmlParserDelegate] blocosRawArray]];
    } else {
        // TODO informar erro no arquivo xml
    }
}

- (void)dealloc {
    [zipData release];
    [errorOnHTTPRequest release];
    [blocosXMLDelegate release];
    [managedObjectContext release];
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
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
        
        [self blocoXmlParserDelegate];
        
        NSURL *xml = [NSURL fileURLWithPath:[unzipPath stringByAppendingString:@"/blocos-2011.xml"]];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:xml];
        parser.delegate = blocosXMLDelegate;
        parser.shouldResolveExternalEntities = NO;
        [parser parse];
        [parser release];
        
        if (blocosXMLDelegate.parseError == nil) {
            NSError *error = nil;
            [[NSFileManager defaultManager] copyItemAtURL:xml toURL:[BlocosService blocosXmlUrl] error:&error];
            ZAssert(error != nil, @"Copia do XML falhou %@\n%@", [error localizedDescription], [error userInfo]);
            
            [self saveBlocosRawArray:[blocosXMLDelegate blocosRawArray]];
        } else {
            // TODO informar erro no arquivo xml
        }
    } else {
        // TODO informar do erro ao descompactar
    }
    
    [zip UnzipCloseFile];
    [zip release];
}

-(void) ErrorMessage:(NSString*) msg {
    NSLog(@"ZipArchive error message %@", msg);
}

- (void)saveBlocosRawArray:(NSArray *)blocosRawArray {
    ZAssert(managedObjectContext, @"managedObjectContext não setado.");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *blocoEntity = [NSEntityDescription entityForName:@"Bloco" inManagedObjectContext:managedObjectContext];
    NSEntityDescription *bairroEntity = [NSEntityDescription entityForName:@"Bairro" inManagedObjectContext:managedObjectContext];
    
    NSError *error = nil;
    
    [managedObjectContext deleteAllObjects:@"Desfile"];

    for (NSDictionary *campos in blocosRawArray) {
        NSString *blocoNome = [campos objectForKey:@"nome"];
        ZAssert(blocoNome, @"Nome do bloco inexistente %@", campos);
        [request setEntity:blocoEntity];
        [request setPredicate:[NSPredicate predicateWithFormat:@"nome == %@", blocoNome]];
        
        NSManagedObject *bloco = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
        ZAssert(error == nil, @"Erro ao procurar bloco %@", [error localizedDescription]);
        
        if (!bloco) {
            bloco = [NSEntityDescription insertNewObjectForEntityForName:@"Bloco" inManagedObjectContext:managedObjectContext];
            [bloco setValue:blocoNome forKey:@"nome"];
        }
        
        NSString *bairroNome = [campos objectForKey:@"bairro"];
        ZAssert(bairroNome, @"Bairro inexistente %@", campos);
        [request setEntity:bairroEntity];
        [request setPredicate:[NSPredicate predicateWithFormat:@"nome == %@", bairroNome]];
        
        NSManagedObject *bairro = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
        ZAssert(error == nil, @"Erro ao procurar bairro %@", [error localizedDescription]);
        
        if (!bairro) {
            bairro = [NSEntityDescription insertNewObjectForEntityForName:@"Bairro" inManagedObjectContext:managedObjectContext];
            [bairro setValue:bairroNome forKey:@"nome"];
        }
        
        NSManagedObject *desfile = [NSEntityDescription insertNewObjectForEntityForName:@"Desfile" inManagedObjectContext:managedObjectContext];
        [desfile setValue:bloco forKey:@"bloco"];
        [desfile setValue:bairro forKey:@"bairro"];
        [desfile setValue:[campos objectForKey:@"data"] forKey:@"dataHora"];
        [desfile setValue:[campos objectForKey:@"endereco"] forKey:@"endereco"];
    }
    [request release];
    
    [managedObjectContext save:&error];
    ZAssert(error == nil, @"Erro salvando atualização de blocos %@", [error localizedDescription]);
}

- (BlocosXMLParserDelegate *)blocoXmlParserDelegate {
    if (blocosXMLDelegate == nil) {
        blocosXMLDelegate = [[BlocosXMLParserDelegate alloc] init];
    }
    return blocosXMLDelegate;
}

@end
