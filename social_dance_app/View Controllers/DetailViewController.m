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


@interface DetailViewController ()
@property (strong, nonatomic) IBOutlet DetailView *detailView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.detailView updateAppearanceWithPost:self.post];
}

- (IBAction)onListenButtonPressed:(UIButton *)sender {
    // TODO: make Spotify API call
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SpotifyWebViewController"]) {
        SpotifyWebViewController *vc = [segue destinationViewController];
        vc.url = [NSURL URLWithString:self.post.song.webURL];
    }
}


@end
