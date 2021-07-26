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


@implementation HomeTableViewCell

static void * cellContext = &cellContext;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    [self.videoView addGestureRecognizer:tapGestureRecognizer];
    [self.videoView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    UITapGestureRecognizer *usernameTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    [self.profilePictureView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePictureView setUserInteractionEnabled:YES];
    [self.usernameLabel addGestureRecognizer:usernameTapGestureRecognizer];
    [self.usernameLabel setUserInteractionEnabled:YES];
}

- (void)updateAppearance {
    PFUser *user = self.post[@"author"];
    
    [self updateUsernameAndProfilePictureWithUser:user];
    
    [self updateBookmark];
    
    [self updateComment];
    
    [self updateLikeView];
    
    [self updateVideo];
    
}

- (void)updateBookmark {
    self.bookmarkButton.selected = NO;
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *likeRelation = [self.post relationForKey:@"bookmarkRelation"];
    PFQuery *query = [likeRelation query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (number > 0) {
            self.bookmarkButton.selected = YES;
        }
    }];
}

- (void)updateComment {
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@", self.post.commentCount];
    
    self.commentButton.selected = NO;
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [Comment query];
    [query whereKey:@"author" equalTo:currentUser];
    [query whereKey:@"post" equalTo:self.post];
    
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (number > 0) {
            self.commentButton.selected = YES;
        }
    }];
}

- (void)updateUsernameAndProfilePictureWithUser:(PFUser *)user {
    self.usernameLabel.text = user[@"username"];
    PFFileObject *postImage = user[@"profilePicture"];
    
    [UIManager updateProfilePicture:self.profilePictureView withPFFileObject:postImage];
}

- (void)updateLikeView {
    self.likeButton.selected = NO;
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *likeRelation = [self.post relationForKey:@"likeRelation"];
    PFQuery *query = [likeRelation query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (number > 0) {
            self.likeButton.selected = YES;
        }
    }];
    
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", self.post.likeCount];
}

- (void)updateVideo {
    // Update autolayout corresponding to video aspect ratio
    CGFloat videoHeight = [self.post[@"videoHeight"] doubleValue];
    CGFloat videoWidth = [self.post[@"videoWidth"] doubleValue];
    
    [self.videoView updateAutolayoutWithHeight:videoHeight withWidth:videoWidth];
}

- (void)startPlayback {
    if (self.player.rate != 0) {
        [self.player pause];
    } else {
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
                [self updateLikeView];
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    } else {
        [Post unlikePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self updateLikeView];
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
                [self updateBookmark];
            }
        }];
    } else {
        [Post unbookmarkPost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self updateBookmark];
            }
        }];
    }
}

@end
