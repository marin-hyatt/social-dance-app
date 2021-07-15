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
    
    self.clientID = [dict objectForKey: @"client_ID"];
    self.clientSecret = [dict objectForKey: @"client_Secret"];
    
    self.tokenSwapURL = [NSURL URLWithString:@"https://social-dance-app.herokuapp.com/api/token"];
    self.tokenRefreshURL = [NSURL URLWithString:@"https://social-dance-app.herokuapp.com/api/refresh_token"];
    self.configuration.tokenSwapURL = self.tokenSwapURL;
    self.configuration.tokenRefreshURL = self. tokenRefreshURL;
    self.configuration.playURI = @"spotify:track:20I6sIOMTCkB6w7ryavxtO";


    // Initialize app remote
    self.appRemote = [[SPTAppRemote alloc] initWithConfiguration:self.configuration logLevel:SPTAppRemoteLogLevelDebug];
    self.appRemote.delegate = self;
    
    return self;
}

#pragma mark - SPTAppRemoteDelegate

- (void)appRemoteDidEstablishConnection:(SPTAppRemote *)appRemote {
    NSLog(@"connected");
    // Connection was successful, you can begin issuing commands
      self.appRemote.playerAPI.delegate = self;
      [self.appRemote.playerAPI subscribeToPlayerState:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
          NSLog(@"error: %@", error.localizedDescription);
        }
      }];
}

- (void)appRemote:(SPTAppRemote *)appRemote didDisconnectWithError:(NSError *)error {
    NSLog(@"disconnected");
}

- (void)appRemote:(SPTAppRemote *)appRemote didFailConnectionAttemptWithError:(NSError *)error {
    NSLog(@"failed");
}

- (void)playerStateDidChange:(id<SPTAppRemotePlayerState>)playerState {
    NSLog(@"player state changed");
    NSLog(@"Track name: %@", playerState.track.name);
}

#pragma mark - SPTSessionManagerDelegate

- (void)sessionManager:(SPTSessionManager *)manager didInitiateSession:(SPTSession *)session {
    NSLog(@"success: %@", session);
    self.appRemote.connectionParameters.accessToken = session.accessToken;
    NSLog(@"Access token: %@", self.appRemote.connectionParameters.accessToken);
    [self.appRemote connect];
}

- (void)sessionManager:(SPTSessionManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"fail: %@", error);
}

- (void)sessionManager:(SPTSessionManager *)manager didRenewSession:(SPTSession *)session {
    NSLog(@"renewed: %@", session);
}

- (void)applicationWillResignActive:(UIApplication *)application {
  if (self.appRemote.isConnected) {
    [self.appRemote disconnect];
  }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (self.appRemote.connectionParameters.accessToken) {
    [self.appRemote connect];
  }
}

