//
//  Created by felipecypriano on 22/01/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BackgroundUpdateTabBarController.h"
#import "BlocosService.h"

@interface UpdateController : UIViewController
@end

@implementation BackgroundUpdateTabBarController {
    UIImageView *updateIconImageView;
}



#pragma mark -
#pragma mark UITabBarControllerDelegate methods

@synthesize managedObjectContext;

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UpdateController class]]) {
        [self updateData];
        return NO;
    }
    
    return YES;
}

- (void)updateData {
    // TODO start animation

    BlocosService *service = [[BlocosService alloc] init];
    service.delegate = self;
    service.managedObjectContext = managedObjectContext;
    [service updateBlocosData];
    [service release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    updateIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"update-tab"]];
    updateIconImageView.center = CGPointMake(280.0f, 20.0f);
    updateIconImageView.autoresizingMask = UIViewAutoresizingNone;
    [[self tabBar] addSubview:updateIconImageView];
}

- (void)viewDidUnload {
    [updateIconImageView release];
    updateIconImageView = nil;
    [super viewDidUnload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        updateIconImageView.center = CGPointMake(280.0f, 20.0f);
    } else {
        updateIconImageView.center = CGPointMake(420.0f, 20.0f);
    }
}



#pragma mark -
#pragma mark BlocosServiceDelegate methods

- (void)blocosService:(BlocosService *)blocosService didUpdateBlocosDataOnDate:(NSDate *)lastUpdate {
    // TODO stop animation

}

- (void)blocosService:(BlocosService *)blocosService didFailWithError:(NSError *)error {
    // TODO stop animation

}

- (void)dealloc {
    [managedObjectContext release];
    [updateIconImageView release];
    [super dealloc];
}

- (void)setViewControllers:(NSArray *)aViewControllers {
    NSMutableArray *controllers = [[[NSMutableArray alloc] initWithArray:aViewControllers] autorelease];
    [controllers addObject:[[[UpdateController alloc] init] autorelease]];
    [super setViewControllers:controllers];
}

@end


@implementation UpdateController

- (id)init {
    self = [super init];
    if (self) {
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Atualizar" image:nil tag:0] autorelease];
    }

    return self;
}

@end