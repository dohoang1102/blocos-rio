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

#import "OpcoesController.h"


@implementation OpcoesController

@synthesize managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc {
    self = [super init];
    if (self) {
        managedObjectContext = moc;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Opções";
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Opções" image:[UIImage imageNamed:@"opcoes.png"] tag:50] autorelease];
        
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        
    }
    return self;
}

- (void)dealloc {
    [managedObjectContext release];
    [updateIndicator release];
    [lastUpdateDate release];
    [lastUpdateInfo release];
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
    updateIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    lastUpdateDate = [[defaults objectForKey:kLastUpdateDateKey] retain];
    
    lastUpdateInfo = lastUpdateDate == nil ? @"nunca" : [lastUpdateDate dateTimeToMediumStyleString];
    [lastUpdateInfo retain];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [updateIndicator release];
    updateIndicator = nil;
    [lastUpdateInfo release];
    lastUpdateInfo = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"CellId";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = updateIndicator;
        
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.minimumFontSize = 8;
    }
    
    cell.textLabel.text = @"Atualizar Dados";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Última atualização: %@", lastUpdateInfo, nil];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return [updateIndicator isAnimating] ? nil : indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [updateIndicator startAnimating];
    
    BlocosService *service = [[BlocosService alloc] init];
    service.delegate = self;
    service.managedObjectContext = managedObjectContext;
    [service updateBlocosData];
    [service release];
}

#pragma mark -
#pragma mark BlocosServiceDelegate methods
- (void)blocosService:(BlocosService *)blocosService didUpdateBlocosDataOnDate:(NSDate *)lastUpdate {
    lastUpdateDate = [lastUpdate retain];
    lastUpdateInfo = [[lastUpdateDate dateTimeToMediumStyleString] retain];
    [updateIndicator stopAnimating];
    [self.tableView reloadData];
}

- (void)blocosService:(BlocosService *)blocosService didFailWithError:(NSError *)error {
    lastUpdateInfo = [@"(erro)" retain];
    [updateIndicator stopAnimating];
    [self.tableView reloadData];
    DLog(@"Fail to update %@", error);
}



@end
