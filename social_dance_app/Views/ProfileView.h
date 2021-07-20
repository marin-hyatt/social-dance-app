//
//  ProfileView.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/20/21.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProfileView : UIView
@property PFUser *user;
-(void)updateAppearance;
@end

NS_ASSUME_NONNULL_END
