//
//  TextComposerViewController.h
//  catwang
//
//  Created by 99centbrains on 12/5/13.
//
//

#import <UIKit/UIKit.h>

@class TextComposerViewController;
@protocol TextComposerViewControllerDelegate <NSObject>


- (void) textComposerDidFinish:(TextComposerViewController *)controller withTextGraphic:(UIImage *)image;

@end

@interface TextComposerViewController : UIViewController

@property (nonatomic, unsafe_unretained) id <TextComposerViewControllerDelegate> delegate;

@end
