#import <Foundation/Foundation.h>

@interface NetUtils : NSObject

typedef void (^ResponseHandler)(NSString* data);

+ (void) getYoCount:(ResponseHandler) handler;
+ (void) getYoTimestamps:(ResponseHandler) handler;

@end
