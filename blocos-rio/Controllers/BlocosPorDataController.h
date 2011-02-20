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

#define kBlocoPorDataLastDateSeen @"BlocosPorDataLastDateSeen"

@interface BlocosPorDataController : UIViewController<NSFetchedResultsControllerDelegate> {
@private
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;

- (IBAction)scrollToFirstTodaysRow;

@end
