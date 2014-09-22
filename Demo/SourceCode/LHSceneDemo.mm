//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneDemo.h"
#import "LevelHelper2-API/LHUtils.h"

#import "LHSceneIntroduction.h"
#import "LHSceneCameraDemo.h"
#import "LHSceneCameraFollowDemo.h"
#import "LHScenePhysicsBodiesDemo.h"
#import "LHSceneCollisionFilteringDemo.h"
#import "LHSceneCharacterAnimationDemo.h"
#import "LHSceneParallaxDemo.h"
#import "LHSceneAssetsDemo.h"
#import "LHSceneRopeJointDemo.h"
#import "LHSceneOtherJointsDemo.h"
#import "LHSceneWaterAreaDemo.h"
#import "LHSceneGravityAreas.h"
#import "LHSceneSpriteSheetAnimationDemo.h"
#import "LHSceneShapesDemo.h"
#import "LHSceneBeziersDemo.h"
#import "LHSceneCollisionDemo.h"
#import "LHSceneRemoveOnCollisionDemo.h"
#import "LHSceneUserPropertiesDemo.h"
#import "LHSceneAssetWithJointsDemo.h"
#import "LHSceneNodesSubclassingTest.h"


//test
#import "LHSceneNodePositioningTest.h"

@implementation LHSceneDemo
{
    NSMutableArray* availableScenes;
}
+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/officerLevel.lhplist"];
    
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(availableScenes);
    LH_SUPER_DEALLOC();
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        availableScenes = [[NSMutableArray alloc] init];
        [availableScenes addObject:[LHSceneIntroduction class]];
        
//        [availableScenes addObject:[LHSceneNodePositioningTest class]];
        
        [availableScenes addObject:[LHSceneNodesSubclassingTest class]];
        [availableScenes addObject:[LHSceneCameraDemo class]];
        [availableScenes addObject:[LHSceneCameraFollowDemo class]];
        [availableScenes addObject:[LHSceneParallaxDemo class]];
        [availableScenes addObject:[LHSceneCharacterAnimationDemo class]];
        [availableScenes addObject:[LHSceneAssetsDemo class]];
        [availableScenes addObject:[LHSceneAssetWithJointsDemo class]];
        [availableScenes addObject:[LHSceneRopeJointDemo class]];
        [availableScenes addObject:[LHSceneWaterAreaDemo class]];
        [availableScenes addObject:[LHSceneGravityAreas class]];
        [availableScenes addObject:[LHSceneCollisionFilteringDemo class]];
        [availableScenes addObject:[LHSceneSpriteSheetAnimationDemo class]];
        [availableScenes addObject:[LHSceneShapesDemo class]];
        [availableScenes addObject:[LHSceneBeziersDemo class]];
        [availableScenes addObject:[LHSceneCollisionDemo class]];
        [availableScenes addObject:[LHSceneRemoveOnCollisionDemo class]];
        [availableScenes addObject:[LHSceneUserPropertiesDemo class]];
        
