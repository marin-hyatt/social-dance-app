//
//  ProfileViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import "ProfileViewController.h"
#import "ProfileView.h"
#import "Parse/Parse.h"
#import <AVFoundation/AVFoundation.h>
#import "DetailViewController.h"
#import "Post.h"
#import "FollowerRelation.h"
#import "EditProfileViewController.h"
#import "CacheManager.h"
#import "BookmarkViewController.h"
#import "PostCell.h"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet ProfileView *profileView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *feed;
@property (weak, nonatomic) IBOutlet UICollectionView *profileCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
- (IBAction)onFollowButtonPressed:(UIButton *)sender;
- (IBAction)onEditProfileButtonPressed:(UIBarButtonItem *)sender;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileCollectionView.delegate = self;
    self.profileCollectionView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateProfile) forControlEvents:UIControlEventValueChanged];
    [self.profileView.scrollView insertSubview:self.refreshControl atIndex:0];
    
    self.profileView.user = self.user;
    
    self.navigationItem.rightBarButtonItems[0].tintColor = [UIColor clearColor];
    self.navigationItem.rightBarButtonItems[1].tintColor = [UIColor clearColor];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFUser *currentUser = [PFUser currentUser];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (![self.user.objectId isEqual:currentUser.objectId]) {
                self.navigationItem.rightBarButtonItems = nil;
            } else {
                self.navigationItem.rightBarButtonItems[0].tintColor = [UIColor systemBlueColor];
                self.navigationItem.rightBarButtonItems[1].tintColor = [UIColor systemBlueColor];
            }
        });
    });
     
    [self updateProfile];
    
    [self.profileCollectionView registerNib:[UINib nibWithNibName:@"PostCell" bundle:nil] forCellWithReuseIdentifier:@"ProfileCollectionViewCell"];
}

- (void)updateProfile {
    [self loadPosts];
    [self loadNumFollowers];
    [self updateFollowerButton];
}

- (void)updateFollowerButton {
    self.profileView.followerButton.selected = NO;
    PFUser *currentUser = [PFUser currentUser];

    PFQuery *query = [FollowerRelation query];
    [query whereKey:@"user" equalTo:self.user];
    [query whereKey:@"follower" equalTo:currentUser];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (number > 0) {
            self.profileView.followerButton.selected = YES;
        }
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  __nonnull context) {
        [self.flowLayout invalidateLayout];
        [self.profileCollectionView layoutIfNeeded];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  __nonnull context) {
        
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int totalwidth = self.profileCollectionView.bounds.size.width;
    int numberOfCellsPerRow = 3;
    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow);
    return CGSizeMake(dimensions, dimensions);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [self.profileCollectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionViewCell" forIndexPath:indexPath];
    
    cell.post = self.feed[indexPath.row];
    PFFileObject *videoFile = cell.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * playerItem) {
        AVAsset *asset = [playerItem asset];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        [generateImg setAppliesPreferredTrackTransform:YES];
        NSError *imgError = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&imgError];
        UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:refImg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell updateAppearanceWithImage:thumbnailImage];
        });
    } withMainBlock:^(AVPlayerItem * playerItem) {
    }];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.feed.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = (PostCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"DetailViewController" sender:cell];
}

-(void)loadPosts{
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"song"];
    [postQuery whereKey:@"author" equalTo:self.user];
    postQuery.limit = 20;

    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.feed = posts;
            [self.profileCollectionView reloadData];
            [self.refreshControl endRefreshing];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (int)loadNumFollowers {
    __block int numFollowers = 0;
    
    PFQuery *followerQuery = [FollowerRelation query];
    [followerQuery whereKey:@"user" equalTo:self.user];
    
    [followerQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            numFollowers = number;
            [self.profileView updateAppearanceWithFollowerCount:number];
        }
    }];
    return numFollowers;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]  isEqual: @"DetailViewController"]) {
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.profileCollectionView indexPathForCell:tappedCell];
        Post *post = self.feed[indexPath.item];
        
        DetailViewController *vc = [segue destinationViewController];
        vc.post = post;
    } else if ([[segue identifier] isEqual:@"EditProfileViewController"]) {
        EditProfileViewController *vc = [segue destinationViewController];
        vc.user = self.user;
    } else if ([[segue identifier] isEqual:@"BookmarkViewController"]) {
        BookmarkViewController *vc = [segue destinationViewController];
        vc.user = self.user;
    }
}


- (IBAction)onEditProfileButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"EditProfileViewController" sender:nil];
}

- (IBAction)onBookmarkButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"BookmarkViewController" sender:nil];
}

- (IBAction)onFollowButtonPressed:(UIButton *)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    if (self.profileView.followerButton.selected) {
        [FollowerRelation removeRelationWithUser:self.user withFollower:currentUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                [self updateFollowerButton];
            }
        }];
    } else {
        // Check for duplicate entries
        PFQuery *followerQuery = [FollowerRelation query];
        [followerQuery whereKey:@"follower" equalTo:currentUser];
        [followerQuery whereKey:@"user" equalTo:self.user];

        [followerQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else if (number == 0) {
                [FollowerRelation newRelationWithUser:self.user withFollower:currentUser withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error != nil) {
                        NSLog(@"Error: %@", error.localizedDescription);
                    } else {
                        [self updateFollowerButton];
                    }
                }];
            }
        }];
    }
    
    
}
@end
