//
//  HomeViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "HomeViewController.h"
#import "Parse/Parse.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "HomeTableViewCell.h"
#import "Post.h"
#import "DetailViewController.h"
#import "ProfileViewController.h"
#import "FollowerRelation.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, HomeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *feed;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property int numDataToLoad;
- (IBAction)onLogoutButtonPressed:(id)sender;


@end

@implementation HomeViewController

static void * cellContext = &cellContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.numDataToLoad = 20;
    [self loadPosts:self.numDataToLoad];
    

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadPosts:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
    
    cell.post = self.feed[indexPath.row];
    cell.delegate = self;
    [cell updateAppearance];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feed.count;
}

-(void)loadPosts:(int)limit {
    

    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    [postQuery includeKey:@"song"];
    [postQuery includeKey:@"likedByUsers"];
    postQuery.limit = limit;
    
    PFQuery *followerQuery = [FollowerRelation query];
    [followerQuery whereKey:@"follower" equalTo:[PFUser currentUser]];
    
    [postQuery whereKey:@"author" matchesKey:@"user" inQuery:followerQuery];
 

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.isMoreDataLoading = false;
            NSLog(@"Feed successfully loaded");
            self.feed = posts;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
        else {
            // handle error
            NSLog(@"Parse error: %@", error.localizedDescription);
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]  isEqual: @"DetailViewController"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Post *post = self.feed[indexPath.row];
  
        DetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.post = post;
    } else if ([[segue identifier]  isEqual: @"ProfileViewController"]) {
        ProfileViewController *vc = [segue destinationViewController];
        vc.user = sender;
    }
}


- (IBAction)onLogoutButtonPressed:(id)sender {
    //Creates app delegate, Main storyboard, and Login view controller. Then sets the root view controller (the one the user sees) to the Login view controller
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
    
    // Logs out user
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
}

- (void)feedCell:(nonnull HomeTableViewCell *)feedCell didTap:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"ProfileViewController" sender:user];
}


@end
