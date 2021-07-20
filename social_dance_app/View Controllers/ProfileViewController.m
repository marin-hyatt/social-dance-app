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

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet ProfileView *profileView;
@property (strong, nonatomic) NSArray *feed;
@property (weak, nonatomic) IBOutlet UICollectionView *profileCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileCollectionView.delegate = self;
    self.profileCollectionView.dataSource = self;
    
    
    self.profileView.user = self.user;
    [self.profileView updateAppearance];
    
    [self loadPosts];
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Get video thumbnail
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        NSError *error = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
        NSLog(@"error==%@, Refimage==%@", error, refImg);
        UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:refImg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell updateAppearanceWithImage:thumbnailImage];
            cell.thumbnailView.transform = CGAffineTransformMakeRotation(M_PI_2);
            [self updateViewConstraints];
        });
    });
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.feed.count;
}

-(void)loadPosts {
    NSLog(@"Load posts");
    
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


@end
