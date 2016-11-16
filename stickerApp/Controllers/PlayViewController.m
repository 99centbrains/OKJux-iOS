//
//  PlayViewController.m
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"
#import "QuartzCore/QuartzCore.h"

#import "SelectStickerQuickViewController.h"
#import "StickerCategoryViewController.h"
#import "StickyImageView.h"
#import "PlayEditModeViewController.h"
#import "ShareViewController.h"
#import "TAOverlay.h"
#import "CBCropViewController.h"
#import "PlayBorderSelectViewController.h"
#import "PlayPaintViewController.h"
#import "CBColorPickerViewController.h"
#import "CBFontToolViewController.h"
#import "CBFontCollectionViewController.h"
#import <Chartboost/Chartboost.h>
#import <AdColony/AdColony.h>

#import "KSLabel.h"
#import "UIImage+Trim.h"
#import <CoreImage/CoreImage.h>
#import "PaintView.h"

#import "OMGPublishViewController.h"

@interface PlayViewController () <PlayBorderSelectViewControllerDelegate, UIActionSheetDelegate, CBCropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PlayPaintViewControllerDelegate, CBColorPickerViewControllerDelegate, CBFontToolViewControllerDelegate, CBFontCollectionViewControllerDelegate, AdColonyAdDelegate, UITextFieldDelegate, StickerCategoryViewControllerDelegate> {

    UIPopoverController *popController;

    PlayEditModeViewController *editMode;
    PlayBorderSelectViewController *borderView;
    
    UITextField *fontTextField;
    CGPoint lastPoint;
    UIView *ibo_DarkView;
    float rotation;
}

- (IBAction)actionStartNew:(id)sender;
- (IBAction)actionSave:(id)sender;
- (IBAction)actionSelectSticker:(id)sender;

- (IBAction)iba_toolCam:(id)sender;
- (IBAction)iba_toolBorder:(id)sender;
- (IBAction)iba_toolPaint:(id)sender;
- (IBAction)iba_toolText:(id)sender;

@property (nonatomic, strong) UIPopoverController *popController;

@property (nonatomic, strong) StickyImageView *currentSticker;
@property (nonatomic, strong) PaintView *painterView;
@property (nonatomic, strong) KSLabel *prop_superlabel;

//TOOLS
@property (nonatomic, strong) PlayPaintViewController *ibo_paintViewTool;
@property (nonatomic, strong) CBFontToolViewController *ibo_fontTool;
@property (nonatomic, strong) CBColorPickerViewController *ibo_colorPickerView;
@property (nonatomic, strong) CBFontCollectionViewController *ibo_fontCollectionList;

//OUTLETS
@property (nonatomic, strong) UIImageView *ibo_imageUser;
@property (nonatomic, strong) UIView *ibo_viewStickerStage;

@property (weak, nonatomic) IBOutlet UIView *ibo_renderView;
@property (weak, nonatomic) IBOutlet UIView *ibo_toolbarView;

@property (weak, nonatomic) IBOutlet UIButton *ibo_btn_text;
@property (weak, nonatomic) IBOutlet UIButton *ibo_btn_cam;
@property (weak, nonatomic) IBOutlet UIButton *ibo_btn_painter;

@end

@implementation PlayViewController

@synthesize userImage;
@synthesize currentSticker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
  
    [self setUpCanvasViews];
    rotation = 0;
  
    //Gestures
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(stickyPinch:)];
    pinchRecognizer.delegate = self;
    [_ibo_viewStickerStage addGestureRecognizer:pinchRecognizer];
    
    UIRotationGestureRecognizer *roateRecognizer = [[UIRotationGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(stickyRotate:)];
    roateRecognizer.delegate = self;
    [_ibo_viewStickerStage addGestureRecognizer:roateRecognizer];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(stickyMove:)];
    panGesture.delegate = self;
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:2];
    [_ibo_viewStickerStage addGestureRecognizer:panGesture];
  
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
    [self.view becomeFirstResponder];
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeCurrentSticker:)
                                                 name:@"SetCurrentStickerNotification"
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    //SET SUBVIEW LAYOUTS
    _ibo_imageUser.frame = _ibo_renderView.bounds;
    _ibo_viewStickerStage.frame = _ibo_renderView.bounds;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     [self.view resignFirstResponder];
}

