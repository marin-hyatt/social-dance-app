//
//  TutorialSettingViewController.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import "TutorialSettingViewController.h"

@interface TutorialSettingViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *mirrorVideoSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *videoSpeedControl;

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
