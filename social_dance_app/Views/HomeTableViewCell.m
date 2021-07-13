//
//  HomeTableViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "HomeTableViewCell.h"
#import "Parse/Parse.h"
#import "PlayerView.h"


@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.videoView = [PlayerView new];
    [self initializeVideoPlayer];
    
    // Add play/pause tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startPlayback)];
    // Attach gesture recognizer to image view and enables user interaction
    [self.videoView addGestureRecognizer:tapGestureRecognizer];
    [self.videoView setUserInteractionEnabled:YES];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.videoView.bounds;
}

-(void)initializeVideoPlayer {
    self.player = [AVPlayer playerWithPlayerItem:nil];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    // Autolayout stuff
    [self.player setExternalPlaybackVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.playerLayer.frame = self.videoView.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.playerLayer.needsDisplayOnBoundsChange = YES;
    
    // code for looping video
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(playerItemDidReachEnd:)
                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                 object:[self.player currentItem]];
    
//    CGFloat height = self.playerLayer.frame.size.height;
//    CGFloat width = self.playerLayer.frame.size.width;
//
//    [self.videoView.heightAnchor constraintEqualToConstant:height].active = YES;
//    [self.videoView.heightAnchor constraintEqualToConstant:width].active = YES;
    
    [self.videoView.layer addSublayer:self.playerLayer];
    
 
    
//    int widthRequired = self.frame.size.width;
//    self.playerLayer.frame = CGRectMake(0, 0, widthRequired, widthRequired / 1.78);
    
    // Set view width and height to correspond to video width and height
//    self.videoView.frame = CGRectMake(0, 0, self.playerLayer.frame.size.width, self.playerLayer.frame.size.height);
//    NSLog(@"Old width: %f", self.videoView.frame.size.width);
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
}

- (void)updateAppearance {
    PFUser *user = self.post[@"author"];
    
    self.usernameLabel.text = user[@"username"];
    
    PFFileObject *videoFile = self.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    [self setUpVideoPlayerWithUrl:videoFileUrl];
}

-(void)setUpVideoPlayerWithUrl:(NSURL *)url {
//    NSLog(@"Set up video player");
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
//    NSLog(@"New width: %f", self.videoView.frame.size.width);
//    [self startPlayback];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
