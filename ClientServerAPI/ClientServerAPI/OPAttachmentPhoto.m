//
//  OPAttachmentPhoto.m
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 18.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPAttachmentPhoto.h"

@implementation OPAttachmentPhoto

- (id)initWithServerResponse:(NSDictionary *) responseObject {
    
    //    self = [super init];
    self = [super initWithServerResponse:responseObject];
    
    if (self) {
        
        self.height = [[responseObject objectForKey:@"height"] integerValue];
        
        self.width = [[responseObject objectForKey:@"width"] integerValue];
        
        NSString *photo75String = [responseObject objectForKey:@"photo_75"];
        if (photo75String) {
            self.photo75URL = [NSURL URLWithString:photo75String];
        }
        
        NSString *photo130String = [responseObject objectForKey:@"photo_130"];
        if (photo130String) {
            self.photo130URL = [NSURL URLWithString:photo130String];
        }
        
        NSString *photo604String = [responseObject objectForKey:@"photo_604"];
        if (photo604String) {
            self.photo604URL = [NSURL URLWithString:photo604String];
        }
        
        NSString *photo807String = [responseObject objectForKey:@"photo_807"];
        if (photo807String) {
            self.photo807URL = [NSURL URLWithString:photo807String];
        }
        
        NSString *srcString = [responseObject objectForKey:@"src"];
        if (srcString) {
            self.srcURL = [NSURL URLWithString:srcString];
        }
        
        NSString *srcBigString = [responseObject objectForKey:@"src_big"];
        if (srcBigString) {
            self.srcBigURL = [NSURL URLWithString:srcBigString];
        }
    }
    return self;
}

@end