- (void) setUpCanvasViews {
    //USER IMAGE
    _ibo_imageUser = [[UIImageView alloc] initWithFrame:_ibo_renderView.bounds];
    [_ibo_imageUser setContentMode:UIViewContentModeScaleAspectFill];
    _ibo_imageUser.clipsToBounds = YES;
    [_ibo_renderView addSubview:_ibo_imageUser];
    if (userImage){
        [_ibo_imageUser setImage:userImage];
    }
    
    //INIT StickerContainer
    _ibo_viewStickerStage = [[UIView alloc] initWithFrame:_ibo_renderView.bounds];
    _ibo_viewStickerStage.userInteractionEnabled = YES;
    [_ibo_renderView addSubview:_ibo_viewStickerStage];
}

#pragma tool_SelectSticker
- (IBAction)actionSelectSticker:(id)sender {
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"StickerSelectStoryboard" bundle:[NSBundle mainBundle]];
    
    //NAVCONT
    UINavigationController *controller = (UINavigationController*)[mainSB instantiateViewControllerWithIdentifier: @"seg_stickerNavigation"];
    
    StickerCategoryViewController *newController = [controller.viewControllers objectAtIndex:0];
    newController.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _popController = [[UIPopoverController alloc] initWithContentViewController:controller];
        //_popController.delegate = self;
        _popController.delegate = self;
        _popController.popoverContentSize = CGSizeMake(500, 650); //your custom size.
        [_popController presentPopoverFromRect:CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, 650) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    } else {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(void) stickerCategory:(StickerCategoryViewController *)controller withCategoryName:(NSString *)name andID:(NSString *)categoryID {
    NSLog(@"CatName %@", name);
}

//SELECT STICKER DELEGATES
-(void) stickerCategory:(StickerCategoryViewController *)controller didFinishPickingStickerImage:(UIImage *)image withPackID:(NSString *)packID{
    if (packID){
        [[CBJSONDictionary shared] parse_trackAnalytic:@{@"PackID":packID} forEvent:@"Sticker"];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [_popController dismissPopoverAnimated:YES];
    } else {
         [controller dismissViewControllerAnimated:YES completion:nil];
    }
    
    image = [image imageByTrimmingTransparentPixels];
    currentSticker = [[StickyImageView alloc] initWithImage:[self imageWithImage:image
                                                                              scaledToSize:CGSizeMake(640,(image.size.height/image.size.width)* 640 )]];
    
    //[dragger setFrameForFrame];
    currentSticker.frame = CGRectMake(0,
                               0,
                               250,
                               (image.size.height/image.size.width) * 250);
    
    currentSticker.contentMode = UIViewContentModeScaleAspectFit;
    currentSticker.center = CGPointMake(_ibo_renderView.frame.size.width/2, _ibo_renderView.frame.size.height/2);
    currentSticker.transform = CGAffineTransformMakeRotation(rotation);
    rotation += 0.1;
    currentSticker.userInteractionEnabled = YES;

    [_ibo_viewStickerStage addSubview:currentSticker];

    [self showEditMode];
    [self hideToolBar];
    
    [self setBorderOnCurrentSticker];
}

- (void) setBorderOnCurrentSticker {
    if (currentSticker){
        currentSticker.backgroundColor = [UIColor colorWithWhite:1 alpha:.5];
        currentSticker.layer.borderColor = [self colorFromHexString:@"#FF38D6"].CGColor;
        currentSticker.layer.borderWidth = 3.0f;
    }
}

- (void) removeBorderOnCurrentSticker {
    if (currentSticker){
        currentSticker.backgroundColor = [UIColor clearColor];
        currentSticker.layer.borderColor = [UIColor clearColor].CGColor;
        currentSticker.layer.borderWidth = .0f;
    }
}

- (void)showEditMode {
    if (!editMode){
        editMode = (PlayEditModeViewController *)[self viewControllerFromMainStoryboardWithName:@"PlayEditModeViewController"];
        editMode.delegate = self;
        editMode.view.frame = CGRectMake(0,
                                         self.view.bounds.size.height - 110,
                                         self.view.bounds.size.width,
                                         110);
        
        [self.view addSubview:editMode.view];
        [self addChildViewController:editMode];
        
        NSLog(@"Create Edit Mode %@", NSStringFromCGRect(editMode.view.frame));

        [self hideSelectedViews:@[_ibo_btn_cam, _ibo_btn_painter, _ibo_btn_text]];
    }
}

- (void)hideEditMode {
    [editMode.view removeFromSuperview];
    editMode.delegate = nil;
    editMode = nil;
    
    [self showSelectedViews:@[_ibo_btn_cam, _ibo_btn_painter, _ibo_btn_text]];
  
    if (ibo_DarkView){
        [self action_darkenViewRemove];
    }
}

- (void)showToolBar {
    _ibo_toolbarView.hidden = NO;

}

- (void)hideToolBar{
    _ibo_toolbarView.hidden = YES;
}

- (void) hideSelectedViews:(NSArray *)viewList {
    [UIView animateWithDuration:.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        for ( UIView* outlet in viewList){
            outlet.alpha = 0;
        }
    } completion:^(BOOL done){
    
    }];
}

