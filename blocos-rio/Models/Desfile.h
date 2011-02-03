//
//  Desfile.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 02/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Bairro;
@class Bloco;

@interface Desfile :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * endereco;
@property (nonatomic, retain) NSDate * dataHora;
@property (nonatomic, retain) Bloco * bloco;
@property (nonatomic, retain) Bairro * bairro;

@end



