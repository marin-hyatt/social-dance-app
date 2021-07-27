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
    
    [self loadUsers:20];
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
    SearchCollectionViewCell *cell = [self.searchCollectionView dequeueReusableCellWithReuseIdentifier:@"SearchCollectionViewCell" forIndexPath:indexPath];

    cell.user = self.filteredFeed[indexPath.item];
    [cell updateAppearance];
    
    return cell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredFeed.count;
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

- (void)loadUsers:(int)limit {
    PFQuery *postQuery = [PFUser query];
    [postQuery orderByDescending:@"createdAt"];
    postQuery.limit = limit;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        if (users) {
            self.feed = users;
            self.filteredFeed = self.feed;
            [self.searchCollectionView reloadData];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
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
    if ([[segue identifier]  isEqual: @"ProfileViewController"]) {
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.searchCollectionView indexPathForCell:tappedCell];
        PFUser *user = self.filteredFeed[indexPath.item];
        
        ProfileViewController *vc = [segue destinationViewController];
        vc.user = user;
    }
}


@end
