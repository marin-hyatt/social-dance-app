//
//  SpotifyAuthView.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/14/21.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyAuthView : UIView
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

NS_ASSUME_NONNULL_END
