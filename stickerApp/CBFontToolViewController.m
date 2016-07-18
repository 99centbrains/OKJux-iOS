//
//  CBFontToolViewController.m
//  catwang
//
//  Created by Fonky on 12/13/14.
//
//

#import "CBFontToolViewController.h"

@interface CBFontToolViewController (){

    NSMutableArray *fontsPackage;
    NSMutableArray *colorPallet;
    
    BOOL isStroked;
}



@end

@implementation CBFontToolViewController
@synthesize delegate;

- (void)viewDidLoad {
    
    isStroked = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)iba_changeFont:(id)sender {
    
    [self.delegate cbFontToolChangeFont:self];

}

- (IBAction)iba_changeColor:(id)sender {
    
    [self.delegate cbFontToolChangeColor:self];
    
}

- (IBAction)iba_stroke:(id)sender {
    
    if (isStroked){
        isStroked = NO;
    } else {
        isStroked = YES;
    }
    
    [self.delegate cbFontToolToggleStroke:self withBool:isStroked];
    
}

@end
