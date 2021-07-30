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

    NSArray *startPlaceholder = [self.startTimePlaceholder componentsSeparatedByString:@":"];
    self.tutorialSettingView.beginningMinuteField.placeholder = startPlaceholder[0];
    self.tutorialSettingView.beginningSecondField.placeholder = startPlaceholder[1];
    
    NSArray *endPlaceholder = [self.endTimePlaceholder componentsSeparatedByString:@":"];
    self.tutorialSettingView.endMinuteField.placeholder = endPlaceholder[0];
    self.tutorialSettingView.endSecondField.placeholder = endPlaceholder[1];
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
 
    CMTime startTime = CMTimeMakeWithSeconds(startTimeInSeconds, NSEC_PER_SEC);

    [self.delegate startTimeChangedToTime:startTime];
}

- (void)updateEndTime {
    float endTimeInSeconds = [self.tutorialSettingView.endMinuteField.text floatValue] * 60 + [self.tutorialSettingView.endSecondField.text floatValue];
    CMTime endTime = CMTimeMakeWithSeconds(endTimeInSeconds, NSEC_PER_SEC);

    [self.delegate endTimeChangedToTime:endTime];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        [self updateStartTime];
    } else {
        [self updateEndTime];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
        
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 2;
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
