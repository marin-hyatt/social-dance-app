//
//  APIManager.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/13/21.
//

#import <Foundation/Foundation.h>
#import <SpotifyiOS/SpotifyiOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject <SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate>
+ (instancetype)shared;
@property (nonatomic, strong) SPTSessionManager *sessionManager;
@property (nonatomic, strong) SPTConfiguration *configuration;
@property (nonatomic, strong) SPTAppRemote *appRemote;
@property NSURL *tokenSwapURL;
@property NSURL *tokenRefreshURL;
@property NSString *clientID;
@property NSString *clientSecret;
-(void)openSpotify;
-(void)getAccessToken;
-(void)exchangeCodeForAccessTokenWithCode:(NSString *)code withCompletion:(void (^)(NSDictionary *, NSError *))completion;
-(void)cacheToken;
-(void)refreshToken;


@end

NS_ASSUME_NONNULL_END
