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

@interface SpotifySearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
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
                NSLog(@"%@", dataDictionary[@"tracks"][@"items"]);
                self.songArray = [Song songsWithDictionaries:dataDictionary[@"tracks"][@"items"]];
                NSLog(@"%@", self.songArray);
            }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *query = self.searchBar.text;
    NSString *formattedQuery = [query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSLog(@"%@", formattedQuery);
    
    [self searchForSongsWithQuery:formattedQuery];
    [self.tableView reloadData];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpotifySearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SpotifySearchTableViewCell"];
    
    cell.song = self.songArray[indexPath.row];
    [cell updateAppearance];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", self.songArray[indexPath.row]);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 20;
    
    return self.songArray.count;
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
