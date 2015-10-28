//
//  OPPost.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 10.10.15.
//  Copyright (c) 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPPost.h"

#import "OPUser.h"
#import "OPGroup.h"
#import "OPAttachmentPhoto.h"
#import "OPAttachmentVideo.h"

#import "AFURLSessionManager.h"

@interface OPPost ()

@end

@implementation OPPost

- (id)initWithServerResponse:(NSDictionary *) responseObject {
    
    self = [super initWithServerResponse:responseObject];
    
    if (self) {
        
        self.postID = [[responseObject objectForKey:@"id"] integerValue];
        
        self.text = [responseObject objectForKey:@"text"];
        
        self.likesCount = [[[responseObject objectForKey:@"likes"] objectForKey:@"count"] integerValue];
        
        self.commentsCount = [[[responseObject objectForKey:@"comments"] objectForKey:@"count"] integerValue];
        
        self.postDate = [[responseObject objectForKey:@"date"] integerValue];
        
        self.ownerID = [[responseObject objectForKey:@"from_id"] integerValue];
        
        self.copyPostDate = [[responseObject objectForKey:@"copy_post_date"] integerValue];
        self.copyOwnerID = [[responseObject objectForKey:@"copy_owner_id"] integerValue];
        
        // replace <br> in text
        self.text = [self.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        
        // attachment
        NSMutableArray *attachment = [NSMutableArray array];
        
        NSDictionary *attachmentDict = [responseObject objectForKey:@"attachment"];
        
        NSString *type = [attachmentDict objectForKey:@"type"];
        
        NSDictionary *dict;
        
        if ([type isEqualToString:@"photo"]) {
            
            dict = [attachmentDict objectForKey:@"photo"];
            
            OPAttachmentPhoto *photo = [[OPAttachmentPhoto alloc] initWithServerResponse:dict];
            
            [attachment addObject:photo];
            
        } else if ([type isEqualToString:@"video"]) {
            
            dict = [attachmentDict objectForKey:@"video"];
            
            OPAttachmentVideo *video = [[OPAttachmentVideo alloc] initWithServerResponse:dict];
            
            [attachment addObject:video];
        }
        
        self.attachment = [attachment copy];
        
        // attachments
        NSArray *attachmentsDictArray = [responseObject objectForKey:@"attachments"];
        
        NSMutableArray *attachments = [NSMutableArray array];
        
        for (NSDictionary *attachmentDict in attachmentsDictArray) {
            
            NSString *type = [attachmentDict objectForKey:@"type"];
            
            NSDictionary *photoDict;
            
            if ([type isEqualToString:@"photo"]) {
                
                photoDict = [attachmentDict objectForKey:@"photo"];
                
                OPAttachmentPhoto *photo = [[OPAttachmentPhoto alloc] initWithServerResponse:photoDict];
                
                [attachments addObject:photo];
                
            } else if ([type isEqualToString:@"video"]) {
                
                photoDict = [attachmentDict objectForKey:@"video"];
                
                OPAttachmentVideo *video = [[OPAttachmentVideo alloc] initWithServerResponse:photoDict];
                
                [attachments addObject:video];
            }
        }
        
        self.attachments = [attachments copy];
        
    }
    
    return self;
}

// that method is needed to initialize object of class OPPost for OPPostProfileViewController
- (id)initPostProfileWithServerResponse:(NSDictionary *) responseObject {
    
    self = [super init];
    
    if (self) {
        
        self.postID = [ [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"id"] integerValue];
        
        self.text = [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"text"];
        
        NSDictionary *likesDict = [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"likes"];
        self.likesCount = [ [likesDict objectForKey:@"count"] integerValue];
        
        NSDictionary *commentsDict = [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"comments"];
        self.commentsCount = [ [commentsDict objectForKey:@"count"] integerValue];
        
        self.repostText = [ [ [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"copy_history"] firstObject] objectForKey:@"text"];
        
        self.ownerID = [ [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"from_id"] integerValue];
        
        NSDictionary *ownerDict;
        
        NSInteger userIsOwner = 0;
        
        if (self.ownerID > 0) {
            
            ownerDict = [ [responseObject objectForKey:@"profiles"] firstObject];
            
            self.postOwnerUser = [[OPUser alloc] initWithServerResponse:ownerDict];
            
            ++userIsOwner;
            
        } else if (self.ownerID < 0) {
            
            ownerDict = [ [responseObject objectForKey:@"groups"] firstObject];
            
            self.postOwnerGroup = [[OPGroup alloc] initGroupForPostProfileWithServerResponse:ownerDict];
        }
        
        self.postDate = [ [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"date"] integerValue];
        
        self.copyPostDate = [ [ [ [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"copy_history"] firstObject] objectForKey:@"date"] integerValue];
        self.copyOwnerID = [ [ [ [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"copy_history"] firstObject] objectForKey:@"from_id"] integerValue];
        
        NSDictionary *repostOwnerDict;
        
        NSInteger repostOwnerIndex = 0;
        
        if (self.copyOwnerID > 0) {
            
            if (userIsOwner) {
                ++repostOwnerIndex;
            }
            
            repostOwnerDict = [ [responseObject objectForKey:@"profiles"] objectAtIndex:repostOwnerIndex];
            
            self.postCopyOwnerUser = [[OPUser alloc] initWithServerResponse:ownerDict];
            
        } else if (self.copyOwnerID < 0) {
            
            if (!userIsOwner) {
                ++repostOwnerIndex;
            }
            
            ownerDict = [ [responseObject objectForKey:@"groups"] objectAtIndex:repostOwnerIndex];
            
            self.postCopyOwnerGroup = [[OPGroup alloc] initGroupForPostProfileWithServerResponse:ownerDict];
        }
        
        NSArray *attachmentsDictArray = [ [ [ [ [responseObject objectForKey:@"items"] firstObject] objectForKey:@"copy_history"] firstObject] objectForKey:@"attachments"];
        
        NSMutableArray *attachments = [NSMutableArray array];
        
        for (NSDictionary *attachmentDict in attachmentsDictArray) {
            
            NSString *type = [attachmentDict objectForKey:@"type"];
            
            NSDictionary *photoDict;
            
            if ([type isEqualToString:@"photo"]) {
                
                photoDict = [attachmentDict objectForKey:@"photo"];
                
                OPAttachmentPhoto *photo = [[OPAttachmentPhoto alloc] initWithServerResponse:photoDict];
                
                [attachments addObject:photo];
                
            } else if ([type isEqualToString:@"video"]) {
                
                photoDict = [attachmentDict objectForKey:@"video"];
                
                OPAttachmentVideo *video = [[OPAttachmentVideo alloc] initWithServerResponse:photoDict];
                
                [attachments addObject:video];
            }
        }
        
        self.attachments = [attachments copy];
        
    }
    
    return self;
}

@end
