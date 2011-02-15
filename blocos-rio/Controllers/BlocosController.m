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

#pragma mark UITableViewDelegate methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Bloco *bloco = (Bloco *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    BlocoDetalhesController *detalhes = [[BlocoDetalhesController alloc] initWithBloco:bloco];
    detalhes.managedObjectContext = self.managedObjectContext;
    [self presentModalViewController:detalhes animated:YES];
    [detalhes release];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"BlocosCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }
    
	NSManagedObject *bloco = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [bloco valueForKey:@"nome"];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)aTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
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

@end
