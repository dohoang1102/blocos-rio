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

#define OVERLAY_ALPHA_WHEN_SCROLLING 0.2f
#define DESFILE_DATA_VIEW_POSITION_X_PORTRAIT 56.0f
#define DESFILE_DATA_VIEW_WIDTH_PORTRAIT 255.0f
#define DESFILE_DATA_VIEW_WIDTH_LANDSCAPE 416.0f
#define DESFILE_DATA_IMAGE_NAME_PORTRAIT @"mapa_contianer_endereco"
#define DESFILE_DATA_IMAGE_NAME_LANDSCAPE @"mapa_contianer_endereco_landscape"

@interface MapController ()
- (void)forwardGeocodeDesfile:(Desfile *)desfile;

- (UIView *)showActivityIndicatorView;

- (void)addDesfileDataAndBackButtonToView;


@end

@implementation MapController {
    MKMapView *mapView_;
    Desfile *desfile_;
    UIButton *backButton_;
    UIView *desfileData_;
    UIImageView *desfileDataImageView_;
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
    mapView_ = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    mapView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mapView_.delegate = self;

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
    [backButton_ release];
    backButton_ = nil;
    [desfileData_ release];
    desfileData_ = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [desfile_ release];
    [mapView_ release];
    [backButton_ release];
    [desfileData_ release];
    [desfileDataImageView_ release];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];  //To change the template use AppCode | Preferences | File Templates.
    NSString *imageName = DESFILE_DATA_IMAGE_NAME_PORTRAIT;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        imageName = DESFILE_DATA_IMAGE_NAME_LANDSCAPE;
    }
    desfileDataImageView_.image = [UIImage imageNamed:imageName];
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

        [self addDesfileDataAndBackButtonToView];
        backButton_.alpha = 0;
        desfileData_.alpha = 0;
        [UIView animateWithDuration:.5 animations:^void() {
            view.frame = endFrame;
            backButton_.alpha = 1;
            desfileData_.alpha = 1;
        }];
    }

}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [UIView animateWithDuration:.2 animations:^void() {
        backButton_.alpha = OVERLAY_ALPHA_WHEN_SCROLLING;
        desfileData_.alpha = OVERLAY_ALPHA_WHEN_SCROLLING;
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [UIView animateWithDuration:.2 animations:^void() {
        backButton_.alpha = 1;
        desfileData_.alpha = 1;
    }];
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

- (void)addDesfileDataAndBackButtonToView {
    backButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    backButton_.frame = CGRectMake(6, 6, 70, 70);
    backButton_.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [backButton_ setImage:[UIImage imageNamed:@"mapa_botao_voltar"] forState:UIControlStateNormal];
    backButton_.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 25);
    [backButton_ addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:backButton_];

    CGFloat positionX = DESFILE_DATA_VIEW_POSITION_X_PORTRAIT;
    CGFloat width = DESFILE_DATA_VIEW_WIDTH_PORTRAIT;
    NSString *imageName = DESFILE_DATA_IMAGE_NAME_PORTRAIT;
    if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
        imageName = DESFILE_DATA_IMAGE_NAME_LANDSCAPE;
        width = DESFILE_DATA_VIEW_WIDTH_LANDSCAPE;
    }

    desfileData_ = [[UIView alloc] initWithFrame:CGRectMake(positionX, 6, width, 70)];
    desfileData_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    desfileData_.backgroundColor = [UIColor clearColor];

    desfileDataImageView_ = [[UIImageView alloc] initWithFrame:[desfileData_ bounds]];
    desfileDataImageView_.image = [UIImage imageNamed:imageName];
    desfileDataImageView_.contentMode = UIViewContentModeTopLeft;
    desfileDataImageView_.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [desfileData_ addSubview:desfileDataImageView_];

    CGFloat labelWidth = width - 15.0f;
    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(8, 2, labelWidth, 16)] autorelease];
    title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont boldSystemFontOfSize:11];
    title.textColor = [UIColor whiteColor];
    title.shadowColor = [UIColor blackColor];
    title.shadowOffset = CGSizeMake(0, 1);
    title.text = [NSString stringWithFormat:@"%@ %@", desfile_.bloco.nome, [desfile_.dataHora timeToString]];
    [desfileData_ addSubview:title];

    UILabel *address = [[[UILabel alloc] initWithFrame:CGRectMake(8, 24, labelWidth, 40)] autorelease];
    address.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    address.numberOfLines = 2;
    address.backgroundColor = [UIColor clearColor];
    address.font = [UIFont boldSystemFontOfSize:13];
    address.textColor = [UIColor colorWithRed:0.310 green:0.310 blue:0.310 alpha:1.000];
    address.minimumFontSize = 12;
    address.adjustsFontSizeToFitWidth = YES;
    address.text = [NSString stringWithFormat:@"%@ - %@", desfile_.endereco, desfile_.bairro.nome];
    [desfileData_ addSubview:address];

    [[self view] insertSubview:desfileData_ belowSubview:backButton_];
}

@end