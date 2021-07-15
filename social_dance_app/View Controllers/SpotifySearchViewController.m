//
//  SpotifySearchViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/15/21.
//

#import "SpotifySearchViewController.h"
#import "APIManager.h"
#import "Song.h"

@interface SpotifySearchViewController ()

@end

@implementation SpotifySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Test search
    [[APIManager shared]searchForTrackWithQuery:@"vanilla%20twilight" withCompletion:^(NSDictionary * dataDictionary, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Successful search!");
//                NSLog(@"%@", dataDictionary);
                [Song songsWithDictionaries:dataDictionary[@"tracks"][@"items"]];
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
