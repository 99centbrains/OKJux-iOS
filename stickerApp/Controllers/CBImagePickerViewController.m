//
//  CBVideoCaptureViewController.m
//  OMFGif
//
//  Created by 99centbrains on 2/27/14.
//  Copyright (c) 2014 99centbrains. All rights reserved.
//

#import "CBImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TAOverlay.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PlayViewController.h"

@interface CBImagePickerViewController ()<AVCaptureFileOutputRecordingDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>{

    
   
    
    AVCaptureSession *captureSession;
    AVCaptureStillImageOutput *stillFileOutput;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

    BOOL cameraflipped;
    
}
@property (nonatomic, weak)  IBOutlet UIView *ibo_videoPreviewView;
@property (nonatomic, weak)  IBOutlet UIButton *ibo_btnPhotoLib;
@end

@implementation CBImagePickerViewController
@synthesize delegate;
@synthesize ibo_videoPreviewView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self setupCaptureCamera];
    
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [captureSession stopRunning];
    
    [super viewDidDisappear:animated];
    
}

- (void)viewDidLoad {
    
    cameraflipped = NO;
   
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
   
    [self setUpPhotoLibButton];
    
    _ibo_btnPhotoLib.layer.borderColor = [UIColor whiteColor].CGColor;
    _ibo_btnPhotoLib.layer.borderWidth = 1;
    _ibo_btnPhotoLib.layer.cornerRadius = 4;
    _ibo_btnPhotoLib.clipsToBounds = YES;
    _ibo_btnPhotoLib.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)cbVideoCaptureDidFinishBlank:(CBImagePickerViewController *)sender{
    
    [self cbVideoCaptureDidFinish:sender withImage:nil];
}

- (void)cbVideoCaptureDidFinish:(CBImagePickerViewController *)sender withImage:(UIImage *)image{
    
    [self cbVideoCaptureDidFinish:self withImage:image];return;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlayViewController *playVC = (PlayViewController *)[storyboard instantiateViewControllerWithIdentifier:@"seg_PlayViewController"];
    
    playVC.userImage = image;
    [self.navigationController pushViewController:playVC animated:YES];

    
}




- (IBAction)iba_cleanCanvas:(id)sender{
    
    [self cbVideoCaptureDidFinish:self withImage:nil];
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Canvas":@"Blank"} forEvent:@"Make"];

    
    
}

- (IBAction)iba_dismissViewController:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) setUpPhotoLibButton{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
                // Stop the enumerations
                *stop = YES; *innerStop = YES;
                
                
                [_ibo_btnPhotoLib setImage:latestPhoto forState:UIControlStateNormal];

            
            }
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups");
    }];
 
}

