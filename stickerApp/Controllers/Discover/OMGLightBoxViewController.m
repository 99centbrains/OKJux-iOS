//
//  OMGLightBoxViewController.m
//  catwang
//
//  Created by Fonky on 2/7/15.
//
//

#import "OMGLightBoxViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SnapServiceManager.h"

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
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui_cropview_checkers.png"]];
    _ibo_spinnerView.hidden = NO;

    fadeout = NO;
    [super viewDidLoad];
    
    _ibo_btn_delete.hidden = YES;
    if (kAdminDebug) {
        _ibo_btn_delete.hidden = NO;
    }
}

- (void)setSnap:(Snap *)snap {
    _snap = snap;
    _ibo_userSnapImage.image = _preloadImage;
    NSString *imageUrl  = _snap.imageUrl;
    [self setImageURL:[NSURL URLWithString:imageUrl]];

    _ibo_photoKarma.text = [NSString stringWithFormat:@"%ld", (long)_snap.netlikes];

    [self setUserLikeStatus];
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

- (void)setUserLikeStatus {
    _ibo_btn_likeDown.userInteractionEnabled = NO;
    _ibo_btn_likeUP.userInteractionEnabled = NO;

    [self updateLikeStatus];

    _ibo_btn_likeDown.userInteractionEnabled = _snap.noAction || _snap.isLiked;
    _ibo_btn_likeUP.userInteractionEnabled = _snap.noAction || !_snap.isLiked;
}

- (void)updateLikeStatus {
    _int_userLikeStatus = _snap.noAction ? OMGVoteNone : (_snap.isLiked ? OMGVoteYES : OMGVoteNO);
    [_ibo_btn_likeDown setSelected: !_snap.noAction && !_snap.isLiked];
    [_ibo_btn_likeUP setSelected: !_snap.noAction && _snap.isLiked];

    _ibo_photoKarma.text = [NSString stringWithFormat:@"%ld", (long)_snap.netlikes];
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
  _ibo_btn_likeUP.userInteractionEnabled = NO;
  _ibo_btn_likeDown.userInteractionEnabled = NO;
  Snap* originalSnap = _snap;
  _snap.netlikes += _snap.noAction ? 1 : 2;
  _snap.noAction = NO;
  _snap.isLiked = YES;
  [self updateLikeStatus];
  [SnapServiceManager rankSnap:_snap.ID withLike:YES OnSuccess:^(NSDictionary *responseObject) {
    if (originalSnap.noAction) {
        NSInteger karma = [DataManager  karma] + 1;
        [DataManager storeKarma: [NSString stringWithFormat:@"%ld", (long)karma]];
    }
    _ibo_btn_likeDown.userInteractionEnabled = YES;
  } OnFailure:^(NSError *error) {
    _snap = originalSnap;
    [self setUserLikeStatus];
  }];
}

- (IBAction) omgSnapVOTEDOWN:(NSInteger) snapIndex{
  _ibo_btn_likeUP.userInteractionEnabled = NO;
  _ibo_btn_likeDown.userInteractionEnabled = NO;
  Snap* originalSnap = _snap;
  _snap.netlikes -= _snap.noAction ? 1 : 2;
  _snap.noAction = NO;
  _snap.isLiked = NO;
  [self updateLikeStatus];
  [SnapServiceManager rankSnap:_snap.ID withLike:NO OnSuccess:^(NSDictionary *responseObject) {
    if (originalSnap.noAction) {
        NSInteger karma = [DataManager  karma] + 1;
        [DataManager storeKarma: [NSString stringWithFormat:@"%ld", (long)karma]];
    }
    _ibo_btn_likeUP.userInteractionEnabled = YES;
  } OnFailure:^(NSError *error) {
    _snap = originalSnap;
    [self setUserLikeStatus];
  }];
}

- (IBAction)iba_flagImage:(id)sender {
    [self.delegate lightBoxItemFlag:_snap];
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
    [self.delegate omgSnapDismissLightBox:_snap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
