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
    // TODO: refactor video player code to go in PlayerView?
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
    
     // TODO: Autolayout stuff
//    [self.videoView setTranslatesAutoresizingMaskIntoConstraints:NO];
    // TODO: put in completion block in main queue
//    [self.videoView addConstraint:[NSLayoutConstraint
//                                      constraintWithItem:self.videoView
//                                      attribute:NSLayoutAttributeHeight
//                                      relatedBy:NSLayoutRelationEqual
//                                      toItem:self.videoView
//                                      attribute:NSLayoutAttributeWidth
//                                      multiplier:(self.playerLayer.frame.size.height / self.playerLayer.frame.size.width)
//                                      constant:0]];
    
//    [self.player setExternalPlaybackVideoGravity:AVLayerVideoGravityResizeAspect];
//    self.playerLayer.frame = self.videoView.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.player.volume = 3;
    
    
//    self.playerLayer.needsDisplayOnBoundsChange = YES;
    
    NSLog(@"Player layer height: %f width: %f", self.playerLayer.frame.size.height, self.playerLayer.frame.size.width);
    
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
    NSLog(@"update appearance");
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
    
    
    // Get dimensions of media within URL
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    NSLog(@"Height: %f, Width: %f", track.naturalSize.height, track.naturalSize.width);
    
    // Re-configure view dimensions to dimensions of video
    [self.videoView.heightAnchor constraintEqualToConstant:track.naturalSize.height].active = YES;
    [self.videoView.heightAnchor constraintEqualToConstant:track.naturalSize.width].active = YES;

    [self.playerLayer setFrame:self.videoView.frame];

    
    NSLog(@"Rect height: %f Rect width: %f", self.playerLayer.videoRect.size.height, self.playerLayer.videoRect.size.width);
    
    NSLog(@"Player layer height: %f width: %f", self.playerLayer.frame.size.height, self.playerLayer.frame.size.width);
    
    NSLog(@"View layer height: %f width: %f", self.videoView.frame.size.height, self.videoView.frame.size.width);
    
//    [self.videoView setFrame:self.playerLayer.frame];
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
