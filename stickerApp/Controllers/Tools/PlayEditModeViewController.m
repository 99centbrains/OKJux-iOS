//
//  PlayEditModeViewController.m
//  stickerApp
//
//  Created by Franky Aguilar on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayEditModeViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface PlayEditModeViewController (){
    

}

- (IBAction)iba_stickerDone:(id)sender;
- (IBAction)iba_stickerFlip:(id)sender;
- (IBAction)iba_stickerSendToBack:(id)sender;
- (IBAction)iba_stickerCopy:(id)sender;
- (IBAction)iba_stickerTrash:(id)sender;

- (IBAction)iba_stickerlayerUP:(id)sender;
- (IBAction)iba_stickerLayerDown:(id)sender;

@end

@implementation PlayEditModeViewController

@synthesize delegate;
@synthesize viewStickerEdit;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)borderChosen:(id)sender {
    [self.delegate editModeBorderChose:self withBorder:[sender currentImage]];
}

- (IBAction)iba_stickerDone:(id)sender  {
    [self.delegate editModeStickerDone:self];
}

- (IBAction)iba_stickerFlip:(id)sender {
    [self.delegate editModeStickerFlip:self];
}

- (IBAction)iba_stickerSendToBack:(id)sender {
    [self.delegate editModeStickerSendToBack:self];
}

- (IBAction)iba_stickerCopy:(id)sender {
    [self.delegate editModeStickerCopy:self];
}

- (IBAction)iba_stickerTrash:(id)sender {
    [self.delegate editModeStickerTrash:self];
}

- (IBAction)iba_stickerlayerUP:(id)sender {
    [self.delegate editModeLayerMoveUp:self];
}

- (IBAction)iba_stickerLayerDown:(id)sender {
    [self.delegate editModeLayerMoveDown:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
