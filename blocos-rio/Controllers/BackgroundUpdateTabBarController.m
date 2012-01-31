//
//  Created by felipecypriano on 22/01/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BackgroundUpdateTabBarController.h"

#define UPDATE_ICON_CENTER_PORTRAIT CGPointMake(280.0f, 20.0f)
#define UPDATE_ICON_CENTER_LANDSCAPE CGPointMake(420.0f, 20.0f)
#define UPDATE_ANIMATION_KEY @"RotateUpdateIconAnimationKey"

@interface UpdateController : UIViewController
- (void)setTabBarItemAtualizar;
- (void)setTabBarItemAtualizando;
- (void)setTabBarItemAtualizado;
@end

@interface BackgroundUpdateTabBarController ()
- (void)startAnimation;

- (void)stopAnimation;
@end

@implementation BackgroundUpdateTabBarController {
    UIImageView *updateIconImageView;
    BOOL updating;
    UpdateController *updateController;
}

@synthesize managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext {
    self = [super init];
    if (self) {
        managedObjectContext = [aManagedObjectContext retain];
        self.delegate = self;

        [[UITabBarItem appearance] setTitleTextAttributes:
                [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil]
                                                 forState:UIControlStateNormal];
    }

    return self;
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UpdateController class]]) {
        [self updateData];
        return NO;
    }
    
    return YES;
}

- (void)updateData {
    if (!updating) {
        [self startAnimation];
    
        BlocosService *service = [[BlocosService alloc] init];
        service.delegate = self;
        service.managedObjectContext = managedObjectContext;
        [service updateBlocosData];
        [service release];
    }
}

- (void)restoreUpdateTabLabel {
    [updateController setTabBarItemAtualizar];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    updateIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bar_atualizar_icone"]];
    updateIconImageView.center = CGPointMake(280.0f, 20.0f);
    updateIconImageView.autoresizingMask = UIViewAutoresizingNone;
    [[self tabBar] addSubview:updateIconImageView];
}

- (void)viewDidLayoutSubviews {
    [[self tabBar] bringSubviewToFront:updateIconImageView];
}


- (void)viewDidUnload {
    [updateIconImageView release];
    updateIconImageView = nil;
    [super viewDidUnload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        updateIconImageView.center = UPDATE_ICON_CENTER_PORTRAIT;
    } else {
        updateIconImageView.center = UPDATE_ICON_CENTER_LANDSCAPE;
    }
}


#pragma mark -
#pragma mark BlocosServiceDelegate methods

- (void)blocosService:(BlocosService *)blocosService didUpdateBlocosDataOnDate:(NSDate *)lastUpdate {
    [self stopAnimation];
}

- (void)blocosService:(BlocosService *)blocosService didFailWithError:(NSError *)error {
    [self stopAnimation];
    [updateController setTabBarItemAtualizar];
}

- (void)dealloc {
    [managedObjectContext release];
    [updateIconImageView release];
    [super dealloc];
}

- (void)setViewControllers:(NSArray *)aViewControllers {
    NSMutableArray *controllers = [[[NSMutableArray alloc] initWithArray:aViewControllers] autorelease];
    updateController = [[[UpdateController alloc] init] autorelease];
    [controllers addObject:updateController];
    [super setViewControllers:controllers];
}

#pragma mark -
#pragma mark Private methods

- (void)startAnimation {
    updating = YES;
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.removedOnCompletion = NO;
    rotate.fillMode = kCAFillModeForwards;
    rotate.cumulative = YES;
    rotate.repeatCount = HUGE_VALF;
    rotate.fromValue = [NSNumber numberWithDouble:0.0];
    rotate.toValue = [NSNumber numberWithDouble:M_PI_2];

    [updateController setTabBarItemAtualizando];
    [[updateIconImageView layer] addAnimation:rotate forKey:UPDATE_ANIMATION_KEY];
}

- (void)stopAnimation {
    updating = NO;
    [[updateIconImageView layer] removeAnimationForKey:UPDATE_ANIMATION_KEY];
    [updateController setTabBarItemAtualizado];
} 

@end


@implementation UpdateController

- (id)init {
    self = [super init];
    if (self) {
        [self setTabBarItemAtualizar];
    }

    return self;
}

- (void)setTabBarItemTitle:(NSString *)title {
    self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:nil tag:0] autorelease];
    self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    [[self tabBarItem] setFinishedSelectedImage:[UIImage imageNamed:nil] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_bar_atualizar_unselected"]];
}

- (void)setTabBarItemAtualizar {
    [self setTabBarItemTitle:NSLocalizedString(@"tab-bar.update", @"Title for the update tab action")];
}

- (void)setTabBarItemAtualizando {
    [self setTabBarItemTitle:NSLocalizedString(@"tab-bar.updating", @"Title when the update is in progress")];
}

- (void)setTabBarItemAtualizado {
    [self setTabBarItemTitle:NSLocalizedString(@"tab-bar.updated", @"Title when the update is complete")];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


@end