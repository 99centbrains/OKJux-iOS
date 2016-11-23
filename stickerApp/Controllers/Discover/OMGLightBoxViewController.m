//
//  OMGLightBoxViewController.m
//  catwang
//
//  Created by Fonky on 2/7/15.
//
//

#import "OMGLightBoxViewController.h"
#import "UIImageView+AFNetworking.h"

@interface OMGLightBoxViewController () {
    BOOL fadeout;
}

@property (nonatomic, strong) NSURL *imageURL;

@property (nonatomic, weak) IBOutlet UIImageView *ibo_userSnapImage;
@property (nonatomic, weak) IBOutlet UILabel *ibo_photoKarma;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *ibo_spinnerView;


@property (nonatomic, weak) IBOutlet UIButton *ibo_btn_likeUP;
@property (nonatomic, weak) IBOutlet UIButton *ibo_btn_likeDown;

@property (nonatomic, weak) IBOutlet UIButton *ibo_btn_delete;

@property (nonatomic) NSInteger int_userLikeStatus;


//FADEOUTS
@property (nonatomic, weak) IBOutlet UIImageView *ibo_fade_heart;
@property (nonatomic, weak) IBOutlet UIButton *ibo_fade_share;

@property (nonatomic) NSInteger intCurrentSnap;


@end

@implementation OMGLightBoxViewController

enum {
    OMGVoteNone = 0,
    OMGVoteYES = 1,
    OMGVoteNO = 2
};

typedef NSInteger OMGVoteSpecifier;

@synthesize delegate;

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    _ibo_spinnerView.hidden = NO;

    fadeout = NO;
    [super viewDidLoad];
    
    _ibo_btn_delete.hidden = YES;
    if (kAdminDebug) {
        _ibo_btn_delete.hidden = NO;
    }
}

//TODO this will be removed
- (void)setSnapObject:(PFObject *)snapObject {
    _snapObject = snapObject;
    [_snapObject fetchInBackground];
    _ibo_userSnapImage.image = _preloadImage;
    PFFile *imageFile  = _snapObject[@"image"];
    [self setImageURL:[NSURL URLWithString:imageFile.url]] ;
    
    NSNumber *netLikes= _snapObject[@"netlikes"];
    _ibo_photoKarma.text = [NSString stringWithFormat:@"%@", netLikes];
    
    NSInteger userStatus = [[DataHolder DataHolderSharedInstance]
                            checkUserLikeStatus:_snapObject];
    
    [self setInt_userLikeStatus:userStatus];
}

//TODO with snap model not parse
- (void)setSnap:(Snap *)snap {
    _snap = snap;
    _ibo_userSnapImage.image = _preloadImage;
    NSString *imageUrl  = _snap.imageUrl;
    [self setImageURL:[NSURL URLWithString:imageUrl]];

    _ibo_photoKarma.text = [NSString stringWithFormat:@"%ld", (long)_snap.netlikes];

    [self setUserLikeStatus:snap.isLiked noAction:snap.noAction];
}

- (void)setImageURL:(NSURL *)imageURL {
    NSLog(@"SET IAMGE URL %@", imageURL);
    [_ibo_userSnapImage setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
        _ibo_userSnapImage.image = image;
        _ibo_spinnerView.hidden = YES;
        [self setupFadeout];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        NSLog(@"Failed Image");
    }];
}

//TODO this will be removed
- (void)setInt_userLikeStatus:(NSInteger)int_userLikeStatus {
    _ibo_btn_likeDown.userInteractionEnabled = NO;
    _ibo_btn_likeDown.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .92134 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _ibo_btn_likeDown.userInteractionEnabled = YES;
        _ibo_btn_likeDown.userInteractionEnabled = YES;
    });
    
    switch (int_userLikeStatus) {
        case 0:
            _int_userLikeStatus = OMGVoteNone;
            [_ibo_btn_likeDown setSelected:NO];
            [_ibo_btn_likeUP setSelected:NO];
            break;
        case OMGVoteYES:
            _int_userLikeStatus = OMGVoteYES;
            [_ibo_btn_likeDown setSelected:NO];
            [_ibo_btn_likeUP setSelected:YES];
            break;
        case OMGVoteNO:
            _int_userLikeStatus = OMGVoteNO;
            [_ibo_btn_likeDown setSelected:YES];
            [_ibo_btn_likeUP setSelected:NO];
            break;
        default:
            break;
    }

    NSNumber *netLikes= _snapObject[@"netlikes"];
    _ibo_photoKarma.text = [NSString stringWithFormat:@"%@", netLikes];
    
    NSLog(@"USER INT STATUS %ld", (long)int_userLikeStatus);
}

//TODO old setInt_userLikeStatus
- (void)setUserLikeStatus:(BOOL)isLiked noAction:(BOOL)noAction {
    _ibo_btn_likeDown.userInteractionEnabled = NO;
    _ibo_btn_likeUP.userInteractionEnabled = NO;

    _int_userLikeStatus = noAction ? OMGVoteNone : (isLiked ? OMGVoteYES : OMGVoteNO);
    [_ibo_btn_likeDown setSelected: isLiked || noAction ? NO : YES];
    [_ibo_btn_likeUP setSelected: !isLiked || noAction ? NO : YES];

    _ibo_photoKarma.text = [NSString stringWithFormat:@"%ld", (long)_snap.netlikes];

    _ibo_btn_likeDown.userInteractionEnabled = YES;
    _ibo_btn_likeUP.userInteractionEnabled = YES;
}

