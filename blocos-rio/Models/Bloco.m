//
//  Bloco.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright (c) 2011 Felipe Cypriano. All rights reserved.
//

#import "Bloco.h"
#import "Desfile.h"

@implementation Bloco

@dynamic nome;
@dynamic nomeLetraInicial;
@dynamic desfiles;

- (NSString *)nomeLetraInicial {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"nomeLetraInicial"];
    
    if ([self.nome length] > 0) {
        tmpValue = [[self.nome substringToIndex:1] uppercaseString];
        if ([[NSScanner scannerWithString:tmpValue] scanInt:NULL]) { //return # if its a number
            tmpValue = @"#";
        }        
    } else {
        tmpValue = @"";
    }
    
    [self didAccessValueForKey:@"nomeLetraInicial"];
    
    return tmpValue;
}

@end
