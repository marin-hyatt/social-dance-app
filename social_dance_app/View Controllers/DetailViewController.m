//
//  DetailViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "DetailViewController.h"
#import "DetailView.h"
#import "APIManager.h"
#import "SpotifyWebViewController.h"
#import "Post.h"
#import "Comment.h"
#import "CommentViewController.h"


@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet DetailView *detailView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.detailView updateAppearanceWithPost:self.post];
    [self updateLikeButton];
    [self updateComment];

}

- (void)updateLikeButton {
    self.detailView.likeButton.selected = NO;
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *likeRelation = [self.post relationForKey:@"likeRelation"];
    PFQuery *query = [likeRelation query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (number > 0) {
            self.detailView.likeButton.selected = YES;
        }
    }];
}

- (void)updateComment {
    self.detailView.commentButton.selected = NO;
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [Comment query];
    [query whereKey:@"author" equalTo:currentUser];
    [query whereKey:@"post" equalTo:self.post];
    
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else if (number > 0) {
            self.detailView.commentButton.selected = YES;
        }
    }];
}

- (IBAction)onListenButtonPressed:(UIButton *)sender {
    // Check to see if Spotify app is installed
    NSURL *webUrl = [NSURL URLWithString:self.post.song.webURL];
    NSURL *uri = [NSURL URLWithString:self.post.song.uri];
    
    if ([[UIApplication sharedApplication] canOpenURL:uri]) {
        [[UIApplication sharedApplication] openURL:webUrl options:@{} completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Success");
            } else {
                NSLog(@"Error");
            }
        }];
    } else {
        // Segue to web view since app can't be opened
        [self performSegueWithIdentifier:@"SpotifyWebViewController" sender:nil];
    }
}

- (IBAction)onLikeButtonPressed:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    
    if (!self.detailView.likeButton.selected) {
        [Post likePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self updateLikeButton];
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    } else {
        [Post unlikePost:self.post withUser:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self updateLikeButton];
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
}

- (IBAction)onCommentButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"CommentViewController" sender:nil];
}

- (IBAction)onBookmarkButtonPressed:(UIButton *)sender {
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SpotifyWebViewController"]) {
        SpotifyWebViewController *vc = [segue destinationViewController];
        vc.url = [NSURL URLWithString:self.post.song.webURL];
    } else if ([segue.identifier isEqualToString:@"CommentViewController"]) {
        CommentViewController *vc = [segue destinationViewController];
        vc.post = self.post;
    }
}


@end
