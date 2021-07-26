//
//  FollowerRelation.h
//  social_dance_app
//
//  Created by Marin Hyatt on 7/22/21.
//

#import "PFObject.h"
#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface FollowerRelation : PFObject<PFSubclassing>
@property PFUser *user;
@property PFUser *follower;

+ (void)newRelationWithUser:(PFUser *)user withFollower:(PFUser *)follower withCompletion:(PFBooleanResultBlock  _Nullable)completion;
+ (void)removeRelationWithUser:(PFUser *)user withFollower:(PFUser *)follower withCompletion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
