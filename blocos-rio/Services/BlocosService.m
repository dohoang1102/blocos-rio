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

/**
 * Faz o parser do XML e o import pro banco de dados numa thread separada
 */
@interface UpdateBlocosDataOperation : NSOperation {
    NSManagedObjectContext *backgroundManagedContext;
    NSString *blocosXmlPath;
    BlocosXMLParserDelegate *blocosXMLDelegate;
}

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) BlocosService *service;

- initWithBlocosXmlPath:(NSString *)xmlPath;
- (BlocosXMLParserDelegate *)blocosXmlParserDelegate;
- (void)saveBlocosRawArray:(NSArray *)blocosRawArray;

@end



@interface BlocosService (Private)
- (void)unzipAndUpdate:(NSString *)zipFile;
- (void)serviceFailedWithError:(NSError *)error;
- (void)serviceDidUpdateBlocosOnDate:(NSDate *)lastUpdateDate;
@end

@implementation BlocosService

@synthesize managedObjectContext, delegate;

+ (NSURL *)blocosXmlUrl {
    NSString *documents = [[AppDelegate sharedDelegate] applicationDocumentsDirectoryString];
    return [NSURL fileURLWithPath:[documents stringByAppendingString:@"/blocos.xml"]];
}

- (void)updateBlocosDataWithLocalXml {
    [self retain];
    
    UpdateBlocosDataOperation *updateOperation = [[UpdateBlocosDataOperation alloc] initWithBlocosXmlPath:[[BlocosService blocosXmlUrl] path]];
    updateOperation.persistentStoreCoordinator = [managedObjectContext persistentStoreCoordinator];
    updateOperation.service = self;
    [[[AppDelegate sharedDelegate] operationQueue] addOperation:updateOperation];
    [updateOperation release];    
}

- (void)dealloc {
    [zipData release];
    [errorOnHTTPRequest release];
    [managedObjectContext release];
    [super dealloc];
}

- (void)updateBlocosData {
    [self retain];
    
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
        NSError *error = nil;
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:@"blocos.zip"];
        if ([zipData writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
            [self unzipAndUpdate:filePath];
        } else {
            [self connection:conn didFailWithError:error];
        }
    } else {
        [self connection:conn didFailWithError:errorOnHTTPRequest];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(blocosService:didFailWithError:)]) {
        [delegate blocosService:self didFailWithError:error];
    }
    [errorOnHTTPRequest release];
    errorOnHTTPRequest = nil;
    [self release];
}


#pragma mark -
#pragma mark Private methods

- (void)unzipAndUpdate:(NSString *)zipFile {
    ZipArchive *zip = [[ZipArchive alloc] init];
    zip.delegate = self;
    
    [zip UnzipOpenFile:zipFile];
    
    NSString *unzipPath = [NSTemporaryDirectory() stringByAppendingString:@"blocos"];
    if ([zip UnzipFileTo:unzipPath overWrite:YES]) {
        NSString *xmlPath = [unzipPath stringByAppendingString:@"/blocos-2011.xml"];
        UpdateBlocosDataOperation *updateOperation = [[UpdateBlocosDataOperation alloc] initWithBlocosXmlPath:xmlPath];
        updateOperation.persistentStoreCoordinator = [managedObjectContext persistentStoreCoordinator];
        updateOperation.service = self;
        [[[AppDelegate sharedDelegate] operationQueue] addOperation:updateOperation];
        [updateOperation release];
    }
    
    [zip UnzipCloseFile];
    [zip release];
}

-(void) ErrorMessage:(NSString*) msg {
    NSError *error = [NSError errorWithDomain:@"Unzip" code:0 userInfo:[NSDictionary dictionaryWithObject:msg forKey:@"message"]];
    [self serviceFailedWithError:error];
}

- (void)serviceFailedWithError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(blocosService:didFailWithError:)]) {
        [delegate blocosService:self didFailWithError:error];
    }
    [self release];
}

- (void)serviceDidUpdateBlocosOnDate:(NSDate *)lastUpdateDate {
    if ([delegate respondsToSelector:@selector(blocosService:didUpdateBlocosDataOnDate:)]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:lastUpdateDate forKey:kLastUpdateDateKey];
        [delegate blocosService:self didUpdateBlocosDataOnDate:lastUpdateDate];
    }
    [self release];
}

@end

@implementation UpdateBlocosDataOperation

@synthesize persistentStoreCoordinator, service;

- initWithBlocosXmlPath:(NSString *)xmlPath {
    self = [super init];
    if (self) {
        blocosXmlPath = [xmlPath retain];
    }
    return self;
}

- (void) dealloc {
    [blocosXmlPath release];
    [persistentStoreCoordinator release];
    [backgroundManagedContext release];
    [super dealloc];
}

