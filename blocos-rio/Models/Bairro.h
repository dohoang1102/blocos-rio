//
//  Bairro.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 11/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Desfile;

@interface Bairro :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSSet* desfiles;

@end


@interface Bairro (CoreDataGeneratedAccessors)
- (void)addDesfilesObject:(Desfile *)value;
- (void)removeDesfilesObject:(Desfile *)value;
- (void)addDesfiles:(NSSet *)value;
- (void)removeDesfiles:(NSSet *)value;

@end

