//    Copyright 2011 Felipe Cypriano
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

#import "ExpandableHeaderView.h"

@interface ExpandableHeaderView (Private)
- (void)setOpen:(BOOL)isOpen animated:(BOOL)animated;
@end

@implementation ExpandableHeaderView

@synthesize textLabel, section, open, delegate;

+ (CGFloat)viewHeight {
    return 44.0f;
}

+ (ExpandableHeaderView *)expandableHeaderViewForSection:(NSInteger)section opened:(BOOL)opened {
    ExpandableHeaderView *newHeader = [[[ExpandableHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, [self viewHeight])] autorelease];
    newHeader.section = section;
    newHeader.open = opened;
    return newHeader;
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchToogle:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        self.userInteractionEnabled = YES;

        UIImage *imgClosed = [UIImage imageNamed:@"arrow-right.png"];
        imgOpenClose = [[UIImageView alloc] initWithFrame:CGRectMake(8, 22 - imgClosed.size.height/2, imgClosed.size.width, imgClosed.size.height)];
        imgOpenClose.image = imgClosed;
        [self addSubview:imgOpenClose];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 6, 288, 30)];
        textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.shadowOffset = CGSizeMake(0, 1);
        textLabel.shadowColor = [UIColor blackColor];
        [self addSubview:textLabel];
        
        UIColor *initialColor = [UIColor colorWithRed:0.471 green:0.518 blue:0.553 alpha:1.0];
        UIColor *endColor = [UIColor colorWithRed:0.718 green:0.753 blue:0.78 alpha:1.0];
        NSArray *colors = [NSArray arrayWithObjects:(id)[initialColor CGColor], (id)[endColor CGColor], nil];
        id gradientLayer = self.layer;
        [gradientLayer setColors:colors];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [imgOpenClose release];
    [textLabel release];
    [super dealloc];
}

- (void)touchToogle:(id)sender {
    [self setOpen:!open animated:YES];
}

- (void)setOpen:(BOOL)isOpen {
    [self setOpen:isOpen animated:NO];
}

#pragma mark -
#pragma mark Private methods

- (void)setOpen:(BOOL)isOpen animated:(BOOL)animated {
    open = isOpen;
    
    void (^toogleImage)(void) = ^{ 
        if (open) {
            imgOpenClose.transform = CGAffineTransformMakeRotation(M_PI_2);
            [delegate expandableHeaderView:self sectionDidOpen:section];
        } else {
            imgOpenClose.transform = CGAffineTransformMakeRotation(0);
            [delegate expandableHeaderView:self sectionDidClose:section];
        }    
    }; 
    
    if (animated) {
        [UIView beginAnimations:@"ExpandableHeaderViewChanging" context:nil];
        [UIView setAnimationDuration:0.3];
        toogleImage();
        [UIView commitAnimations];
    } else {
        toogleImage();
    }

}

@end