- (NSManagedObjectContext *)backgroundManagedContext {
    ZAssert(self.persistentStoreCoordinator, @"Persistent store coordinator não setado");
    if (!backgroundManagedContext) {
        backgroundManagedContext = [[NSManagedObjectContext alloc] init];
        [backgroundManagedContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return backgroundManagedContext;
}

- (void) main {
    ZAssert(blocosXmlPath, @"xmlPath não setado");
	id appDelegate = [AppDelegate sharedDelegate];
    [[NSNotificationCenter defaultCenter] addObserver:appDelegate
                                             selector:@selector(blocosServiceBackgroundContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:backgroundManagedContext];    
    
    NSURL *xml = [NSURL fileURLWithPath:blocosXmlPath];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:xml];
    parser.delegate = self.blocosXmlParserDelegate;
    parser.shouldResolveExternalEntities = NO;
    [parser parse];
    [parser release];
    
    if (self.blocosXmlParserDelegate.parseError == nil) {
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtURL:xml toURL:[BlocosService blocosXmlUrl] error:&error];
        ZAssert(error != nil, @"Copia do XML falhou %@\n%@", [error localizedDescription], [error userInfo]);

        [self saveBlocosRawArray:[blocosXMLDelegate blocosRawArray]];
    } else {
        [service performSelectorOnMainThread:@selector(serviceFailedWithError:) withObject:self.blocosXmlParserDelegate.parseError waitUntilDone:NO];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:appDelegate
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:backgroundManagedContext];
}

- (void)saveBlocosRawArray:(NSArray *)blocosRawArray {
    ZAssert(self.backgroundManagedContext, @"backgroundManagedContext não setado.");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *blocoEntity = [NSEntityDescription entityForName:@"Bloco" inManagedObjectContext:backgroundManagedContext];
    NSEntityDescription *bairroEntity = [NSEntityDescription entityForName:@"Bairro" inManagedObjectContext:backgroundManagedContext];
    
    NSError *error = nil;
    
    [backgroundManagedContext deleteAllObjects:@"Desfile"];
    
    for (NSDictionary *campos in blocosRawArray) {
        NSString *blocoNome = [campos objectForKey:@"nome"];
		NSString *blocoNomeSemAcento = [blocoNome removeAccents];
        ZAssert(blocoNome, @"Nome do bloco inexistente %@", campos);
        [request setEntity:blocoEntity];
        [request setPredicate:[NSPredicate predicateWithFormat:@"nomeSemAcento == %@", blocoNomeSemAcento]];
        
        NSManagedObject *bloco = [[backgroundManagedContext executeFetchRequest:request error:&error] lastObject];
        ZAssert(error == nil, @"Erro ao procurar bloco %@", [error localizedDescription]);
        
        if (!bloco) {
            bloco = [NSEntityDescription insertNewObjectForEntityForName:@"Bloco" inManagedObjectContext:backgroundManagedContext];
            [bloco setValue:blocoNome forKey:@"nome"];
            [bloco setValue:blocoNomeSemAcento forKey:@"nomeSemAcento"];
        }
        
        NSString *bairroNome = [campos objectForKey:@"bairro"];
        ZAssert(bairroNome, @"Bairro inexistente %@", campos);
        [request setEntity:bairroEntity];
        [request setPredicate:[NSPredicate predicateWithFormat:@"nome == %@", bairroNome]];
        
        NSManagedObject *bairro = [[backgroundManagedContext executeFetchRequest:request error:&error] lastObject];
        ZAssert(error == nil, @"Erro ao procurar bairro %@", [error localizedDescription]);
        
        if (!bairro) {
            bairro = [NSEntityDescription insertNewObjectForEntityForName:@"Bairro" inManagedObjectContext:backgroundManagedContext];
            [bairro setValue:bairroNome forKey:@"nome"];
        }
        
        NSManagedObject *desfile = [NSEntityDescription insertNewObjectForEntityForName:@"Desfile" inManagedObjectContext:backgroundManagedContext];
        [desfile setValue:bloco forKey:@"bloco"];
        [desfile setValue:bairro forKey:@"bairro"];
        id dataHora = [campos objectForKey:@"data"];
        if (![dataHora isKindOfClass:[NSNull class]]) {
            [desfile setValue:[campos objectForKey:@"data"] forKey:@"dataHora"];
        }
        [desfile setValue:[campos objectForKey:@"endereco"] forKey:@"endereco"];
    }
    [request release];
    
    [backgroundManagedContext save:&error];
    ZAssert(error == nil, @"Erro salvando atualização de blocos %@", [error localizedDescription]);
    if (error) {
        [service performSelectorOnMainThread:@selector(serviceFailedWithError:) withObject:error waitUntilDone:NO];
    } else {
        [service performSelectorOnMainThread:@selector(serviceDidUpdateBlocosOnDate:) withObject:[NSDate date] waitUntilDone:NO];
    }
}

- (BlocosXMLParserDelegate *)blocosXmlParserDelegate {
    if (blocosXMLDelegate == nil) {
        blocosXMLDelegate = [[BlocosXMLParserDelegate alloc] init];
    }
    return blocosXMLDelegate;
}

@end

