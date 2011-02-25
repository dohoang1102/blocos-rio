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
#import "BlocosService.h"
#import "Bloco.h"
#import "BlocoDetalhesController.h"

@implementation BlocosController

@synthesize tableView, fetchedResultsController, managedObjectContext;

- (id)init {
    self = [self initWithNibName:@"Blocos" bundle:nil];
    return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc {
    self = [self init];
    if (self) {
        self.managedObjectContext = moc;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Blocos";
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Blocos" image:[UIImage imageNamed:@"por-blocos.png"] tag:10] autorelease];
    }
    return self;
}

- (void)dealloc {
    [tableView release];
    [managedObjectContext release];
    [fetchedResultsController release];
    [searchResultsArray release];
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
    
    searchFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *blocoEntity = [NSEntityDescription entityForName:@"Bloco" inManagedObjectContext:managedObjectContext];
    [searchFetchRequest setEntity:blocoEntity];    
    NSSortDescriptor *sortSearchByNome = [NSSortDescriptor sortDescriptorWithKey:@"nome" ascending:YES];
    [searchFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortSearchByNome]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectSelectedRow:) name:kBlocoDetalhesDismissModalNotification object:nil];
}

- (void)deselectSelectedRow:(NSNotification *)notification {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [searchFetchRequest release];
    searchFetchRequest = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark UITableViewDelegate methods

- (void) tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Bloco *bloco = nil;
    if (aTableView == self.tableView) {
        bloco = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else if (aTableView == self.searchDisplayController.searchResultsTableView) {
        bloco = [searchResultsArray objectAtIndex:indexPath.row];
    }

    BlocoDetalhesController *detalhes = [[BlocoDetalhesController alloc] initWithBloco:bloco];
    detalhes.managedObjectContext = self.managedObjectContext;
    [self presentModalViewController:detalhes animated:YES];
    [detalhes release];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    NSInteger numberOfSections = 1;
    if (aTableView == self.tableView) {
        numberOfSections = [[self.fetchedResultsController sections] count];
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (aTableView == self.tableView) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    } else if (aTableView == self.searchDisplayController.searchResultsTableView) {
        numberOfRows = [searchResultsArray count];
    }

    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"BlocosCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
    
	NSManagedObject *bloco = nil;
    if (aTableView == self.tableView) {
        bloco = [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else if (aTableView == self.searchDisplayController.searchResultsTableView) {
        bloco = [searchResultsArray objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = [bloco valueForKey:@"nome"];

    return cell;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section { 
    NSString *title = @"Resultados";
    if (aTableView == self.tableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        title = [sectionInfo name];
    }
    return title;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView {
    NSMutableArray *indexTitles = nil;
    if (aTableView == self.tableView) {
        indexTitles = [NSMutableArray arrayWithObject:UITableViewIndexSearch];  // add magnifying glass
        [indexTitles addObjectsFromArray:[self.fetchedResultsController sectionIndexTitles]];
    }
    
    return indexTitles;
}

- (NSInteger)tableView:(UITableView *)aTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {    
    NSInteger section = -1;
    if (title == UITableViewIndexSearch) {
        [aTableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
    } else {
        section = [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index-1];
    }

    return section;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
	ZAssert(managedObjectContext, @"BlocosController - managedObjectContext não setado");
	
	if (!fetchedResultsController) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"Bloco" inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"desfiles.@count > 0"]];
		[request setFetchBatchSize:20];
		
		NSSortDescriptor *sortByNome = [[[NSSortDescriptor alloc] initWithKey:@"nomeSemAcento" ascending:YES] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObject:sortByNome]];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext 
																		 sectionNameKeyPath:@"nomeLetraInicial" cacheName:@"ListaBlocosCache"];
		fetchedResultsController.delegate = self;
		
		[request release];
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [tableView reloadData];
}

#pragma mark -
#pragma mark Search methods

- (void)searchBlocosByNome:(NSString *)searchTerm {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *blocoEntity = [NSEntityDescription entityForName:@"Bloco" inManagedObjectContext:managedObjectContext];
    [request setEntity:blocoEntity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"nome CONTAINS[cd] %@ AND desfiles.@count > 0", searchTerm]];
    
    NSError *error = nil;
    if (searchResultsArray) {
        [searchResultsArray release];
    }
    searchResultsArray = [[managedObjectContext executeFetchRequest:request error:&error] retain];
    [request release];
    ZAssert(error == nil, @"Erro ao procurar bloco por nome %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark UISearchDisplayControllerDelegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self searchBlocosByNome:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
