//
//  OMGMapViewController.m
//  catwang
//
//  Created by Fonky on 2/16/15.
//
//

#import "OMGMapViewController.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "TAOverlay.h"
#import "DataHolder.h"
#import "OMGHeadSpaceViewController.h"
#import "NewUserViewController.h"
#import "JPSThumbnail.h"
#import "JPSThumbnailAnnotation.h"
#import "OMGMapAnnotation.h"
#import "OMGLightBoxViewController.h"
#import "OMGTabBarViewController.h"
#import "ChannelSelectViewCell.h"

@interface OMGMapViewController ()<MKMapViewDelegate, OMGLightBoxViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>{

    BOOL mapbrowsing;
    BOOL mapStopped;
    BOOL firstLoad;
    
    int timercounter;
    
}

@property (nonatomic, weak) IBOutlet MKMapView * ibo_mapView;

@property (nonatomic, assign) CLLocationCoordinate2D mapFocusCoordinates;

@property (nonatomic, strong) PFGeoPoint * geoPoint;
@property (nonatomic, strong) NSTimer * mapStopTimer;

@property (nonatomic, strong) UIActivityIndicatorView * ibo_activity;

@property (nonatomic, weak) IBOutlet UILabel *ibo_dragDescriptor;

@property (nonatomic, weak) IBOutlet UIView *ibo_notAvailableView;
@property (nonatomic, weak) IBOutlet UILabel *ibo_notAvailableDescription;
@property (nonatomic, strong) OMGLightBoxViewController *ibo_lightboxView;

@property (nonatomic, strong) NSMutableArray *snapsArray;

@property (nonatomic, strong) NSMutableArray *arrayLocations;


@property (nonatomic, weak) IBOutlet UICollectionView *ibo_collectionView;


@end


#define METERS_PER_MILE 16093.4


@implementation OMGMapViewController

@synthesize delegate;

- (void)viewDidLoad {

    mapStopped = YES;
    mapbrowsing = NO;
    _newLocation = NO;
    firstLoad = YES;
    
    
    _arrayLocations = [[NSMutableArray alloc] init];
    
    [self setUpLocations];
    
    

    _ibo_notAvailableView.hidden = YES;
    _ibo_notAvailableDescription.text = NSLocalizedString(@"PERMISSION_LOCATION_MAP", nil);
    _ibo_dragDescriptor.text = NSLocalizedString(@"EXP_MAPBODY", nil);
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewWillAppear:(BOOL)animated{
    

        if (![self locationGranted]){
            NSLog(@"NO LOCATION");
            _ibo_notAvailableView.hidden = NO;
            return;
        }
        
        _ibo_notAvailableView.hidden = YES;
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if (!firstLoad){
        [self segmentView_loadSnaps];
    }

}

- (void)viewWillDisappear:(BOOL)animated{
    
    if (_ibo_mapView){
        
        [_ibo_mapView removeAnnotations:_ibo_mapView.annotations];
        
    }
    
}

#pragma MAPKIT

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (firstLoad){
        
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = [DataHolder DataHolderSharedInstance].userGeoPoint.latitude;
        zoomLocation.longitude= [DataHolder DataHolderSharedInstance].userGeoPoint.longitude;
        
        NSLog(@"LOCATION LAT %f", [DataHolder DataHolderSharedInstance].userGeoPoint.latitude);
        NSLog(@"LOCATION LAT %f", [DataHolder DataHolderSharedInstance].userGeoPoint.longitude);
        
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [_ibo_mapView setRegion:[_ibo_mapView regionThatFits:viewRegion] animated:YES];
            
        });
        
        firstLoad = NO;
    }
    
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    if (_ibo_mapView.annotations){
        [_ibo_mapView removeAnnotations:_ibo_mapView.annotations];
    }
    
    if (!_ibo_activity){
        
        _ibo_activity = [[UIActivityIndicatorView alloc] init];
        _ibo_activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [_ibo_activity startAnimating];
        _ibo_activity.center = _ibo_activity.center;
        [self.view addSubview:_ibo_activity];
        
    }
    
    timercounter = 0;
    [_mapStopTimer invalidate];
    
    
    // NSLog(@"MOVING");
    
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    
    _mapFocusCoordinates = mapView.centerCoordinate;
    
    if (_mapStopTimer ){
        
        [_mapStopTimer invalidate];
        _mapStopTimer = nil;
        
    }
    
    _mapStopTimer = [NSTimer timerWithTimeInterval:.25
                                            target:self
                                          selector:@selector(countMap:)
                                          userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_mapStopTimer
                              forMode:NSDefaultRunLoopMode];
    
}

