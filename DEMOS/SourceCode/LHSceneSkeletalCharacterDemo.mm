//
//  LHSceneSkeletalCharacterDemo.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneSkeletalCharacterDemo.h"

@implementation LHSceneSkeletalCharacterDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/skeletalCharacter.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [self size];
        
        [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                      asChildOfNode:[self uiNode]
                                           withText:@"Skeletal Character."];
        
    }
    
    return self;
}



@end
