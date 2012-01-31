//    Copyright 2012 Felipe Cypriano
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

#import "TableHeaderView.h"

#define WIDTH 320
#define HEIGHT 20

@implementation TableHeaderView

- (id)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        CAGradientLayer *gradientLayer = (CAGradientLayer *) [self layer];
        gradientLayer.colors = [NSArray arrayWithObjects:
                (id)[[UIColor colorWithRed:0.988 green:0.655 blue:0.122 alpha:1.000] CGColor],
                (id)[[UIColor colorWithRed:0.890 green:0.557 blue:0.024 alpha:1.000] CGColor], nil];

        UILabel *lblTitle = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, WIDTH, HEIGHT)] autorelease];
        lblTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lblTitle.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        lblTitle.textColor = [UIColor whiteColor];
        lblTitle.shadowColor = [UIColor colorWithRed:0.282 green:0.282 blue:0.282 alpha:1.000];
        lblTitle.shadowOffset = CGSizeMake(0, 1);
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.text = title;
        [self addSubview:lblTitle];
    }
    return self;
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end