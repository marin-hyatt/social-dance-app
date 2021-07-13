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

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *feed;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property int numDataToLoad;
- (IBAction)onLogoutButtonPressed:(id)sender;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Gets posts from Parse
    self.numDataToLoad = 20;
    [self loadPosts:self.numDataToLoad];
    
    // Initializes refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadPosts:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
    
    // Set up cell
    cell.post = self.feed[indexPath.row];
    [cell updateAppearance];
    
    return cell;
    
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row + 1 == [self.feed count] && !self.isMoreDataLoading){
//        self.isMoreDataLoading = true;
//        self.numDataToLoad++;
//        [self loadPosts:self.numDataToLoad];
//    }
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feed.count;
}

-(void)loadPosts:(int)limit {
    NSLog(@"Load posts");
    
    //Querys Parse for posts
    
    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = limit;

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
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end