- (void) countMap:(NSTimer *)timer{
    
    NSLog(@"Timer %d", timercounter);
    timercounter++;
    
    if (timercounter >= 2){
        
        [self segmentView_loadSnaps];
        
        mapbrowsing = YES;
        _newLocation = YES;
        
        //MAP STOPPED
        
        [timer invalidate];
        
        if (_ibo_activity){
            [_ibo_activity removeFromSuperview];
            _ibo_activity = nil;
        }
        
    }
    
    
}


- (void) mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    
    if (fullyRendered){
        NSLog(@"RENDERED");
    }
    
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    
    NSLog(@"FINISHED LOADING");
    
}




#pragma ANNOTATIONS

- (void) segmentView_loadSnaps{
    
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Map":@"ChangedLocation"} forEvent:@"Explore"];

    
    PFQuery *query= [PFQuery queryWithClassName:@"snap"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        query.limit = 50;
        
    } else {

        query.limit = 20;
    
    }
    
   

    
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:_mapFocusCoordinates.latitude
                                                  longitude:_mapFocusCoordinates.longitude];
    
 
    
    
    [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:kMinDistance];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"hidden" equalTo:[NSNumber numberWithBool:0]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@"FOUND %lu", (unsigned long)[objects count]);
        NSLog(@"GEO POINT %@", NSStringFromCGPoint(CGPointMake(_mapFocusCoordinates.latitude, _mapFocusCoordinates.longitude)));
        
        _snapsArray = [objects copy];
        [self displayAnnotationsForQuery:objects];
        
    }];
    
}

- (void) displayAnnotationsForQuery:(NSArray *)geoObjects{
    
    if (_ibo_mapView){
        
        [_ibo_mapView removeAnnotations:_ibo_mapView.annotations];
        
    }
    
    for (PFObject *obj in geoObjects){
        
        
        
            //PFGEOPOINT
            PFGeoPoint * geoPoint = obj[@"location"];
            PFFile * imageFile = obj[@"thumbnail"];

            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIImage *img = [UIImage imageWithData:data];
                
                CLLocationCoordinate2D coord;
                coord.latitude = geoPoint.latitude;
                coord.longitude = geoPoint.longitude;
                
                
                OMGMapAnnotation *anno = [[OMGMapAnnotation alloc] initWithCoordinates:coord andTitle:@"turkey" andThumbNail:img];
                anno.snapObject = obj;
                [_ibo_mapView addAnnotation:anno];
                
//                JPSThumbnail *thumbnail = [[JPSThumbnail alloc] init];
//                thumbnail.image = img;
//                thumbnail.title = @"Turtle";
//                thumbnail.subtitle = @" ";
//                thumbnail.coordinate = coord;
//                
//                [_ibo_mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:thumbnail]];
//                
            
               
                
                
            }];
        
  
    }


}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
//    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
//        
//        
//        
//        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
//        
//    }
    
    
     if ([view.annotation isKindOfClass:[OMGMapAnnotation class]]){
         
        OMGMapAnnotation *anno = view.annotation;
        [self showLightBoxView:0 andThumbNail:anno.thumbnail withPFObject:anno.snapObject];
         
     }
    
    NSLog(@"Touched Annotation");
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[OMGMapAnnotation class]]){
        
        OMGMapAnnotation *myAnno = (OMGMapAnnotation *)annotation;
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"com.anno"];
        annotationView = myAnno.annotationView;
        

        
        return annotationView;
        

    }
    
    return nil;
    
    
    
    
//    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
//        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
//    }
//    return nil;
    
}






#pragma LOADLOCATIONS
- (void)iba_resetLocation:(NSInteger)index {
    
    CGPoint newPoint = [[[_arrayLocations objectAtIndex:index] objectAtIndex:2] CGPointValue];
    
    _mapFocusCoordinates = CLLocationCoordinate2DMake(newPoint.x,
                                                      newPoint.y);
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = _mapFocusCoordinates.latitude;
    zoomLocation.longitude= _mapFocusCoordinates.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
    [_ibo_mapView setRegion:viewRegion animated:YES];
    
    
}

