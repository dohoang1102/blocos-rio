//
//  Desfile.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright (c) 2011 Felipe Cypriano. All rights reserved.
//

#import "Desfile.h"s

@implementation Desfile
@dynamic endereco;
@dynamic dataHora;
@dynamic dataSemHora;
@dynamic bloco;
@dynamic bairro;

- (NSString *)dataSemHora {
    NSString *tmpValue = nil;
    
    [self willAccessValueForKey:@"dataSemHora"];
	if (self.dataHora != nil) {
		tmpValue = [[self.dataHora dateWithoutTime] dateToMediumStyleString];
	} else {
		tmpValue = @"Sem Data";
	}

    [self didAccessValueForKey:@"dataSemHora"];
    
    return tmpValue;
}

@end
