//
//  UIManager.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/26/21.
//

#import <Foundation/Foundation.h>
#import "UIImageView+AFNetworking.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIManager : NSObject
+ (void)updateProfilePicture:(UIImageView *)profilePictureView withPFFileObject:(PFFileObject *)file;
+ (void)presentAlertWithMessage:(NSString *)message overViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