- (IBAction)iba_photoLibrary:(id)sender {
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
     [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^(void){
        
        [self cbVideoCaptureDidFinish:self withImage:[self fixrotation:image]];
        [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Canvas":@"PhotoLibrary"} forEvent:@"Make"];
        
    }];
    
}

- (IBAction)iba_toggleFlash:(id)sender {

}

- (IBAction)iba_flipCamera:(id)sender {
    
        if (cameraflipped){
            cameraflipped = NO;
        } else {
            cameraflipped = YES;
        }
    
        [captureSession stopRunning];
        captureSession = nil;
        [self setupCaptureCamera];
    
}

/*CAMERA CAPTURE*/
- (void) setupCaptureCamera{
    
    if (!captureSession){
        
        captureSession = [[AVCaptureSession alloc] init];
        [captureSession beginConfiguration];
        captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        //Capture Preview Layer
        captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]
                                                                initWithSession:captureSession];
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        captureVideoPreviewLayer.frame = ibo_videoPreviewView.bounds;
        captureVideoPreviewLayer.backgroundColor = [UIColor blackColor].CGColor;
        
        //Add Preview Layer
        if  (ibo_videoPreviewView.layer.sublayers){
            [[ibo_videoPreviewView.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
            [ibo_videoPreviewView.layer addSublayer:captureVideoPreviewLayer];
        } else {
            [ibo_videoPreviewView.layer addSublayer:captureVideoPreviewLayer];
        }
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
        [tapGR setNumberOfTapsRequired:1];
        [tapGR setNumberOfTouchesRequired:1];
        [self.ibo_videoPreviewView addGestureRecognizer:tapGR];
        
        
//        if([currentDevice isFocusPointOfInterestSupported] && [currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
//            NSError *error = nil;
//            [currentDevice lockForConfiguration:&error];
//            if(!error){
//                [currentDevice setFocusPointOfInterest:convertedPoint];
//                [currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
//                [currentDevice unlockForConfiguration];
//            }
//        }
        
        //flashView.alpha = 1;
        [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            
        } completion:^(BOOL finished) {
            
        }];
        
        
        //SET UP CAPTURE DEVICES
        /* Video */
        AVCaptureDevice *deviceVideo = [self getCameraDevice];
        
        //AVCaptureDevice *currentDevice =[self getCameraDevice];
        
        
        NSError *error = nil;
        AVCaptureDeviceInput *inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:deviceVideo error:&error];
        
        if (!inputVideo) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        
        //[inputVideo setFocusMode:AVCaptureFocusModeAutoFocus];

        
        stillFileOutput = [[AVCaptureStillImageOutput alloc] init];
        [[stillFileOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
        
        //Add Inputs
        [captureSession addInput:inputVideo];
        
        //OUTPUT
        [captureSession addOutput:stillFileOutput];
        
        
        
        
        
        //Commit and Start
        [captureSession commitConfiguration];
        
    }
    
        
    
    
    [captureSession startRunning];
        
    
    
}

-(void)tapToFocus:(UITapGestureRecognizer *)singleTap{
    
    CGPoint touchPoint = [singleTap locationInView:self.ibo_videoPreviewView];
    CGPoint convertedPoint = [captureVideoPreviewLayer captureDevicePointOfInterestForPoint:touchPoint];
    AVCaptureDevice *currentDevice =[self getCameraDevice];
    
    if([currentDevice isFocusPointOfInterestSupported] && [currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        NSError *error = nil;
        [currentDevice lockForConfiguration:&error];
        if(!error){
            [currentDevice setFocusPointOfInterest:convertedPoint];
            [currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            [currentDevice unlockForConfiguration];
        }
    }
    
    
//    if([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
//        NSError *error = nil;
//        if(!error){
//            
//            [device lockForConfiguration:nil];
//            
//            CGPoint autofocusPoint = CGPointMake(0.5f, 0.5f);
//            [device setFocusPointOfInterest:autofocusPoint];
//            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
//            
//            [device setTorchMode:AVCaptureTorchModeAuto];  // use AVCaptureTorchModeOff to turn off
//            [device unlockForConfiguration];
//            
//            //                        [currentDevice setFocusPointOfInterest:convertedPoint];
//            //                        [currentDevice unlockForConfiguration];
//        }
//    }
    
    
}

- (AVCaptureDevice *)getCameraDevice {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        
        
        
        if (cameraflipped){
            if ([device position] == AVCaptureDevicePositionBack) {
                return device;
                
            }
        } else {
            
            if ([device position] == AVCaptureDevicePositionFront) {
                return device;
            }
        }
        
    }
    
    return nil;
    
}



#pragma SNAPSHOT

- (IBAction)iba_snapShot:(id)sender{
    
    [self captureStillFrame];
    
}

/* ACTIONS FOR CAPTURE */

- (void) captureStillFrame {
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillFileOutput.connections){
        
        for (AVCaptureInputPort *port in [connection inputPorts]){
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    NSLog(@"about to request a capture from: %@", stillFileOutput);
    [stillFileOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments){
             
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
         
         } else
             NSLog(@"no attachments");
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         [self cbVideoCaptureDidFinish:self withImage:[self fixrotation:image]];
         
     }];

}


- (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
