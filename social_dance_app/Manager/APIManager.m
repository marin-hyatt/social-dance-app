//
//  APIManager.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/13/21.
//

#import "APIManager.h"
#import <SpotifyiOS/SpotifyiOS.h>

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


-(id)init {
    self = [super init];
    
    // Get keys from plist file
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    NSString *clientID = [dict objectForKey: @"client_ID"];
    NSString *secret = [dict objectForKey: @"client_Secret"];

    
    return self;
}

#pragma mark - SPTSessionManagerDelegate

- (void)sessionManager:(SPTSessionManager *)manager didInitiateSession:(SPTSession *)session {
    NSLog(@"success: %@", session);
}

- (void)sessionManager:(SPTSessionManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"fail: %@", error);
}

- (void)sessionManager:(SPTSessionManager *)manager didRenewSession:(SPTSession *)session {
    NSLog(@"renewed: %@", session);
}

-(void)openSpotify {
    NSURL *tokenSwapURL = [NSURL URLWithString:@"https://social-dance-app.herokuapp.com/api/token"];
    NSURL *tokenRefreshURL = [NSURL URLWithString:@"https://social-dance-app.herokuapp.com/api/refresh_token"];

    self.configuration.tokenSwapURL = tokenSwapURL;
    self.configuration.tokenRefreshURL = tokenRefreshURL;
    self.configuration.playURI = @"";

    self.sessionManager = [[SPTSessionManager alloc] initWithConfiguration:self.configuration delegate:self];

    // Go to authorization screen
    SPTScope requestedScope = SPTAppRemoteControlScope;
    [self.sessionManager initiateSessionWithScope:requestedScope options:SPTDefaultAuthorizationOption];
    
    
}

// When user returns to app, notify session manager
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    [self.sessionManager application:app openURL:url options:options];
    return true;
}


@end
