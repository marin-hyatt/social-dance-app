//
//  HomeTableViewCell.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "HomeTableViewCell.h"
#import "Parse/Parse.h"


@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initializeVideoPlayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.videoView.bounds;
}

-(void)initializeVideoPlayer {
    self.player = [AVPlayer playerWithPlayerItem:nil];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    // Autolayout stuff
    [self.player setExternalPlaybackVideoGravity:AVLayerVideoGravityResizeAspect];
    self.playerLayer.frame = self.videoView.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.needsDisplayOnBoundsChange = YES;
    
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
    NSLog(@"Old width: %f", self.videoView.frame.size.width);
}


- (void)updateAppearance {
    PFUser *user = self.post[@"author"];
    
    self.usernameLabel.text = user[@"username"];
    
    PFFileObject *videoFile = self.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    [self setUpVideoPlayerWithUrl:videoFileUrl];
}

-(void)setUpVideoPlayerWithUrl:(NSURL *)url {
    NSLog(@"Set up video player");
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    NSLog(@"New width: %f", self.videoView.frame.size.width);
    [self.player play];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
