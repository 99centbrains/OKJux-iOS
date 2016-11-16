//
//  ViewController.m
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "PlayViewController.h"
#import "TAOverlay.h"
#import <Accounts/Accounts.h>
#import "SVWebViewController.h"
#import "StickerCategoryViewController.h"
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CBImagePickerViewController.h"
#import <Chartboost/Chartboost.h>
#import "NewUserViewController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MessageUI/MessageUI.h>
#import "OMGTabBarViewController.h"
#import "TMCache.h"


@interface ViewController ()<StickerCategoryViewControllerDelegate, MFMessageComposeViewControllerDelegate, CBImagePickerViewControllerDelegate> {

}

- (IBAction)iba_Facebook:(id)sender;
- (IBAction)iba_Twitter:(id)sender;
- (IBAction)iba_Insta:(id)sender;
- (IBAction)iba_Web:(id)sender;

- (IBAction)iba_photoChoose:(id)sender;
- (IBAction)iba_photoTake:(id)sender;

- (IBAction)showDetailsView:(id)sender;
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@property (nonatomic, weak) IBOutlet UIImageView *ibo_userImage;
@property (nonatomic, strong) UIPopoverController *popController;

@end


@implementation ViewController

@synthesize ibo_getphoto = _ibo_getphoto;

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar setTintColor:[UIColor magentaColor]];
    self.navigationController.navigationBarHidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    if (!_ibo_userImage.image)
    _ibo_userImage.alpha = 0;
    [[TMCache sharedCache] objectForKey:@"image"
                                  block:^(TMCache *cache, NSString *key, id object) {
                                      UIImage *image = (UIImage *)object;
                                      _ibo_userImage.image = image;
                                      
                                      [UIView animateWithDuration:.5 animations:^{
                                          _ibo_userImage.alpha = 1;
                                      }];
                                  }];
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kNewUserKey]){
      [self pushTutorial];
    }
}

- (void)pushTutorial {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FTUEStoryboard" bundle:nil];
  
  NewUserViewController *newVC = (NewUserViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_NewUserViewController"];
  newVC.sourceVC = self;
  [self presentViewController:newVC animated:NO completion:^(void){
    
  }];
}

- (IBAction)showTutorial:(UIButton *)sender {
  [self pushTutorial];
}

- (IBAction)shareApp:(UIButton *)sender{
    NSString *textToShare = kShareDescription;

    NSURL *url = [NSURL URLWithString:@"http://okjux.com/"];
    UIImage *imgData = [UIImage imageNamed:@"icon_promo.png"];
    
    NSArray *activityItems = [[NSArray alloc]  initWithObjects:textToShare, imgData, url, nil];
    UIActivity *activity = [[UIActivity alloc] init];
    
    NSArray *applicationActivities = [[NSArray alloc] initWithObjects:activity, nil];
    
    UIActivityViewController *activityVC =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:applicationActivities];
    
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeSaveToCameraRoll, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
    
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
      NSLog(@"Activity Completion");
        
      if (activityType){ }
    }];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      _popController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
      _popController.delegate = self;
      _popController.popoverContentSize = CGSizeMake(self.view.frame.size.width/2, 800); //your custom size.
      [_popController presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    }else {
      [self presentViewController:activityVC animated:YES completion:nil];
    }
}


