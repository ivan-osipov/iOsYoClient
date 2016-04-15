//
//  ViewController.m
//  YoClient
//
//  Created by Admin on 19.03.16.
//  Copyright © 2016 Admin. All rights reserved.
//
@import Foundation;
#import "ViewController.h"
#import "NetUtils.h"
#import <CoreData/CoreData.h>

@interface ViewController ()
@end

@implementation ViewController

typedef void (^ResponseHandler)(NSString* data);

- (IBAction)checkYoButton:(UIButton *)sender {
    ResponseHandler handler = ^(NSString* data) {
        if([data length]) {
            [self showInAppNotification : @"Yo notification" : data : @"Like a boss"];
            
            NSManagedObjectContext *context = [self managedObjectContext];
            NSEntityDescription *entityDesc = [NSEntityDescription
                                               entityForName:@"YoInfo"
                                               inManagedObjectContext:context];
            NSFetchRequest *request = [NSFetchRequest new];
            [request setEntity:entityDesc];
            NSArray *yoInfos = [context executeFetchRequest:request error: nil];
            
            NSManagedObject* yoInfo = [yoInfos firstObject];
            [yoInfo setValue:0 forKey:@"yoTotalCount"];
            [context save: nil];
        }
        else {
            [self showInAppNotification:@"Yo notification" :@"Sorry, no Yos for you" : @"Okay :("];
        }
    };
    [NetUtils getYoTimestamps:handler];
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showInAppNotification :(NSString*) title :(NSString*) msg :(NSString*) okButtonLabel {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle: title
                                      message:msg
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:okButtonLabel
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

@end
