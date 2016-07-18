//


#import <UIKit/UIKit.h>

@class UIActivityTumblr;



@interface UIActivityTumblr : UIActivity


@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, strong) NSString *shareString;
@property (nonatomic, strong) NSArray *backgroundColors;
@property (readwrite) BOOL includeURL;

@property (nonatomic, strong) NSURL *fileURL;



@end
