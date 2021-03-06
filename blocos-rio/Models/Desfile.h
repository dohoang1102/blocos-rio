//
//  Desfile.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright (c) 2011 Felipe Cypriano. All rights reserved.
//

#import "Bloco.h"
#import "Bairro.h"

@interface Desfile : NSManagedObject {
@private
}

+ (NSString *)dateToDataSemHora:(NSDate *)date;

@property (nonatomic, retain) NSString * endereco;
@property (nonatomic, retain) NSDate * dataHora;
@property (nonatomic, retain) NSString * dataSemHora;
@property (nonatomic, retain) Bloco * bloco;
@property (nonatomic, retain) Bairro * bairro;


@end