//Prompts for UIActionSheet
- (IBAction)iba_photoStart:(id)sender{
    
    NSLog(@"PHOTO START");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlayViewController *playVC = (PlayViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_PlayViewController"];
    playVC.userImage = nil;
    [self.navigationController pushViewController:playVC animated:YES];
}

- (void)cbVideoCaptureDidDismiss:(CBImagePickerViewController *)sender{
    [sender dismissViewControllerAnimated:YES completion:nil];
}

- (void)cbVideoCaptureDidFinishBlank:(CBImagePickerViewController *)sender {
    [self cbVideoCaptureDidFinish:sender withImage:nil];
}

- (void)cbVideoCaptureDidFinish:(CBImagePickerViewController *)sender withImage:(UIImage *)image {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlayViewController *playVC = (PlayViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_PlayViewController"];
    
    [sender dismissViewControllerAnimated:YES completion:^(void){
        playVC.userImage = image;
        [self.navigationController pushViewController:playVC animated:YES];
    }];
}



#pragma EMOJIS

- (IBAction)iba_emojiStickers:(UIButton *)sender{
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"StickerSelectStoryboard" bundle:[NSBundle mainBundle]];
    
    //NAVCONT
    UINavigationController *controller = (UINavigationController*)[mainSB instantiateViewControllerWithIdentifier: @"seg_stickerNavigation"];
    
    StickerCategoryViewController *newController = [controller.viewControllers objectAtIndex:0];
    newController.delegate = self;
 
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        _popController = [[UIPopoverController alloc] initWithContentViewController:controller];
        _popController.delegate = self;
        _popController.popoverContentSize = CGSizeMake(500, 650); //your custom size.
        [_popController presentPopoverFromRect:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 650) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    } else {
      [self presentViewController:controller animated:YES completion:nil];
    }
}


#pragma GIF SEND

- (UIImage *)getPopmoji:(UIImage *)image withPad:(int)pad{
    image = [self imageFixBoundingBox:image];
    
    CGRect rect = CGRectMake(0, 0, 100, 100);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
  
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    CGRect lowerImage = CGRectMake((rect.size.width - image.size.width) / 2,
                                   (rect.size.height - image.size.height) / 2 + pad,
                                   image.size.width,
                                   image.size.height);
    
    NSLog(@"IMAGE SIZE %@", NSStringFromCGSize(image.size));
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, lowerImage, image.CGImage);
  
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    
    return final;
}

- (void)sendMMSAnimated:(NSArray *)recipitants withImage:(NSURL *)image{
    if(![MFMessageComposeViewController canSendText]) {
        
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSData *imgData = [NSData dataWithContentsOfURL:image];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    
    if (recipitants){
        [messageController setRecipients:recipitants];
    }
    
    [messageController addAttachmentData:imgData typeIdentifier:(NSString *)kUTTypeGIF filename:@"popmoji.gif"];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


- (NSURL *) makeAnimatedGif:(NSArray *) gifImages{
    NSUInteger kFrameCount =(unsigned long) [gifImages count];
    
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(0.15f), // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"popmoji.gif"];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            CGImageDestinationAddImage(destination, ((UIImage *)[gifImages objectAtIndex:i]).CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
  
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
  
    CFRelease(destination);
    NSLog(@"url=%@", fileURL);
    
    return fileURL;
}


#pragma GIF END
-(void) stickerCategory:(StickerCategoryViewController *)controller withCategoryName:(NSString *)name andID:(NSString *)categoryID {
    NSLog(@"CatName %@", name);
}

//SELECT STICKER DELEGATES
-(void) stickerCategory:(StickerCategoryViewController *)controller didFinishPickingStickerImage:(UIImage *)image withPackID:(NSString *)packID{
    NSLog(@"HIT IMAGE");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [_popController dismissPopoverAnimated:YES];
    } else {
        [controller dismissViewControllerAnimated:YES completion:^(void){
            
            if(![MFMessageComposeViewController canSendText]) {
                
                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support MMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warningAlert show];
                return;
                
            }
            
            [self sendMMSAnimated:nil withImage:[self makeAnimatedGif:@[[self getPopmoji:image withPad:5],
                                                                        [self getPopmoji:image withPad:0]
                                                                        ]]];
            
            return;
            
            NSData *imgData = UIImagePNGRepresentation([self imageFixBoundingBox:image]);
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController addAttachmentData:imgData typeIdentifier:(NSString *)kUTTypePNG filename:@"popmoji.png"];
            // Present message view controller on screen
            [self presentViewController:messageController animated:YES completion:nil];
        }];
    }
}

