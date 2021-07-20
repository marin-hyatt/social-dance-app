//
//  DetailView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "DetailView.h"
#import "UIImageView+AFNetworking.h"
#import "Parse/Parse.h"


@implementation DetailView

- (void)updateAppearanceWithPost:(Post *)post {
    self.usernameLabel.text = post.author.username;
    self.captionLabel.text = post.caption;
    
    if (post.song == nil) {
        [self.songView setHidden:YES];
    } else {
        self.songNameLabel.text = post[@"song"][@"title"];
        
        self.albumImageView.image = nil;
        
        if (post.song.albumImageURLString != nil) {
            [self.albumImageView setImageWithURL: [NSURL URLWithString:post.song.albumImageURLString]];
        }
    }
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    [self.videoPlayerView addGestureRecognizer:tapGestureRecognizer];
    [self.videoPlayerView setUserInteractionEnabled:YES];
    
    [self.videoPlayerView setPlayer:[AVPlayer playerWithPlayerItem:nil]];
    
    
    PFFileObject *videoFile = post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:videoFileUrl];
    
    // As I understand it, the task runs on a background thread
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // generate a temporary file URL
        NSString *filename = [[NSUUID UUID] UUIDString];
        
        NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *fileURL = [[temporaryDirectoryURL URLByAppendingPathComponent:filename] URLByAppendingPathExtension:@"mp4"];

        NSError *fileError;
        [data writeToURL:fileURL options:0 error:&fileError];

        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.player currentItem]];
            [self.videoPlayerView setPlayer:self.player];
        });
    }];
    [task resume];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

-(void)startPlayback {
    if (self.player.rate != 0) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

@end
