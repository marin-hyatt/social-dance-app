//
//  TutorialSettingView.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TutorialSettingView : UIView
@property (weak, nonatomic) IBOutlet UITextField *beginningMinuteField;
@property (weak, nonatomic) IBOutlet UITextField *beginningSecondField;
@property (weak, nonatomic) IBOutlet UITextField *endMinuteField;
@property (weak, nonatomic) IBOutlet UITextField *endSecondField;


@end

NS_ASSUME_NONNULL_END
