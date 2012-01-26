//    Copyright 2012 Felipe Cypriano
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

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import "MapController.h"
#import "Desfile.h"

@interface MapController ()
- (void)forwardGeocodeDesfile:(Desfile *)desfile;

- (UIView *)titleViewForDesfile:(Desfile *)desfile;

- (UIView *)showActivityIndicatorView;


@end

@implementation MapController {
    MKMapView *mapView_;
    Desfile *desfile_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (id)iniWithDesfile:(Desfile *)desfile {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        desfile_ = [desfile retain];
        self.title = [NSString stringWithFormat:@"%@ %@", desfile.bloco.nome, [desfile.dataHora timeToString]];
        self.navigationItem.titleView = [self titleViewForDesfile:desfile];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)backButtonTouched:(id)backButtonTouched {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    mapView_ = [[MKMapView alloc] initWithFrame:[[self view] bounds]];
    mapView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mapView_.delegate = self;

    MKCoordinateRegion brazilRegion;
    brazilRegion.center = CLLocationCoordinate2DMake(-14.239424, -53.186502);
    brazilRegion.span = MKCoordinateSpanMake(1, 30);
    mapView_.region = brazilRegion;
    [mapView_ regionThatFits:brazilRegion];
    [[self view] addSubview:mapView_];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(6, 6, 46, 55);
    [back addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:back];

    [self forwardGeocodeDesfile:desfile_];
}

- (void)viewDidUnload {
    [mapView_ release];
    mapView_ = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [desfile_ release];
    [mapView_ release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *view in views) {
        CGRect endFrame = [view frame];

        CGRect startFrame = endFrame;
        startFrame.origin.x = [view center].x;
        startFrame.origin.y += endFrame.size.height;
        startFrame.size.height = 0;
        startFrame.size.width = 0;
        view.frame = startFrame;
        
        [UIView animateWithDuration:.5 animations:^void() {
            view.frame = endFrame;
        }];
    }

}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Private methods

- (NSString *)onlyAddressStreet {
    NSString *street = [desfile_ endereco];
    NSRange commaLocation = [street rangeOfString:@","];
    if (!NSEqualRanges(commaLocation, NSMakeRange(NSNotFound, 0))) {
        street = [street substringToIndex:commaLocation.location];
    }
    return street;
}

- (void)forwardGeocodeDesfile:(Desfile *)desfile {
    NSDictionary *addressDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            @"Brazil", kABPersonAddressCountryKey,
            @"br", kABPersonAddressCountryCodeKey,
            @"Rio de Janeiro", kABPersonAddressCityKey,
            @"Rio de Janeiro", kABPersonAddressStateKey,
            [NSString stringWithFormat:@"%@ - %@", [self onlyAddressStreet], desfile.bairro.nome], kABPersonAddressStreetKey,
            nil];

    UIView *activity = [self showActivityIndicatorView];
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    [geocoder geocodeAddressDictionary:addressDictionary completionHandler:^void(NSArray *placemarks, NSError *error) {
        [activity removeFromSuperview];
        if (error) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"map.geocode.error.title", @"The title when can't geocode an address")
                                                                 message:NSLocalizedString(@"map.geocode.error.message", @"The error messagem when can't geocode an address")
                                                                delegate:self
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
            DLog(@"geocoder fail %@", [error localizedDescription]);
            return;
        }

        CLPlacemark *topPlacemark = [placemarks objectAtIndex:0];
        MKPlacemark *annotation = [[MKPlacemark alloc] initWithPlacemark:topPlacemark];
        [mapView_ addAnnotation:annotation];
        [annotation release];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(topPlacemark.location.coordinate,
                500, 500);
        [mapView_ setRegion:region animated:YES];
        [mapView_ regionThatFits:region];
    }];
}

- (UIView *)titleViewForDesfile:(Desfile *)desfile {
    UIView *title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)] autorelease];
    title.backgroundColor = [UIColor clearColor];
    title.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    UILabel *label = [[[UILabel alloc] initWithFrame:[title bounds]] autorelease];
    label.frame = CGRectOffset(label.frame, 10, 0);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:11.0f];
    label.numberOfLines = 3;
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textColor = [UIColor colorWithRed:0.310 green:0.310 blue:0.310 alpha:1.000];
    label.text = [NSString stringWithFormat:@"%@ %@\n%@ - %@", desfile.bloco.nome, [desfile.dataHora timeToString], desfile.endereco, desfile.bairro.nome];
    [title addSubview:label];
    return title;
}

- (UIView *)showActivityIndicatorView {
    UIView *rounded = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)] autorelease];
    rounded.center = [[self view] center];
    rounded.backgroundColor = [UIColor colorWithRed:0.424 green:0.424 blue:0.424 alpha:.8];
    rounded.layer.cornerRadius = 10;
    rounded.autoresizingMask = UIViewAutoresizingNone;

    UIActivityIndicatorView *activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    activityIndicator.center = CGPointMake(40, 40);
    activityIndicator.autoresizingMask = UIViewAutoresizingNone;
    [activityIndicator startAnimating];
    [rounded addSubview:activityIndicator];
    
    [[self view] addSubview:rounded];
    
    return rounded;
}

@end