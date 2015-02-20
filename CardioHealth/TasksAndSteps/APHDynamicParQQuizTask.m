//
//  APHDynamicParQQuizTask.m
//  MyHeartCounts
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APHDynamicParQQuizTask.h"

static  NSString  *MainStudyIdentifier          = @"com.cardiovascular.parqquiz";
static  NSString  *kParQQuizTaskIdentifier      = @"par-q quiz";

static  NSString  *kInstructionStep         = @"instructionStep";
static  NSString  *kInstructionStep2        = @"instructionStep2";
static  NSString  *kHeartCondition          = @"heartCondition";
static  NSString  *kChestPain               = @"chestPain";
static  NSString  *kChestPainInLastMonth    = @"chestPainInLastMonth";
static  NSString  *kDizziness               = @"dizziness";
static  NSString  *kJointProblem            = @"jointProblem";
static  NSString  *kPrescriptionDrugs       = @"prescriptionDrugs";
static  NSString  *kPhysicallyCapable       = @"physicallyCapable";
static  NSString  *kStopHere                = @"stopHere";
static  NSString  *kGoodToGo                = @"goodToGo";

static NSString *const kInstructionTitle = @"Physical Activity Readiness Questionnaire: PAR-Q";

static NSString *const kInstructionDetail = @"Regular physical activity is fun and healthy, and increasingly more people are starting to become more active every day. Being more active is very safe for most people. However, some people should check with their doctor before they start becoming much more physically active.\n\nSource:  Canadian Society for Exercise Physiology, © 2012. Used with permission.";

static NSString *const kInstruction2Title = @"Physical Activity Readiness Questionnaire: PAR-Q";

static NSString *const kInstruction2Detail = @"If you are planning to become much more physically active than you are now, start by answering the seven questions on the following screens. If you are between the ages of 15 and 69, the PAR-Q will tell you if you should check with your doctor before you start. If you are over 69 years of age, and you are not used to being very active, check with your doctor. Common sense is your best guide when you answer these questions. Please read the questions carefully and answer each one honestly: check YES or NO.";



static NSString *const kHeartConditionTitle         = @"Has your doctor ever said that you have a heart condition and that you should only do physical activity recommended by a doctor?";

static  NSString  *const kChestPainTitle            = @"Do you feel pain in your chest when you do physical activity?";

static  NSString  *const kChestPainInLastMonthTitle = @"In the past month, have you had chest pain when you were not doing physical activity?";

static  NSString  *const kDizzinessTitle            = @"Do you lose your balance because of dizziness or do you ever lose consciousness?";

static  NSString  *const kJointProblemTitle         = @"Do you have a bone or joint problem (for example, back, knee or hip) that could be made worse by a change in your physical activity?";

static  NSString  *const kPrescriptionDrugsTitle    = @"Is your doctor currently prescribing drugs (for example, water pills) for your blood pressure or heart condition?";

static  NSString  *const kPhysicallyCapableTitle    = @"Do you know of any other reason why you should not do physical activity?";

static  NSString  *const kStopHereTitle = @"If you answered YES to one or more questions";

static  NSString  *const kStopHereDetail = @"Talk with your doctor by phone or in person BEFORE you start becoming much more physically active or BEFORE you have a fitness appraisal. Tell your doctor about the PAR-Q and which questions you answered YES.\nYou may be able to do any activity you want — as long as you start slowly and build up gradually. Or, you may need to restrict your activities to those which are safe for you. Talk with your doctor about the kinds of activities you wish to participate in and follow his/her advice.";

static  NSString  *const kGoodToGoTitle = @"If you answered NO to all questions, you can reasonably be sure that you can:";

static  NSString  *const kGoodToGoDetail = @"• start becoming much more physically active – begin slowly and build up gradually. This is the safest and easiest way to go.\n\n• take part in a fitness appraisal – this is an excellent way to determine your basic fitness so that you can plan the best way for you to live actively. It is also highly recommended that you have your blood pressure evaluated. If your reading is over 144/94, talk with your doctor before you start becoming much more physically active.\n\nDELAY BECOMING MUCH MORE ACTIVE\n • if you are not feeling well because of a temporary illness such as a cold or a fever – wait until you feel better; or\n• if you are or may be pregnant – talk to your doctor before you start becoming more active.\n\n PLEASE NOTE: If your health changes so that you then answer YES to any of the above questions, tell your fitness or health professional. Ask whether you should change your physical activity plan.\n\n";

