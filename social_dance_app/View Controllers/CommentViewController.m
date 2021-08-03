//
//  CommentViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/23/21.
//

#import "CommentViewController.h"
#import "Comment.h"
#import "CommentTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIManager.h"
#import "ProfileViewController.h"

@interface CommentViewController () <UITableViewDelegate, UITableViewDataSource, CommentTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *comments;
@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadComments) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    PFUser *currentUser = [PFUser currentUser];
    PFFileObject *postImage = currentUser[@"profilePicture"];
    [UIManager updateProfilePicture:self.profilePictureView withPFFileObject:postImage];
    
    [self loadComments];
}

- (IBAction)onSendButtonPressed:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];

    [Comment newCommentWithPost:self.post withAuthor:user withText:self.commentField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self withHandler:nil];
        } else {
            self.commentField.text = @"";
            [self loadComments];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell"];
    cell.comment = self.comments[indexPath.row];
    cell.delegate = self;
    [cell updateAppearance];
    
    return cell;
}

- (void)feedCell:(CommentTableViewCell *)feedCell didTap:(PFUser *)user {
    [self performSegueWithIdentifier:@"ProfileViewController" sender:user];
}

- (void)loadComments {
    PFQuery *commentQuery = [Comment query];
    [commentQuery orderByDescending:@"createdAt"];
    [commentQuery includeKey:@"author"];
    [commentQuery whereKey:@"post" equalTo:self.post];
    commentQuery.limit = 20;


    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray<Comment *> * _Nullable comments, NSError * _Nullable error) {
        if (comments) {
            self.comments = comments;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
        else {
            [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self withHandler:nil];
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqual:@"ProfileViewController"]) {
        ProfileViewController *vc = [segue destinationViewController];
        vc.user = sender;
    }
}


@end
