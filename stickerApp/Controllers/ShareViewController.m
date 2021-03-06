//
//  ShareViewController.m
//  stickerApp
//
//  Created by Franky Aguilar on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import <QuartzCore/CALayer.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <StoreKit/StoreKit.h>
#import "SVModalWebViewController.h"
#import "TAOverlay.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>

#import "JPSThumbnail.h"
#import "JPSThumbnailAnnotation.h"
#import "OMGMapAnnotation.h"
#import "TMCache.h"
#import "DataManager.h"
#import "UserServiceManager.h"
#import "MixPanelManager.h"

@interface ShareViewController ()<MFMessageComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, SKStoreProductViewControllerDelegate> {
    
    IBOutlet UIImageView* ibo_previewImage;
    
    NSString * filename;
    BOOL boolSharePublic;
}

@property (nonatomic, strong) UIActivityViewController *activityVC;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, weak) IBOutlet MKMapView * ibo_mapView;
@property (nonatomic, weak) IBOutlet UIButton *ibo_btnPublish;
@property (nonatomic, weak) IBOutlet UILabel *ibo_noLocation;
@property (nonatomic, weak) IBOutlet UILabel *ibo_publicPublish;
@property (nonatomic, weak) IBOutlet UILabel *ibo_headerShare;

@property(nonatomic,assign)BOOL isFeatured;

@end

@implementation ShareViewController

@synthesize userExportedImage;
@synthesize delegate;

#define METERS_PER_MILE 40233.6

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"PUBLISH_SHARE", nil);
    _ibo_headerShare.text = NSLocalizedString(@"PUBLISH_SHARE", nil);
    
    _ibo_publicPublish.text = [@"" stringByAppendingString:NSLocalizedString(@"PUBLISH_PUBLIC", nil)];
    
    filename = [self generateFileNameWithExtension:@".png"];
  
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    [self setup_yoshirt];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"PACK_DONE", nil)
                                                                    style: UIBarButtonItemStylePlain
                                                                   target: self
                                                                   action: @selector(iba_createNew:)];
  
    self.navigationItem.rightBarButtonItem = rightButton;
    _ibo_noLocation.text = NSLocalizedString(@"PERMISSION_NO_LOCATION", nil);
    _ibo_noLocation.hidden = YES;
    
    [[TMCache sharedCache] setObject:userExportedImage forKey:@"image" block:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated {
    [TAOverlay hideOverlay];
    
    _ibo_btnPublish.layer.cornerRadius = _ibo_btnPublish.frame.size.width/2;
    _ibo_btnPublish.layer.borderColor = [UIColor blackColor].CGColor;
    _ibo_btnPublish.backgroundColor = [UIColor whiteColor];
    _ibo_btnPublish.layer.borderWidth = 2;
    _ibo_btnPublish.clipsToBounds = YES;

    boolSharePublic = NO;
    
    if ([self locationGranted]){
        [self setupMapView];
    } else {
        _ibo_mapView.hidden = YES;
        _ibo_noLocation.hidden = NO;
    }
    
    [super viewDidAppear:animated];
}

- (void) setup_yoshirt {
    ibo_previewImage.image = userExportedImage;
}

- (IBAction) iba_sendto_yoshirt{
    NSURL *yoURL = [NSURL URLWithString:@"yoshirt://app"];
    if ([[UIApplication sharedApplication] canOpenURL:yoURL]) {
        UIPasteboard *pasteboard;
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
            pasteboard = [UIPasteboard generalPasteboard];
        } else {
            pasteboard = [UIPasteboard pasteboardWithUniqueName];
        }
        
        NSString *imgName = @"yoshirt.png";
        [pasteboard setData:UIImagePNGRepresentation(userExportedImage) forPasteboardType:imgName];
        NSURL *url = [NSURL URLWithString:[@"yoshirt://local/" stringByAppendingString:imgName]];
        [[UIApplication sharedApplication] openURL:url];
        
        [self sharePhotoLibraryComplete];
        [MixPanelManager triggerEvent:@"Share" withData:@{ @"Type": @"YoShirt" }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Yoshirt!" message:@"Download Yoshirt free and make your own custom clothes!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Download", nil];
        alert.tag = 0;
        alert.delegate = self;
        [alert show];
    }
}


#pragma SHARE ITEMS
- (IBAction)iba_sharePhotoLibrary:(id)sender {
    NSLog(@"Share Photo Libarary");
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library saveImage:userExportedImage toAlbum:kAlbumName withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"Big error: %@", [error description]);
        }
    }];
    
    [self sharePhotoLibraryComplete];
    [TAOverlay showOverlayWithLabel:@"Saved!" Options:(TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionOverlayShadow | TAOverlayOptionAutoHide)];
    [MixPanelManager triggerEvent:@"Share" withData:@{ @"Type": @"Photolibrary" }];
}

- (void)sharePhotoLibraryComplete {
    NSData *imageData = UIImagePNGRepresentation(userExportedImage);
    NSString *imageName = [NSString stringWithFormat:@"lastImage.png"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPathToFile atomically:YES];
}


