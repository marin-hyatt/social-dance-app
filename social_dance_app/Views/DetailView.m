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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateAppearanceWithPost:(Post *)post {
    self.usernameLabel.text = post.author.username;
    self.captionLabel.text = post.caption;
    NSLog(@"%@", post.author.username);
    self.songNameLabel.text = post[@"song"][@"title"];
    
    [self initializeVideoPlayer];
    
    PFFileObject *videoFile = post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    [self setUpVideoPlayerWithUrl:videoFileUrl];
}

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
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
//    NSLog(@"New width: %f", self.videoView.frame.size.width);
//    [self startPlayback];
    
    
    // Get dimensions of media within URL
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    // Re-configure view dimensions to dimensions of video
    [self.videoPlayerView.heightAnchor constraintEqualToConstant:track.naturalSize.height].active = YES;
    [self.videoPlayerView.heightAnchor constraintEqualToConstant:track.naturalSize.width].active = YES;

    [self.playerLayer setFrame:self.videoPlayerView.frame];
}

@end
