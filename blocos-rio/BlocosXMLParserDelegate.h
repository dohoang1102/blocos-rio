//
//  BlocosXMLParserDelegate.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 05/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BlocosXMLParserDelegate : NSObject<NSXMLParserDelegate> {
@private
    NSInteger versao;
    
    NSString *bairroAtual;
    NSString *nomeAtual;
    NSString *enderecoAtual;
    NSString *dataAtual;
    NSString *horaAtual;
    
    NSMutableString *currentStringValue;
}

@end
