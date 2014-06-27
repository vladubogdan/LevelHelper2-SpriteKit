//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneDemo.h"
#import "LHUtils.h"

#import "LHSceneCameraDemo.h"
#import "LHSceneCameraFollowNodeDemo.h"
#import "LHScenePhysicsBodiesDemo.h"
#import "LHSceneCollisionFilteringDemo.h"
#import "LHSceneAnimationsDemo.h"
#import "LHSceneParallaxDemo.h"

@implementation LHSceneDemo
{
    NSMutableArray* availableScenes;
}
+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/officerLevel.plist"];
    
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
        
        [availableScenes addObject:[LHSceneCameraDemo class]];
        [availableScenes addObject:[LHSceneCameraFollowNodeDemo class]];
        [availableScenes addObject:[LHSceneAnimationsDemo class]];
        [availableScenes addObject:[LHSceneParallaxDemo class]];
        [availableScenes addObject:[LHScenePhysicsBodiesDemo class]];
        [availableScenes addObject:[LHSceneCollisionFilteringDemo class]];
        
        
        
        {
            CGSize size = [self size];
            
            {
                SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                [label setName:@"PreviousLabel"];
                [label setFontSize:32];
                [label setZPosition:60];
                [label setText:@"Previous"];
                [label setFontColor:[SKColor greenColor]];
                [label setPosition:CGPointMake(80, 150)];
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
                [label setFontColor:[SKColor greenColor]];
                [label setPosition:CGPointMake(size.width*0.5, 150)];
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
                [label setFontColor:[SKColor greenColor]];
                [label setPosition:CGPointMake(size.width- 50, 150)];
                [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
                [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
                [[self uiNode] addChild:label];
            }

        }
    }
    
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
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

-(void)previousDemo{

    int idx = 0;
    for(Class cls in availableScenes)
    {
        if(cls == [self class])
        {
            int nextIdx = idx-1;
            if(nextIdx < 0){
                nextIdx = [availableScenes count] -1;
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

@end
