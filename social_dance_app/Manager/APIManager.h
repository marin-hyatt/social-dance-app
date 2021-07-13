//
//  APIManager.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/13/21.
//

#import <Foundation/Foundation.h>
#import <SpotifyiOS/SpotifyiOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject <SPTSessionManagerDelegate>
+ (instancetype)shared;
@property (nonatomic, strong) SPTSessionManager *sessionManager;
@property (nonatomic, strong) SPTConfiguration *configuration;
- (void)openSpotify;


@end

NS_ASSUME_NONNULL_END
