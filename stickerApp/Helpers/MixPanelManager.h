//
//  MixPanelManager.h
//  okjux
//
//  Created by TopTier labs on 12/1/16.
//
//

#import <Foundation/Foundation.h>
#import "Mixpanel/Mixpanel.h"

@interface MixPanelManager : NSObject

+ (void)triggerEvent:(NSString*)event withData:(NSDictionary*)data;

@end