- (UIImage *)imageFixBoundingBox:(UIImage *)image{
    float height;
    float width;
    
    if (image.size.height >= image.size.width){
        height = 80;
        width = image.size.width / image.size.height * 80;
    } else {
        height = image.size.height / image.size.width * 80;
        width = 80;
    }
    
    CGRect rect;

    rect = CGRectMake(0, 0, 110, 120);

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    CGRect lowerImage = CGRectMake((rect.size.width - width) / 2, (rect.size.height - height) / 2,
                                   width,
                                   height);
    
    NSLog(@"IMAGE SIZE %@", NSStringFromCGSize(image.size));
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, lowerImage, image.CGImage);
    
    
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    
    return final;
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
        [Chartboost showInterstitial:CBLocationDefault];
    }];
}



#pragma SOCIAL ICONS

- (IBAction)iba_Facebook:(id)sender{
    NSURL *fanPageURL = [NSURL URLWithString:@"fb://profile/193823404061225"];
  
    if (![[UIApplication sharedApplication] openURL: fanPageURL]){
        [[UIApplication sharedApplication]
         openURL:[NSURL URLWithString:@"http://m.facebook.com/193823404061225"]];
    } else {
        [[UIApplication sharedApplication] openURL:fanPageURL];
    }
}


- (IBAction)iba_Twitter:(id)sender{
    NSURL *fanPageURL = [NSURL URLWithString:@"twitter:///user?screen_name=99centbrains"];
    
    if (![[UIApplication sharedApplication] openURL: fanPageURL]){
        [[UIApplication sharedApplication] openURL:[NSURL
           URLWithString:@"http://twitter.com/99centbrains"]];
           NSLog(@"Open Twitter"); 
    } else {
         NSLog(@"Open Twitte2r");
        [[UIApplication sharedApplication] openURL:fanPageURL];
    }
}

- (IBAction)iba_Insta:(id)sender{
    NSLog(@"Open Insta");
    NSURL *instagramURL = [NSURL 
                           URLWithString:@"instagram://user?username=99centbrains"];
    // OPENS USER 99CENTBRAINS
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        [[UIApplication sharedApplication] 
         openURL:[NSURL URLWithString:@"http://instagram.com/99centbrains"]];
    }
}

- (IBAction)iba_Web:(id)sender{
  NSLog(@"Open Web");
    
  NSURL *URL = [NSURL URLWithString:@"http://okjux.com/"];
	SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
  webViewController.barsTintColor = [UIColor blackColor];
	webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
   
	[self presentViewController:webViewController animated:YES completion:nil];
}


- (IBAction)iba_displayOMGSnap:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OMGStoryboard" bundle:nil];
    OMGTabBarViewController *playVC = (OMGTabBarViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_OMGTabBarViewController"];
    [self presentViewController:playVC animated:YES completion:^(void){
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    popoverController = nil;
    NSLog(@"PopOver NIL");
}

// EXTERNAL

- (void)handleDocumentOpenURL:(NSString *)url {
    if (url) {
      [TAOverlay showOverlayWithLabel:@"Downloading..." Options:(TAOverlayOptionOverlayTypeActivityBlur | TAOverlayOptionOverlaySizeFullScreen | TAOverlayOptionOverlayShadow)];
      [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                    selector:@selector(loadImageOnTimer:) userInfo:url repeats:NO];
    }
}

- (void)loadImageOnTimer:(NSTimer *)timer {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlayViewController *playVC = (PlayViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_PlayViewController"];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[timer userInfo]]];
    UIImage *image = [UIImage imageWithData:data];
    data = nil;

    playVC.userImage = image;
    [self.navigationController pushViewController:playVC animated:YES];
}



//UA
- (void)handleExternalURL:(NSString*)url{
    NSURL *URL = [NSURL URLWithString:url];
    [[UIApplication sharedApplication] openURL:URL];
}

- (void)handleInternalURL:(NSString*)url{
    NSURL *URL = [NSURL URLWithString:url];
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
    webViewController.barsTintColor = [UIColor blackColor];
    webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:webViewController animated:YES completion:nil];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
