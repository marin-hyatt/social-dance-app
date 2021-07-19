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
    self.songNameLabel.text = post[@"song"][@"title"];
    
    self.albumImageView.image = nil;
    
    if (post.song.albumImageURLString != nil) {
        [self.albumImageView setImageWithURL: [NSURL URLWithString:post.song.albumImageURLString]];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    [self.videoPlayerView addGestureRecognizer:tapGestureRecognizer];
    [self.videoPlayerView setUserInteractionEnabled:YES];
    
    [self.videoPlayerView setPlayer:[AVPlayer playerWithPlayerItem:nil]];
    
    
    PFFileObject *videoFile = post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
//    [self.videoPlayerView setUpVideoPlayerWithUrl:videoFileUrl];
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
        
        // save the NSData to that URL
        NSError *fileError;
        [data writeToURL:fileURL options:0 error:&fileError];
        
        // give player the video with that file URL
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            // code for looping video
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.player currentItem]];
            [self.videoPlayerView setPlayer:self.player];
        });
    }];
    [task resume];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:videoFileUrl]];
//        [self.videoPlayerView setPlayer:self.player];
////        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:videoFile.url]];
//    });
//    [self setUpVideoPlayerWithUrl:videoFileUrl];

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

/*
- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.videoPlayerView.bounds;
}

-(void)initializeVideoPlayer {
    self.player = [AVPlayer playerWithPlayerItem:nil];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    

    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.player.volume = 3;
    
    NSLog(@"Player layer height: %f width: %f", self.playerLayer.frame.size.height, self.playerLayer.frame.size.width);
    
    // code for looping video
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(playerItemDidReachEnd:)
                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                 object:[self.player currentItem]];
    
    [self.videoPlayerView.layer addSublayer:self.playerLayer];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

-(void)setUpVideoPlayerWithUrl:(NSURL *)url {
//    NSLog(@"Set up video player");
    
    // TODO: use multithreading to get the video from url
//    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error != nil || data == nil) {
//            NSLog(@"Error: %@",  error.localizedDescription);
//        } else {
//            NSLog(@"Success");
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
//            }];
//        }
//    }];
//    [task resume];
    
//    NSLog(@"New width: %f", self.videoView.frame.size.width);
//    [self startPlayback];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    });
    
    
    
    // Get dimensions of media within URL
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    // Re-configure view dimensions to dimensions of video
    [self.videoPlayerView.heightAnchor constraintEqualToConstant:track.naturalSize.height].active = YES;
    [self.videoPlayerView.heightAnchor constraintEqualToConstant:track.naturalSize.width].active = YES;

    [self.playerLayer setFrame:self.videoPlayerView.frame];
}

-(void)startPlayback {
    NSLog(@"Playback time");
    if (self.player.rate != 0) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

-(void)stopPlayback {
    [self.player pause];
}
*/

@end
