//
//  ProfileViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import "ProfileViewController.h"
#import "ProfileView.h"
#import "Parse/Parse.h"
#import "ProfileCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "DetailViewController.h"
#import "Post.h"
#import "FollowerRelation.h"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet ProfileView *profileView;
@property (strong, nonatomic) NSArray *feed;
@property (weak, nonatomic) IBOutlet UICollectionView *profileCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
- (IBAction)onFollowButtonPressed:(UIButton *)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileCollectionView.delegate = self;
    self.profileCollectionView.dataSource = self;
    
    
    self.profileView.user = self.user;
    
    
    [self loadPosts];
    [self loadNumFollowers];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.flowLayout invalidateLayout];
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
    ProfileCollectionViewCell *cell = [self.profileCollectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionViewCell" forIndexPath:indexPath];
    

    cell.post = self.feed[indexPath.row];
    PFFileObject *videoFile = cell.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    // TODO: cache image thumbnails
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:videoFileUrl];
    
    // As I understand it, the task runs on a background thread
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // generate a temporary file URL
        NSString *filename = [[NSUUID UUID] UUIDString];
        
        NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *fileURL = [[temporaryDirectoryURL URLByAppendingPathComponent:filename] URLByAppendingPathExtension:@"mp4"];

        NSError *fileError;
        [data writeToURL:fileURL options:0 error:&fileError];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        
        // Get video thumbnail
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        [generateImg setAppliesPreferredTrackTransform:YES];
        NSError *imgError = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&imgError];
        NSLog(@"error==%@, Refimage==%@", imgError, refImg);
        UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:refImg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell updateAppearanceWithImage:thumbnailImage];
        });
        
    }];
    [task resume];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.feed.count;
}

-(void)loadPosts {
    
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"song"];
    [postQuery whereKey:@"author" equalTo:self.user];
    postQuery.limit = 20;

    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            NSLog(@"Feed successfully loaded");
            self.feed = posts;
            [self.profileCollectionView reloadData];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

-(int)loadNumFollowers {
    // Load number of followers
    __block int numFollowers = 0;
    
    PFQuery *followerQuery = [FollowerRelation query];
    [followerQuery whereKey:@"user" equalTo:self.user];
    
    [followerQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Number of followers: %d", number);
            numFollowers = number;
            [self.profileView updateAppearanceWithFollowerCount:number];
        }
    }];
    
    return numFollowers;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]  isEqual: @"DetailViewController"]) {
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.profileCollectionView indexPathForCell:tappedCell];
        Post *post = self.feed[indexPath.item];
        NSLog(@"%@", post);
        
        DetailViewController *vc = [segue destinationViewController];
        vc.post = post;
    }
}


- (IBAction)onFollowButtonPressed:(UIButton *)sender {
    NSLog(@"follow button pressed");
    NSLog(@"%@", self.user[@"followedByUsers"]);
    NSLog(@"%@", [PFUser currentUser]);
    
    [FollowerRelation newRelationWithUser:self.user withFollower:[PFUser currentUser] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Follower relation added");
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}
@end
