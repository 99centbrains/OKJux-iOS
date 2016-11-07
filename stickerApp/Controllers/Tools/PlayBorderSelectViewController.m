//
//  PlayBorderSelectViewController.m
//  catwang
//
//  Created by 99centbrains on 12/2/13.
//
//

#import "PlayBorderSelectViewController.h"

@interface PlayBorderSelectViewController (){

    IBOutlet UIScrollView *ibo_scrollview_borders;
    NSMutableArray *borderColorPallette;
}


- (IBAction)iba_changeSize:(UISlider *)sender;

@end

@implementation PlayBorderSelectViewController
@synthesize delegate;
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
    
    ibo_scrollview_borders.scrollEnabled = YES;
    
    
    borderColorPallette = [[NSMutableArray alloc] initWithObjects:nil];

     for (int i = 1; i <= 28; i++){
         [borderColorPallette addObject:[NSString stringWithFormat:@"i_swatch_%d.png", i]];
     }
    
    for (int i = 1; i <= 12; i++){
        [borderColorPallette addObject:[NSString stringWithFormat:@"i_gradient%d.png", i]];
    }
    
    for (int i = 1; i <= 11; i++){
        [borderColorPallette addObject:[NSString stringWithFormat:@"i_pattern_%d.png", i]];
    }
    
    int i = 0;
    
    for (NSString* colorName in borderColorPallette){
        
        UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(
                                                                          10 + (ibo_scrollview_borders.frame.size.height + 10) * i,
                                                                          0,
                                                                          ibo_scrollview_borders.frame.size.height,
                                                                          ibo_scrollview_borders.frame.size.height)];
        
        
        //UIColor *bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:colorName]];
        //tempButton.backgroundColor = bgColor;
        
        tempButton.layer.cornerRadius = 30; // this value vary as per your desire
        tempButton.clipsToBounds = YES;
        tempButton.layer.borderWidth = 2;
        tempButton.layer.borderColor = [UIColor blackColor].CGColor;
        
        [tempButton setBackgroundImage:[UIImage imageNamed:colorName] forState:UIControlStateNormal];
        tempButton.tag = i;
        [tempButton addTarget:self
                       action:@selector(borderChosen:)
             forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
        
        
        
        [ibo_scrollview_borders addSubview:tempButton];
        
        tempButton = nil;
        
        i++;
    }
    
    
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in ibo_scrollview_borders.subviews) {
        
        scrollViewHeight += view.frame.size.height;
    }
    scrollViewHeight += [borderColorPallette count] * 10;
    
    [ibo_scrollview_borders setContentSize:(CGSizeMake(scrollViewHeight+20, ibo_scrollview_borders.frame.size.height))];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)borderChosen:(UIButton *)sender{
    
    
    [self.delegate playBorderSelectVCChoseBorder:self withImage:sender.currentBackgroundImage];
    
}

- (IBAction)iba_done:(id)sender{
    [borderColorPallette removeAllObjects];
    borderColorPallette = nil;
    
    [ibo_scrollview_borders removeFromSuperview];
    
    [self.delegate playBorderSelectVCDone:self];
    //self.view.hidden = YES;

}

- (IBAction)iba_cancel:(id)sender{
    [borderColorPallette removeAllObjects];
    borderColorPallette = nil;
    
    [ibo_scrollview_borders removeFromSuperview];
    [self.delegate playBorderSelectVCChoseBorder:self withImage:nil];
    [self.delegate playBorderSelectVCDone:self];
    //self.view.hidden = YES;
    
}

- (IBAction)iba_changeSize:(UISlider *)sender{
    
    int discreteValue = [sender value];
    [self.delegate playBorderSelectVCChoseSize:self withSize:discreteValue];

}

-(void)viewDidDisappear:(BOOL)animated{
    
    NSLog(@"No More View");
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
