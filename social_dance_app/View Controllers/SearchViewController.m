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

@interface SearchViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *searchCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSMutableArray *filteredUsers;

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
    [self.flowLayout invalidateLayout];
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
    
    // Passes user into cell
    cell.user = self.filteredUsers[indexPath.item];
    [cell updateAppearance];
    
    return cell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredUsers.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
            // Creates a predicate used for filtering, in this case we use the title
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *user, NSDictionary *bindings) {
                return [user[@"username"] containsString:searchText];
            }];
            // Filters the array of movies using the predicate
            self.filteredUsers = [self.users filteredArrayUsingPredicate:predicate];
        }
        else {
            //If no search, don't filter anything
            self.filteredUsers = self.users;
        }
        //Refresh the data to reflect filtering
        [self.searchCollectionView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //Display cancel button when user beigns typing
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //Takes away cancel button, deletes text, hides keyboard
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    //Removes filter and refreshes data
    self.filteredUsers = self.users;
    [self.searchCollectionView reloadData];
}

-(void)loadUsers:(int)limit {
    PFQuery *postQuery = [PFUser query];
    [postQuery orderByDescending:@"createdAt"];
    postQuery.limit = limit;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<PFUser *> * _Nullable users, NSError * _Nullable error) {
        if (users) {
            self.users = users;
            self.filteredUsers = self.users;
            [self.searchCollectionView reloadData];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]  isEqual: @"ProfileViewController"]) {
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.searchCollectionView indexPathForCell:tappedCell];
        PFUser *user = self.filteredUsers[indexPath.item];
        
        ProfileViewController *vc = [segue destinationViewController];
        vc.user = user;
    }
}


@end
