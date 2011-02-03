//
//  Bloco.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 02/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Desfile;

@interface Bloco :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSSet* desfiles;

@end


@interface Bloco (CoreDataGeneratedAccessors)
- (void)addDesfilesObject:(Desfile *)value;
- (void)removeDesfilesObject:(Desfile *)value;
- (void)addDesfiles:(NSSet *)value;
- (void)removeDesfiles:(NSSet *)value;

@end

