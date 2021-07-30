//
//  TutorialSettingViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import "TutorialSettingViewController.h"
#import "TutorialSettingView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface TutorialSettingViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *mirrorVideoSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *videoSpeedControl;
@property (strong, nonatomic) IBOutlet TutorialSettingView *tutorialSettingView;

@end

@implementation TutorialSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mirrorVideoSwitch.on = self.isMirrored;
    
    if (self.videoSpeedMutliplier == 0.25) {
        self.videoSpeedControl.selectedSegmentIndex = 0;
    } else if (self.videoSpeedMutliplier == 0.5) {
        self.videoSpeedControl.selectedSegmentIndex = 1;
    } else if (self.videoSpeedMutliplier == 0.75) {
        self.videoSpeedControl.selectedSegmentIndex = 2;
    } else {
        self.videoSpeedControl.selectedSegmentIndex = 3;
    }
    
    self.tutorialSettingView.beginningMinuteField.delegate = self;
    self.tutorialSettingView.beginningSecondField.delegate = self;
    self.tutorialSettingView.endMinuteField.delegate = self;
    self.tutorialSettingView.endSecondField.delegate = self;
}

- (IBAction)onMirrorVideoSwitchChanged:(id)sender {
    self.isMirrored = self.mirrorVideoSwitch.on;
    
    [self.delegate mirrorVideoChangedWithNewValue:self.isMirrored];
}

- (IBAction)onVideoSpeedControlChanged:(UISegmentedControl *)sender {
    if (self.videoSpeedControl.selectedSegmentIndex == 0) {
        self.videoSpeedMutliplier = 0.25;
    } else if (self.videoSpeedControl.selectedSegmentIndex == 1) {
        self.videoSpeedMutliplier = 0.5;
    } else if (self.videoSpeedControl.selectedSegmentIndex == 2) {
        self.videoSpeedMutliplier = 0.75;
    } else {
        self.videoSpeedMutliplier = 1;
    }
    
    [self.delegate videoSpeedChangedWithNewMultiplier:self.videoSpeedMutliplier];
}

- (void)updateStartTime {
    float startTimeInSeconds = [self.tutorialSettingView.beginningMinuteField.text floatValue] * 60 + [self.tutorialSettingView.beginningSecondField.text floatValue];
    NSLog(@"%f", startTimeInSeconds);
    CMTime startTime = CMTimeMakeWithSeconds(startTimeInSeconds, NSEC_PER_SEC);
    NSLog(@"%f", CMTimeGetSeconds(startTime));
    self.startTime = startTime;
    NSLog(@"%f", CMTimeGetSeconds(self.startTime));
    [self.delegate startTimeChangedToTime:self.startTime];
}

- (void)updateEndTime {
    float endTimeInSeconds = [self.tutorialSettingView.endMinuteField.text floatValue] * 60 + [self.tutorialSettingView.endSecondField.text floatValue];
    CMTime endTime = CMTimeMakeWithSeconds(endTimeInSeconds, NSEC_PER_SEC);
    self.endTime = endTime;
    [self.delegate endTimeChangedToTime:self.endTime];
    NSLog(@"%f", endTimeInSeconds);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        [self updateStartTime];
    } else {
        [self updateEndTime];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
