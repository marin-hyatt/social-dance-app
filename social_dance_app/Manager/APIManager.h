//
//  APIManager.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/13/21.
//

#import <Foundation/Foundation.h>
#import <SpotifyiOS/SpotifyiOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject
+ (instancetype)shared;
@property NSURL *tokenSwapURL;
@property NSURL *tokenRefreshURL;
@property NSString *clientID;
@property NSString *clientSecret;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSDate *expirationDate;
-(BOOL)shouldRefreshToken;
-(void)exchangeCodeForAccessTokenWithCode:(NSString *)code withCompletion:(void (^)(NSDictionary *, NSError *))completion;
-(void)refreshTokenIfNeededWithCompletion:(void (^)(BOOL, NSError *))completion;
-(void)cacheTokenWithDictionary:(NSDictionary *)dataDictionary;
-(void)searchForTrackWithQuery:(NSString *)trackName withCompletion:(void (^)(NSDictionary *, NSError *))completion;


@end

NS_ASSUME_NONNULL_END
