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
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSDate *expirationDate;
@property NSCache *cache;
-(BOOL)shouldRefreshToken;
-(void)exchangeCodeForAccessTokenWithCode:(NSString *)code withCompletion:(void (^)(NSDictionary *, NSError *))completion;
-(void)refreshTokenIfNeededWithCompletion:(void (^)(BOOL, NSError *))completion;
-(void)cacheTokenWithDictionary:(NSDictionary *)dataDictionary;
-(void)searchForTrackWithQuery:(NSString *)trackName withCompletion:(void (^)(NSDictionary *, NSError *))completion;


@end

NS_ASSUME_NONNULL_END
