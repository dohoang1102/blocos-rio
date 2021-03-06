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
#import "MapController.h"
#import "TableHeaderView.h"

#define TITLE_TO_BACK_BUTTON NSLocalizedString(@"blocos-by-day.back-button.title", @"The small title to show on the back button")
#define TITLE NSLocalizedString(@"blocos-by-day.title", @"The title of the view blocos by day")

@implementation BlocosPorDataController

@synthesize btnHoje;
@synthesize tableView = tableView_;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

- (id)init {
    self = [self initWithNibName:nil bundle:nil];
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
        self.title = TITLE;

        [self configureTabBarItemInterfaceOrientation:[self interfaceOrientation]];

        btnHoje = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Today", @"Dictionary", @"The word 'Today'")
                                                   style:UIBarButtonItemStyleBordered
                                                  target:self
                                                  action:@selector(scrollToFirstTodaysRow)];
        self.navigationItem.rightBarButtonItem = btnHoje;

        self.titleImageBaseName = @"nav_bar_titulo_dia";
    }
    return self;
}

- (void)dealloc {
    [tableView_ release];
    [managedObjectContext release];
    [fetchedResultsController release];
    [btnHoje release];
    [proximoDiaDesfiles release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)configureTabBarItemInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [self configureTabBarItemWithTitle:NSLocalizedString(@"tab-bar.blocos-by-day.title", @"Title for blocos by day")
                         imageBaseName:@"tab_bar_dia"
               forInterfaceOrientation:interfaceOrientation];
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
    tableView_ = [[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStylePlain];
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView_.delegate = self;
    tableView_.dataSource = self;
    tableView_.separatorColor = [UIColor colorWithRed:0.937 green:0.769 blue:0.502 alpha:1.000];
    tableView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView_.rowHeight = [DesfileEnderecoCell rowHeight];
    [[self view] addSubview:tableView_];

    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    ZAssert(error == nil, @"Erro ao obter blocos %@", [error localizedDescription]); 
    
    if ([[AppDelegate sharedDelegate] shoudlShowOnlyFutureDesfiles]) {
        [self atualizarProximoDiaDesfiles];
    } else {
        btnHoje.title = NSLocalizedStringFromTable(@"Top", @"Dictionary",  @"The word 'top', used to scrool to the top in blocos by day view");
        btnHoje.action = @selector(scrollToTableViewTop);
    }

    [self addShadowImageBellowNavigationBarToView];
}

- (void)atualizarProximoDiaDesfiles {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Desfile" inManagedObjectContext:managedObjectContext]];
    NSDate *currentDate = [[NSDate date] dateWithoutTime];
    [request setPredicate:[NSPredicate predicateWithFormat:@"dataHora >= %@ AND dataHora != NULL", currentDate]];
    NSSortDescriptor *sortByData = [[[NSSortDescriptor alloc] initWithKey:@"dataHora" ascending:YES] autorelease];
    [request setSortDescriptors:[NSArray arrayWithObject:sortByData]];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *desfiles = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    ZAssert(error == nil, @"Erro ao obter primeiro dia de desfiles %@", [error localizedDescription]);
    if (desfiles.count > 0) {
        proximoDiaDesfiles = [[[desfiles objectAtIndex:0] dataHora] retain];
        
        if ([[proximoDiaDesfiles dateWithoutTime] compare:[[NSDate date] dateWithoutTime]] == NSOrderedSame) {
            btnHoje.title = NSLocalizedStringFromTable(@"Today", @"Dictionary", @"The word 'Today'");
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd";
            btnHoje.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"Day", @"Dictionary", @"The word 'day'"), [dateFormatter stringFromDate:proximoDiaDesfiles]];
            [dateFormatter release];
        }
    } else {
        proximoDiaDesfiles = [[NSDate date] retain];
        btnHoje.title = NSLocalizedStringFromTable(@"Today", @"Dictionary", @"The word 'Today'");
    }
}

- (void)viewDidUnload {
    [proximoDiaDesfiles release];
    proximoDiaDesfiles = nil;
    [tableView_ release];
    tableView_ = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = TITLE;
    [tableView_ deselectRowAtIndexPath:[tableView_ indexPathForSelectedRow] animated:animated];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    ZAssert(managedObjectContext, @"managedObjectContext não setado");
	
	if (!fetchedResultsController) {
        NSDate *currentDate = [[NSDate date] dateWithoutTime];
        
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:[NSEntityDescription entityForName:@"Desfile" inManagedObjectContext:managedObjectContext]];
        if ([[AppDelegate sharedDelegate] shoudlShowOnlyFutureDesfiles]) {
            [request setPredicate:[NSPredicate predicateWithFormat:@"dataHora >= %@ OR dataHora = NULL", currentDate]];
        }        
		
		NSSortDescriptor *sortByData = [[[NSSortDescriptor alloc] initWithKey:@"dataHora" ascending:YES] autorelease];
		[request setSortDescriptors:[NSArray arrayWithObject:sortByData]];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext 
																		 sectionNameKeyPath:@"dataSemHora" cacheName:nil];
		fetchedResultsController.delegate = self;
		
		[request release];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:currentDate forKey:kBlocoPorDataLastDateSeen];        
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [tableView_ reloadData];
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
        cell = [[[DesfileEnderecoCell alloc] initWithReuseIdentifier:cellId] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	[cell updateWithDesfile:desfile];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [[[TableHeaderView alloc] initWithTitle:[sectionInfo name]] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.title = TITLE_TO_BACK_BUTTON;
	Desfile *desfile = (Desfile *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    MapController *mapController = [[MapController alloc] iniWithDesfile:desfile];
    [[self navigationController] pushViewController:mapController animated:YES];
    [mapController release];
}

#pragma mark -
#pragma mark Eventos da view

- (IBAction)scrollToFirstTodaysRow {
    NSString *proximaDataSemHora = [Desfile dateToDataSemHora:proximoDiaDesfiles];
    NSUInteger section = NSNotFound;
    NSArray *sections = [self.fetchedResultsController sections];
    for (NSUInteger i = 0; i < sections.count; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:i];
        if ([[sectionInfo name] isEqual:proximaDataSemHora]) {
            section = i;
            break;
        }
    }
    if (section != NSNotFound) {
        NSIndexPath *firstTodaysRow = [NSIndexPath indexPathForRow:0 inSection:section];
        [tableView_ scrollToRowAtIndexPath:firstTodaysRow atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)scrollToTableViewTop {
    [tableView_ setContentOffset:CGPointZero animated:YES];
}

@end
