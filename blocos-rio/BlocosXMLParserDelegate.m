//
//  BlocosXMLParserDelegate.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 05/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlocosXMLParserDelegate.h"


@implementation BlocosXMLParserDelegate

- (NSArray *)blocosRawArray {
    return [[blocosRawData copy] autorelease];
}

- (void)dealloc {
    [dataAtual release];
    [bairroAtual release];
    [nomeAtual release];
    [enderecoAtual release];
    [horaAtual release];
    [currentStringValue release];
    [blocosRawData release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"root"]) {
        versao = [(NSString *) [attributeDict objectForKey:@"versao"] integerValue];
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
        dataAtual = [currentStringValue copy];
    } else if ([elementName isEqualToString:@"b"]) {
        bairroAtual = [currentStringValue copy];
    } else if ([elementName isEqualToString:@"n"]) {
        nomeAtual = [currentStringValue copy];
    } else if ([elementName isEqualToString:@"e"]) {
        enderecoAtual = [currentStringValue copy];
    } else if ([elementName isEqualToString:@"h"]) {
        horaAtual = [currentStringValue copy];
        
        NSDictionary *dadosBloco = [NSDictionary dictionaryWithObjectsAndKeys:dataAtual, @"data", bairroAtual, @"bairro", nomeAtual, @"nome", enderecoAtual, @"endereco", horaAtual, @"hora", nil];
        [blocosRawData addObject:dadosBloco];
    }
    
    [currentStringValue release];
    currentStringValue = nil;
}

@end
