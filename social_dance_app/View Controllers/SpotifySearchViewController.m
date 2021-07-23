//
//  SpotifySearchViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/15/21.
//

#import "SpotifySearchViewController.h"
#import "APIManager.h"
#import "Song.h"
#import "SpotifySearchTableViewCell.h"
#import "SpotifyWebViewController.h"

@interface SpotifySearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SpotifySearchCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *songArray;


@end

@implementation SpotifySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
}

-(void)searchForSongsWithQuery:(NSString *)query {
    // Test search
    [[APIManager shared]searchForTrackWithQuery:query withCompletion:^(NSDictionary * dataDictionary, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Successful search!");
                self.songArray = [Song songsWithDictionaries:dataDictionary[@"tracks"][@"items"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *query = self.searchBar.text;
    NSString *formattedQuery = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    [self searchForSongsWithQuery:formattedQuery];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpotifySearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SpotifySearchTableViewCell"];
    
    if ([self.songArray count] > 0) {
        cell.song = self.songArray[indexPath.row];
        [cell updateAppearance];
        cell.delegate = self;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Song *song = self.songArray[indexPath.row];
    [self.delegate didPickSong:song];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songArray.count;
}

- (void)openSpotifyWithSong:(Song *)song {
    // Check to see if Spotify app is installed
    NSURL *webUrl = [NSURL URLWithString:song.webURL];
    NSURL *uri = [NSURL URLWithString:song.uri];
    
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
        [self performSegueWithIdentifier:@"SpotifyWebViewController" sender:song];
    }
}


#pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"SpotifyWebViewController"]) {
         Song *song = sender;
         SpotifyWebViewController *vc = [segue destinationViewController];
         vc.url = [NSURL URLWithString:song.webURL];
     }
 }

@end