- (void) setupFadeout {
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _ibo_fade_voter.alpha = 0;
        _ibo_fade_heart.alpha = 0;
        _ibo_fade_share.alpha = 0;
        _ibo_photoKarma.alpha = 0;
    } completion:nil];
    
    fadeout = YES;
}



#pragma VOTING MECHANICS
- (IBAction) omgSnapVOTEUP:(NSInteger) snapIndex {
    int pointsGranted = kParseLikingPoints;
    int imgVote = kParseLikedPoints;
    
    NSMutableArray *likeArray= [[NSMutableArray alloc] initWithArray:_snapObject[@"likes"]];
    NSMutableArray *disArray= [[NSMutableArray alloc] initWithArray:_snapObject[@"dislikes"]];
    
    //CHECK IF USER HAS NOT LIKED PIC
    if ([self checkUserInArray:likeArray]) {
        [likeArray addObject:[DataHolder DataHolderSharedInstance].userObject.objectId];
        _snapObject[@"dislikes"] = [self removeUserInArray:disArray];
    } else {
        pointsGranted = 0;
        imgVote = 0;
    }
    
    NSInteger likesnet = [_snapObject[@"netlikes"] integerValue];
    
    _snapObject[@"netlikes"] = [NSNumber numberWithInteger:likesnet + imgVote];
    _snapObject[@"likes"] = likeArray;
    
    [_snapObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //GRAND POINTS for VOTE
        NSInteger score = [[DataHolder DataHolderSharedInstance].userObject[@"points"] integerValue] + pointsGranted;
        [DataHolder DataHolderSharedInstance].userObject[@"points"] = [NSNumber numberWithInteger:score];
        [[DataHolder DataHolderSharedInstance].userObject saveInBackground];
    }];

    [self setInt_userLikeStatus:OMGVoteYES];
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Action":@"VoteUp"} forEvent:@"Explore"];

}

- (IBAction) omgSnapVOTEDOWN:(NSInteger) snapIndex{
    int pointsGranted = kParseLikingPoints;
    int imgVote = kParseLikedPoints;

    NSMutableArray *disLikeArray= [[NSMutableArray alloc] initWithArray:_snapObject[@"dislikes"]];
    NSMutableArray *likeArray= [[NSMutableArray alloc] initWithArray:_snapObject[@"likes"]];
    
    if ([self checkUserInArray:disLikeArray]) {
        [disLikeArray addObject:[DataHolder DataHolderSharedInstance].userObject.objectId];
        _snapObject[@"likes"] = [self removeUserInArray:likeArray];
    } else {
        pointsGranted = 0;
        imgVote = 0;
    }
    
    NSInteger likesnet= [_snapObject[@"netlikes"] integerValue];
    
    _snapObject[@"netlikes"] = [NSNumber numberWithInteger:likesnet - imgVote];
    
    if (kAdminDebug && likesnet <= 0){
        _snapObject[@"netlikes"] = [NSNumber numberWithInteger:0];
    }
    
    _snapObject[@"dislikes"] = disLikeArray;
    
    [_snapObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //GRAND POINTS for VOTE
        NSInteger score = [[DataHolder DataHolderSharedInstance].userObject[@"points"] integerValue] + pointsGranted;
        [DataHolder DataHolderSharedInstance].userObject[@"points"] = [NSNumber numberWithInteger:score];
        [[DataHolder DataHolderSharedInstance].userObject saveInBackground];
    }];
    
    [self setInt_userLikeStatus:OMGVoteNO];
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Action":@"VoteDown"} forEvent:@"Explore"];
}

- (BOOL) checkUserInArray:(NSMutableArray *)array {
    if ([array count] > 0) {
        for (NSString *userLike in array) {
            NSLog(@"USER LIKE %@", userLike);
            if ([userLike isEqualToString:[DataHolder DataHolderSharedInstance].userObject.objectId]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSMutableArray *) removeUserInArray:(NSMutableArray *)array {
    if ([array count] > 0) {
        for (NSString *userLike in array) {
            if ([userLike isEqualToString:[DataHolder DataHolderSharedInstance].userObject.objectId]){
                [array removeObject:[DataHolder DataHolderSharedInstance].userObject.objectId];
                return array;
            }
        }
    }

    return array;
}

- (IBAction)iba_flagImage:(id)sender {
    [self.delegate lightBoxItemFlag:_snapObject];
    NSLog(@"Flag Item");
    
    [[CBJSONDictionary shared] parse_trackAnalytic:@{@"Action":@"Flag"} forEvent:@"Explore"];
}

- (IBAction)iba_deleteItem:(id)sender {
    [_snapObject fetchInBackground];
    [_snapObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {}];
    
    [self.delegate omgSnapDismissLightBox:_snapObject];
}

- (IBAction)iba_shareItem:(id)sender {
    [self.delegate lightBoxShareImage:_ibo_userSnapImage.image];
    NSLog(@"Share Item");
}


#pragma DIMISS
- (IBAction)iba_dismiss:(id)sender {
    if (fadeout) {
        _ibo_fade_voter.alpha = 1;
        _ibo_fade_heart.alpha = 1;
        _ibo_fade_share.alpha = 1;
        _ibo_photoKarma.alpha = 1;
        fadeout = NO;
        
        return;
    }
    
    _imageURL = nil;
    [self.delegate omgSnapDismissLightBox:_snapObject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