#pragma MAPLIGHTBOX

- (void)showLightBoxView:(NSInteger)itemIndex andThumbNail:(UIImage *)thumbnail withPFObject:(PFObject *)object {
    
    OMGTabBarViewController *owner = (OMGTabBarViewController *)self.parentViewController;
    [owner showSnapFullScreen:object preload:thumbnail shouldShowVoter:NO];

}



- (BOOL) locationGranted{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined) {
        return NO;
    }
    
    return YES;
}



#pragma NO DATA AVAILABLE
- (IBAction)iba_notAvailableAction:(id)sender{
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PROMPT_LOCAL_TITLE", nil)
                                                                         message:NSLocalizedString(@"PROMPT_LOCAL_BODY", nil)
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *action_spam = [UIAlertAction actionWithTitle:NSLocalizedString(@"PROMPT_LOCAL_ACTION", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"PROMPT_LOCAL_CANCEL", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    
    [actionSheet addAction:action_spam];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
    
}



#pragma LOCATIONS

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //NSLog(@"SECTION %d", [stickerpack_dir count]);
    
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    //NSLog(@"Items %d", [[_array_stickerpack_dir objectAtIndex:section] count]);
    return [_arrayLocations count];
    
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ChannelSelectViewCell *cell = (ChannelSelectViewCell *)[collectionView
                                                            dequeueReusableCellWithReuseIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    cell.ibo_channelIcon.text = [[_arrayLocations objectAtIndex:indexPath.item] objectAtIndex:0];
    cell.ibo_channelTitle.text = [[_arrayLocations objectAtIndex:indexPath.item] objectAtIndex:1];
    
    return cell;
}

//
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self iba_resetLocation:indexPath.item];
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

        return CGSizeMake(collectionView.frame.size.width/2 - 12, 50);
        
    }
    
    return CGSizeMake(collectionView.frame.size.width, 50);
    
}


- (void)setUpLocations{

    
    NSArray * flags = @[@"🏠",
                        @"🇺🇸",
                        @"🗽",
                        @"🇨🇳",
                        @"🐉",
                        @"🇰🇷",
                        @"💂",
                        @"🇷🇺",
                        @"🇬🇧",
                        @"⭐️"
                        
                        ];
    NSArray * places = @[@"Your Location",
                         @"Los Angeles",
                         @"New York City",
                         @"Shanghai",
                         @"Beijing",
                         @"South Korea",
                         @"London",
                         @"Moscow",
                         @"Stockholm",
                         @"Istanbul"
                         
                         ];
    
    NSArray * coord = @[[NSValue valueWithCGPoint:CGPointMake([DataHolder DataHolderSharedInstance].userGeoPoint.latitude,
                                                              [DataHolder DataHolderSharedInstance].userGeoPoint.longitude)],
                        [NSValue valueWithCGPoint:CGPointMake(34.056519, -118.22855)],
                        [NSValue valueWithCGPoint:CGPointMake(40.745091160629116, -73.98071757051396)],
                        [NSValue valueWithCGPoint:CGPointMake(31.238705, 121.48997)],
                        [NSValue valueWithCGPoint:CGPointMake(39.960209, 116.38259)],
                        [NSValue valueWithCGPoint:CGPointMake(37.514427, 126.84566)],
                        [NSValue valueWithCGPoint:CGPointMake(51.507954, -0.17872441)],
                        [NSValue valueWithCGPoint:CGPointMake(55.754387, 37.625851)],
                        [NSValue valueWithCGPoint:CGPointMake(59.329601, 18.063143)],
                        [NSValue valueWithCGPoint:CGPointMake(41.014069, 29.007841)]
                        ];
    
    for (int i = 0; i < [places count]; i++){
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        [tempArray addObject:[flags objectAtIndex:i]];
        [tempArray addObject:[places objectAtIndex:i]];
        [tempArray addObject:[coord objectAtIndex:i]];
        
        [_arrayLocations addObject:tempArray];
        tempArray = nil;
        
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
