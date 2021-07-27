//
//  SearchViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "SearchViewController.h"
#import "Parse/Parse.h"
#import "SearchCollectionViewCell.h"
#import "ProfileViewController.h"
#import "Post.h"
#import "PostCell.h"
#import "CacheManager.h"
#import "DetailViewController.h"

@interface SearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *searchCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSArray *feed;
@property (strong, nonatomic) NSMutableArray *filteredFeed;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchCollectionView.dataSource = self;
    self.searchCollectionView.delegate = self;
    self.searchBar.delegate = self;
    
    [self loadPosts:20];
    
    [self.searchCollectionView registerNib:[UINib nibWithNibName:@"PostCell" bundle:nil] forCellWithReuseIdentifier:@"SearchCollectionViewCell"];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  __nonnull context) {
        [self.flowLayout invalidateLayout];
        [self.searchCollectionView layoutIfNeeded];
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
    int totalwidth = self.searchCollectionView.bounds.size.width;
    int numberOfCellsPerRow = 3;
    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow);
    return CGSizeMake(dimensions, dimensions);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [self.searchCollectionView dequeueReusableCellWithReuseIdentifier:@"SearchCollectionViewCell" forIndexPath:indexPath];

    cell.post = self.filteredFeed[indexPath.item];
    
    PFFileObject *videoFile = cell.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    NSLog(@"%@", cell.post);
    
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
    return self.filteredFeed.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = (PostCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"DetailViewController" sender:cell];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *user, NSDictionary *bindings) {
                return [user[@"username"] containsString:searchText];
            }];

            self.filteredFeed = [self.feed filteredArrayUsingPredicate:predicate];
        }
        else {
            self.filteredFeed = self.feed;
        }
        [self.searchCollectionView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //Takes away cancel button, deletes text, hides keyboard
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    //Removes filter and refreshes data
    self.filteredFeed = self.feed;
    [self.searchCollectionView reloadData];
}

- (void)loadPosts:(int)limit {
    PFQuery *postQuery = [Post query];
    
    // TODO: possibly implement better algorithm rather than just sorting by number of likes
    [postQuery orderByDescending:@"likeCount"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"song"];
    postQuery.limit = limit;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.feed = posts;
            self.filteredFeed = self.feed;
            [self.searchCollectionView reloadData];
        }
        else {
            NSLog(@"Parse error: %@", error.localizedDescription);
        }
    }];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self performSegueWithIdentifier:@"UserSearchViewController" sender:nil];
    return NO;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqual:@"DetailViewController"]) {
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.searchCollectionView indexPathForCell:tappedCell];
        Post *post = self.filteredFeed[indexPath.item];
        
        DetailViewController *vc = [segue destinationViewController];
        vc.post = post;
    }
}


@end
