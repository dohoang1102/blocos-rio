//
//  BlocosXMLParserDelegate.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 05/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlocosXMLParserDelegate.h"


@implementation BlocosXMLParserDelegate

- (void)dealloc {
    [dataAtual release];
    [bairroAtual release];
    [nomeAtual release];
    [enderecoAtual release];
    [horaAtual release];
    [currentStringValue release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"root"]) {
        versao = [(NSString *) [attributeDict objectForKey:@"versao"] integerValue];
        // TODO inicar o array com todos os dados
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
        
        // sempre o último, monta o objeto aqui
    }
    
    [currentStringValue release];
    currentStringValue = nil;
}

@end
