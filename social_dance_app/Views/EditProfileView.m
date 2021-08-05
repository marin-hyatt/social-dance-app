//
//  EditProfileView.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/22/21.
//

#import "EditProfileView.h"
#import "UIImageView+AFNetworking.h"
#import "UIManager.h"

@implementation EditProfileView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateAppearance {
    PFFileObject *profileImage = self.user[@"profilePicture"];
    [UIManager updateProfilePicture:self.profilePictureView withPFFileObject:profileImage];
    
    self.editUsernameField.text = self.user.username;
    self.editBioField.text = self.user[@"bio"];
}

@end
