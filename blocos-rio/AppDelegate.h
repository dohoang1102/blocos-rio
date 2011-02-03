//
//  blocos_rioAppDelegate.h
//  blocos-rio
//
//  Created by Felipe Cypriano on 02/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject <UIApplicationDelegate> {
@private

    UINavigationController *navigationController;
}

+ (AppDelegate *)sharedDelegate;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
