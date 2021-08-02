//
//  DetailViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "DetailViewController.h"
#import "DetailView.h"
#import "APIManager.h"
#import "SpotifyWebViewController.h"
#import "Post.h"
#import "Comment.h"
#import "CommentViewController.h"
#import "CacheManager.h"
#import "TutorialViewController.h"
#import "UIManager.h"
#import "PostUtility.h"

@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet DetailView *detailView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.detailView updateAppearanceWithPost:self.post];
    [self updateVideo];

    [PostUtility updateLikeButton:self.detailView.likeButton withPost:self.post];
    [PostUtility updateCommentButton:self.detailView.commentButton withPost:self.post];
    [PostUtility updateBookmarkButton:self.detailView.bookmarkButton usingPost:self.post];
    [PostUtility updateUsernameLabel:self.detailView.usernameLabel andProfilePicture:self.detailView.profilePictureView WithUser:self.post.author];
    [PostUtility updateTimestampForLabel:self.detailView.timestampLabel usingPost:self.post];
    
    
    NSArray *tags = self.post.tags;
    for (NSString *tag in tags) {
        [self.detailView.tagView addTag:tag];
    }

}

- (void)updateVideo {
    PFFileObject *videoFile = self.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * _Nonnull playerItem) {
    } withMainBlock:^(AVPlayerItem * _Nonnull playerItem) {
        if (self.detailView.player == nil) {
            self.detailView.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.detailView.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.detailView.player currentItem]];
            [self.detailView.videoPlayerView setPlayer:self.detailView.player];
        }
    }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}


- (IBAction)onListenButtonPressed:(UIButton *)sender {
    // Check to see if Spotify app is installed
    NSURL *webUrl = [NSURL URLWithString:self.post.song.webURL];
    NSURL *uri = [NSURL URLWithString:self.post.song.uri];
    
    if ([[UIApplication sharedApplication] canOpenURL:uri]) {
        [[UIApplication sharedApplication] openURL:webUrl options:@{} completionHandler:^(BOOL success) {
        }];
    } else {
        // Segue to web view since app can't be opened
        [self performSegueWithIdentifier:@"SpotifyWebViewController" sender:nil];
    }
}

- (IBAction)onLikeButtonPressed:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    
    if (!self.detailView.likeButton.selected) {
        [Post likePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PostUtility updateLikeButton:self.detailView.likeButton withPost:self.post];
            } else {
                [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self];
            }
        }];
    } else {
        [Post unlikePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PostUtility updateLikeButton:self.detailView.likeButton withPost:self.post];
            } else {
                [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self];
            }
        }];
    }
}

- (IBAction)onCommentButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"CommentViewController" sender:nil];
}

- (IBAction)onBookmarkButtonPressed:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    
    if (!self.detailView.bookmarkButton.selected) {
        [Post bookmarkPost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PostUtility updateBookmarkButton:self.detailView.bookmarkButton usingPost:self.post];
            }
        }];
    } else {
        [Post unbookmarkPost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PostUtility updateBookmarkButton:self.detailView.bookmarkButton usingPost:self.post];
            }
        }];
    }
}

- (IBAction)onLearnButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"TutorialViewController" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SpotifyWebViewController"]) {
        SpotifyWebViewController *vc = [segue destinationViewController];
        vc.url = [NSURL URLWithString:self.post.song.webURL];
    } else if ([segue.identifier isEqualToString:@"CommentViewController"]) {
        CommentViewController *vc = [segue destinationViewController];
        vc.post = self.post;
    } else if ([segue.identifier isEqualToString:@"TutorialViewController"]) {
        TutorialViewController *vc = [segue destinationViewController];
        vc.post = self.post;
    }
}


@end
