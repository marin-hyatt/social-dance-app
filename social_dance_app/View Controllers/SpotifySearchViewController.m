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

@interface SpotifySearchViewController () <UITableViewDelegate, UITableViewDataSource>
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
    
    [self searchForSongs];
    
}

-(void)searchForSongs {
    // Test search
    [[APIManager shared]searchForTrackWithQuery:@"vanilla%20twilight" withCompletion:^(NSDictionary * dataDictionary, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Successful search!");
//                NSLog(@"%@", dataDictionary);
                self.songArray = [Song songsWithDictionaries:dataDictionary[@"tracks"][@"items"]];
                
                // Reloads data on main thread. Not quite sure why I got an error in the first place
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                });
            }
    }];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SpotifySearchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SpotifySearchTableViewCell"];
    
    cell.song = self.songArray[indexPath.row];
    [cell updateAppearance];
    
    return cell;
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