- (void) showSelectedViews:(NSArray *)viewList {
    [UIView animateWithDuration:.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        for ( UIView* outlet in viewList){
            outlet.alpha = 1;
        }
        
    } completion:^(BOOL done){
        
    }];
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)selectStickerQuickViewControllerDidCancel:(SelectStickerQuickViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

// STICKER NSNOTIFICATION
- (void) changeCurrentSticker:(NSNotification *) notification {
    currentSticker.layer.borderWidth = 0;
    currentSticker.backgroundColor = nil;
    [self showEditMode];
    [self hideToolBar];

    currentSticker = (StickyImageView*)notification.object;

    [[currentSticker superview] bringSubviewToFront:currentSticker];
    [self setBorderOnCurrentSticker];
}

-(void) selectStickerViewControllerDidCancel:(SelectStickerQuickViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma EDIT MODE
- (void)editModeLayerMoveUp:(SelectStickerQuickViewController *)controller {
    int currentStickerIndex = [_ibo_viewStickerStage.subviews indexOfObject:currentSticker];
    [_ibo_viewStickerStage exchangeSubviewAtIndex:currentStickerIndex+1 withSubviewAtIndex:currentStickerIndex];
}

- (void)editModeLayerMoveDown:(SelectStickerQuickViewController *)controller {
    int currentStickerIndex = [_ibo_viewStickerStage.subviews indexOfObject:currentSticker];
    [_ibo_viewStickerStage exchangeSubviewAtIndex:currentStickerIndex- 1 withSubviewAtIndex:currentStickerIndex];
}

- (void)editModeStickerDone:(SelectStickerQuickViewController *)controller {
    [self hideEditMode];
    [self showToolBar];
    [self removeBorderOnCurrentSticker];
    
    currentSticker = nil;
}

- (void)editModeStickerCopy:(SelectStickerQuickViewController *)controller {
    [self removeBorderOnCurrentSticker];
    [self stickerCategory:nil didFinishPickingStickerImage:currentSticker.image withPackID:nil];
}

- (void) editModeStickerSendToBack:(PlayEditModeViewController*)controller {
     [[currentSticker superview] sendSubviewToBack:currentSticker];
}

- (void) editModeStickerTrash:(PlayEditModeViewController*)controller {
    [UIView animateWithDuration:.1 delay: 0.0 options: UIViewAnimationOptionCurveEaseIn
                     animations:^ {
                         currentSticker.transform = CGAffineTransformScale(currentSticker.transform, .5, .5);
                         currentSticker.alpha = 0;
                         
                     } completion:^ (BOOL finished) {
                         [currentSticker removeFromSuperview];
                         currentSticker = nil;
                     }];
    
    [self showToolBar];
    [self hideEditMode];
}

- (void) editModeStickerFlip:(PlayEditModeViewController*)controller {
    [currentSticker flipImage];
}


#pragma Tool Actions

- (IBAction)iba_toolCam:(id)sender {
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Type":@"CameraImport"} forEvent:@"Tool"];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showFromRect:CGRectMake(0, 900, 200, 200) inView:self.view animated:YES];
    }else {
        [actionSheet showFromRect:self.view.frame inView:self.view animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            NSLog(@"Take Photo");
            [self iba_photoTake:nil];
            break;
        case 1:
            NSLog(@"Choose Photo");
            [self iba_photoChoose:nil];
            break;
        default:
            break;
    }
}

- (IBAction)iba_photoTake:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
      picker.sourceType = UIImagePickerControllerSourceTypeCamera;
      [self presentViewController:picker animated:YES completion:nil];
    } else {
      [self iba_photoChoose:sender];
    }
}

