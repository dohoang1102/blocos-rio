//
//  Desfile.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright (c) 2011 Felipe Cypriano. All rights reserved.
//

#import "Desfile.h"
#import "Bloco.h"
#import "Bairro.h"

@implementation Desfile
@dynamic endereco;
@dynamic dataHora;
@dynamic dataSemHora;
@dynamic bloco;
@dynamic bairro;

- (NSString *)dataSemHora {
    NSString *tmpValue = nil;
    
    [self willAccessValueForKey:@"dataSemHora"];
    tmpValue = [[self.dataHora dateWithoutTime] dateToMediumStyleString];
    [self didAccessValueForKey:@"dataSemHora"];
    
    return tmpValue;
}

@end
