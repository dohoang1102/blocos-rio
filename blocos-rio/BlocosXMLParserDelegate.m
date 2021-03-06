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

#import "BlocosXMLParserDelegate.h"


@implementation BlocosXMLParserDelegate

@synthesize parseError;

- (id) init {
    self = [super init];
    if (self) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT-2"];
    }
    return self;
}

- (NSArray *)blocosRawArray {
    return [[blocosRawData copy] autorelease];
}

- (void)dealloc {
    [currentStringValue release];
    [blocosRawData release];
    [parseError release];
    [releasePool release];
    [dateFormatter release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    if (!parseError) {
        [parseError release];
        parseError = nil;
    }
    releasePool = [[NSAutoreleasePool alloc] init];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
    [releasePool drain];
    releasePool = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"root"]) {
        blocosRawData = [[NSMutableArray alloc] init];
    } else {
        currentStringValue = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [currentStringValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName { 
    if ([elementName isEqualToString:@"d"]) {
        dataAtual = [[[currentStringValue trim] copy] autorelease];
    } else if ([elementName isEqualToString:@"b"]) {
        bairroAtual = [[[currentStringValue trim] copy] autorelease];
    } else if ([elementName isEqualToString:@"n"]) {
        nomeAtual = [[[currentStringValue trim] copy] autorelease];
    } else if ([elementName isEqualToString:@"e"]) {
        enderecoAtual = [[[currentStringValue trim] copy] autorelease];
    } else if ([elementName isEqualToString:@"h"]) {
        if ([currentStringValue isEqualToString:@""]) {
            [currentStringValue appendString:@"00"];
        }
        horaAtual = [[currentStringValue trim] copy];
        
        NSString *dataHora = [dataAtual stringByAppendingFormat:@" %@:00", horaAtual, nil];
        NSDate *dataHoraConvertida = [dateFormatter dateFromString:dataHora];
        
        NSMutableDictionary *dadosBloco = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                                    bairroAtual,@"bairro", 
                                    nomeAtual, @"nome", 
                                    enderecoAtual, @"endereco", nil];
        if (!dataHoraConvertida) {
            [dadosBloco setObject:[NSNull null] forKey:@"data"]; // Resolve o problema quando a data é inválida. gh-1
        } else {
            [dadosBloco setObject:dataHoraConvertida forKey:@"data"]; 
        }
        NSDictionary *imutableDados = [dadosBloco copy];
        [blocosRawData addObject:imutableDados];
        [imutableDados release];
        
        [horaAtual release];
    }
    
    [currentStringValue release];
    currentStringValue = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)theParseError {
    DLog(@"Blocos XML error. Line %d Column %d -- %@", parser.lineNumber, parser.columnNumber, theParseError);
    parseError = [theParseError retain];
}

@end
