//
//  SpotifyAuthViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/14/21.
//

#import "SpotifyAuthViewController.h"
#import <WebKit/WebKit.h>
#import "APIManager.h"
#import "SpotifyAuthView.h"
#import "UIManager.h"

@interface SpotifyAuthViewController () <WKNavigationDelegate>
@property (strong, nonatomic) IBOutlet SpotifyAuthView *authView;

@end

@implementation SpotifyAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.authView.webView.navigationDelegate = self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    NSString *clientID = [dict objectForKey: @"client_ID"];
    
    NSString *base = @"https://accounts.spotify.com/authorize";
    NSString *scope = @"user-read-recently-played%20user-read-playback-state%20app-remote-control%20user-read-private";
    NSString *redirectURI = @"social-dance-app://social-dance-app-callback";
    NSString *signInString = [NSString stringWithFormat:@"%@?response_type=code&client_id=%@&scope=%@&redirect_uri=%@", base, clientID, scope, redirectURI];
    
    NSURL *url = [NSURL URLWithString:signInString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.authView.webView loadRequest:request];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlString = navigationAction.request.URL.absoluteString;
    
    if ([urlString hasPrefix:@"social-dance-app"]) {
        NSString *code = [urlString stringByReplacingOccurrencesOfString:@"social-dance-app://social-dance-app-callback/?code=" withString:@""];
        
        [[APIManager shared]exchangeCodeForAccessTokenWithCode:code withCompletion:^(NSDictionary * dataDictionary, NSError * error) {
            if (error != nil) {
                [UIManager presentAlertWithMessage:error.localizedDescription overViewController:self];
            }
        }];
        
        decisionHandler(WKNavigationActionPolicyCancel);

        [self performSegueWithIdentifier:@"HomeSegue" sender:nil];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
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
