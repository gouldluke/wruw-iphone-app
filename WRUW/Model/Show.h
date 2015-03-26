//
//  Show.h
//  WRUWShowTest
//
//  Created by Nick Jordan on 11/14/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LoadShowBlock)();

@interface Show : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *lastShowUrl;
@property (nonatomic, copy) NSString *day;
@property (nonatomic, copy) NSString *infoDescription;

- (void)loadInfo:(LoadShowBlock)successBlock;

@end