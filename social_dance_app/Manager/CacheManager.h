//
//  CacheManager.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/22/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "PlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CacheManager : NSObject

+ (void)retrieveVideoFromCacheWithURL:(NSURL *)url withBackgroundBlock:(void (^)(AVPlayerItem *))backgroundBlock withMainBlock:(void (^)(AVPlayerItem *))mainBlock;

@end

NS_ASSUME_NONNULL_END
