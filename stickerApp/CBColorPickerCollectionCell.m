//
//  CBColorPickerCollectionCell.m
//  catwang
//
//  Created by 99centbrains on 12/3/13.
//
//

#import "CBColorPickerCollectionCell.h"

@implementation CBColorPickerCollectionCell
@synthesize ibo_btn;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"CBColorPickerCollectionCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        
         // this value vary as per your desire
        ibo_btn.layer.cornerRadius = ibo_btn.frame.size.width/2;
        ibo_btn.clipsToBounds = YES;
        ibo_btn.layer.borderWidth = 4;
        ibo_btn.layer.borderColor = [UIColor whiteColor].CGColor;
        ibo_btn.layer.shouldRasterize = YES;
        ibo_btn.layer.rasterizationScale = 2;
        
    }
    return self;
}

- (void)prepareForReuse {
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
