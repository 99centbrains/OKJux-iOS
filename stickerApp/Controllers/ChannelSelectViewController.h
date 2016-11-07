//
//  ChannelSelectViewController.h
//  catwang
//
//  Created by Fonky on 2/18/15.
//
//

#import <UIKit/UIKit.h>

@class ChannelSelectViewController;

@protocol ChannelSelectViewControllerDelegate <NSObject>

-(void) channelSelectWithTitle:(ChannelSelectViewController *)controller withChannel:(NSString *)channel withIcon:(NSString *)iconEmoji;

@end


@interface ChannelSelectViewController : UIViewController


@property (nonatomic, unsafe_unretained) id <ChannelSelectViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *array_channels;
@property (nonatomic, strong) NSArray *array_icons;

@end
