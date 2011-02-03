//
//  BlocosController.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 02/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BlocosController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
@private
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
