//
//  BookmarkViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/23/21.
//

#import "BookmarkViewController.h"
#import "PostCell.h"
#import "CacheManager.h"
#import "Post.h"
#import "DetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIManager.h"

@interface BookmarkViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSArray *bookmarks;

@end

@implementation BookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self loadPosts];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PostCell" bundle:nil] forCellWithReuseIdentifier:@"BookmarkCollectionViewCell"];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  __nonnull context) {
        [self.flowLayout invalidateLayout];
        [self.collectionView layoutIfNeeded];
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
    int totalwidth = self.collectionView.bounds.size.width;
    int numberOfCellsPerRow = 3;
    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow);
    return CGSizeMake(dimensions, dimensions);
}

- (void)loadPosts {
    PFQuery *query = [Post query];
    [query whereKey:@"bookmarkRelation" equalTo:self.user];
    [query includeKey:@"author"];
    [query includeKey:@"song"];
    [query includeKey:@"tags"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self];
        } else {
            self.bookmarks = objects;
            NSLog(@"%@", objects);
            [self.collectionView reloadData];
        }
    }];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"BookmarkCollectionViewCell" forIndexPath:indexPath];
    
    cell.post = self.bookmarks[indexPath.row];
    PFFileObject *videoFile = cell.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * playerItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *thumbnailURL = [NSURL URLWithString:cell.post.thumbnailImage.url];
            UIImage *thumbnailImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:thumbnailURL]];
            [cell updateAppearanceWithImage:thumbnailImage];
        });
    } withMainBlock:^(AVPlayerItem * playerItem) {
    }];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.bookmarks.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = (PostCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"DetailViewController" sender:cell];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqual:@"DetailViewController"]) {
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
        Post *post = self.bookmarks[indexPath.item];
        
        DetailViewController *vc = [segue destinationViewController];
        vc.post = post;
    }
}


@end
