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

#import "BlocosPorDataController.h"
#import "DesfileEnderecoCell.h"
#import "Desfile.h"
#import "BlocoDetalhesController.h"


@implementation BlocosPorDataController

@synthesize managedObjectContext, fetchedResultsController, tableView;

- (id)init {
    self = [self initWithNibName:@"BlocosPorData" bundle:nil];
    return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc {
    self = [super init];
    if (self) {
        self.managedObjectContext = moc;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Blocos Por Dia";
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Dia" image:[UIImage imageNamed:@"por-data.png"] tag:20] autorelease];
    }
    return self;
}

- (void)dealloc {
    [tableView release];
    [managedObjectContext release];
    [fetchedResultsController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    ZAssert(error == nil, @"Erro ao obter blocos %@", [error localizedDescription]);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    ZAssert(managedObjectContext, @"managedObjectContext não setado");
	
	if (!fetchedResultsController) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"Desfile" inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"dataHora >= %@ OR dataHora = NULL", [NSDate date]]];
		[request setFetchBatchSize:20];
		
		NSSortDescriptor *sortByData = [[[NSSortDescriptor alloc] initWithKey:@"dataHora" ascending:YES] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObject:sortByData]];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext 
																		 sectionNameKeyPath:@"dataSemHora" cacheName:nil];
		fetchedResultsController.delegate = self;
		
		[request release];
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [tableView reloadData];
}

#pragma mark -
#pragma UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"BlocosPorDataCell";
    
	Desfile *desfile = (Desfile *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    DesfileEnderecoCell *cell = (DesfileEnderecoCell *) [aTableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[DesfileEnderecoCell alloc] initWithDesfile:desfile reuseIdentifier:cellId] autorelease];
    } else {
        cell.desfile = desfile;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Desfile *desfile = (Desfile *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    BlocoDetalhesController *detalhes = [[BlocoDetalhesController alloc] initWithBloco:desfile.bloco];
    detalhes.managedObjectContext = self.managedObjectContext;
    [self presentModalViewController:detalhes animated:YES];
    [detalhes release];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return [ExpandableHeaderView viewHeight];
//}
//
//- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
//    ExpandableHeaderView *header = [ExpandableHeaderView expandableHeaderViewForSection:section opened:YES];
//    header.textLabel.text = [self tableView:aTableView titleForHeaderInSection:(NSInteger)section];
//    return header;
//}

@end
