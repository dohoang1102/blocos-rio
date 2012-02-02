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

#import "BlocoDetalhesController.h"
#import "Desfile.h"
#import "MapController.h"
#import "TableHeaderView.h"

@interface BlocoDetalhesController (Private)

- (void)updateComponentWithBlocoData;

@end

@implementation BlocoDetalhesController

@synthesize desfilesFetchedResults;
@synthesize managedObjectContext;
@synthesize bloco;
@synthesize lblNome;
@synthesize tableView = tableView_;

- (id)initWithBloco:(Bloco *)newBloco {
    self = [self initWithNibName:@"BlocoDetalhes" bundle:nil];
    if (self) {
        self.bloco = newBloco;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        maxRowSize = 44.0;
        self.title = NSLocalizedStringFromTable(@"details", @"Dictionary", @"The word 'details'");
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self addShadowImageBellowNavigationBarToView];

    NSError *error = nil;
    [self.desfilesFetchedResults performFetch:&error];
    ZAssert(error == nil, @"Erro ao obter desfiles do bloco %@: %@", bloco, [error localizedDescription]);    
    
    [self updateComponentWithBlocoData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [lblNome release];
    [tableView_ release];
    [bloco release];
    [managedObjectContext release];
    [desfilesFetchedResults release];
    [super dealloc];
}

- (void)setBloco:(Bloco *)newBloco {
    if (newBloco != bloco) {
        [bloco release];
        bloco = [newBloco retain];
    }
    
    [self updateComponentWithBlocoData];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	id<NSFetchedResultsSectionInfo> sectionInfo = [[self.desfilesFetchedResults sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"BlocosPorBairroCell";
    
	Desfile *desfile = (Desfile *) [self.desfilesFetchedResults objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [desfile.dataHora dateTimeToMediumStyleString];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", desfile.endereco, desfile.bairro.nome];
    cell.detailTextLabel.numberOfLines = 2;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (section == 0) {
        title = NSLocalizedStringFromTable(@"Parades", @"Dictionary", @"The word 'parades");
    }
    return [[[TableHeaderView alloc] initWithTitle:title] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZAssert([self navigationController], @"BlocoDetalhesController must be in a UINavigationController");

    Desfile *desfile = (Desfile *) [self.desfilesFetchedResults objectAtIndexPath:[tableView indexPathForSelectedRow]];

    MapController *mapController = [[MapController alloc] iniWithDesfile:desfile];
    [[self navigationController] pushViewController:mapController animated:YES];
    [mapController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)desfilesFetchedResults {
    ZAssert(managedObjectContext, @"managedObjectContext não setado");
	
	if (!desfilesFetchedResults) {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"Desfile" inManagedObjectContext:managedObjectContext]];
		[request setPredicate:[NSPredicate predicateWithFormat:@"bloco = %@", bloco]];
		
		NSSortDescriptor *sortByData = [[[NSSortDescriptor alloc] initWithKey:@"dataHora" ascending:YES] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObjects:sortByData, nil]];

        desfilesFetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                     managedObjectContext:managedObjectContext
                                                                       sectionNameKeyPath:nil cacheName:nil];
		desfilesFetchedResults.delegate = self;
		
		[request release];
	}
	
	return desfilesFetchedResults;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Private methods

- (void)updateComponentWithBlocoData {
    lblNome.text = bloco.nome;
}

@end
