//
//  NSManagedObjectContext+DeleteAll.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 10/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import "NSManagedObjectContext+DeleteAll.h"


@implementation NSManagedObjectContext (DeleteAll)

- (void)deleteAllObjects:(NSString *)entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *items = [self executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    ZAssert(error == nil, @"Erro ao procurar todos objetos de %@: %@", entityDescription, [error localizedDescription]);
    
    DLog(@"Apagando objetos de %@", entityDescription);
    for (NSManagedObject *managedObject in items) {
        [self deleteObject:managedObject];
    }
}

@end
