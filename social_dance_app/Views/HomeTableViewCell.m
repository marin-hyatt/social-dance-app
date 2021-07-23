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
    
    self.usernameLabel.text = user[@"username"];
    
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.layer.masksToBounds = true;
    PFFileObject * postImage = user[@"profilePicture"];
    NSURL * imageURL = [NSURL URLWithString:postImage.url];
    [self.profilePictureView setImageWithURL:imageURL];
    
    PFFileObject *videoFile = self.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    // Update autolayout corresponding to video aspect ratio
    CGFloat videoHeight = [self.post[@"videoHeight"] doubleValue];
    CGFloat videoWidth = [self.post[@"videoWidth"] doubleValue];
    
    [self.videoView updateAutolayoutWithHeight:videoHeight withWidth:videoWidth];
    
    
    // Figure out if user liked video or not
    
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
    
    
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * _Nonnull playerItem) {
        self.playerItem = playerItem;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
        
    } withMainBlock:^(AVPlayerItem * _Nonnull playerItem) {
        if (self.player == nil) {
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [self.videoView setPlayer:self.player];
        }
    }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

-(void)startPlayback {
    NSLog(@"Playback time");
    if (self.player.rate != 0) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

-(void)onProfileTapped:(UITapGestureRecognizer *)sender {
    NSLog(@"Profile picture tapped");
    [self.delegate feedCell:self didTap:self.post[@"author"]];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.player = nil;
}

- (IBAction)onLikeButtonTapped:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    NSLog(@"%@", user);
    
    if (!self.likeButton.selected) {
        [Post likePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self updateAppearance];
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    } else {
        // Unlike post
        [Post unlikePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self updateAppearance];
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
    
}

@end
