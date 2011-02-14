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

#import <UIKit/UIKit.h>

@class ExpandableHeaderView;

@protocol ExpandableHeaderViewDelegate <NSObject>

@required
- (void)expandableHeaderView:(ExpandableHeaderView *)expandableHeaderView sectionDidOpen:(NSInteger)section;
- (void)expandableHeaderView:(ExpandableHeaderView *)expandableHeaderView sectionDidClose:(NSInteger)section;

@end


@interface ExpandableHeaderView : UIView {
@private
    UIImageView *imgOpenClose;
}

+ (CGFloat)viewHeight;
+ (ExpandableHeaderView *)expandableHeaderViewForSection:(NSInteger)section opened:(BOOL)opened;

@property (nonatomic, retain, readonly) UILabel *textLabel; 
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign, getter=isOpen) BOOL open;
@property (nonatomic, assign) id<ExpandableHeaderViewDelegate> delegate;

- (void)touchToogle:(id)sender;

@end
