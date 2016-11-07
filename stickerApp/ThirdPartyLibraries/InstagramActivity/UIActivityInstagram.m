//
//  DMActivityInstagram.m
//  DMActivityInstagram
//
//  Created by Cory Alder on 2012-09-21.
//  Copyright (c) 2012 Cory Alder. All rights reserved.
//

#import "UIActivityInstagram.h"

@implementation UIActivityInstagram
@synthesize fileURL;


- (NSString *)activityType {
    return @"UIActivityTypePostToInstagram";
}

- (NSString *)activityTitle {
    return @"Instagram";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"instagram.png"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) return NO; // no instagram.
    
    for (UIActivityItemProvider *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            if ([self imageIsLargeEnough:(UIImage *)item]) return YES; // has image, of sufficient size.
            else NSLog(@"DMActivityInstagam: image too small %@",item);
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) self.shareImage = item;
        else if ([item isKindOfClass:[NSString class]]) {
            self.shareString = [(self.shareString ? self.shareString : @"") stringByAppendingFormat:@"%@%@",(self.shareString ? @" " : @""),item]; // concat, with space if already exists.
        }
        else if ([item isKindOfClass:[NSURL class]]) {
          if (self.includeURL) {
            self.shareString = [(self.shareString ? self.shareString : @"") stringByAppendingFormat:@"%@%@",(self.shareString ? @" " : @""),[(NSURL *)item absoluteString]]; // concat, with space if already exists.
          }
        }
        else NSLog(@"Unknown item type %@", item);
    }
    
}

- (void)performActivity {
    //no resize, just fire away.
    CGFloat cropVal = (self.shareImage.size.height > self.shareImage.size.width ? self.shareImage.size.width : self.shareImage.size.height);
    
    cropVal *= [self.shareImage scale];
    
    CGRect cropRect = (CGRect){.size.height = cropVal, .size.width = cropVal};
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.shareImage CGImage], cropRect);
    
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 1.0);
    CGImageRelease(imageRef);
    
    NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
    if (![imageData writeToFile:writePath atomically:YES]) {
        // failure
        NSLog(@"image save failed to path %@", writePath);
        [self activityDidFinish:NO];
        return;
    } else {
        // success.
    }
    
    // send it to instagram.
    self.fileURL = [NSURL fileURLWithPath:writePath];

    [self activityDidFinish:YES];
   
}



-(BOOL)imageIsLargeEnough:(UIImage *)image {
    CGSize imageSize = [image size];
    return ((imageSize.height * image.scale) >= 612 && (imageSize.width * image.scale) >= 612);
}

-(BOOL)imageIsSquare:(UIImage *)image {
    CGSize imageSize = image.size;
    return (imageSize.height == imageSize.width);
}

@end
