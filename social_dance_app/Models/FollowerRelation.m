//
//  FollowerRelation.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/22/21.
//

#import "FollowerRelation.h"

@implementation FollowerRelation

@dynamic user;
@dynamic follower;

+ (nonnull NSString *)parseClassName {
    return @"FollowerRelation";
}

+ (void)newRelationWithUser:(PFUser *)user withFollower:(PFUser *)follower withCompletion:(PFBooleanResultBlock)completion {
    FollowerRelation *relation = [FollowerRelation new];
    relation.user = user;
    relation.follower = follower;
    
    [relation saveInBackgroundWithBlock:completion];
}

@end
