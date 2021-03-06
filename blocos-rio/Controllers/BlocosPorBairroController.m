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

#import "BlocosPorBairroController.h"
#import "DesfilesDoBairroController.h"

@implementation BlocosPorBairroController

@synthesize managedObjectContext, fetchedResultsController;
@synthesize tableView = _tableView;


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
        self.title = NSLocalizedString(@"blocos-by-neighborhood.title", @"Title of the view that shows blocos by neighborhood");

        [self configureTabBarItemInterfaceOrientation:[self interfaceOrientation]];

        self.titleImageBaseName = @"nav_bar_titulo_bairros";
    }
    return self;
}

- (void)dealloc {
    [managedObjectContext release];
    [_tableView release];
    [fetchedResultsController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)configureTabBarItemInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [self configureTabBarItemWithTitle:NSLocalizedString(@"tab-bar.blocos-by-neighborhood", @"Title for neighborhoods tab") imageBaseName:@"tab_bar_bairros" forInterfaceOrientation:interfaceOrientation];
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
    self.tableView = [[[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [[self view] addSubview:[self tableView]];

    [self addShadowImageBellowNavigationBarToView];

    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    ZAssert(error == nil, @"Erro ao obter blocos por bairro %@", [error localizedDescription]);
}

- (void)viewDidUnload {
    self.tableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    ZAssert(managedObjectContext, @"managedObjectContext não setado");
	
	if (!fetchedResultsController) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"Bairro" inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"desfiles.@count > 0"]];
		
        NSSortDescriptor *sortByNome = [[[NSSortDescriptor alloc] initWithKey:@"nome" ascending:YES] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObjects:sortByNome, nil]];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext 
																		 sectionNameKeyPath:nil cacheName:nil];
		fetchedResultsController.delegate = self;
		
		[request release];
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
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
    NSString *cellId = @"BlocosPorBairroCell";
    
	NSManagedObject *bairro = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [bairro valueForKey:@"nome"];
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)aTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {    
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id bairro = [self.fetchedResultsController objectAtIndexPath:indexPath];
	DesfilesDoBairroController *desfiles = [[DesfilesDoBairroController alloc] initWithBairro:bairro managedObjectContext:managedObjectContext];
	[self.navigationController pushViewController:desfiles animated:YES];
	[desfiles release];
}

@end
