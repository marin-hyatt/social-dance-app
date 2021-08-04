//
//  HomeTableViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "HomeTableViewCell.h"
#import "Parse/Parse.h"
#import "PlayerView.h"
#import "UIImageView+AFNetworking.h"
#import "CacheManager.h"
#import "Comment.h"
#import "UIManager.h"
#import "DateTools.h"
#import "PostUtility.h"

@implementation HomeTableViewCell

static void * cellContext = &cellContext;
BOOL didSetupConstraints = NO;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    [self.videoView addGestureRecognizer:tapGestureRecognizer];
    [self.videoView setUserInteractionEnabled:YES];
    
    self.videoView.delegate = self;
    
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    UITapGestureRecognizer *usernameTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    [self.profilePictureView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePictureView setUserInteractionEnabled:YES];
    [self.usernameLabel addGestureRecognizer:usernameTapGestureRecognizer];
    [self.usernameLabel setUserInteractionEnabled:YES];
}

- (void)updateConstraints {
    [super updateConstraints];
    CGFloat videoHeight = [self.post[@"videoHeight"] doubleValue];
    CGFloat videoWidth = [self.post[@"videoWidth"] doubleValue];
    
    [self.videoView updateAutolayoutWithHeight:videoHeight withWidth:videoWidth];

}

- (void)updateAppearance {
    [PostUtility updateBookmarkButton:self.bookmarkButton usingPost:self.post];
    [PostUtility updateTimestampForLabel:self.timestampLabel usingPost:self.post];
    [PostUtility updateCommentButton:self.commentButton withPost:self.post];
    [PostUtility updateCommentLabel:self.commentCountLabel withPost:self.post];
    [PostUtility updateLikeButton:self.likeButton withPost:self.post];
    [PostUtility updateLikeLabel:self.likeCountLabel withPost:self.post];
    [PostUtility updateUsernameLabel:self.usernameLabel andProfilePicture:self.profilePictureView WithUser:self.post.author];
}

- (void)updateVideo {
    CGFloat videoHeight = [self.post[@"videoHeight"] doubleValue];
    CGFloat videoWidth = [self.post[@"videoWidth"] doubleValue];
    
    [self fadeIn];
    
    if (self.videoView.constraint == nil) {
        [self.videoView updateAutolayoutWithHeight:videoHeight withWidth:videoWidth];
    }
}

- (void)displayVideoThumbnail {
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:self.videoView.frame];

    NSURL *thumbnailURL = [NSURL URLWithString:self.post.thumbnailImage.url];
    [thumbnailView setImageWithURL:thumbnailURL];
    [self.videoView addSubview:thumbnailView];
    [thumbnailView setBounds:self.videoView.bounds];
    [thumbnailView setClipsToBounds:YES];
    
    thumbnailView.center = CGPointMake(self.videoView.bounds.size.width  / 2,
                                     self.videoView.bounds.size.height / 2);
    [self.videoView layoutIfNeeded];
}

- (void)removeVideoThumbnail {
    for (UIImageView *subview in self.videoView.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)fadeIn {
    [self.videoView setAlpha:0];
    [PlayerView animateWithDuration:1 animations:^{
            [self.videoView setAlpha:1];
    }];
}

- (void)startPlayback {
    if (self.player.rate != 0) {
        [self.player pause];
    } else {
        [self removeVideoThumbnail];
        [self.player play];
    }
}

- (void)onProfileTapped:(UITapGestureRecognizer *)sender {
    [self.delegate feedCell:self didTap:self.post[@"author"]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.player = nil;
}

- (IBAction)onLikeButtonTapped:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    
    if (!self.likeButton.selected) {
        [Post likePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PostUtility updateLikeLabel:self.likeCountLabel withPost:self.post];
                [PostUtility updateLikeButton:self.likeButton withPost:self.post];
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    } else {
        [Post unlikePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PostUtility updateLikeLabel:self.likeCountLabel withPost:self.post];
                [PostUtility updateLikeButton:self.likeButton withPost:self.post];
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
}

- (IBAction)onCommentButtonTapped:(UIButton *)sender {
    [self.delegate feedCell:self didTapWithPost:self.post];
}

- (IBAction)onBookmarkButtonTapped:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    
    if (!self.bookmarkButton.selected) {
        [Post bookmarkPost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PostUtility updateBookmarkButton:self.bookmarkButton usingPost:self.post];
            }
        }];
    } else {
        [Post unbookmarkPost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PostUtility updateBookmarkButton:self.bookmarkButton usingPost:self.post];
            }
        }];
    }
}

@end
