//
//  APHAppDelegate+APHMigration.m
//  MyHeart Counts 
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHAppDelegate+APHMigration.h"

@implementation APHAppDelegate (APHMigration)

- (BOOL) performMigrationFromOneToTwoWithError:(NSError *__autoreleasing *)error{
    
    error = nil;
    
    BOOL success = [self updateTaskScheduleToOnceWithTaskId];
    
    return success;
}

- (BOOL)updateTaskScheduleToOnceWithTaskId
{
    //Change the schedule type to Once
//    NSDictionary * schedules    = @{
//                                      @"schedules":
//                                          @[
//
//                                              @{
//                                                  @"expire"         : @"P89D",
//                                                  @"scheduleType"   : @"once",
//                                                  @"taskID"         : @"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF"
//                                              },
//
//                                              @{
//                                                  @"expire"         : @"P89D",
//                                                  @"scheduleType"   : @"once",
//                                                  @"taskID"         : @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995"
//                                              },
//                                          ]
//                                      };
//
//    [APCSchedule updateSchedulesFromJSON:schedules[@"schedules"]
//                               inContext:self.dataSubstrate.persistentContext];
    
    

    [self findScheduledTaskAndClean: @[@"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF",
                                       @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995"]];

    
    return YES;
}


- (BOOL)findScheduledTaskAndClean:(NSArray *)tasksIdentifiers {
    
    BOOL success = YES;
    
    for (NSString* identifier in tasksIdentifiers)
    {
        
        //Retrieve the reference for today and tomorrow's scheduled tasks if they exist
        NSFetchRequest * request = [APCScheduledTask request];
        request.predicate = [NSPredicate predicateWithFormat:@"task.taskID == %@", identifier];
        NSError * error;
        NSArray * scheduledTasks = [self.dataSubstrate.persistentContext executeFetchRequest:request error:&error];
        
        if (error)
        {
            APCLogError2(error);
            success = NO;
            goto errorOccurred;
        }
        
        APCScheduledTask *tempScheduledTask = nil;
        
        if (scheduledTasks.count > 0)
        {
            tempScheduledTask = [scheduledTasks firstObject];
        }
        
        //Delete all scheduled tasks that are recurring types
        for (APCScheduledTask *scheduledTask in scheduledTasks) {
            [self.dataSubstrate.persistentContext deleteObject:scheduledTask];
            
        }
        
        
        NSError* MOCError = nil;
        
        if (! [self.dataSubstrate.persistentContext save:&MOCError])
        {
            APCLogError2(MOCError);
            success = NO;
            goto errorOccurred;
        }

        
        //Update the schedule type to 'Once' from 'Recurring'
        
#warning TODO figure out how many days until expiration
        NSDictionary * schedules    = @{
                                        @"schedules":
                                            @[
                                                
                                                @{
                                                    @"expire"         : @"P89D",
                                                    @"scheduleType"   : @"once",
                                                    @"taskID"         : @"2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF"
                                                    },
                                                
                                                @{
                                                    @"expire"         : @"P89D",
                                                    @"scheduleType"   : @"once",
                                                    @"taskID"         : @"3-APHFitnessTest-00000000-1111-1111-1111-F810BE28D995"
                                                    },
                                                ]
                                        };
        
        [APCSchedule updateSchedulesFromJSON:schedules[@"schedules"]
                                   inContext:self.dataSubstrate.persistentContext];
        
        if ( [self returnAllAPCResultsWithTaskId:identifier] == nil || [self returnAllAPCResultsWithTaskId:identifier].count <= 0)
        //If there are no results update scheduled tasks as necessary
        {
            APCScheduler*       scheduler               = [[APCScheduler alloc] initWithDataSubstrate:self.dataSubstrate];
            
            scheduler.referenceRange.startDate = [[NSDate date] startOfDay];

            APCSchedule*        taskSchedule            = [APCSchedule cannedScheduleForTaskID:identifier
                                                                                     inContext:self.dataSubstrate.persistentContext];

            [scheduler updateScheduledTasksForSchedule:taskSchedule];

        }
    }
    
errorOccurred:
    
    return success;
}

- (NSArray *)returnAllAPCResultsWithTaskId:(NSString *)taskId {
    
    APCAppDelegate*     appDelegate         = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest*     request             = [APCResult request];

    
    NSPredicate*        predicate           = [NSPredicate predicateWithFormat:@"taskID == %@", taskId];
    
                        request.predicate   = predicate;
    
    NSError*            error               = nil;
    
    NSArray *           results             = [appDelegate.dataSubstrate.mainContext executeFetchRequest:request
                                                                                                   error:&error];
    
    if (error)
    {
        APCLogError2(error);
    }
    
    return results;
}

@end
