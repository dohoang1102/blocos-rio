//
//  OpcoesController.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 12/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlocosService.h"

@interface OpcoesController : UITableViewController<BlocosServiceDelegate> {
@private
    UIActivityIndicatorView *updateIndicator;
    NSString *lastUpdateInfo;
    NSDate *lastUpdateDate;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;

@end
