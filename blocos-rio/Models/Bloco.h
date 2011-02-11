//
//  Bloco.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright (c) 2011 Felipe Cypriano. All rights reserved.
//


@class Desfile;

@interface Bloco : NSManagedObject {
@private
}

@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSString * nomeLetraInicial;
@property (nonatomic, retain) NSSet* desfiles;

@end
