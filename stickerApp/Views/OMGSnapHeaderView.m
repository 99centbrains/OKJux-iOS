//
//  OMGSnapHeaderView.m
//  okjux
//
//  Created by German Pereyra on 3/2/17.
//
//

#import "OMGSnapHeaderView.h"

@implementation OMGSnapHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.mapView = [[MKMapView alloc] initWithFrame:self.frame];
    [self addSubview:self.mapView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.mapView.frame = self.bounds;
}

@end
