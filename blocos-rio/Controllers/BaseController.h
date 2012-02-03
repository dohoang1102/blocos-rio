//
//  Created by felipe on 30/01/12.
//
//


#import <Foundation/Foundation.h>


@interface BaseController : UIViewController

@property(nonatomic, retain) NSString *titleImageBaseName;

- (void)addShadowImageBellowNavigationBarToView;

- (void)configureTabBarItemInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)configureTabBarItemWithTitle:(NSString *)title imageBaseName:(NSString *)imageBaseName forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end