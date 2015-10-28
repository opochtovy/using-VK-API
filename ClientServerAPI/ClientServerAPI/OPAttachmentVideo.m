//
//  OPAttachmentVideo.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 19.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPAttachmentVideo.h"

@implementation OPAttachmentVideo

- (id)initWithServerResponse:(NSDictionary *) responseObject {
    
    //    self = [super init];
    self = [super initWithServerResponse:responseObject];
    
    if (self) {
        
        self.title = [responseObject objectForKey:@"title"];
        
        NSString *photo130String = [responseObject objectForKey:@"photo_130"];
        if (photo130String) {
            self.photo130URL = [NSURL URLWithString:photo130String];
        }
        
        NSString *photo320String = [responseObject objectForKey:@"photo_320"];
        if (photo320String) {
            self.photo320URL = [NSURL URLWithString:photo320String];
        }
        
        NSString *imageString = [responseObject objectForKey:@"image"];
        if (imageString) {
            self.imageURL = [NSURL URLWithString:imageString];
        }
    }
    return self;
}

@end