typedef NS_ENUM(NSUInteger, APHDynamicParQQuizType) {
    ParQQuizTypeInstructionStep = 0,
    ParQQuizTypeInstructionStep2,
    ParQQuizTypeHeartCondition,
    ParQQuizTypeChestPain,
    ParQQuizTypeChestPainInLastMonth,
    ParQQuizTypeDizziness,
    ParQQuizTypeJointProblem,
    ParQQuizTypePrescriptionDrugs,
    ParQQuizTypePhysicallyCapable,
    ParQQuizTypeStopHere,
    ParQQuizTypeGoodToGo,
    ParQQuizTypeFinal,
};

@interface APHDynamicParQQuizTask()
@property (nonatomic, strong) NSDictionary *keys;
@property (nonatomic, strong) NSDictionary *backwardKeys;

@property (nonatomic) NSInteger currentState;
@property (nonatomic, strong) NSDictionary *currentOrderedSteps;


@end

@implementation APHDynamicParQQuizTask 

- (instancetype) init {
    

    
    NSMutableArray *steps = [NSMutableArray array];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kInstructionStep];
        step.title = NSLocalizedString(kInstructionTitle, kInstructionTitle);
        step.detailText = NSLocalizedString(kInstructionDetail, kInstructionDetail);
        
        
        
        [steps addObject:step];
    }
    
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kInstructionStep2];
        step.title = NSLocalizedString(kInstruction2Title, kInstruction2Title);
        step.detailText = NSLocalizedString(kInstruction2Detail, kInstruction2Detail);
        
        
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kHeartCondition title:NSLocalizedString(kHeartConditionTitle, kHeartConditionTitle) answer:[ORKBooleanAnswerFormat new]];
        
        
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kChestPain title:NSLocalizedString(kChestPainTitle, kChestPainTitle) answer:[ORKBooleanAnswerFormat new]];
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kChestPainInLastMonth title:NSLocalizedString(kChestPainInLastMonthTitle, kChestPainInLastMonthTitle) answer:[ORKBooleanAnswerFormat new]];
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kDizziness title:NSLocalizedString(kDizzinessTitle, kDizzinessTitle) answer:[ORKBooleanAnswerFormat new]];
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kJointProblem title:NSLocalizedString(kJointProblemTitle, kJointProblemTitle) answer:[ORKBooleanAnswerFormat new]];
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kPrescriptionDrugs title:NSLocalizedString(kPrescriptionDrugsTitle, kPrescriptionDrugsTitle) answer:[ORKBooleanAnswerFormat new]];
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:kPhysicallyCapable title:NSLocalizedString(kPhysicallyCapableTitle, kPhysicallyCapableTitle) answer:[ORKBooleanAnswerFormat new]];
        
        step.optional = NO;
        
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kStopHere];
        step.title = NSLocalizedString( kStopHereTitle, kStopHereTitle);;
        step.detailText = NSLocalizedString( kStopHereDetail, kStopHereDetail);;
        
        
        [steps addObject:step];
    }

    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:kGoodToGo];
        step.title = NSLocalizedString( kGoodToGoTitle, kGoodToGoTitle);
        step.detailText = NSLocalizedString( kGoodToGoDetail, kGoodToGoDetail);;
        
        
        [steps addObject:step];
    }

    
        self  = [super initWithIdentifier:kParQQuizTaskIdentifier steps:steps];
    
    return self;
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result
{

    [self setFlowState:1];
    
    NSArray *stepArray = @[
                           kHeartCondition,
                           kChestPain,
                           kChestPainInLastMonth,
                           kDizziness,
                           kJointProblem,
                           kPrescriptionDrugs,
                           kPhysicallyCapable
                           ];
    
    for (NSString *stepId in stepArray)
    {
        ORKStepResult *stepResult = [result stepResultForStepIdentifier:stepId];
        NSNumber *boolAnswer = [stepResult.results.firstObject booleanAnswer];
        
        if (![boolAnswer  isEqual: @(0)]) {
            [self setFlowState:0];
            
            break;
        }
        
    }
    
    if (step == nil)
    {
        step = self.steps[0];
    }
    
    else if ([[self.steps[self.steps.count - 1] identifier] isEqualToString:step.identifier] || [[self.steps[self.steps.count - 2] identifier] isEqualToString:step.identifier])
    {
        step = nil;
    }
    else
    {
        NSNumber *index = (NSNumber *) self.keys[step.identifier];
        
        step = self.steps[[index intValue]];
    }
    
    return step;
    
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *)result
{
    
    if ([[self.steps[0] identifier] isEqualToString:step.identifier]) {
        step = nil;
    }
    
    else
    {
        NSNumber *index = (NSNumber *) self.backwardKeys[step.identifier];
        
        step = self.steps[[index intValue]];

    }

    
    return step;
    
}

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *)result
{
    return ORKTaskProgressMake([[self.currentOrderedSteps objectForKey:step.identifier] intValue], self.currentOrderedSteps.count);
}