-(void)exchangeCodeForAccessTokenWithCode:(NSString *)code withCompletion:(void (^)(NSDictionary *, NSError *))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.tokenSwapURL];
    [request setHTTPMethod:@"POST"];
    
    NSURLComponents *components = [NSURLComponents new];
    NSURLQueryItem *grant_type = [NSURLQueryItem queryItemWithName:@"grant_type" value:@"authorization_code"];
    NSURLQueryItem *codeQuery = [NSURLQueryItem queryItemWithName:@"code" value:code];
    NSURLQueryItem *redirect_uri = [NSURLQueryItem queryItemWithName:@"redirect_uri" value:@"social-dance-app://social-dance-app-callback"];
    [components setQueryItems:@[grant_type, codeQuery, redirect_uri]];
    
    NSData *encodedQuery = [components.query dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clientIdAndSecret = [[NSString stringWithFormat: @"%@:%@", self.clientID, self.clientSecret] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedAuth = [clientIdAndSecret base64EncodedStringWithOptions:0];
    NSString *encodedAuthBasic = [NSString stringWithFormat:@"Basic: %@", encodedAuth];
    
    [request setHTTPBody:encodedQuery];
    [request setValue:@"application/x-www-form-urlencoded " forHTTPHeaderField:@"Content-Type"];
    [request setValue:encodedAuthBasic forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            // Once access token and other info is received, cache it
            [self cacheTokenWithDictionary:dataDictionary];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
}

- (void)cacheTokenWithDictionary:(NSDictionary *)dataDictionary {
    [NSUserDefaults.standardUserDefaults setValue:dataDictionary[@"access_token"] forKey:@"access_token"];
    [NSUserDefaults.standardUserDefaults setValue:dataDictionary[@"refresh_token"] forKey:@"refresh_token"];
    
    NSLog(@"Expiration interval when caching: %@", dataDictionary[@"expires_in"]);
    NSLog(@"Expiration date when caching: %@", [NSDate.now dateByAddingTimeInterval:[dataDictionary[@"expires_in"] doubleValue]]);
    
    [NSUserDefaults.standardUserDefaults setValue:[NSDate.now dateByAddingTimeInterval:[dataDictionary[@"expires_in"] doubleValue]] forKey:@"expiration_date"];
    
    NSLog(@"Cached expiration date: %@", [NSUserDefaults.standardUserDefaults objectForKey:@"expiration_date"]);
    
    /*
    [self.cache setValue:dataDictionary[@"access_token"] forKey:@"access_token"];
    [self.cache setValue:dataDictionary[@"refresh_token"] forKey:@"refresh_token"];
    [self.cache setValue:[NSDate.now dateByAddingTimeInterval:[dataDictionary[@"expires_in"] doubleValue]] forKey:@"expiration_date"];
     */
    
}


-(void)openSpotify {
    self.sessionManager = [[SPTSessionManager alloc] initWithConfiguration:self.configuration delegate:self];

    // Go to authorization screen
    SPTScope requestedScope = SPTAppRemoteControlScope;
    [self.sessionManager initiateSessionWithScope:requestedScope options:SPTDefaultAuthorizationOption];
    
    
    NSString *base = @"https://accounts.spotify.com/authorize";
    NSString *scope = @"user-read-recently-played";
    NSString *redirectURI = @"social-dance-app://social-dance-app-callback";
    NSString *signInString = [NSString stringWithFormat:@"%@?response_type=code&client_id=%@&scope=%@&redirect_uri=%@", base, self.clientID, scope, redirectURI];
    
    NSLog(@"%@", signInString);
    

    
//    /*
//     Start the authorization process. This requires user input.
//     */
//    SPTScope scope = SPTUserLibraryReadScope | SPTPlaylistReadPrivateScope;
//    if (@available(iOS 11, *)) {
//        // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
//        [self.sessionManager initiateSessionWithScope:scope options:SPTDefaultAuthorizationOption];
//    } else {
//        // Use this on iOS versions < 11 to use SFSafariViewController
//        [self.sessionManager initiateSessionWithScope:scope options:SPTDefaultAuthorizationOption presentingViewController:self];
//    }
    
}

-(NSString *)accessToken {
    
    /*
    
//    // Swapping code for access_token
//    NSURL *swapServiceURL = [NSURL URLWithString:<#(nonnull NSString *)#>:@"https://social-dance-app.herokuapp.com/api/token"];
//
//    [SPTAuth handleAuthCallbackWithTriggeredAuthURL:url
//            tokenSwapServiceEndpointAtURL:swapServiceURL
//            callback:callback];

    
//    NSLog(@"Access token: %@", self.appRemote.connectionParameters.accessToken);
    
    // Set up request
    NSURL *url = [NSURL URLWithString:@"https://accounts.spotify.com/api/token"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    NSData *encoded = [[NSString stringWithFormat: @"%@:%@", self.clientID, self.clientSecret] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *spotifyAuthKey = [NSString stringWithFormat: @"Basic: %@", encoded];
    [urlRequest setValue:spotifyAuthKey forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    

    // Make request
    NSURLComponents *requestBodyComponents = [NSURLComponents new];
    [[requestBodyComponents setQueryItems:[NSURLQueryItem queryItemWithName:@"client_id" value:self.clientID], [NSURLQueryItem queryItemWithName:@"grant_type" value:@"authorization_code"], [NSURLQueryItem queryItemWithName:@"code" value:]] ]
    
    requestBodyComponents.queryItems = [URLQueryItem(name: "client_id", value: spotifyClientId), URLQueryItem(name: "grant_type", value: "authorization_code"), URLQueryItem(name: "code", value: responseTypeCode!), URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString), URLQueryItem(name: "code_verifier", value: codeVerifier), URLQueryItem(name: "scope", value: scopeAsString),]
    
    [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    NSLog(@"%@", spotifyAuthKey);
     
     */
    
    
    return [NSUserDefaults.standardUserDefaults stringForKey:@"access_token"];
//    return [self.cache objectForKey:@"access_token"];
    
}

- (NSString *)refreshToken {
    return [NSUserDefaults.standardUserDefaults stringForKey:@"refresh_token"];
//    return [self.cache objectForKey:@"refresh_token"];
}

- (NSDate *)expirationDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSLog(@"Expiration date: %@", [NSUserDefaults.standardUserDefaults stringForKey:@"expiration_date"]);
//    NSLog(@"Formatted expiration date: %@", [dateFormatter dateFromString:[NSUserDefaults.standardUserDefaults stringForKey:@"expiration_date"]]);
    return [NSUserDefaults.standardUserDefaults objectForKey:@"expiration_date"];
//    return [dateFormatter dateFromString:[self.cache objectForKey:@"expiration_date"]];
}

- (BOOL)shouldRefreshToken {
    // Should refresh token when it is 5 min away from expiring
    [self printUserDefaults];
//    NSLog(@"Access token: %@", [self.cache objectForKey:@"access_token"]);
    NSDate *currentDate = [NSDate now];
    double fiveMinutes = 300;
    return [currentDate dateByAddingTimeInterval:fiveMinutes] >= self.expirationDate;
}

// Debugging method
-(void)printUserDefaults {
    NSLog(@"Expiration date: %@", self.expirationDate);
    NSLog(@"Access token: %@", self.accessToken);
    NSLog(@"Refresh token: %@", self.refreshToken);
}

// When user returns to app, notify session manager
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [self.sessionManager application:app openURL:url options:options];
    return true;
}


@end
