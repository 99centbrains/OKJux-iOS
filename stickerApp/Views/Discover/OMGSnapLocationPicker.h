//
//  OMGSnapLocationPicker.h
//  okjux
//
//  Created by German Pereyra on 3/6/17.
//
//

#import <UIKit/UIKit.h>

@class OMGSnapLocationPicker;

@protocol OMGSnapLocationPickerDelegate <NSObject>
- (void)OMGSnapLocationPicker:(OMGSnapLocationPicker*)snapLocationPicker didSelectLocationCoordinates:(CGPoint)coordinates;
@end

@interface OMGSnapLocationPicker : UIView
@property (weak) id<OMGSnapLocationPickerDelegate> delegate;
@end
