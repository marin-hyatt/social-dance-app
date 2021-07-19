//
//  PlayerView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/13/21.
//

#import "PlayerView.h"

@implementation PlayerView


- (instancetype)initWithFrame:(CGRect)frame {
    NSLog(@"Init with frame called");
    self = [super initWithFrame:frame];
    
    if (self) {
        self.player = [AVPlayer playerWithPlayerItem:nil];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        // code for looping video
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                       name:AVPlayerItemDidPlayToEndTimeNotification
                                                     object:[self.player currentItem]];
//        self.playerLayer.frame = self.bounds;
//        NSLog(@"%f",self.playerLayer.frame.size.width);
//        NSLog(@"%f",self.playerLayer.frame.size.height);
        [self.layer addSublayer:self.playerLayer];
    }
    return self;
}

- (void)layoutSubviews {
    self.playerLayer.frame = self.bounds;
    NSLog(@"%f",self.playerLayer.frame.size.width);
    NSLog(@"%f",self.playerLayer.frame.size.height);
}

-(void)setUpVideoPlayerWithUrl:(NSURL *)url {
    NSLog(@"Set up video player");
    NSLog(@"%@", self.player.currentItem);
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    NSLog(@"%@", self.player.currentItem);
    
    [self startPlayback];
}

-(void)startPlayback {
    [self.player play];
}

-(void)stopPlayback {
    [self.player pause];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

@end
