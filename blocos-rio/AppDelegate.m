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

#import "BlocosController.h"
#import "BlocosPorBairroController.h"
#import "BlocosService.h"
#import "TrackingService.h"
#import "BackgroundUpdateTabBarController.h"
#import "Desfile.h"

@interface AppDelegate (Private)
- (void)copyBundledBlocosXmlToDocumentsDir;
- (void)atualizarDadosUmaVezPorDia;
- (void)tryToScrollBlocosPorDiaTableView;
- (void)atualizarDataUltimoDesfile;
@end


@implementation AppDelegate {
    TrackingService *trackingService;
    NSOperationQueue *operationQueue;
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@synthesize window;
@synthesize navigationController;
@synthesize tabBarController;

+ (AppDelegate *)sharedDelegate {
    return UIAppDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self copyBundledBlocosXmlToDocumentsDir];
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id dataUltimoDesfile = [userDefaults objectForKey:kDataUltimoDesfileKey];
    if (dataUltimoDesfile == nil) {
        [self atualizarDataUltimoDesfile];
    }

    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];

    BlocosController *blocos = [[[BlocosController alloc] initWithManagedObjectContext:moc] autorelease];
    UINavigationController *navBlocos = [[[UINavigationController alloc] initWithRootViewController:blocos] autorelease];
    blocosPorData = [[BlocosPorDataController alloc] initWithManagedObjectContext:moc];
    UINavigationController *navData = [[[UINavigationController alloc] initWithRootViewController:blocosPorData] autorelease];
    BlocosPorBairroController *bairro = [[[BlocosPorBairroController alloc] initWithManagedObjectContext:moc] autorelease];
    UINavigationController *navBairro = [[[UINavigationController alloc] initWithRootViewController:bairro] autorelease];
    tabBarController = [[BackgroundUpdateTabBarController alloc] initWithManagedObjectContext:moc];
    tabBarController.viewControllers = [NSArray arrayWithObjects: navData, navBlocos, navBairro, nil];
    tabBarController.selectedViewController = navData;
	
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    trackingService = [[TrackingService alloc] init];
    [trackingService trackUsageWithTarget:self selector:_cmd];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    didActiveFromBackground = YES;
    [trackingService trackUsageWithTarget:self selector:_cmd];
    [tabBarController restoreUpdateTabLabel];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (didActiveFromBackground) {
        [self atualizarDadosUmaVezPorDia];
        [self tryToScrollBlocosPorDiaTableView];
        
        didActiveFromBackground = NO;
    }
}

- (void)tryToScrollBlocosPorDiaTableView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastDate = [defaults objectForKey:kBlocoPorDataLastDateSeen];
    NSDate *currentDate = [[NSDate date] dateWithoutTime];
    if ([currentDate compare:lastDate] == NSOrderedDescending) {
        [blocosPorData atualizarProximoDiaDesfiles];
        [blocosPorData scrollToFirstTodaysRow];
        
        [defaults setObject:currentDate forKey:kBlocoPorDataLastDateSeen];
    }
}

- (void)atualizarDadosUmaVezPorDia {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdate = [defaults objectForKey:kBlocosServiceLastUpdateDateKey];
    NSDate *currentDate = [NSDate date];
    if (lastUpdate == nil || ([self shoudlShowOnlyFutureDesfiles] && [currentDate daysSince:lastUpdate] >= 1)) {
        [tabBarController updateData];
    }
    
}

- (BOOL)shoudlShowOnlyFutureDesfiles {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *ultimoDesfile = [defaults objectForKey:kDataUltimoDesfileKey];
    NSDate *currentDate = [NSDate date];
    return [currentDate compare:ultimoDesfile] != NSOrderedDescending;
}

#define USER_UUID_KEY @"UserUUID"
- (NSString *)userUUID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [userDefaults stringForKey:USER_UUID_KEY];
    if (!uuid) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        uuid = (NSString *) CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        CFRelease(uuidRef);

        [userDefaults setObject:uuid forKey:USER_UUID_KEY];
    }
    return uuid;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [trackingService trackUsageWithTarget:self selector:_cmd];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [trackingService trackUsageWithTarget:self selector:_cmd];
}

- (void)dealloc {
    [window release];
    [navigationController release];
    [blocosPorData release];
    [tabBarController release];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    [operationQueue release];
    [trackingService release];
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

- (NSOperationQueue *) operationQueue {
    if (!operationQueue) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
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
            [managedObjectContext_ setMergePolicy:NSOverwriteMergePolicy];
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
#pragma mark Merge da atualização em background
- (void)blocosServiceBackgroundContextDidSave:(NSNotification *)notification {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(blocosServiceBackgroundContextDidSave:)
                               withObject:notification
                            waitUntilDone:NO];
        return;
    }
	
	[[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
    [self atualizarDataUltimoDesfile];
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
        } else {
            // Se der certo atualiza os dados
            BlocosService *service = [[[BlocosService alloc] init] autorelease];
            service.managedObjectContext = self.managedObjectContext;
            [service updateBlocosDataWithLocalXml];
        }
    }    
}

- (void)atualizarDataUltimoDesfile {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Desfile" inManagedObjectContext:[self managedObjectContext]]];
    NSSortDescriptor *sortByData = [[[NSSortDescriptor alloc] initWithKey:@"dataHora" ascending:NO] autorelease];
    [request setSortDescriptors:[NSArray arrayWithObject:sortByData]];
    [request setFetchLimit:1];
    
    NSError *error = nil;
    Desfile *ultimoDesfile = [[[self managedObjectContext] executeFetchRequest:request error:&error] lastObject];
    ZAssert(error == nil, @"Erro ao atualizar data do último desfile. Causa: %@ %@", [error localizedDescription], [error userInfo]);
    [request release];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[ultimoDesfile dataHora] forKey:kDataUltimoDesfileKey];

    [blocosPorData atualizarProximoDiaDesfiles];
}


@end
