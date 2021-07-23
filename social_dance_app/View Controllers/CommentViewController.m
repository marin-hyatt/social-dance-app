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

@interface CommentViewController () <UITableViewDelegate, UITableViewDataSource>
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
    NSLog(@"%@", self.post);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadComments) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    PFUser *currentUser = [PFUser currentUser];
    self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.width / 2;
    self.profilePictureView.layer.masksToBounds = true;
    PFFileObject * postImage = currentUser[@"profilePicture"];
    NSURL * imageURL = [NSURL URLWithString:postImage.url];
    [self.profilePictureView setImageWithURL:imageURL];
    
    [self loadComments];
}

- (IBAction)onSendButtonPressed:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    // Post comment to Parse
    [Comment newCommentWithPost:self.post withAuthor:user withText:self.commentField.text withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            self.commentField.text = @"";
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell"];
    cell.comment = self.comments[indexPath.row];
    [cell updateAppearance];
    
    return cell;
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
            NSLog(@"Parse error: %@", error.localizedDescription);
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

@end