- (IBAction)iba_photoChoose:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (popController){
            [popController  dismissPopoverAnimated:NO];
        }
        popController = [[UIPopoverController alloc] initWithContentViewController:picker];
        [popController setPopoverContentSize:CGSizeMake(320, 460)];
        [popController presentPopoverFromRect:_ibo_toolbarView.frame
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES ];
    } else {
       [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (popController){
            [popController dismissPopoverAnimated:YES];
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
      [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"Cropper Alloc");
  
    [self photoCropUseImage:picker withImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    return;
  
    CBCropViewController *photoCropViewController = [[CBCropViewController alloc]initWithNibName:@"CBCropViewController" bundle:nil];
    photoCropViewController.delegate = self;
    photoCropViewController.userImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //[picker pushViewController:photoCropViewController animated:NO];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        [picker pushViewController:photoCropViewController animated:YES];
        [popController dismissPopoverAnimated:YES];
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            [popController dismissPopoverAnimated:YES];
            [picker dismissViewControllerAnimated:YES completion:nil];
            [self presentViewController:photoCropViewController animated:YES completion:nil];
            return;
        } else {
            [picker pushViewController:photoCropViewController animated:YES];
        }
    }
}

- (void)photoRetakeImage:(CBCropViewController*)controller{
   [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoCropUseImage:(id)controller withImage:(UIImage*)image{
    [TAOverlay showOverlayWithLabel:@"..." Options:(TAOverlayOptionOverlayShadow | TAOverlayOptionOverlayTypeActivityBlur)];
    
    [(UIImagePickerController *)controller dismissViewControllerAnimated:YES completion:^(void){
        [TAOverlay hideOverlay];
        [self stickerCategory:nil didFinishPickingStickerImage:image withPackID:nil];
    }];
}

#pragma PAINTTOOL
- (IBAction)iba_toolPaint:(UIButton *)sender{
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Type":@"Painter"} forEvent:@"Tool"];
    if (!_painterView){
        
        //INIT PAINTERVIEW
        _painterView = [[PaintView alloc] initWithFrame:_ibo_renderView.bounds];
        [_ibo_renderView insertSubview:_painterView aboveSubview:_ibo_imageUser];
        _painterView.backgroundColor = [UIColor clearColor];
        _painterView.layer.contentsScale = [[UIScreen mainScreen] scale];
        
    }
    
    if (!_ibo_paintViewTool){
    
        _ibo_paintViewTool = (PlayPaintViewController *)[self viewControllerFromMainStoryboardWithName:@"seg_PlayPaintViewController"];
        _ibo_paintViewTool.view.frame = CGRectMake(sender.frame.origin.x,
                                               sender.frame.size.height + sender.frame.origin.y,
                                               50,
                                               160);
        
        NSLog(@"Sender Frame %@", NSStringFromCGRect(_ibo_paintViewTool.view.frame));
        
        _ibo_paintViewTool.delegate = self;
        [self.view addSubview:_ibo_paintViewTool.view];
        
        _ibo_viewStickerStage.userInteractionEnabled = NO;
        _painterView.userInteractionEnabled = YES;
        _painterView.brushcolor = [UIColor blackColor];
        [_painterView setEraser:YES];
        _painterView.strokeSize = 20;
        
        [self hideToolBar];
        [self hideSelectedViews:@[_ibo_btn_text, _ibo_btn_cam]];
        
    } else {
        
        //painterView.userInteractionEnabled = NO;
        _ibo_viewStickerStage.userInteractionEnabled = YES;
        
        [_ibo_paintViewTool.view removeFromSuperview];
        _ibo_paintViewTool.delegate = nil;
        _ibo_paintViewTool = nil;
        
        [self showToolBar];
        [self showSelectedViews:@[_ibo_btn_text, _ibo_btn_cam]];
    }
}


- (void) playPaintVCChangeSize:(PlayPaintViewController *)controller withSize:(NSInteger)size{
    __block UIView *brushView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    brushView.layer.cornerRadius = brushView.frame.size.height/2;
    brushView.backgroundColor = [UIColor blackColor];
    brushView.layer.borderColor = [UIColor whiteColor].CGColor;
    brushView.layer.borderWidth = 2;
  
    brushView.frame = CGRectMake(self.view.frame.size.width/2 - size/2, self.view.frame.size.height/2 - size/2, size, size);
    [self.view addSubview:brushView];
    
    [UIView animateWithDuration:.65 animations:^(void){
        brushView.alpha = 0;
    } completion:^(BOOL done){
        [brushView removeFromSuperview];
        brushView = nil;
    }];
    
   _painterView.strokeSize = size;
}

- (void) playPaintVCChangeMode:(PlayPaintViewController *)controller withMode:(BOOL)mode {
    [_painterView setEraser:mode];
}

- (void) playPaintVCChangeColor:(PlayPaintViewController *)controller {
    [self action_displayColorPicker:controller];
}



#pragma TEXTTOOL
- (IBAction)iba_toolText:(UIButton *)sender {
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Type":@"Text"} forEvent:@"Tool"];
    if (!_ibo_fontTool){
        _ibo_fontTool = (CBFontToolViewController *)[self viewControllerFromMainStoryboardWithName:@"seg_CBFontToolViewController"];
        _ibo_fontTool.delegate = self;
        _ibo_fontTool.view.frame = CGRectMake(sender.frame.origin.x,
                                              sender.frame.origin.y + sender.frame.size.height,
                                              50,
                                              160);
        
        NSLog(@"Sender Frame %@", NSStringFromCGRect(_ibo_fontTool.view.frame));
        
        [self.view addSubview:_ibo_fontTool.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(action_keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        //SETUP FONT
        KSLabel *fancyLabel = [[KSLabel alloc] initWithFrame:CGRectMake(10,
                                                                        _ibo_renderView.frame.size.height/2 - 100,
                                                                        _ibo_renderView.frame.size.width - 20,
                                                                        200)];
        
        NSInteger fontSize = 84;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            fontSize = 400;
        }
      
        fancyLabel.text = @"";
        fancyLabel.font = [UIFont fontWithName:@"ROCKY AOE" size:fontSize];
        fancyLabel.adjustsFontSizeToFitWidth = YES;
        fancyLabel.textAlignment = NSTextAlignmentCenter;
        fancyLabel.numberOfLines = 3;
        [fancyLabel setMinimumScaleFactor:3/[UIFont labelFontSize]];
        [fancyLabel setDrawOutline:YES];
        [fancyLabel setTextColor:[UIColor whiteColor]];
        [fancyLabel setOutlineColor:[UIColor blackColor]];
        [fancyLabel setDrawGradient:NO];
        
        fontTextField = [[UITextField alloc] initWithFrame:fancyLabel.frame];
        fontTextField.delegate = self;
        fontTextField.hidden = YES;
        [fontTextField becomeFirstResponder];
        [fontTextField addTarget:self action:@selector(iba_changedText:) forControlEvents:UIControlEventEditingChanged];
        
        [_ibo_viewStickerStage addSubview:fontTextField];
        [_ibo_viewStickerStage addSubview:fancyLabel];

        _prop_superlabel = fancyLabel;
        
        [self hideToolBar];
        [self hideSelectedViews:@[_ibo_btn_painter, _ibo_btn_cam]];
    } else {
        [_ibo_fontTool.view removeFromSuperview];
        _ibo_fontTool.delegate = nil;
        _ibo_fontTool = nil;
        
        [self renderFancyLabel];
        [self showSelectedViews:@[_ibo_btn_painter, _ibo_btn_cam]];
    }
}

- (void) cbFontToolChangeColor:(CBFontToolViewController *)controller {
    [self action_displayColorPicker:controller];
}

- (void)iba_changedText:(UITextField *)sender {
    _prop_superlabel.text = sender.text;
}

- (void) cbFontToolToggleStroke:(CBFontToolViewController *)controller withBool:(BOOL)stroked {
    _prop_superlabel.drawOutline = stroked;
    _prop_superlabel.text = _prop_superlabel.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_ibo_fontTool.view removeFromSuperview];
    _ibo_fontTool.delegate = nil;
    _ibo_fontTool = nil;
    
    [self renderFancyLabel];
    //[self showSelectedViews:@[_ibo_btn_painter, _ibo_btn_cam]];
    
    return YES;
}

- (void) renderFancyLabel {
    if (![_prop_superlabel.text isEqualToString:@""]){
        CGSize fontViewSize = CGSizeMake(_prop_superlabel.frame.size.width, _prop_superlabel.frame.size.height);
        UIGraphicsBeginImageContextWithOptions(fontViewSize, NO, 4);
        [_prop_superlabel.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self stickerCategory:nil didFinishPickingStickerImage:image withPackID:nil];
    } else {
        [self editModeStickerDone:nil];
    }
    
    [_prop_superlabel removeFromSuperview];
    _prop_superlabel = nil;
    
    [fontTextField resignFirstResponder];
    [fontTextField removeFromSuperview];
    fontTextField = nil;
    fontTextField.delegate = nil;
}

- (void)action_keyboardWasShown:(NSNotification *)notification {
    // Get the size of the keyboard.
    //CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //your other code here..........
}

//FONT LISTER
- (void) cbFontToolChangeFont:(CBFontToolViewController *)controller {
    [fontTextField resignFirstResponder];
    
    _ibo_fontCollectionList = (CBFontCollectionViewController *)[self viewControllerFromMainStoryboardWithName:@"seg_CBFontCollectionViewController"];
    _ibo_fontCollectionList.delegate = self;
    _ibo_fontCollectionList.view.frame = self.view.frame;
    _ibo_fontCollectionList.view.frame = CGRectOffset(self.view.frame, -self.view.frame.size.width, 0);
    [self.view addSubview:_ibo_fontCollectionList.view];
    
    [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        _ibo_fontCollectionList.view.frame = CGRectOffset(self.view.frame, 0, 0);
    } completion:^(BOOL done){
    
    }];
  
    //SHOW FONT CONTROLLER
}

- (void)CBFontCollectionDidChooseFont:(CBFontCollectionViewController *)controller withFont:(UIFont *)font{
    [fontTextField becomeFirstResponder];
    [_prop_superlabel setFont:font];
    
    if (_ibo_fontCollectionList){
        [_ibo_fontCollectionList.view removeFromSuperview];
        _ibo_fontCollectionList.delegate = nil;
        _ibo_fontCollectionList = nil;
    }
}

#pragma CBColorPicker
- (void) action_displayColorPicker:(id)sender {
    if ([sender isKindOfClass:[CBFontToolViewController class]]){
        NSLog(@"Text Field");
        [fontTextField resignFirstResponder];
    }
    
    if (!_ibo_colorPickerView){
        
        _ibo_colorPickerView = [[CBColorPickerViewController alloc] initWithNibName:@"CBColorPickerViewController" bundle:nil];
        _ibo_colorPickerView.view.frame = CGRectMake(0, 0, 10, 10);
        _ibo_colorPickerView.highRes = YES;
        _ibo_colorPickerView.delegate = self;
        _ibo_colorPickerView.someController = sender;
        [self.view addSubview:_ibo_colorPickerView.view];
        
        [UIView animateWithDuration:.5 animations:^(void){
        
            _ibo_colorPickerView.view.frame = self.view.frame;

        }];
    }
}

- (void) CBColorPickerVCChangeColor:(CBColorPickerViewController *)controller withImage:(UIImage *)pickedImage {
    if ([_ibo_colorPickerView.someController isKindOfClass:[PlayPaintViewController class]]){
        NSLog(@"Sender Tag %@", [_ibo_colorPickerView.someController  class]);
        _painterView.brushcolor = [UIColor colorWithPatternImage:[self imageResize:pickedImage andResizeTo:CGSizeMake(640, 640)]];
    }
    
    if ([_ibo_colorPickerView.someController  isKindOfClass:[CBFontToolViewController class]]){
        NSLog(@"Sender Tag %@", [_ibo_colorPickerView.someController  class]);

        [fontTextField becomeFirstResponder];
        [_prop_superlabel setTextColor:[UIColor colorWithPatternImage:[self imageResize:pickedImage andResizeTo:CGSizeMake(640, 640)]]];
    }
    
    _ibo_colorPickerView.view.hidden = YES;
    [_ibo_colorPickerView.view removeFromSuperview];
    _ibo_colorPickerView.delegate = nil;
    _ibo_colorPickerView = nil;
}

- (void)action_darkenView {
    ibo_DarkView = [[UIView alloc] initWithFrame:self.view.frame];
    ibo_DarkView.backgroundColor = [UIColor blackColor];
    ibo_DarkView.alpha = .50;
    [self.view addSubview:ibo_DarkView];
    
    
}

- (void)action_darkenViewRemove{
    
    [ibo_DarkView removeFromSuperview];
    ibo_DarkView = nil;
    
}

#pragma GESTURE RECOGNITION
BOOL currenltyScaling = NO;
static CGFloat previousScale = 1.0;

-(void) stickyPinch:(UIPinchGestureRecognizer *)recognizer {
    if (currentSticker) {
        
        if([recognizer state] == UIGestureRecognizerStateEnded) {
            currenltyScaling = NO;
            previousScale = 1.0;
            return;
        }
        currenltyScaling = YES;
        CGFloat newScale = 1.0 - (previousScale - [recognizer scale]);
        
        CGAffineTransform currentTransformation = currentSticker.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransformation, newScale, newScale);
        
        currentSticker.transform = newTransform;
        
        previousScale = [recognizer scale];
    }
    
}

BOOL currentlyRotating = NO;
static CGFloat previousRotation = 0.0;

- (void)stickyRotate:(UIRotationGestureRecognizer *)recognizer {
    //NSLog(@"Rotate");
    if (currentSticker){
        if([recognizer state] == UIGestureRecognizerStateEnded) {
            currentlyRotating = NO;
            previousRotation = 0.0;
            return;
        }
        
        currentlyRotating = YES;
        CGFloat newRotation = 0.0 - (previousRotation - [recognizer rotation]);
        
        CGAffineTransform currentTransformation = currentSticker.transform;
        CGAffineTransform newTransform = CGAffineTransformRotate(currentTransformation, newRotation);
        
        currentSticker.transform = newTransform;
        
        previousRotation = [recognizer rotation];
    }
}

static CGFloat beginX = 0;
static CGFloat beginY = 0;
BOOL toggleToolBar = NO;

-(void)stickyMove:(UIPanGestureRecognizer *) recognizer {
    if (currentSticker){
        StickyImageView *view = currentSticker;
        
        [[currentSticker superview] bringSubviewToFront:currentSticker];
        
        if([recognizer state] == UIGestureRecognizerStateEnded) {
            currentlyRotating = NO;
            return;
        }
        
        if (view == currentSticker) {
            CGPoint newCenter = [recognizer translationInView:self.view];
            
            if([recognizer state] == UIGestureRecognizerStateBegan) {
                beginX = view.center.x;
                beginY = view.center.y;
            }
            
            newCenter = CGPointMake(beginX + newCenter.x, beginY + newCenter.y);
            
            [view setCenter:newCenter];
        }
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

typedef enum {
  ClearAllStickersAlertViewTag,
  StartOverAlertViewTag
} AlertViewTag;

//SHAKE CLEAR
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"SHAKED");
    if (motion == UIEventSubtypeMotionShake) {
        UIAlertView *shakeToClear = [[UIAlertView alloc] initWithTitle:@"Clear All?" message:@"Would you like to clear all stickers from canvas?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Yes", nil];
        shakeToClear.tag = ClearAllStickersAlertViewTag;
        [shakeToClear show];
    }
}

- (void)iba_clearAll {
    for (UIView * sticker in self.view.subviews){
        if ([sticker isKindOfClass:[StickyImageView class]]){
            [sticker removeFromSuperview];
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) animateInView:(UIView *)sender {
    [UIView animateWithDuration:.2 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        sender.alpha = 1;
    } completion:^ (BOOL finished){

    }];
}

- (void) animateOutView:(UIView *)sender{
    
    [UIView animateWithDuration:.2 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        
        sender.alpha = 0;
        
    } completion:^ (BOOL finished){

    }];
}

#pragma CREATE NEW
- (IBAction)actionStartNew:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PHOTO_STARTOVER", nil) message:NSLocalizedString(@"PHOTO_NEW", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"PHOTO_NOTHANKS", nil) otherButtonTitles:NSLocalizedString(@"PHOTO_YES", nil), nil]; 
    alertView.tag = StartOverAlertViewTag;
    [alertView show];
}