- (IBAction)iba_messageImage{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support MMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSData *imgData = UIImagePNGRepresentation(userExportedImage);
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController addAttachmentData:imgData typeIdentifier:(NSString *)kUTTypePNG filename:@"catwang.png"];

    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Message sending cancelled.");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Message sending failed.");
            break;
        case MessageComposeResultSent:
            NSLog(@"Message sent.");
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:^(){
    }];
  
    [MixPanelManager triggerEvent:@"Share" withData:@{ @"Type": @"MMS" }];
}


#pragma SOCIAL SHARING
- (IBAction)iba_shareTwitter:(id)sender {
    [MixPanelManager triggerEvent:@"Share" withData:@{ @"Type": @"Twitter" }];
    
    SLComposeViewController *twController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    SLComposeViewControllerCompletionHandler __block completionHandler =
    ^(SLComposeViewControllerResult result) {
        
        [twController dismissViewControllerAnimated:YES completion:nil];
        
        if(result == SLComposeViewControllerResultDone) {
          [TAOverlay showOverlayWithLabel:@"Sent!" Options:(TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionOverlayShadow | TAOverlayOptionAutoHide)];
        }
    };
    
    [twController addImage:userExportedImage];
    [twController setInitialText:kShareDescription];
    [twController addURL:[NSURL URLWithString:kShareURL]];
    [twController setCompletionHandler:completionHandler];
    [self presentViewController:twController animated:YES completion:nil];
}


- (IBAction)iba_shareFacebook:(id)sender{
    [MixPanelManager triggerEvent:@"Share" withData:@{ @"Type": @"Facebook" }];
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending){
        SLComposeViewController *fbController = [SLComposeViewController
                                                 composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        SLComposeViewControllerCompletionHandler __block completionHandler=
        ^(SLComposeViewControllerResult result){
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    break;
                case SLComposeViewControllerResultDone: {
                    [TAOverlay showOverlayWithLabel:@"Posted!" Options:(TAOverlayOptionOverlayTypeSuccess | TAOverlayOptionOverlayShadow | TAOverlayOptionAutoHide)];
                   break;
                default: { }
            }
                
            }};
        
        [fbController addImage:userExportedImage];
        [fbController setInitialText:kShareDescription];
        [fbController addURL:[NSURL URLWithString:kShareURL]];
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Failed!"
                                  message:@"Please connect Facebook via the Settings on your Device."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (IBAction)iba_shareInstagram:(id)sender{
    [MixPanelManager triggerEvent:@"Share" withData:@{ @"Type": @"Instagram" }];
    
    UIImage *image = [UIImage imageWithData:UIImagePNGRepresentation(userExportedImage)];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        NSURL *url;
        CGRect cropRect = CGRectMake(0, 0, image.size.height, image.size.height);
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Share.igo"];
        CGImageRef imageRef = CGImageCreateWithImageInRect([userExportedImage CGImage], cropRect);

        UIGraphicsBeginImageContext(cropRect.size);
       
        [[UIColor whiteColor] setFill];
        UIRectFill(cropRect); //fill the bitmap context

        [[UIImage imageWithCGImage:imageRef] drawInRect:CGRectMake(image.size.height/2 -
                                                                   image.size.width/2,
                                                                   0,
                                                                   image.size.width,
                                                                   image.size.height)];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        CGImageRelease(imageRef);
        
        [UIImagePNGRepresentation(img) writeToFile:jpgPath atomically:YES];
        url = [[NSURL alloc] initFileURLWithPath:jpgPath];
        
        UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        interactionController.UTI = @"com.instagram.exclusivegram";
        interactionController.annotation = [NSDictionary dictionaryWithObject:kInstagramParam forKey:@"InstagramCaption"];
        interactionController.delegate = self;
        
        self.documentInteractionController = interactionController;
        [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        
        [self sharePhotoLibraryComplete];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:@"You dont have Instagram on this Device." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (IBAction)iba_sendSnapchat:(id)sender{
    [MixPanelManager triggerEvent:@"Share" withData:@{ @"Type": @"Snapchat" }];
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"snapchat://app"]]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ooops" message:@"Snapchat is not installed on this Device." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        [self iba_sendToExternalApp:self];
    }

}

- (IBAction)iba_sendTumbler:(id)sender{
    [MixPanelManager triggerEvent:@"Share" withData:@{ @"Type": @"Tumblr" }];
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tumblr://app"]]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ooops" message:@"Tumblr is not installed on this Device." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert show];
        return;
    } else {
        [self iba_sendToExternalApp:self];
    }
}

