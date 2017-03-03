//
//  OMGSnapLocationPicker.m
//  okjux
//
//  Created by German Pereyra on 3/6/17.
//
//

#import "OMGSnapLocationPicker.h"
#import "DataManager.h"


@interface LocationCollectionViewCell : UICollectionViewCell
+(NSString*)reuseIdentifier;
@property (weak, nonatomic) IBOutlet UILabel *icon;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end

@implementation LocationCollectionViewCell

+(NSString*)reuseIdentifier {
    return @"LocationCollectionViewCell";
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

@end

@interface OMGSnapLocationPicker () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong) NSMutableArray *arrayLocations;
@property (strong) UICollectionView *locationsCollection;
@property (strong) UIView *delimiter;
@end

@implementation OMGSnapLocationPicker

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpLocations];
        [self setUpUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.locationsCollection.frame = self.bounds;
    self.delimiter.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
}

- (void)setUpLocations {
    NSArray * flags = @[@"🏠",
                        @"🇺🇸",
                        @"🗽",
                        @"🇨🇳",
                        @"🐉",
                        @"🇰🇷",
                        @"💂",
                        @"🇷🇺",
                        @"🇸🇪",
                        @"⭐️"
                        ];
    NSArray * places = @[@"Your Location",
                         @"Los Angeles",
                         @"New York City",
                         @"Shanghai",
                         @"Beijing",
                         @"South Korea",
                         @"London",
                         @"Moscow",
                         @"Stockholm",
                         @"Istanbul"
                         ];

    NSArray * sizes = @[@64,
                        @74,
                        @64,
                        @74,
                        @64,
                        @74,
                        @74,
                        @74,
                        @74,
                        @64
                        ];

    NSArray * coord = @[[NSValue valueWithCGPoint:CGPointMake([[DataManager currentLatitud] floatValue], [[DataManager currentLongitud] floatValue])],
                        [NSValue valueWithCGPoint:CGPointMake(34.056519, -118.22855)],
                        [NSValue valueWithCGPoint:CGPointMake(40.745091160629116, -73.98071757051396)],
                        [NSValue valueWithCGPoint:CGPointMake(31.238705, 121.48997)],
                        [NSValue valueWithCGPoint:CGPointMake(39.960209, 116.38259)],
                        [NSValue valueWithCGPoint:CGPointMake(37.514427, 126.84566)],
                        [NSValue valueWithCGPoint:CGPointMake(51.507954, -0.17872441)],
                        [NSValue valueWithCGPoint:CGPointMake(55.754387, 37.625851)],
                        [NSValue valueWithCGPoint:CGPointMake(59.329601, 18.063143)],
                        [NSValue valueWithCGPoint:CGPointMake(41.014069, 29.007841)]
                        ];

    self.arrayLocations = [[NSMutableArray alloc] init];
    for (int i = 0; i < [places count]; i++) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObject:[flags objectAtIndex:i]];
        [tempArray addObject:[places objectAtIndex:i]];
        [tempArray addObject:[coord objectAtIndex:i]];
        [tempArray addObject:[sizes objectAtIndex:i]];
        [self.arrayLocations addObject:tempArray];
        tempArray = nil;
    }
}

- (void)setUpUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.itemSize = CGSizeMake(100, 100);
    [layout setScrollDirection: UICollectionViewScrollDirectionHorizontal];
    self.locationsCollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:self.locationsCollection];
    UINib *nib = [UINib nibWithNibName:@"LocationCollectionViewCell" bundle: nil];

    [self.locationsCollection registerNib:nib forCellWithReuseIdentifier:[LocationCollectionViewCell reuseIdentifier]];
    self.locationsCollection.delegate = self;
    self.locationsCollection.dataSource = self;
    self.backgroundColor = [UIColor whiteColor];
    self.locationsCollection.backgroundColor = [UIColor whiteColor];

    self.delimiter = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height -1 , self.frame.size.width, 1)];
    self.delimiter.backgroundColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.62 alpha:1.0];
    [self addSubview:self.delimiter];
}

#pragma mark - UICollectionView delegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayLocations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LocationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LocationCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    if (!cell) {
        cell = [[LocationCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    cell.icon.text = [[self.arrayLocations objectAtIndex:indexPath.item] objectAtIndex:0];
    NSNumber *size = [[self.arrayLocations objectAtIndex:indexPath.item] objectAtIndex:3];
    cell.icon.font = [UIFont systemFontOfSize: [size floatValue]];
    cell.name.text = [[self.arrayLocations objectAtIndex:indexPath.item] objectAtIndex:1];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CGPoint coordinates = [[[self.arrayLocations objectAtIndex:indexPath.item] objectAtIndex:2] CGPointValue];
    [self.delegate OMGSnapLocationPicker:self didSelectLocationCoordinates:coordinates];
}
@end
