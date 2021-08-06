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
#import "UIManager.h"
#import "PostUtility.h"

@interface SearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *searchCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
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
    
    [self loadPosts:50];
    
    [self.searchCollectionView registerNib:[UINib nibWithNibName:@"PostCell" bundle:nil] forCellWithReuseIdentifier:@"SearchCollectionViewCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadPosts:) forControlEvents:UIControlEventValueChanged];
    [self.searchCollectionView addSubview:self.refreshControl];
    self.searchCollectionView.alwaysBounceVertical = YES;
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
    
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * playerItem) {
    } withMainBlock:^(AVPlayerItem * playerItem) {
    }];
    
    __weak PostCell *weakCell = cell;
    [PostUtility updateThumbnailView:weakCell.thumbnailView withPost:cell.post];
    
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
    BOOL userSegmentSelected = self.segmentedControl.selectedSegmentIndex == 0;
    BOOL tagSegmentSelected = self.segmentedControl.selectedSegmentIndex == 1;
    
    if (userSegmentSelected) {
        [self performSegueWithIdentifier:@"UserSearchViewController" sender:nil];
    } else {
        self.searchQuery = searchText;
        [self searchPostsWithQuery:self.searchQuery isTag:tagSegmentSelected];
    }
    
}

- (void)searchPostsWithQuery:(NSString *)query isTag:(BOOL)isTag {
    if (query != nil && query.length != 0) {
        self.searchBar.text = query;
        [self.segmentedControl setSelectedSegmentIndex: isTag ? 1 : 2];
        NSPredicate *predicate;
        
        if (self.segmentedControl.selectedSegmentIndex == 1) {
            // Search using tags
            self.filteredFeed = [self.feed filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY %K LIKE[cd] %@", @"tags", [query stringByAppendingString:@"*"]]];
        } else {
            // Search using songs
            predicate = [NSPredicate predicateWithBlock:^BOOL(Post *post, NSDictionary *bindings) {
                return [[post.song[@"title"] lowercaseString] containsString:[query lowercaseString]];
            }];
            self.filteredFeed = [self.feed filteredArrayUsingPredicate:predicate];
        }
    } else {
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

    [postQuery orderByDescending:@"likeCount"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"song"];
    [postQuery includeKey:@"tags"];
    
    postQuery.limit = limit;

    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.feed = posts;
            self.filteredFeed = self.feed;
            [self.filteredFeed sortUsingSelector:@selector(comparewithPost:)];
            [self.refreshControl endRefreshing];
            
            [self searchPostsWithQuery:self.searchQuery isTag:self.isTag];
            
            [self.searchCollectionView reloadData];
        }
        else {
            [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self withHandler:nil];
        }
    }];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self performSegueWithIdentifier:@"UserSearchViewController" sender:nil];
        return NO;
    } else {
        return YES;
    }
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
