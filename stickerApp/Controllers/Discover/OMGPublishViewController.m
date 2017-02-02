//
//  OMGPublishViewController.m
//  catwang
//
//  Created by Fonky on 2/5/15.
//
//

#import "OMGPublishViewController.h"
#import "ShareViewController.h"
#import "ChannelSelectViewController.h"
#import "AppDelegate.h"
#import "MixPanelManager.h"

#import "FeSlideFilterView.h"

@interface OMGPublishViewController ()<FeSlideFilterViewDataSource, FeSlideFilterViewDelegate, ChannelSelectViewControllerDelegate>{
    NSString *filename;
    BOOL boolSharePublic;
    BOOL boolSharedPublic;
    NSInteger imageFilterNumber;
}

@property (nonatomic, weak) IBOutlet UIImageView *ibo_userImageView;
@property (nonatomic, weak) IBOutlet UIView *ibo_userFilterView;
@property (nonatomic, weak) IBOutlet UIButton *ibo_btnChannel;

@property (nonatomic,assign) CLLocationCoordinate2D coord;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *publish_channel;


///SLIDE FILTER
@property (strong, nonatomic) FeSlideFilterView *slideFilterView;
@property (strong, nonatomic) NSMutableArray *arrPhoto;

@end


@implementation OMGPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    filename = [self generateFileNameWithExtension:@".png"];
    [self initPhotoFilter];
    imageFilterNumber = 0;
    boolSharedPublic = NO;
    _publish_channel = @"General";
}

#pragma FILTERS
-(void) initPhotoFilter {
    _arrPhoto = [[NSMutableArray alloc] init];
    [_arrPhoto addObject:_userExportedImage];
    NSArray *filterNames = @[@"CIPhotoEffectInstant", @"CIPhotoEffectFade", @"CIPhotoEffectChrome", @"CIPhotoEffectTransfer", @"CIPhotoEffectProcess", @"CIPhotoEffectTonal", @"CIPhotoEffectNoir"];
    
    for (NSString *filter in filterNames) {
            UIImage *newImage = [self filterEffect:filter andImage:_userExportedImage];
            if (newImage){
                [_arrPhoto addObject:newImage];
            }
    }
}

- (UIImage *)filterEffect:(NSString *)filterName andImage:(UIImage *)img {
    CIImage *beginImage = [CIImage imageWithCGImage:img.CGImage];
    CIImage *output = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, beginImage, nil].outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage];
    CGImageRelease(cgiimage);
    
    return newImage;
}

-(void) initFeSlideFilterView {
    _slideFilterView = [[FeSlideFilterView alloc] initWithFrame:_ibo_userFilterView.frame];
    _slideFilterView.dataSource = self;
    _slideFilterView.delegate = self;
    [_ibo_userFilterView addSubview:_slideFilterView];
    
    [TAOverlay hideOverlay];
}

#pragma mark - Delegate / Data Source
-(NSInteger) numberOfFilter {
    return [_arrPhoto count];
}

-(NSString *) FeSlideFilterView:(FeSlideFilterView *)sender titleFilterAtIndex:(NSInteger)index {
    return 0;
}

-(UIImage *) FeSlideFilterView:(FeSlideFilterView *)sender imageFilterAtIndex:(NSInteger)index {
    return _arrPhoto[index];
}

-(void) FeSlideFilterView:(FeSlideFilterView *)sender didEndSlideFilterAtIndex:(NSInteger) index{
    imageFilterNumber = index;
}

-(NSString *) kCAContentGravityForLayer {
    return kCAGravityResizeAspectFill;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initFeSlideFilterView];
}

- (IBAction)iba_channelSelect:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChannelSelectViewController *newVC = (ChannelSelectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_ChannelSelectViewController"];
    newVC.delegate = self;
    [self.navigationController pushViewController:newVC animated:YES];
}

-(void) channelSelectWithTitle:(ChannelSelectViewController *)controller withChannel:(NSString *)channel withIcon:(NSString *)iconEmoji {
    [_ibo_btnChannel setTitle:iconEmoji forState:UIControlStateNormal];
    NSLog(@"UPDATE CHANNEL %@", channel);
    _publish_channel = channel;
}

- (IBAction)iba_skip:(id)sender {
    ShareViewController *vc_shareview = (ShareViewController *)[self  viewControllerFromMainStoryboardWithName:@"ShareViewController"];
    vc_shareview.userExportedImage = [_arrPhoto objectAtIndex:imageFilterNumber];
    [self.navigationController pushViewController:vc_shareview animated:YES];
}

- (IBAction)iba_publish:(id)sender {
    [self iba_skip:nil];
}

- (IBAction)iba_toggle_public:(UIButton *)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserBanStatus]) {
        [self promptUserBanned];
        return;
    }

    AppDelegate *delegate= (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate askForLocation];
    NSLog(@"TOGGLE");
}

- (void) promptUserBanned {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Nope!" message:@"Your account has been suspected of suspicious activity, you've been banned from public posts. Play Nice!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive handler:nil];
  
    [actionSheet addAction:actionDelete];
    [self presentViewController:actionSheet animated:YES completion:^(void){}];
}

- (IBAction)iba_goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIImage *) scaledImageWithImage:(UIImage *) sourceImage {
    float oldWidth = sourceImage.size.width;
    float i_width = sourceImage.size.width/3;
    float scaleFactor = i_width/oldWidth;
    
    float newHeight = sourceImage.size.height*scaleFactor;
    float newWidth = oldWidth*scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied: {
                NSLog(@"kCLAuthorizationStatusDenied");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Not Enabled" message:@"The app can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
                _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
                [_locationManager startUpdatingLocation];
            }
            break;
        case kCLAuthorizationStatusAuthorizedAlways: {
                _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
                [_locationManager startUpdatingLocation];
            }
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"kCLAuthorizationStatusRestricted");
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString*)generateFileNameWithExtension:(NSString *)extensionString {
    NSDate *time = [NSDate date];
    NSDateFormatter* df = [NSDateFormatter new];
    [df setDateFormat:@"dd-MM-yyyy-hh-mm-ss"];
    NSString *timeString = [df stringFromDate:time];
    NSString *fileName = [NSString stringWithFormat:@"snap_%@%@", timeString, extensionString];
    
    return fileName;
}

#pragma StoryBoard
- (UIViewController *)viewControllerFromMainStoryboardWithName:(NSString *)name {
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    return [mainSB instantiateViewControllerWithIdentifier:name];
}

@end