//        [availableScenes addObject:[LHSceneOtherJointsDemo class]];
//        [availableScenes addObject:[LHScenePhysicsBodiesDemo class]];

        
        
        {
            CGSize size = [self size];
         
            {
                NSInteger demoIdx = [availableScenes indexOfObject:[self class]];
                
                SKLabelNode* ttf = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                [ttf setText:[NSString stringWithFormat:@"Demo %d/%d",(int)demoIdx+1, (int)[availableScenes count]]];
                [ttf setFontSize:20];
                [ttf setZPosition:60];
                [ttf setFontColor:[SKColor blackColor]];
                [ttf setPosition:CGPointMake(20, size.height-50)];
                [ttf setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
                [ttf setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
                [[self uiNode]  addChild:ttf];
            }
            
            {
                SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                [label setName:@"PreviousLabel"];
                [label setFontSize:32];
                [label setZPosition:60];
                [label setText:@"Previous"];
                [label setFontColor:[SKColor magentaColor]];
                [label setPosition:CGPointMake(size.width*0.5 - 200, size.height-50)];
                [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
                [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
                [[self uiNode] addChild:label];
            }
            
            {
                SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                [label setName:@"RestartLabel"];
                [label setFontSize:32];
                [label setZPosition:60];
                [label setText:@"Restart"];
                [label setFontColor:[SKColor magentaColor]];
                [label setPosition:CGPointMake(size.width*0.5, size.height-50)];
                [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
                [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
                [[self uiNode] addChild:label];
            }
            
            {
                SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                [label setName:@"NextLabel"];
                [label setFontSize:32];
                [label setZPosition:60];
                [label setText:@"Next"];
                [label setFontColor:[SKColor magentaColor]];
                [label setPosition:CGPointMake(size.width*0.5 + 200, size.height-50)];
                [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
                [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
                [[self uiNode] addChild:label];
            }

        }
    }
    
    return self;
}

-(void)handleLabelsAtLocation:(CGPoint)location
{
    NSArray* nodes = [self nodesAtPoint:location];
    for(SKNode* node in nodes)
    {
        //if fire button touched, bring the rain
        if ([node.name isEqualToString:@"PreviousLabel"]) {
            [self previousDemo];
        }
        if ([node.name isEqualToString:@"RestartLabel"]) {
            [self restartDemo];
        }
        if ([node.name isEqualToString:@"NextLabel"]) {
            [self nextDemo];
        }
    }
}

#if TARGET_OS_IPHONE
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    [self handleLabelsAtLocation:location];
    
    //dont forget to call super
    [super touchesEnded:touches withEvent:event];
}
#else

-(void)mouseUp:(NSEvent *)theEvent
{
    CGPoint location = [theEvent locationInNode:self];
    
    [self handleLabelsAtLocation:location];
    
    [super mouseUp:theEvent];
}

#endif

-(void)previousDemo{

    int idx = 0;
    for(Class cls in availableScenes)
    {
        if(cls == [self class])
        {
            int nextIdx = idx-1;
            if(nextIdx < 0){
                nextIdx = (int)[availableScenes count] -1;
            }
            
            if(0 <= nextIdx && nextIdx < [availableScenes count] )
            {
                Class goTo = [availableScenes objectAtIndex:nextIdx];
                [[self view] presentScene:[goTo scene]];
            }
        }
        ++idx;
    }
}

-(void)restartDemo{
    [[self view] presentScene:[[self class] scene]];
}

-(void)nextDemo{
    
    int idx = 0;
    for(Class cls in availableScenes)
    {
        if(cls == [self class])
        {
            int nextIdx = idx+1;
            if(nextIdx >= [availableScenes count]){
                nextIdx = 0;
            }
            
            if(0 <= nextIdx && nextIdx < [availableScenes count] )
            {
                Class goTo = [availableScenes objectAtIndex:nextIdx];
                [[self view] presentScene:[goTo scene]];
            }
        }
        ++idx;
    }
}

+(void)createMultilineLabelAtPosition:(CGPoint)labelPosition
                        asChildOfNode:(SKNode*)parent
                             withText:(NSString*)text
{
    NSArray* lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if([lines count] == 0)return;
    
    
    SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    [label setName:@"InfoLabel"];
    [label setFontSize:16];
    [label setZPosition:60];
    [label setText:[lines objectAtIndex:0]];
    [label setFontColor:[SKColor blackColor]];
    [label setColor:[SKColor whiteColor]];
    [label setPosition:labelPosition];
    [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
    [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
    [parent addChild:label];
    
    float yPos = label.position.y-40;
    
    for(int i = 1; i < [lines count]; ++i)
    {
        SKLabelNode* labelLine = [label copy];
        [labelLine setText:[lines objectAtIndex:i]];
        [labelLine setPosition:CGPointMake(labelPosition.x, yPos)];
        [parent addChild:labelLine];
        yPos-=20;
    }
}

@end
