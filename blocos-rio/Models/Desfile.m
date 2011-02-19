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

+ (NSString *)dateToDataSemHora:(NSDate *)date {
    NSString *tmpValue = nil;
	if (date != nil) {
		tmpValue = [[date dateWithoutTime] dateToMediumStyleString];
	} else {
		tmpValue = @"Sem Data";
	}
    return tmpValue;
}

- (NSString *)dataSemHora {
    NSString *tmpValue = nil;
    
    [self willAccessValueForKey:@"dataSemHora"];
    tmpValue = [Desfile dateToDataSemHora:self.dataHora];
    [self didAccessValueForKey:@"dataSemHora"];
    
    return tmpValue;
}

@end
