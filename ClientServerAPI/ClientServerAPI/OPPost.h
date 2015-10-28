//
//  OPPost.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPServerObject.h"
#import <UIKit/UIKit.h>

@class OPUser;
@class OPGroup;

@interface OPPost : OPServerObject

@property (assign, nonatomic) NSInteger postID;

@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) NSInteger likesCount;
@property (assign, nonatomic) BOOL isLiked;

@property (assign, nonatomic) NSInteger commentsCount;

@property (assign, nonatomic) NSInteger postDate;
@property (assign, nonatomic) NSInteger ownerID;

@property (strong, nonatomic) OPUser *postOwnerUser;
@property (strong, nonatomic) OPGroup *postOwnerGroup;

@property (assign, nonatomic) NSInteger copyPostDate;
@property (assign, nonatomic) NSInteger copyOwnerID;
@property (strong, nonatomic) OPUser *postCopyOwnerUser;
@property (strong, nonatomic) OPGroup *postCopyOwnerGroup;

@property (strong, nonatomic) NSString *repostText;

@property (strong, nonatomic) NSArray *attachments;
@property (strong, nonatomic) NSArray *repostAttachments;

@property (strong, nonatomic) NSArray *attachment;

- (id)initPostProfileWithServerResponse:(NSDictionary *) responseObject;

@end
