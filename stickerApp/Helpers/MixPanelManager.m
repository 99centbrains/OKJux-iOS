//
//  MixPanelManager.m
//  okjux
//
//  Created by TopTier labs on 12/1/16.
//
//

#import "MixPanelManager.h"

@implementation MixPanelManager

+ (void)triggerEvent:(NSString*)event withData:(NSDictionary*)data {
  Mixpanel *mixpanel = [Mixpanel sharedInstance];
  [mixpanel track:event properties:data];
}

@end
