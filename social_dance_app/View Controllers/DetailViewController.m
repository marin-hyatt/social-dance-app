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
#import "RKTagsView.h"
#import "SearchViewController.h"
#import "SVProgressHUD.h"
#import "ProfileViewController.h"

@interface DetailViewController () <RKTagsViewDelegate, PlayerViewDelegate>
@property (strong, nonatomic) IBOutlet DetailView *detailView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property int tagCount;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.detailView updateAppearanceWithPost:self.post];
    [self loadVideo];
    [self updateVideoWithPost:self.post];
    [self updatePostInfo];
    
    self.detailView.tagView.delegate = self;
    self.detailView.videoPlayerView.delegate = self;
    NSArray *tags = self.post.tags;
    self.tagCount = [self.post.tags count];
    for (NSString *tag in tags) {
        [self.detailView.tagView addTag:tag];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updatePostInfo) forControlEvents:UIControlEventValueChanged];
    [self.detailView.scrollView insertSubview:self.refreshControl atIndex:0];
    [self.detailView.scrollView setAlwaysBounceVertical:YES];
    
    [self addDeleteButtonIfNeeded];
    [self addGestureRecognizers];
}

- (void)updatePostInfo {
    [PostUtility updateLikeButton:self.detailView.likeButton withPost:self.post];
    [PostUtility updateCommentButton:self.detailView.commentButton withPost:self.post];
    [PostUtility updateBookmarkButton:self.detailView.bookmarkButton usingPost:self.post];
    [PostUtility updateUsernameLabel:self.detailView.usernameLabel andProfilePicture:self.detailView.profilePictureView WithUser:self.post.author];
    [PostUtility updateTimestampForLabel:self.detailView.timestampLabel usingPost:self.post];
    [self.refreshControl endRefreshing];
}

- (void)addGestureRecognizers {
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    UITapGestureRecognizer *usernameTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProfileTapped:)];
    [self.detailView.profilePictureView addGestureRecognizer:profileTapGestureRecognizer];
    [self.detailView.profilePictureView setUserInteractionEnabled:YES];
    [self.detailView.usernameLabel addGestureRecognizer:usernameTapGestureRecognizer];
    [self.detailView.usernameLabel setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *songNameTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchForSong:)];
    [self.detailView.songNameLabel addGestureRecognizer:songNameTapGestureRecognizer];
    [self.detailView.songNameLabel setUserInteractionEnabled:YES];
    [self.detailView.albumImageView addGestureRecognizer:songNameTapGestureRecognizer];
    [self.detailView.albumImageView setUserInteractionEnabled:YES];
}

- (void)addDeleteButtonIfNeeded {
    NSMutableArray *rightBarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    [rightBarButtons removeObject:self.deleteButton];
    [self.navigationItem setRightBarButtonItems:rightBarButtons animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFUser *currentUser = [PFUser currentUser];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([self.post.author.objectId isEqual:currentUser.objectId]) {
                [rightBarButtons addObject:self.deleteButton];
                [self.navigationItem setRightBarButtonItems:rightBarButtons];
            }
        });
    });
}

- (void)updateVideoWithPost:(Post *)post {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    [self.detailView.videoPlayerView addGestureRecognizer:tapGestureRecognizer];
    [self.detailView.videoPlayerView setUserInteractionEnabled:YES];
    [self.detailView.videoPlayerView setPlayer:[AVPlayer playerWithPlayerItem:nil]];
    
    // Update autolayout corresponding to video aspect ratio
    CGFloat videoHeight = [post[@"videoHeight"] doubleValue];
    CGFloat videoWidth = [post[@"videoWidth"] doubleValue];
    
    [self.detailView.videoPlayerView updateAutolayoutWithHeight:videoHeight withWidth:videoWidth];
}

- (void)startPlayback {
    if (self.detailView.player.rate != 0) {
        [PostUtility addPlayButtonOverView:self.detailView.videoPlayerView];
        [self.detailView.player pause];
    } else {
        [self removeVideoThumbnail];
        [self.detailView.player play];
    }
}

- (void)onProfileTapped:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"ProfileViewController" sender:nil];
}

- (UIButton *)tagsView:(RKTagsView *)tagsView buttonForTagAtIndex:(NSInteger)index {
    UIButton *button = [[UIButton alloc] init];
    UIColor *perfectBlue = [UIColor colorWithRed:149.0f/255.0f green:189.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    button.titleLabel.font = self.detailView.tagView.font;
    
    if (index == self.tagCount - 1) {
        [button setTitle:[NSString stringWithFormat:@"%@", self.detailView.tagView.tags[index]] forState:UIControlStateNormal];
    } else {
        [button setTitle:[NSString stringWithFormat:@"%@,", self.detailView.tagView.tags[index]] forState:UIControlStateNormal];
    }
    
    [button setTintColor:perfectBlue];
    [button setTitleColor:perfectBlue forState:UIControlStateNormal];
    [button.layer setBorderColor:[perfectBlue CGColor]];
    
    [button addTarget:self
               action:@selector(searchForTag:)
       forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)searchForTag:(UIButton *)sender {
    [self searchInExploreScreenWithQuery:[sender.titleLabel.text stringByReplacingOccurrencesOfString:@"," withString:@""] isTag:YES];
}

- (void)searchForSong:(UITapGestureRecognizer *)sender {
    NSString *songName = self.detailView.songNameLabel.text;
    [self searchInExploreScreenWithQuery:songName isTag:NO];
}

- (void)searchInExploreScreenWithQuery:(NSString *)query isTag:(BOOL)isTag {
    UINavigationController *searchNavigationController = [self.tabBarController.viewControllers objectAtIndex:1];
    if (self.tabBarController.selectedViewController != searchNavigationController) {
        SearchViewController *vc = (SearchViewController*) [[searchNavigationController viewControllers] objectAtIndex:0];
        vc.searchQuery = query;
        vc.isTag = isTag;
        [vc searchPostsWithQuery:vc.searchQuery isTag:isTag];
        self.tabBarController.selectedViewController = searchNavigationController;
    } else {
        SearchViewController *vc = [self.navigationController.viewControllers objectAtIndex:0];
        vc.searchQuery = query;
        vc.isTag = isTag;
        [vc searchPostsWithQuery:vc.searchQuery isTag:isTag];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)loadVideo {
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

- (void)displayVideoThumbnail {
    [PostUtility displayVideoThumbnailOverView:self.detailView.videoPlayerView withPost:self.post withPlayButtonIncluded:YES];
}

- (void)removeVideoThumbnail {
    for (UIImageView *subview in self.detailView.videoPlayerView.subviews) {
        [subview removeFromSuperview];
    }
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
                [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self withHandler:nil];
            }
        }];
    } else {
        [Post unlikePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [PostUtility updateLikeButton:self.detailView.likeButton withPost:self.post];
            } else {
                [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self withHandler:nil];
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

- (IBAction)onTrashButtonPressed:(UIBarButtonItem *)sender {
    [UIManager presentAlertWithMessage:@"Are you sure you want to delete this post?" overViewController:self withHandler:^{
        [self deletePost];
    }];
}

- (void)deletePost {
    [SVProgressHUD showWithStatus:@"Deleting post"];
    [self.post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self withHandler:nil];
        } else {
            [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (error != nil) {
                    [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self withHandler:nil];
                }
            }];
        }
        [SVProgressHUD dismiss];
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
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
    } else if ([segue.identifier isEqualToString:@"ProfileViewController"]) {
        ProfileViewController *vc = [segue destinationViewController];
        vc.user = self.post.author;
    }
}


@end
