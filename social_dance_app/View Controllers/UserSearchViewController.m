//
//  UserSearchViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/27/21.
//

#import "UserSearchViewController.h"
#import "UserSearchTableViewCell.h"
#import "ProfileViewController.h"

@interface UserSearchViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *feed;
@property NSMutableArray *filteredFeed;

@end

@implementation UserSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self loadUsers:20];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserSearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserSearchTableViewCell"];
    
    cell.user = self.filteredFeed[indexPath.row];
    [cell updateAppearance];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredFeed.count;
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
            [self.tableView reloadData];
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
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        PFUser *user = self.filteredFeed[indexPath.item];
        
        ProfileViewController *vc = [segue destinationViewController];
        vc.user = user;
    }
}


@end
