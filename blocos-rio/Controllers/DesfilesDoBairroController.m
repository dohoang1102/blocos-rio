    //
//  DesfilesDoBairroController.m
//  blocos-rio
//
//  Created by Felipe Cypriano on 24/02/11.
//  Copyright 2011 Felipe Cypriano. All rights reserved.
//

#import "DesfilesDoBairroController.h"
#import "BlocoDetalhesController.h"
#import "Bairro.h"
#import "DesfileEnderecoCell.h"

@implementation DesfilesDoBairroController

@synthesize managedObjectContext, fetchedResultsController;

- (id)initWithBairro:(Bairro *)bairro managedObjectContext:(NSManagedObjectContext *)moc {
	self = [super init];
	if (self) {
		self.managedObjectContext = moc;
		bairroId = [[bairro objectID] retain];
		self.title = bairro.nome;
	}
	return self;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    ZAssert(error == nil, @"Erro ao obter blocos %@", [error localizedDescription]); 	

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deselectSelectedRow:) name:kBlocoDetalhesDismissModalNotification object:nil];
}

- (void)deselectSelectedRow:(NSNotification *)notification {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
	[bairroId release];
    [super dealloc];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    ZAssert(managedObjectContext, @"managedObjectContext não setado");
	
	if (!fetchedResultsController) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"Desfile" inManagedObjectContext:managedObjectContext]];
		id bairro = [managedObjectContext objectWithID:bairroId];
		[request setPredicate:[NSPredicate predicateWithFormat:@"bairro == %@ AND dataHora >= %@", bairro, [NSDate date]]];
		[request setFetchBatchSize:20];
		
        NSSortDescriptor *sortByDataHora = [[[NSSortDescriptor alloc] initWithKey:@"dataHora" ascending:YES] autorelease];
        NSSortDescriptor *sortByNome = [[[NSSortDescriptor alloc] initWithKey:@"bloco.nome" ascending:YES] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObjects:sortByDataHora, sortByNome, nil]];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext 
																		 sectionNameKeyPath:@"dataSemHora" cacheName:nil];
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
    NSString *cellId = @"BlocosPorDataCell";
    
	id desfile = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    DesfileEnderecoCell *cell = (DesfileEnderecoCell *) [aTableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[DesfileEnderecoCell alloc] initWithReuseIdentifier:cellId] autorelease];
    }
	
	[cell updateWithDesfile:desfile];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id desfile = [self.fetchedResultsController objectAtIndexPath:indexPath];
	BlocoDetalhesController *detalhes = [[BlocoDetalhesController alloc] initWithBloco:[desfile valueForKey:@"bloco"]];
	detalhes.managedObjectContext = self.managedObjectContext;
	[self presentModalViewController:detalhes animated:YES];
	[detalhes release];
}

@end
