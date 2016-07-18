//
//  CBPhotoCropViewController.m
//  thecreator
//
//  Created by Franky Aguilar on 1/7/13.
//  Copyright (c) 2013 99centbrains. All rights reserved.
//

#import "CBPhotoCropViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface CBPhotoCropViewController ()<UIGestureRecognizerDelegate>{
    
    //IBOutlet UIView* uiviewCropView;
    IBOutlet UIImageView* userSelectedPhoto;
    IBOutlet UIImageView *transImage;
    IBOutlet UIView* uiviewCropView;
    
    UIPinchGestureRecognizer *pinchRecognizer;
    UIRotationGestureRecognizer *roateRecognizer;
    UIPanGestureRecognizer *panGesture;
}

@end

@implementation CBPhotoCropViewController

@synthesize delegate = _delegate;
@synthesize userImageOverlay;
@synthesize userImage;
@synthesize cropRectangle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                       initWithTarget:self action:@selector(stickyPinch:)];
    pinchRecognizer.delegate = self;
    [uiviewCropView addGestureRecognizer:pinchRecognizer];
    
    roateRecognizer = [[UIRotationGestureRecognizer alloc]
                       initWithTarget:self action:@selector(stickyRotate:)];
    roateRecognizer.delegate = self;
    [uiviewCropView addGestureRecognizer:roateRecognizer];
    
    panGesture = [[UIPanGestureRecognizer alloc]
                  initWithTarget:self action:@selector(stickyMove:)];
    panGesture.delegate = self;
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:2];
    [uiviewCropView addGestureRecognizer:panGesture];

    
    float sizeforscreen = 0;
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
         sizeforscreen = 700;
         
     } else {
         sizeforscreen = 320;
         
     }
    if (userImage.size.height > userImage.size.width){
        //Portrait
        userSelectedPhoto.frame = CGRectMake(0, 0, sizeforscreen, (userImage.size.height/userImage.size.width) *sizeforscreen);
        
    } else {
        //LandScape
        userSelectedPhoto.frame = CGRectMake(0, 0, (userImage.size.width/userImage.size.height) *sizeforscreen, sizeforscreen);

        
    }
    
    userSelectedPhoto.center = CGPointMake(sizeforscreen/2, sizeforscreen/2);
    
    userSelectedPhoto.image = userImage;
    
    //uiviewCropView.layer.contentsScale = [[UIScreen mainScreen] scale];
    
    
    uiviewCropView.layer.rasterizationScale = 2;


    
    NSLog(@"Set Image");
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{

    
   
}

- (void)viewDidAppear:(BOOL)animated    {
    NSLog(@"CROP X %f", cropRectangle.origin.x);
    NSLog(@"CROP Y %f", cropRectangle.origin.y);
    NSLog(@"CROP W %f", cropRectangle.size.width);
    NSLog(@"CROP H %f", cropRectangle.size.height);

    
    //self.view.frame = CGRectMake(0, 0, 500, 800);
    
    //uiviewCropView.frame = cropRectangle;
    //transImage.frame = cropRectangle;
}

- (IBAction)iba_retakePhoto:(id)sender{
    
    
    [self.delegate photoRetakeImage:self];
    
    
}

- (IBAction)iba_usePhoto:(id)sender{
    NSLog(@"IBA USE");
    
    
    
    UIImage *image = [self imageWithImage:[self render]];
    NSLog(@"use image h: %f", image.size.height);
    NSLog(@"use image w: %f", image.size.width);
    
    [self.delegate photoCropUseImage:self withImage:image];
    image = nil;
}

- (UIImage *)imageWithImage:(UIImage *)image {
    //UIGraphicsBeginImageContext(newSize);
    
    int scale = [[UIScreen mainScreen]scale];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        scale = 2.0;
    }
    
    
    float w = image.size.width *  scale;
    float h = image.size.height *  scale;
    
    CGRect bounds = CGRectMake(0.0, 0.0, w, h);
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)render{
    
    CGFloat scale = 1.0;
    
   
    if([[UIScreen mainScreen]respondsToSelector:@selector(scale)]) {
        
        CGFloat tmp = [[UIScreen mainScreen]scale];
        if (tmp > 1.5) {
            scale = 2.0;
        }
    
    }
    
    float w = uiviewCropView.bounds.size.width;
    float h = uiviewCropView.bounds.size.height;
    
    CGRect bounds = CGRectMake(0.0, 0.0, w, h);
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, scale);
    //uiviewCropView.layer.transform = CATransform3DMakeScale(scale, scale, 1);

    [uiviewCropView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSLog(@"image h: %f", image.size.height);
    NSLog(@"image w: %f", image.size.width);
    
    return image;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// GESTURES

static CGFloat beginX = 0;
static CGFloat beginY = 0;

-(void)stickyMove:(UIPanGestureRecognizer *) recognizer {
    
    //UIImage *tempImage = ibo_forground.image;
    
    
    
    
    
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        //cbRotating = NO;
        
        return;
        
    }
    
    CGPoint newCenter = [recognizer translationInView:self.view];
    
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        
        beginX = userSelectedPhoto.center.x;
        beginY = userSelectedPhoto.center.y;
        

        
    }
    
    newCenter = CGPointMake(beginX + newCenter.x, beginY + newCenter.y);
    
    [userSelectedPhoto setCenter:newCenter];
    
    
    
    
}

BOOL cbScaling = NO;
static CGFloat previousScale = 1.0;

-(void) stickyPinch:(UIPinchGestureRecognizer *)recognizer {
    
    
    
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        cbScaling = NO;
        previousScale = 1.0;
        return;
    }
    cbScaling = YES;
    CGFloat newScale = 1.0 - (previousScale - [recognizer scale]);
    
    CGAffineTransform currentTransformation = userSelectedPhoto.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransformation, newScale, newScale);
    
    userSelectedPhoto.transform = newTransform;
    
    previousScale = [recognizer scale];
    
    
}


BOOL cbRotating = NO;

static CGFloat previousRotation = 0.0;
- (void)stickyRotate:(UIRotationGestureRecognizer *)recognizer {
    
    
    
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        
        cbRotating = NO;
        previousRotation = 0.0;
        return;
    }
    
    cbRotating = YES;
    CGFloat newRotation = 0.0 - (previousRotation - [recognizer rotation]);
    
    CGAffineTransform currentTransformation = userSelectedPhoto.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransformation, newRotation);
    
    userSelectedPhoto.transform = newTransform;
    
    previousRotation = [recognizer rotation];
    
    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
