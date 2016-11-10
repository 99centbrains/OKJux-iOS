//
//  PlayPaintViewController.m
//  catwang
//
//  Created by 99centbrains on 12/2/13.
//
//

#import "PlayPaintViewController.h"

@interface PlayPaintViewController (){
    
    BOOL bool_paintMode;
    
    NSArray *brushSize;
    int brush;

}

@end

@implementation PlayPaintViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    bool_paintMode = YES;
    brushSize = @[@"20", @"50", @"100", @"200", @"10", @"5"];
}


- (IBAction)iba_done:(id)sender {
    [self.delegate playPaintVCDone:self];
    self.view.hidden = YES;
}

- (IBAction)iba_changecolor:(id)sender {
    [self.delegate playPaintVCChangeColor:self];
}

- (IBAction)iba_switchmode:(UIButton *)sender {
    if (bool_paintMode){
        [sender setImage:[UIImage imageNamed:@"ui_btn_tool_paint_eraser.png"] forState:UIControlStateNormal];
        bool_paintMode = NO;
    } else {
        [sender setImage:[UIImage imageNamed:@"ui_btn_tool_paint_painter.png"] forState:UIControlStateNormal];
        bool_paintMode = YES;
    }
    
    [self.delegate playPaintVCChangeMode:self withMode:bool_paintMode];
}

- (IBAction)iba_changesize:(id)sender {
    if (brush < [brushSize count]-1){
        brush++;
    } else {
        brush = 0;
    }
    
    NSInteger sizer = [[brushSize objectAtIndex:brush] integerValue];
    [self.delegate playPaintVCChangeSize:self withSize:sizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