#pragma ActionSave
- (IBAction)actionSave:(id)sender {
    [TAOverlay showOverlayWithLabel:nil Options:(TAOverlayOptionOverlayTypeActivityBlur | TAOverlayOptionOverlaySizeFullScreen)];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIGraphicsBeginImageContextWithOptions(_ibo_renderView.bounds.size, NO, 0);
        [_ibo_renderView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
      
        NSData *imgData = UIImagePNGRepresentation(image);
        
        [self show_shareview:image];
    });
}

- (void)show_shareview:(UIImage *)img {
    OMGPublishViewController *vc_shareview = (OMGPublishViewController *)[self viewControllerFromMainStoryboardWithName:@"seg_OMGPublishViewController"];
    vc_shareview.userExportedImage = img;
  [self.navigationController pushViewController:vc_shareview animated:YES];
}

- (void)shareViewDidComplete:(ShareViewController*)controller withMessage:(NSString *)message {
  //TODO
}

- (void)saveImage:(void (^)(UIImage *))callback{
    UIGraphicsBeginImageContextWithOptions(_ibo_renderView.bounds.size, NO, 0);
    [_ibo_renderView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"Save Image Size %@", NSStringFromCGSize(image.size));
    UIGraphicsEndImageContext();
    
    callback([self imageWithImage:image]);
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

    NSLog(@"New Image Size %@", NSStringFromCGSize(newImage.size));
    UIGraphicsEndImageContext();
        
    return newImage;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch ([alertView tag]) {
        case StartOverAlertViewTag:
            if (buttonIndex == 1) {
                [self showAdColony];
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        case ClearAllStickersAlertViewTag:
            if (_ibo_viewStickerStage.subviews){//Clean Up
                if (buttonIndex == 1){
                    for (UIView *view in _ibo_viewStickerStage.subviews) {
                        [view removeFromSuperview];
                    }
                    [self editModeStickerDone:nil];
                }
            }
            break;
        default:
            break;
    }
}

- (void)dealloc {
}

-(void)setView:(UIView*)view {
    if(view != nil) {
        [super setView:view];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize {
    CGFloat scale = [[UIScreen mainScreen]scale];

    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma AdColony
- (void)showAdColony{
    [AdColony playVideoAdForZone:@"vz6420aff8d9ed4b4eb1" withDelegate:self];
}

- (void) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID{
    NSLog(@"ADCOLONY ATTEMPTED %@", zoneID);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma StoryBoard
- (UIViewController *)viewControllerFromMainStoryboardWithName:(NSString *)name {
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    return [mainSB instantiateViewControllerWithIdentifier:name];
}

@end
