//
//  Desfile.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright (c) 2011 Felipe Cypriano. All rights reserved.
//

@class Bairro, Bloco;

@interface Desfile : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * endereco;
@property (nonatomic, retain) NSDate * dataHora;
@property (nonatomic, retain) NSString * dataSemHora;
@property (nonatomic, retain) Bloco * bloco;
@property (nonatomic, retain) Bairro * bairro;

@end
