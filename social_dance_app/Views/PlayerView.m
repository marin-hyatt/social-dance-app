//
//  PlayerView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/13/21.
//

#import "PlayerView.h"

@implementation PlayerView

/*
- (instancetype)initWithFrame:(CGRect)frame {
    NSLog(@"Init with frame called");
    self = [super initWithFrame:frame];
    if (self) {
        self.player= [AVPlayer new];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:self.playerLayer];
    }
    return self;
}

- (void)layoutSubviews {
    self.playerLayer.frame = self.layer.bounds;
}

-(void)setUpVideoPlayerWithUrl:(NSURL *)url {
    NSLog(@"Set up video player");
    NSLog(@"%@", self.player.currentItem);
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    NSLog(@"%@", self.player.currentItem);
//    NSLog(@"New width: %f", self.videoView.frame.size.width);
    [self startPlayback];
}

-(void)startPlayback {
    [self.player play];
}

-(void)stopPlayback {
    [self.player pause];
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
