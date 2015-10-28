//
//  OPAttachmentVideo.h
//  ClientServerAPI
//
//  Created by Oleg Pochtovy on 19.10.15.
//  Copyright © 2015 Oleg Pochtovy. All rights reserved.
//

#import "OPServerObject.h"

@interface OPAttachmentVideo : OPServerObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSURL *photo130URL;
@property (strong, nonatomic) NSURL *photo320URL;

@property (strong, nonatomic) NSURL *imageURL;

@end
