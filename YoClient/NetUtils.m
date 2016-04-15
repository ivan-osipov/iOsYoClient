//
//  NetUtils.m
//  YoClient
//
//  Created by Admin on 02.04.16.
//  Copyright © 2016 Admin. All rights reserved.
//
#import "NetUtils.h"

@implementation NetUtils

static NSString* const SERVER_ADDRESS = @"http://192.168.0.86:8080";

+ (void) getYoCount:(ResponseHandler) handler {
    NSMutableString* url = [NSMutableString new];
    [url appendString: SERVER_ADDRESS];
    [url appendString: @"/yo/count"];
    
    [NetUtils getAsyncDataFromUrl:url :handler];
}

+ (void) getYoTimestamps:(ResponseHandler) handler {
    NSMutableString* url = [NSMutableString new];
    [url appendString: SERVER_ADDRESS];
    [url appendString: @"/yo"];
    
    [NetUtils getAsyncDataFromUrl:url :handler];
}

+ (void) getAsyncDataFromUrl:(NSString *)url:(ResponseHandler) handler{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData* data,
                                NSURLResponse* responce,
                                NSError* error) {
                NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                handler(response);
            }] resume];
    
}

@end