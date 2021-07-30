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
#import "CommentViewController.h"
#import "CacheManager.h"
#import "UIManager.h"

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

    [self updateCellVideoWithCell:cell];
    
    [cell updateAppearance];
    
    return cell;
    
}

- (void)updateCellVideoWithCell:(HomeTableViewCell *)cell {
    PFFileObject *videoFile = cell.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * _Nonnull playerItem) {
        cell.playerItem = playerItem;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
        
    } withMainBlock:^(AVPlayerItem * _Nonnull playerItem) {
        if (cell.player == nil) {
            cell.player = [AVPlayer playerWithPlayerItem:playerItem];
            
            cell.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [cell.videoView setPlayer:cell.player];
        }
    }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
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
    [postQuery includeKey:@"tags"];
    postQuery.limit = limit;
    
    PFQuery *followerQuery = [FollowerRelation query];
    [followerQuery whereKey:@"follower" equalTo:[PFUser currentUser]];
    
    [postQuery whereKey:@"author" matchesKey:@"user" inQuery:followerQuery];
 
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.isMoreDataLoading = false;
            self.feed = posts;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
        else {
            [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self];
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
    } else if ([[segue identifier]  isEqual: @"CommentViewController"]) {
        CommentViewController *vc = [segue destinationViewController];
        vc.post = sender;
    }
}


- (IBAction)onLogoutButtonPressed:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
    
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
}

- (void)feedCell:(nonnull HomeTableViewCell *)feedCell didTap:(nonnull PFUser *)user {
    [self performSegueWithIdentifier:@"ProfileViewController" sender:user];
}

- (void)feedCell:(HomeTableViewCell *)feedCell didTapWithPost:(Post *)post {
    [self performSegueWithIdentifier:@"CommentViewController" sender:post];
}


@end
