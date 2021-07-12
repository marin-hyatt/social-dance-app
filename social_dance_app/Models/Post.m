//
//  Post.m
//  social_dance_app
//
//  Created by Marin Hyatt on 7/12/21.
//

#import "Post.h"
#import "Parse/Parse.h"

@implementation Post

@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic likeCount;
@dynamic commentCount;
@dynamic createdAt;
@dynamic video;
@dynamic song;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

@end
