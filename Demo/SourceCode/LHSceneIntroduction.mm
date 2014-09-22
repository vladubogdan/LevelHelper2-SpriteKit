//
//  LHSceneIntroduction.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneIntroduction.h"

@implementation LHSceneIntroduction

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/introductionScene.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"INTRODUCTION\nUse the Previous and Next buttons to toggle between demos.\nUse the Restart button to start the current demo again.\nInvestigate each demo source file and LevelHelper document file for more info on how it was done.\nYou can find all scene files in the DEMO_DOCUMENTS\\levels folder.\nYou can find all source files in the DemoExamples folder located under Classes in Xcode.\n\nFor acurate FPS count use a real device and disable DEBUG DRAWING from LHConfig.h.\n\nGo to ViewController.m to set your own starting scene."];

    }
    
    return self;
}

@end
