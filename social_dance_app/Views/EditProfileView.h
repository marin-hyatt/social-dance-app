//
//  EditProfileView.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/22/21.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditProfileView : UIView
@property PFUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UITextField *editUsernameField;
- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
