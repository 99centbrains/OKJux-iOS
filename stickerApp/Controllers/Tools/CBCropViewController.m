//
//  CBCropViewController.m
//  StickyApp
//
//  Created by 99centbrains on 10/22/13.
//  Copyright (c) 2013 99centbrains. All rights reserved.
//

#import "CBCropViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CBCropViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>{

    UIImageView* ibo_userSelectedImageView;
    IBOutlet UIScrollView *ibo_uiScrollView;
    IBOutlet UIView* ibo_uiviewCropView;
    
    IBOutlet UIImageView *ibo_backgroundImage;
    
    UITapGestureRecognizer *ges_tapGestureRecognizer;
    UIPinchGestureRecognizer *ges_pinchGestureRecognizer;
    UIRotationGestureRecognizer *ges_rotateGestureRecognizer;
    UIPanGestureRecognizer *ges_panGestureRecognizer;

}

@end

@implementation CBCropViewController

@synthesize delegate;
@synthesize userImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Scale + Crop";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    
    UIBarButtonItem *navBarBtnNew = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(iba_chooseNewImage:)];
    
    
    self.navigationItem.leftBarButtonItem = navBarBtnNew;
    
    
    UIBarButtonItem *navbarButton = [[UIBarButtonItem alloc] initWithTitle:@"Crop"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(iba_cropComplete:)];
    self.navigationItem.rightBarButtonItem = navbarButton;
    
    
    
    
    ibo_userSelectedImageView = [[UIImageView alloc] init];
    ibo_userSelectedImageView.image = userImage;
    [ibo_uiScrollView addSubview:ibo_userSelectedImageView];
    
    ibo_uiScrollView.delegate = self;
    ibo_uiScrollView.scrollEnabled = YES;
    
    ibo_uiviewCropView.layer.borderColor = [UIColor whiteColor].CGColor;
    ibo_uiviewCropView.layer.borderWidth = 2.0f;
    ibo_uiviewCropView.layer.masksToBounds = NO;
    
    self.navigationController.navigationBarHidden = NO;
    
    NSLog(@"Crop Size Rect: %@", NSStringFromCGRect(ibo_uiviewCropView.frame));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self autoSizeImage];
}

- (void)autoSizeImage {
    if (userImage.size.width >= userImage.size.height){
        NSLog(@"Wide Image");
        ibo_userSelectedImageView.frame = CGRectMake(0, 0,
                                                     userImage.size.width/userImage.size.height * ibo_uiviewCropView.frame.size.height,
                                                     ibo_uiviewCropView.frame.size.height);
    } else {
        ibo_userSelectedImageView.frame = CGRectMake(0, 0,
                                                     ibo_uiviewCropView.frame.size.width,
                                                     userImage.size.height/userImage.size.width * ibo_uiviewCropView.frame.size.width);
        
        if (ibo_userSelectedImageView.frame.size.height < ibo_uiviewCropView.frame.size.height){
            
            ibo_userSelectedImageView.frame = CGRectMake(0, 0,
                                                         userImage.size.width/userImage.size.height * ibo_uiviewCropView.frame.size.height,
                                                         ibo_uiviewCropView.frame.size.height);
        }
    }

    //SET SCROLLVIEW
    ibo_uiScrollView.contentSize = ibo_userSelectedImageView.frame.size;
    ibo_uiScrollView.minimumZoomScale = 1;
    ibo_uiScrollView.maximumZoomScale = 2;
    ibo_uiScrollView.clipsToBounds = NO;
}

#pragma UIScroll Scaling
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [ibo_uiScrollView.subviews objectAtIndex:0];
}

- (IBAction)iba_chooseNewImage:(id)sender{
if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UIImage *)render {
    int resolutionScale;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        resolutionScale = 2;
    } else {
     resolutionScale = 4;
    }
    
    UIGraphicsBeginImageContextWithOptions(ibo_uiviewCropView.bounds.size, NO, 2 * resolutionScale);
    [ibo_uiviewCropView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"crop image h: %f", image.size.height);
    NSLog(@"crop image w: %f", image.size.width);
    
    return image;
}

- (IBAction)iba_cropComplete:(id)sender{
    ibo_uiviewCropView.layer.borderColor = [UIColor whiteColor].CGColor;
    ibo_uiviewCropView.layer.borderWidth = 0.0f;
    ibo_uiviewCropView.layer.masksToBounds = NO;
    
    [self.delegate photoCropUseImage:self withImage:[self imageWithImage:[self render]]];
}

- (UIImage *)imageWithImage:(UIImage *)image {
    int resolutionScale;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        resolutionScale = 2;
    } else {
        resolutionScale = 4;
    }
    
    float w = image.size.width *  resolutionScale;
    float h = image.size.height *  resolutionScale;
    CGRect bounds = CGRectMake(0.0, 0.0, w, h);

    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0);

    [image drawInRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return newImage;
}

// GESTURES

BOOL cbScaling = NO;
static CGFloat previousScale = 1.0;

- (void)iba_pinchGestureRecognizer:(UIPinchGestureRecognizer *)recognizer{
        if([recognizer state] == UIGestureRecognizerStateEnded) {
            previousScale = 1.0;
            NSLog(@"END SCALE");
            [self correctScaling];
            
            cbScaling = NO;
            return;
        }
    
        cbScaling = YES;
        CGFloat newScale = 1.0 - (previousScale - [recognizer scale]);
        
        CGAffineTransform currentTransformation = ibo_userSelectedImageView.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransformation, newScale, newScale);
        
        ibo_userSelectedImageView.transform = newTransform;
        
        previousScale = [recognizer scale];
}

