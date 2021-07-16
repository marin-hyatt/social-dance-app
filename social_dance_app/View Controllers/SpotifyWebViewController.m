//
//  SpotifyWebViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/16/21.
//

#import "SpotifyWebViewController.h"
#import <WebKit/WebKit.h>

@interface SpotifyWebViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation SpotifyWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURLRequest *request = [NSURLRequest requestWithURL:self.url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:10.0];
    [self.webView loadRequest:request];
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
