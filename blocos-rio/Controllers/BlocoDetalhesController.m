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

@interface BlocoDetalhesController (Private)

- (void)updateComponentWithBlocoData;

@end

@implementation BlocoDetalhesController

@synthesize lblNome, tableView, bloco, managedObjectContext, desfilesFetchedResults;

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
    NSError *error = nil;
    [self.desfilesFetchedResults performFetch:&error];
    ZAssert(error == nil, @"Erro ao obter desfiles do bloco %@: %@", bloco, [error localizedDescription]);    
    
    [self updateComponentWithBlocoData];
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Ações" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:nil 
                                     otherButtonTitles:@"Ver no Mapa", nil];
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
    [actionSheet release];
    actionSheet = nil;
}


- (void)dealloc {
    [lblNome release];
    [tableView release];
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
    }
    
    cell.textLabel.text = [desfile.dataHora dateTimeToMediumStyleString];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", desfile.endereco, desfile.bairro.nome];
    cell.detailTextLabel.numberOfLines = 2;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    NSString *title = nil;
    if (section == 0) {
        title = @"Desfiles";
    }
    
    return title;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [actionSheet showInView:self.view];
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
		[request setFetchBatchSize:20];
		
		NSSortDescriptor *sortByData = [[[NSSortDescriptor alloc] initWithKey:@"dataHora" ascending:YES] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObjects:sortByData, nil]];
		
		desfilesFetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext 
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
#pragma mark Eventos da view

- (IBAction)btnVoltarTouched {
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBlocoDetalhesDismissModalNotification object:self];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        Desfile *desfile = (Desfile *) [self.desfilesFetchedResults objectAtIndexPath:[tableView indexPathForSelectedRow]];
        NSString *mapsQuery = [NSString stringWithFormat:@"%@, %@ - Rio de Janeiro", desfile.endereco, desfile.bairro.nome];
        NSString *mapsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [mapsQuery stringWithPercentEscape]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsURL]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    }
}

#pragma mark -
#pragma mark Private methods

- (void)updateComponentWithBlocoData {
    self.title = bloco.nome ? bloco.nome : @"Detalhes";
    lblNome.text = bloco.nome;
    
    CGRect newLabelFrame = lblNome.frame;
    newLabelFrame.size.height = [lblNome.text sizeWithFont:lblNome.font constrainedToSize:CGSizeMake(312, 40)].height;
    lblNome.frame = newLabelFrame;
    
    UIView *headerView = lblNome.superview;
    CGRect newHeaderFrame = headerView.frame;
    newHeaderFrame.size.height = lblNome.frame.size.height + lblNome.frame.origin.y;
    headerView.frame = newHeaderFrame;
}

@end
