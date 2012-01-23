//
//  Created by felipecypriano on 22/01/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "BlocosService.h"


@interface BackgroundUpdateTabBarController : UITabBarController<UITabBarControllerDelegate, BlocosServiceDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

- (void)updateData;
- (void)restoreUpdateTabLabel;

@end