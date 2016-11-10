//
//  CBFontToolViewController.m
//  catwang
//
//  Created by Fonky on 12/13/14.
//
//

#import "CBFontToolViewController.h"

@interface CBFontToolViewController() {
    NSMutableArray *fontsPackage;
    NSMutableArray *colorPallet;
  
    BOOL isStroked;
}

@end

@implementation CBFontToolViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    isStroked = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)iba_changeFont:(id)sender {
    [self.delegate cbFontToolChangeFont:self];
}

- (IBAction)iba_changeColor:(id)sender {
    [self.delegate cbFontToolChangeColor:self];
}

- (IBAction)iba_stroke:(id)sender {
    isStroked = !isStroked;
    [self.delegate cbFontToolToggleStroke:self withBool:isStroked];
}

@end
