//
//  CacheManager.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/22/21.
//

#import "CacheManager.h"



@implementation CacheManager

+ (void)retrieveVideoFromCacheWithURL:(NSURL *)url withBackgroundBlock:(void (^)(AVPlayerItem * _Nonnull))backgroundBlock withMainBlock:(void (^)(AVPlayerItem * _Nonnull))mainBlock {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // generate a temporary file URL
        NSString *filename = [[NSUUID UUID] UUIDString];
        NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *fileURL = [[temporaryDirectoryURL URLByAppendingPathComponent:filename] URLByAppendingPathExtension:@"mp4"];

        NSError *fileError;
        [data writeToURL:fileURL options:0 error:&fileError];
        
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        backgroundBlock(playerItem);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mainBlock(playerItem);
        });
    }];
    [task resume];
}


@end
