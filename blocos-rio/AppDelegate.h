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
#import "BlocosPorDataController.h"

#define kDataUltimoDesfileKey @"DataUltimoDesfileUserKey"

@class OpcoesController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
@private
    UINavigationController *navigationController;
    BOOL didActiveFromBackground;
    BlocosPorDataController *blocosPorData;
    OpcoesController *opcoesController;
}

+ (AppDelegate *)sharedDelegate;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

// Core Data
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSOperationQueue *operationQueue; 

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)applicationDocumentsDirectoryString;
- (BOOL)shoudlShowOnlyFutureDesfiles;


@end
