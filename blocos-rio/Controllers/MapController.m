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

@end

@implementation MapController {
    MKMapView *mapView_;
    Desfile *desfile_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (id)iniWithDesfile:(Desfile *)desfile {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        desfile_ = [desfile retain];
        self.title = [NSString stringWithFormat:@"%@ %@", desfile.bloco.nome, [desfile.dataHora timeToString]];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    mapView_ = [[MKMapView alloc] initWithFrame:[[self view] bounds]];
    mapView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mapView_.delegate = self;

    // http://maps.google.com.br/?ll=-14.239424,-53.186502&spn=51.291196,79.013672&t=m&z=4&vpsrc=1
    MKCoordinateRegion brazilRegion;
    brazilRegion.center = CLLocationCoordinate2DMake(-14.239424, -53.186502);
    brazilRegion.span = MKCoordinateSpanMake(1, 30);
    mapView_.region = brazilRegion;
    [mapView_ regionThatFits:brazilRegion];
    [[self view] addSubview:mapView_];

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
#pragma mark Private methods

- (void)forwardGeocodeDesfile:(Desfile *)desfile {
    NSDictionary *addressDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
            @"Brazil", kABPersonAddressCountryKey,
            @"br", kABPersonAddressCountryCodeKey,
            @"Rio de Janeiro", kABPersonAddressCityKey,
            @"Rio de Janeiro", kABPersonAddressStateKey,
            [NSString stringWithFormat:@"%@ - %@", desfile.endereco, desfile.bairro.nome], kABPersonAddressStreetKey,
            nil];

    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    [geocoder geocodeAddressDictionary:addressDictionary completionHandler:^void(NSArray *placemarks, NSError *error) {
        if (error) {
            // TODO handle the error
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

@end