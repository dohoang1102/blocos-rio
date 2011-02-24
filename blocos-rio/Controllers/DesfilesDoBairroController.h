//
//  DesfilesDoBairroController.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 24/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bairro;

@interface DesfilesDoBairroController : UITableViewController<NSFetchedResultsControllerDelegate> {
@private
	NSManagedObjectID *bairroId;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (id)initWithBairro:(Bairro *)bairro managedObjectContext:(NSManagedObjectContext *)moc;

@end
