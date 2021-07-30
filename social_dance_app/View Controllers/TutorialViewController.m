//
//  TutorialViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import "TutorialViewController.h"
#import "CacheManager.h"
#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "TutorialView.h"
#import "TutorialSettingViewController.h"


@interface TutorialViewController () <TutorialSettingDelegate>
@property (strong, nonatomic) IBOutlet TutorialView *tutorialView;
@property BOOL isMirrored;
@property float videoSpeedMultiplier;
@property CMTime startTime;
@property CMTime endTime;

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isMirrored = YES;
    self.videoSpeedMultiplier = 1;
    self.tutorialView.slider.value = 0;
    self.startTime = CMTimeMakeWithSeconds(0, NSEC_PER_SEC);
    
    
    [self.tutorialView updateViewWithMirrorSetting:self.isMirrored];
    self.tutorialView.playbackSpeed = 1;
    [self updateVideo];
    
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateSliderWithTimestamp:) userInfo:nil repeats:YES];
}

- (void)setStartLabel {
    NSUInteger currentTime = CMTimeGetSeconds(self.tutorialView.player.currentItem.currentTime);

    NSUInteger minutes = floor(currentTime % 3600 / 60);
    NSUInteger seconds = floor(currentTime % 3600 % 60);

    NSString *startTime = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)minutes, (unsigned long)seconds];
    
    self.tutorialView.startLabel.text = startTime;
}

- (void)setEndLabel {
    NSUInteger duration = CMTimeGetSeconds(self.tutorialView.player.currentItem.asset.duration);
    NSLog(@"%lu", (unsigned long)duration);

    NSUInteger minutes = floor(duration % 3600 / 60);
    NSUInteger seconds = floor(duration % 3600 % 60);

    NSString *endTime = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)minutes, (unsigned long)seconds];
    
    self.tutorialView.endLabel.text = endTime;
}

- (void)updateVideo {
    PFFileObject *videoFile = self.post[@"videoFile"];
    NSURL *videoFileUrl = [NSURL URLWithString:videoFile.url];
    
    [CacheManager retrieveVideoFromCacheWithURL:videoFileUrl withBackgroundBlock:^(AVPlayerItem * _Nonnull playerItem) {
    } withMainBlock:^(AVPlayerItem * _Nonnull playerItem) {
        if (self.tutorialView.player == nil) {
            self.tutorialView.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.tutorialView.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.tutorialView.player currentItem]];
            [self.tutorialView.playerView setPlayer:self.tutorialView.player];
            [(AVPlayerLayer *)[self.tutorialView.playerView layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
            [self setEndLabel];
            self.endTime = self.tutorialView.player.currentItem.duration;
        }
    }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:self.startTime completionHandler:nil];
}

- (IBAction)onSettingsButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"TutorialSettingViewController" sender:nil];
}

- (void)mirrorVideoChangedWithNewValue:(BOOL)isMirrored {
    self.isMirrored = isMirrored;
    [self.tutorialView mirrorViewWithSetting:self.isMirrored];
}

- (void)videoSpeedChangedWithNewMultiplier:(float)multiplier {
    self.videoSpeedMultiplier = multiplier;
    
    [self.tutorialView changePlaybackRateWithRate:self.videoSpeedMultiplier];
}

- (IBAction)onSliderValueChanged:(UISlider *)sender {
    // Jump to appropriate point in video
    CMTime playerDuration = self.tutorialView.player.currentItem.duration;
    
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        float minValue = [self.tutorialView.slider minimumValue];
        float maxValue = [self.tutorialView.slider maximumValue];
        float value = [self.tutorialView.slider value];
        
        double time = duration * (value - minValue) / (maxValue - minValue);
        
        if (time > CMTimeGetSeconds(self.endTime)) {
            [self.tutorialView.player seekToTime:self.endTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        } else if (time < CMTimeGetSeconds(self.startTime)) {
        } else {
            [self.tutorialView.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        
    }
    [self.tutorialView.player pause];
}


- (void)updateSliderWithTimestamp:(CMTime)timestamp {
    [self setStartLabel];
    
    if (CMTimeGetSeconds(self.tutorialView.player.currentItem.currentTime) > CMTimeGetSeconds(self.endTime)) {
        [self.tutorialView.player seekToTime:self.startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    self.tutorialView.slider.value = CMTimeGetSeconds(self.tutorialView.player.currentItem.currentTime)  / CMTimeGetSeconds(self.tutorialView.player.currentItem.duration);
}

- (void)startTimeChangedToTime:(CMTime)startTime {
    self.startTime = startTime;
    [self.tutorialView.player seekToTime:self.startTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)endTimeChangedToTime:(CMTime)endTime {
    self.endTime = endTime;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.tutorialView.player pause];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqual:@"TutorialSettingViewController"]) {
        TutorialSettingViewController *vc = [segue destinationViewController];
        vc.delegate = self;
        vc.isMirrored = self.isMirrored;
        vc.videoSpeedMutliplier = self.videoSpeedMultiplier;
    }
}


@end
