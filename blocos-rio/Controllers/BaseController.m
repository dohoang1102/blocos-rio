//
//  Created by felipe on 30/01/12.
//
//


#import "BaseController.h"

#define TITLE_IMAGE_LANDSCAPE_SUFIX @"_landscape"

@interface BaseController ()
- (void)configureNavigationItemTitleView;

- (void)setTitleImageForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@implementation BaseController {
    UIImageView *_titleImageView;
}

@synthesize titleImageBaseName = _titleImageBaseName;

- (void)dealloc {
    [_titleImageBaseName release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitleImageForInterfaceOrientation:[self interfaceOrientation]];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self setTitleImageForInterfaceOrientation:toInterfaceOrientation];
}

- (void)setTitleImageBaseName:(NSString *)titleImageBaseName {
    if (titleImageBaseName != _titleImageBaseName) {
        [_titleImageBaseName release];
        _titleImageBaseName = [titleImageBaseName retain];

        [self configureNavigationItemTitleView];
        [self setTitleImageForInterfaceOrientation:[self interfaceOrientation]];
    }
}

- (void)addShadowImageBellowNavigationBarToView {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIImage *image = [[UIImage imageNamed:@"nav_bar_sombra"] resizableImageWithCapInsets:insets];
    UIImageView *shadow = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [[self view] bounds].size.width, 6)] autorelease];
    shadow.image = image;
    shadow.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [[self view] addSubview:shadow];
}


#pragma mark -
#pragma mark Private methods

- (void)configureNavigationItemTitleView {
    if (_titleImageBaseName && !_titleImageView) {
        _titleImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:_titleImageBaseName]] autorelease];
        self.navigationItem.titleView = _titleImageView;
    } else {
        self.navigationItem.titleView = nil;
    }
}

- (void)setTitleImageForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (_titleImageView) {
        UIImage *image;
        if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            image = [UIImage imageNamed:_titleImageBaseName];
        } else {
            image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", _titleImageBaseName, TITLE_IMAGE_LANDSCAPE_SUFIX]];
        }

        _titleImageView.image = image;
        _titleImageView.frame = CGRectSetSize(_titleImageView.frame, image.size.width, image.size.height);
    }
}

@end