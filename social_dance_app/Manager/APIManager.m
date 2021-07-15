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
    
//    self.tokenSwapURL = [NSURL URLWithString:@"https://accounts.spotify.com/api/token"];
    self.tokenSwapURL = [NSURL URLWithString:@"https://social-dance-app.herokuapp.com/api/token"];
    self.tokenRefreshURL = [NSURL URLWithString:@"https://social-dance-app.herokuapp.com/api/refresh_token"];
    
    return self;
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
    
    NSLog(@"Request: %@", request);
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", dataDictionary);
            // Once access token and other info is received, cache it
            [self cacheTokenWithDictionary:dataDictionary];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
}

- (void)cacheTokenWithDictionary:(NSDictionary *)dataDictionary {
    NSLog(@"%@", dataDictionary[@"access_token"]);
    [NSUserDefaults.standardUserDefaults setValue:dataDictionary[@"access_token"] forKey:@"access_token"];
    
    
    if ([dataDictionary objectForKey:@"refresh_token"]) {
        [NSUserDefaults.standardUserDefaults setValue:dataDictionary[@"refresh_token"] forKey:@"refresh_token"];
    }

    [NSUserDefaults.standardUserDefaults setValue:[NSDate.now dateByAddingTimeInterval:[dataDictionary[@"expires_in"] doubleValue]] forKey:@"expiration_date"];
    
    /*
    [self.cache setValue:dataDictionary[@"access_token"] forKey:@"access_token"];
    [self.cache setValue:dataDictionary[@"refresh_token"] forKey:@"refresh_token"];
    [self.cache setValue:[NSDate.now dateByAddingTimeInterval:[dataDictionary[@"expires_in"] doubleValue]] forKey:@"expiration_date"];
     */
    
}

- (void)refreshTokenIfNeededWithCompletion:(void (^)(BOOL, NSError *))completion {
    if ([self shouldRefreshToken] || self.accessToken == nil) {
        // Refresh token
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.tokenRefreshURL];
        [request setHTTPMethod:@"POST"];
        
        NSURLComponents *components = [NSURLComponents new];
        NSURLQueryItem *grant_type = [NSURLQueryItem queryItemWithName:@"grant_type" value:@"refresh_token"];
        NSURLQueryItem *refresh_token = [NSURLQueryItem queryItemWithName:@"refresh_token" value:self.refreshToken];
        [components setQueryItems:@[grant_type, refresh_token]];
        NSLog(@"%@", [components query]);
        
        NSData *encodedQuery = [components.query dataUsingEncoding:NSUTF8StringEncoding];
        NSData *clientIdAndSecret = [[NSString stringWithFormat: @"%@:%@", self.clientID, self.clientSecret] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedAuth = [clientIdAndSecret base64EncodedStringWithOptions:0];
        NSString *encodedAuthBasic = [NSString stringWithFormat:@"Basic %@", encodedAuth];
        
        [request setHTTPBody:encodedQuery];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:encodedAuthBasic forHTTPHeaderField:@"Authorization"];
        
        NSLog(@"Request: %@", request);
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                completion(false, error);
            } else {
                NSLog(@"%@", response);
                NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                // Once access token and other info is received, cache it
                [self cacheTokenWithDictionary:dataDictionary];
                completion(true, nil);
            }
        }];
        [task resume];
    }
    NSLog(@"No refresh needed!");
    completion(true, nil);
}

- (void)searchForTrackWithQuery:(NSString *)trackName withCompletion:(void (^)(NSDictionary *, NSError *))completion {
    // Pass in query to search
    NSURL *searchWithQuery = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@&type=track", trackName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:searchWithQuery];
    [request setHTTPMethod:@"GET"];
    NSString *accessTokenForHeader = [NSString stringWithFormat:@"Bearer %@", self.accessToken];
    [request setValue:accessTokenForHeader forHTTPHeaderField:@"Authorization"];
    
    // Make request
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            completion(nil, error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
    
}


-(NSString *)accessToken {
    return [NSUserDefaults.standardUserDefaults stringForKey:@"access_token"];
//    return [self.cache objectForKey:@"access_token"];
    
}

- (NSString *)refreshToken {
    return [NSUserDefaults.standardUserDefaults stringForKey:@"refresh_token"];
//    return [self.cache objectForKey:@"refresh_token"];
}

- (NSDate *)expirationDate {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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


@end