#pragma mark - Helper methods

- (void) setFlowState:(NSInteger)state {
    
    self.currentState = state;
    
    switch (state) {
        case 0:
        {
            
            self.backwardKeys           = @{
                                            kInstructionStep        : [NSNull null],
                                            kInstructionStep2       : @(ParQQuizTypeInstructionStep),
                                            kHeartCondition         : @(ParQQuizTypeInstructionStep2),
                                            kChestPain              : @(ParQQuizTypeHeartCondition),
                                            kChestPainInLastMonth   : @(ParQQuizTypeChestPain),
                                            kDizziness              : @(ParQQuizTypeChestPainInLastMonth),
                                            kJointProblem           : @(ParQQuizTypeDizziness),
                                            kPrescriptionDrugs      : @(ParQQuizTypeJointProblem),
                                            kPhysicallyCapable      : @(ParQQuizTypePrescriptionDrugs),
                                            kStopHere               : @(ParQQuizTypePhysicallyCapable),
                                            kGoodToGo               : [NSNull null],
                                            };
            
            self.keys                   = @{
                                            kInstructionStep        : @(ParQQuizTypeInstructionStep2),
                                            kInstructionStep2       : @(ParQQuizTypeHeartCondition),
                                            kHeartCondition         : @(ParQQuizTypeChestPain),
                                            kChestPain              : @(ParQQuizTypeChestPainInLastMonth),
                                            kChestPainInLastMonth   : @(ParQQuizTypeDizziness),
                                            kDizziness              : @(ParQQuizTypeJointProblem),
                                            kJointProblem           : @(ParQQuizTypePrescriptionDrugs),
                                            kPrescriptionDrugs      : @(ParQQuizTypePhysicallyCapable),
                                            kPhysicallyCapable      : @(ParQQuizTypeStopHere),
                                            kStopHere               : [NSNull null],
                                            kGoodToGo               : [NSNull null],
                                            };
            
            self.currentOrderedSteps    = @{
                                            kInstructionStep        : @(ParQQuizTypeInstructionStep),
                                            kInstructionStep2       : @(ParQQuizTypeInstructionStep2),
                                            kHeartCondition         : @(ParQQuizTypeHeartCondition),
                                            kChestPain              : @(ParQQuizTypeChestPain),
                                            kChestPainInLastMonth   : @(ParQQuizTypeChestPainInLastMonth),
                                            kDizziness              : @(ParQQuizTypeDizziness),
                                            kJointProblem           : @(ParQQuizTypeJointProblem),
                                            kPrescriptionDrugs      : @(ParQQuizTypePrescriptionDrugs),
                                            kPhysicallyCapable      : @(ParQQuizTypePhysicallyCapable),
                                            kStopHere               : @(ParQQuizTypeStopHere),
                                            };
            
        }
            break;
        case 1:
        {
            self.backwardKeys           = @{
                                            kInstructionStep        : [NSNull null],
                                            kInstructionStep2       : @(ParQQuizTypeInstructionStep),
                                            kHeartCondition         : @(ParQQuizTypeInstructionStep2),
                                            kChestPain              : @(ParQQuizTypeHeartCondition),
                                            kChestPainInLastMonth   : @(ParQQuizTypeChestPain),
                                            kDizziness              : @(ParQQuizTypeChestPainInLastMonth),
                                            kJointProblem           : @(ParQQuizTypeDizziness),
                                            kPrescriptionDrugs      : @(ParQQuizTypeJointProblem),
                                            kPhysicallyCapable      : @(ParQQuizTypePrescriptionDrugs),
                                            kStopHere               : [NSNull null],
                                            kGoodToGo               : @(ParQQuizTypePhysicallyCapable),
                                            };
            
            self.keys                   = @{
                                            kInstructionStep        : @(ParQQuizTypeInstructionStep2),
                                            kInstructionStep2       : @(ParQQuizTypeHeartCondition),
                                            kHeartCondition         : @(ParQQuizTypeChestPain),
                                            kChestPain              : @(ParQQuizTypeChestPainInLastMonth),
                                            kChestPainInLastMonth   : @(ParQQuizTypeDizziness),
                                            kDizziness              : @(ParQQuizTypeJointProblem),
                                            kJointProblem           : @(ParQQuizTypePrescriptionDrugs),
                                            kPrescriptionDrugs      : @(ParQQuizTypePhysicallyCapable),
                                            kPhysicallyCapable      : @(ParQQuizTypeGoodToGo),
                                            kStopHere               : [NSNull null],
                                            kGoodToGo               : [NSNull null],
                                            };
            
            self.currentOrderedSteps    = @{
                                            kInstructionStep        : @(ParQQuizTypeInstructionStep),
                                            kInstructionStep2       : @(ParQQuizTypeInstructionStep2),
                                            kHeartCondition         : @(ParQQuizTypeHeartCondition),
                                            kChestPain              : @(ParQQuizTypeChestPain),
                                            kChestPainInLastMonth   : @(ParQQuizTypeChestPainInLastMonth),
                                            kDizziness              : @(ParQQuizTypeDizziness),
                                            kJointProblem           : @(ParQQuizTypeJointProblem),
                                            kPrescriptionDrugs      : @(ParQQuizTypePrescriptionDrugs),
                                            kPhysicallyCapable      : @(ParQQuizTypePhysicallyCapable),
                                            kGoodToGo               : @(9),
                                            };
            
        }
            break;
            
        default:{

            self.backwardKeys           = @{
                                            kInstructionStep        : [NSNull null],
                                            kInstructionStep2       : @(ParQQuizTypeInstructionStep),
                                            kHeartCondition         : @(ParQQuizTypeInstructionStep2),
                                            kChestPain              : @(ParQQuizTypeHeartCondition),
                                            kChestPainInLastMonth   : @(ParQQuizTypeChestPain),
                                            kDizziness              : @(ParQQuizTypeChestPainInLastMonth),
                                            kJointProblem           : @(ParQQuizTypeDizziness),
                                            kPrescriptionDrugs      : @(ParQQuizTypeJointProblem),
                                            kPhysicallyCapable      : @(ParQQuizTypePrescriptionDrugs),
                                            kStopHere               : [NSNull null],
                                            kGoodToGo               : @(ParQQuizTypePhysicallyCapable),
                                            };
            
            self.keys                   = @{
                                            kInstructionStep        : @(ParQQuizTypeInstructionStep2),
                                            kInstructionStep2       : @(ParQQuizTypeHeartCondition),
                                            kHeartCondition         : @(ParQQuizTypeChestPain),
                                            kChestPain              : @(ParQQuizTypeChestPainInLastMonth),
                                            kChestPainInLastMonth   : @(ParQQuizTypeDizziness),
                                            kDizziness              : @(ParQQuizTypeJointProblem),
                                            kJointProblem           : @(ParQQuizTypePrescriptionDrugs),
                                            kPrescriptionDrugs      : @(ParQQuizTypePhysicallyCapable),
                                            kPhysicallyCapable      : @(ParQQuizTypeGoodToGo),
                                            kStopHere               : [NSNull null],
                                            kGoodToGo               : [NSNull null],
                                            };
            
            self.currentOrderedSteps    = @{
                                            kInstructionStep        : @(ParQQuizTypeInstructionStep),
                                            kInstructionStep2       : @(ParQQuizTypeInstructionStep2),
                                            kHeartCondition         : @(ParQQuizTypeHeartCondition),
                                            kChestPain              : @(ParQQuizTypeChestPain),
                                            kChestPainInLastMonth   : @(ParQQuizTypeChestPainInLastMonth),
                                            kDizziness              : @(ParQQuizTypeDizziness),
                                            kJointProblem           : @(ParQQuizTypeJointProblem),
                                            kPrescriptionDrugs      : @(ParQQuizTypePrescriptionDrugs),
                                            kPhysicallyCapable      : @(ParQQuizTypePhysicallyCapable),
                                            kGoodToGo               : @(ParQQuizTypeGoodToGo),
                                            };
        }
            break;
    }
}



@end
