//
//  PostUtility.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/30/21.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "PlayerView.h"
#import "UIImageView+AFNetworking.h"
#import "CacheManager.h"
#import "Comment.h"
#import "UIManager.h"
#import "DateTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostUtility : NSObject

+ (void)updateTimestampForLabel:(UILabel *)label usingPost:(Post *)post;
+ (void)updateBookmarkButton:(UIButton *)button usingPost:(Post *)post;
+ (void)updateCommentButton:(UIButton *)button withPost:(Post *)post;
+ (void)updateCommentLabel:(UILabel *)label withPost:(Post *)post;
+ (void)updateUsernameLabel:(UILabel *)label andProfilePicture:(UIImageView *)imageView WithUser:(PFUser *)user;
+ (void)updateLikeButton:(UIButton *)button withPost:(Post *)post;
+ (void)updateLikeLabel:(UILabel *)label withPost:(Post *)post;
+ (void)updateThumbnailView:(__weak UIImageView *)imageView withPost:(Post *)post;

@end

NS_ASSUME_NONNULL_END