BOOL kCorrectingImage = NO;
- (void)correctScaling{
    kCorrectingImage = YES;
    
    float destinationX;
    float destinationY;
    
    //POSITIONING
    if (ibo_userSelectedImageView.frame.origin.x > 0){
        destinationX = 0;
    } else if (ibo_userSelectedImageView.frame.origin.x + ibo_userSelectedImageView.frame.size.width < ibo_uiviewCropView.frame.origin.x + ibo_uiviewCropView.frame.size.width){
        destinationX = ibo_uiviewCropView.frame.size.width - ibo_userSelectedImageView.frame.size.width;
    } else {
        destinationX = ibo_userSelectedImageView.frame.origin.x;
    }

    if (ibo_userSelectedImageView.frame.origin.y > ibo_uiviewCropView.frame.origin.y - ibo_uiviewCropView.frame.origin.y){
        destinationY = ibo_uiviewCropView.frame.origin.y - ibo_uiviewCropView.frame.origin.y;
    } else if (ibo_userSelectedImageView.frame.origin.y + ibo_userSelectedImageView.frame.size.height < ibo_uiviewCropView.frame.origin.y + ibo_uiviewCropView.frame.size.height - ibo_uiviewCropView.frame.origin.y){
        destinationY = ibo_uiviewCropView.frame.size.height - ibo_userSelectedImageView.frame.size.height;
    } else {
        destinationY = ibo_userSelectedImageView.frame.origin.y;
    }

    //POSITIONING END
    CGRect imageRect  = CGRectMake(destinationX,
                                   destinationY,
                                   ibo_userSelectedImageView.frame.size.width,
                                   ibo_userSelectedImageView.frame.size.height);
    
    //Correct Sizing
    //PORTRAIT
    if (ibo_userSelectedImageView.frame.size.width < ibo_userSelectedImageView.frame.size.height){
        //Width of Image is Less than Crop Width
        if (ibo_userSelectedImageView.frame.size.width < ibo_uiviewCropView.frame.size.width){
            
            imageRect = CGRectMake(imageRect.origin.x,
                                   imageRect.origin.y,
                                   ibo_uiviewCropView.frame.size.width,
                                   ibo_userSelectedImageView.frame.size.height/ibo_userSelectedImageView.frame.size.width * ibo_uiviewCropView.frame.size.width);
        }
    } else {
        //Height of Image is Less than Crop Height
        if (ibo_userSelectedImageView.frame.size.height < ibo_uiviewCropView.frame.size.height){
            
            imageRect = CGRectMake(imageRect.origin.x,
                                   imageRect.origin.y,
                                    ibo_userSelectedImageView.frame.size.width/ibo_userSelectedImageView.frame.size.height * ibo_uiviewCropView.frame.size.height,
                                   ibo_uiviewCropView.frame.size.height);
            
        }
    }
    
    //ANIMATE FIX
    [UIView animateWithDuration:.5 animations:^(void){
        ibo_userSelectedImageView.frame = imageRect;
    } completion:^(BOOL completed){
        kCorrectingImage = NO;
    }];
}

static CGFloat beginX = 0;
static CGFloat beginY = 0;

- (void)iba_panGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        NSLog(@"END PAN");
        [self correctScaling];
        return;
    }
    
    CGPoint newCenter = [recognizer translationInView:self.view];
    
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        beginX = ibo_userSelectedImageView.center.x;
        beginY = ibo_userSelectedImageView.center.y;
    }
    
    newCenter = CGPointMake(beginX + newCenter.x, beginY + newCenter.y);
    
    [ibo_userSelectedImageView setCenter:newCenter];
}

- (void)correctPan{
    float destinationX;
    float destinationY;
    
    //WIDTH
    if (ibo_userSelectedImageView.frame.origin.x > 0){
        destinationX = 0;
    } else if (ibo_userSelectedImageView.frame.origin.x + ibo_userSelectedImageView.frame.size.width < ibo_uiviewCropView.frame.origin.x + ibo_uiviewCropView.frame.size.width){
        destinationX = ibo_uiviewCropView.frame.size.width - ibo_userSelectedImageView.frame.size.width;
    } else {
        destinationX = ibo_userSelectedImageView.frame.origin.x;
    }
    
    //HEIGHT
    if (ibo_userSelectedImageView.frame.origin.y > ibo_uiviewCropView.frame.origin.y - ibo_uiviewCropView.frame.origin.y){
        destinationY = ibo_uiviewCropView.frame.origin.y - ibo_uiviewCropView.frame.origin.y;
    } else if (ibo_userSelectedImageView.frame.origin.y + ibo_userSelectedImageView.frame.size.height < ibo_uiviewCropView.frame.origin.y + ibo_uiviewCropView.frame.size.height - ibo_uiviewCropView.frame.origin.y){
        destinationY = ibo_uiviewCropView.frame.size.height - ibo_userSelectedImageView.frame.size.height;
    } else {
        destinationY = ibo_userSelectedImageView.frame.origin.y;
    }

    [UIView animateWithDuration:.5 animations:^(void){
        ibo_userSelectedImageView.frame = CGRectMake(destinationX,
                                                      destinationY,
                                                      ibo_userSelectedImageView.frame.size.width,
                                                      ibo_userSelectedImageView.frame.size.height);
    } completion:^(BOOL completed){}];
}

- (void)iba_tapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        return;
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    userImage = nil;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

@end
