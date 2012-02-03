//
//  Created by felipecypriano on 03/02/12.
//
// To change the template use AppCode | Preferences | File Templates.
//



@implementation UINavigationController (FixTabBarItem)

- (UITabBarItem *)tabBarItem {
    return [[[self viewControllers] objectAtIndex:0] tabBarItem];
}

@end