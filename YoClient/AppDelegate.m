//
//  AppDelegate.m
//  YoClient
//
//  Created by Admin on 19.03.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "NetUtils.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

NSTimer *fiveSecondTimer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void) application:application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    NSLog(@"Notified");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"We go to background");
    [self startTimedTask];
    
}

- (void)startTimedTask {
    fiveSecondTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateYoBackgroundTask) userInfo:nil repeats:YES];
}

- (void)updateYoBackgroundTask
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NetUtils getYoCount:^(NSString *data) {
            NSLog(@"Yo count: %@", data);
            NSNumberFormatter * numFormatter = [NSNumberFormatter new];
            NSNumber* yoCount = [numFormatter numberFromString:data];
            
            NSManagedObjectContext *context = [self managedObjectContext];
            NSEntityDescription *entityDesc = [NSEntityDescription
                                                    entityForName:@"YoInfo"
                                                    inManagedObjectContext:context];
            NSFetchRequest *request = [NSFetchRequest new];
            [request setEntity:entityDesc];
            NSArray *yoInfos = [context executeFetchRequest:request error: nil];
            
            NSManagedObject* yoInfo;
            if (yoInfos == nil || [yoInfos count] == 0) {
                NSLog(@"Creating default you info");
                yoInfo = [NSEntityDescription
                              insertNewObjectForEntityForName:@"YoInfo"
                              inManagedObjectContext:context];
                [yoInfo setValue:0 forKey:@"yoTotalCount"];
                [self saveContext];
            } else {
                yoInfo = [yoInfos firstObject];
            }
            
            NSNumber* yoOldTotalCount = [yoInfo valueForKey:@"yoTotalCount"];
            long countDelta = [yoCount longValue] - [yoOldTotalCount longValue];
            if( countDelta > 0) {
                NSLog(@"Showing. Count delta: %lu", countDelta);
                [yoInfo setValue:yoCount forKey:@"yoTotalCount"];
                [self scheduleAlarmAboutYo: [NSNumber numberWithLong: countDelta]];
                [self saveContext];
            } else {
                NSLog(@"Nothing to show");
            }
        }];
    });
}

- (void)scheduleAlarmAboutYo :(NSNumber*) newMessagesAmount {
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* oldNotifications = [app scheduledLocalNotifications];
    NSString* message = [NSString stringWithFormat: @"We have %@ new Yo for You", newMessagesAmount];
    if ([oldNotifications count] > 0) {
        [app cancelAllLocalNotifications];
    }
    
    UILocalNotification* yoNotification = [UILocalNotification new];
    yoNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    yoNotification.timeZone = [NSTimeZone defaultTimeZone];
    yoNotification.repeatInterval = 0;
    yoNotification.alertBody = message;
    [app scheduleLocalNotification:yoNotification];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"We go to foreground");
    [self stopTimedTask];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)stopTimedTask {
    if(fiveSecondTimer)
    {
        [fiveSecondTimer invalidate];
        fiveSecondTimer = nil;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"Application did become active!");
    ViewController* mainController = (ViewController*)  self.window.rootViewController;
    [mainController checkYoButton:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"We terminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