//SEND
-(IBAction)iba_sendToExternalApp:(id)sender {
    NSLog(@"Send to External App");
    
    NSString * pngPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/99centbrains.png"];
    
    [UIImagePNGRepresentation(userExportedImage)writeToFile:pngPath atomically:YES];
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:pngPath];
    
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    interactionController.delegate = self;
    
    self.documentInteractionController = interactionController;
    CGRect rect = CGRectMake(0 ,0 , 0, 0);
    [self.documentInteractionController presentOpenInMenuFromRect:rect inView:self.view animated:YES];
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
  
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 0:
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"https://itunes.apple.com/app/id785725887?mt=8&uo=4&at=10ly5p"]];
            break;
        default:
            break;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (IBAction)iba_createNew:(id)sender {
  AppDelegate *appdelegate= (AppDelegate *) [[UIApplication sharedApplication] delegate];
  [appdelegate askForLocation];
  
  if (boolSharePublic) {
    [self iba_publish:nil];
  } else {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}

#pragma PUBLISH PUBLIC
- (IBAction)iba_publish:(id)sender{
  [TAOverlay showOverlayWithLabel:NSLocalizedString(@"PUBLISH_PROGRESS", nil) Options:TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeActivityDefault ];
  NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(userExportedImage)];
  NSMutableDictionary *snap = [NSMutableDictionary dictionary];
  snap[@"image"] = imageData;
  snap[@"location"] = [DataManager currentLocation];
  //Delete this key in the future
  snap[@"channel"] = @"General";
  [UserServiceManager createSnap: @{ @"snap": snap } Onsuccess:^(NSDictionary *responseObject) {
    NSInteger karma = [DataManager  karma] + 2;
    [DataManager storeKarma: [NSString stringWithFormat:@"%ld", (long)karma]];
    [TAOverlay hideOverlay];
    [self.navigationController popToRootViewControllerAnimated:YES];
  } Onfailure:^(NSError *error) {
    [TAOverlay hideOverlay];
    [TAOverlay showOverlayWithLabel:@"Oops! Try again later." Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeBar | TAOverlayOptionOverlayTypeError ];
  }];
}

- (NSString*)generateFileNameWithExtension:(NSString *)extensionString {
    NSDate *time = [NSDate date];
    NSDateFormatter* df = [NSDateFormatter new];
    [df setDateFormat:@"dd-MM-yyyy-hh-mm-ss"];
    NSString *timeString = [df stringFromDate:time];
    NSString *fileName = [NSString stringWithFormat:@"snap_%@%@", timeString, extensionString];
    
    return fileName;
}

- (IBAction)iba_toggle_public:(UIButton *)sender{
    if (![self locationGranted]){
        [self promptAddLocation];
        return;
    }
  
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserBanStatus]){
        [self promptUserBanned];
        return;
    }
    
    if (boolSharePublic){
        [_ibo_btnPublish setBackgroundColor:[UIColor whiteColor]];
        boolSharePublic = NO;
        [self annotationsREMOVE];
    } else {
        [self annotationsADD];
        [_ibo_btnPublish setBackgroundColor:[UIColor magentaColor]];
        boolSharePublic = YES;
    }
}

-(UIImage *) scaledImageWithImage:(UIImage *) sourceImage {
    NSInteger scale = 4;
    
    NSLog(@"Image Size %@", NSStringFromCGSize(sourceImage.size));
  
    float oldWidth = sourceImage.size.width;
    float i_width = sourceImage.size.width/scale;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"Image Size %@", NSStringFromCGSize(newImage.size));
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) promptUserBanned{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Nope!" message:@"Your account has been suspected of suspicious activity, you've been banned from public posts. Play Nice!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive handler:nil];
    
    [actionSheet addAction:actionDelete];
    [self presentViewController:actionSheet animated:YES completion:^(void){
        
    }];
}

- (void) promptAddLocation{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PROMPT_LOCAL_TITLE", nil)
                                                                         message:NSLocalizedString(@"PROMPT_LOCAL_BODY", nil)
                                                                  preferredStyle:UIAlertControllerStyleAlert];
  
    UIAlertAction *action_spam = [UIAlertAction actionWithTitle:NSLocalizedString(@"PROMPT_LOCAL_ACTION", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL_BUTTON", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
  
    [actionSheet addAction:action_spam];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma MAPVIEW
- (void) setupMapView{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [[DataManager currentLatitud] doubleValue];
    zoomLocation.longitude= [[DataManager currentLongitud] doubleValue];

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
    
    [_ibo_mapView setRegion:viewRegion animated:NO];
}

- (void)annotationsADD{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [[DataManager currentLatitud] doubleValue];
    zoomLocation.longitude = [[DataManager currentLongitud] doubleValue];
    
    JPSThumbnail *thumbnail = [[JPSThumbnail alloc] init];
    thumbnail.image = userExportedImage;
    thumbnail.title = @" ";
    thumbnail.subtitle = @" ";
    thumbnail.coordinate = zoomLocation;
    [_ibo_mapView addAnnotation:[JPSThumbnailAnnotation
                                 annotationWithThumbnail:thumbnail]];
}

- (void)annotationsREMOVE{
    [_ibo_mapView removeAnnotations:_ibo_mapView.annotations];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
      return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}


- (BOOL) locationGranted{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined) {
        return NO;
    }
    
    return YES;
}

@end
