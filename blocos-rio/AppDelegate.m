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

#import "AppDelegate.h"
#import "BlocosController.h"
#import "BlocosPorDataController.h"
#import "FavoritosController.h"
#import "BlocosPorBairroController.h"
#import "BlocosService.h"

@interface AppDelegate (Private)
- (void)copyBundledBlocosXmlToDocumentsDir;
@end


@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize tabBarController;

@synthesize managedObjectContext=managedObjectContext_, managedObjectModel=managedObjectModel_, persistentStoreCoordinator=persistentStoreCoordinator_;

+ (AppDelegate *)sharedDelegate {
    return [UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self copyBundledBlocosXmlToDocumentsDir];

    BlocosService *service = [[[BlocosService alloc] init] autorelease];
    service.managedObjectContext = self.managedObjectContext;
    [service updateBlocosData];
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    BlocosController *blocos = [[[BlocosController alloc] initWithManagedObjectContext:moc] autorelease];
    BlocosPorDataController *blocosPorData = [[[BlocosPorDataController alloc] initWithManagedObjectContext:moc] autorelease];
    BlocosPorBairroController *bairro = [[[BlocosPorBairroController alloc] init] autorelease];
    FavoritosController *favoritos = [[[FavoritosController alloc] init] autorelease];
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = [NSArray arrayWithObjects: blocosPorData, blocos, bairro, favoritos, nil];
    tabBarController.selectedViewController = blocosPorData;
	
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate.
}

- (void)dealloc {
    [window release];
    [navigationController release];
    [tabBarController release];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    [super dealloc];
}


- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext { 
    if (managedObjectContext_ == nil) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            managedObjectContext_ = [[NSManagedObjectContext alloc] init];
            [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
        }
    }
    
    return managedObjectContext_;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel_ == nil) {
        managedObjectModel_ = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    }
    
    return managedObjectModel_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator { 
    if (persistentStoreCoordinator_ == nil) {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Blocos.sqlite"];
        
        NSError *error = nil;
        persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }    
    }
    
    
    return persistentStoreCoordinator_;
}

#pragma mark - Application's Documents directory

- (NSString *)applicationDocumentsDirectoryString {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [NSURL fileURLWithPath:[self applicationDocumentsDirectoryString]];
}

- (void)awakeFromNib {
    UIViewController *rootViewController = [navigationController topViewController];
    
    SEL setContext = @selector(setManagedObjectContext:);
    if ([rootViewController respondsToSelector:setContext]) {
        [rootViewController performSelector:setContext withObject:self.managedObjectContext];
    }
}


#pragma mark -
#pragma mark Private methods
- (void)copyBundledBlocosXmlToDocumentsDir {
    NSString *xmlBundled = [[NSBundle mainBundle] pathForResource:@"blocos" ofType:@"xml"];
    NSString *blocosXmlPath = [[BlocosService blocosXmlUrl] path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:blocosXmlPath]) {
        NSError *copyError = nil;
        if (![fileManager copyItemAtPath:xmlBundled toPath:blocosXmlPath error:&copyError]) {
            NSLog(@"ERRO ao copiar arquivo xml. Causa: %@", copyError);
        }
    }    
}


@end
