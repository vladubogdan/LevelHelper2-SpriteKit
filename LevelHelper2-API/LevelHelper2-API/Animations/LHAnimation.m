//
//  LHAnimation.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHAnimation.h"

#import "LHNode.h"
#import "LHSprite.h"
#import "LHCamera.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"

#import "LHAnimationProperty.h"
#import "LHFrame.h"

#import "LHPositionProperty.h"
#import "LHChildrenPositionsProperty.h"
#import "LHPositionFrame.h"

#import "LHRotationProperty.h"
#import "LHChildrenRotationsProperty.h"
#import "LHRotationFrame.h"

#import "LHScaleProperty.h"
#import "LHChildrenScalesProperty.h"
#import "LHScaleFrame.h"

#import "LHOpacityProperty.h"
#import "LHChildrenOpacitiesProperty.h"
#import "LHOpacityFrame.h"

#import "LHSpriteFrameProperty.h"
#import "LHSpriteFrame.h"

#import "LHCameraActivateProperty.h"

#import "LHGameWorldNode.h"
#import "LHBackUINode.h"
#import "LHUINode.h"


@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(CGPoint)designOffset;
-(CGSize)designResolutionSize;
@end


@implementation LHAnimation
{
    NSMutableArray* _properties;
    int _repetitions;
    float _totalFrames;
    NSString* _name;
    BOOL _active;
    float _fps;
    
    BOOL animating;
    int currentRepetition;
    float currentTime;
    float previousTime;
    
    __weak LHScene* _scene;
    __weak id<LHNodeAnimationProtocol, LHNodeProtocol> node;
}

-(void)dealloc{
    node = nil;
    _scene = nil;
    
    LH_SAFE_RELEASE(_properties);
    LH_SUPER_DEALLOC();
}

+(instancetype)animationWithDictionary:(NSDictionary*)dict node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)n{
    return LH_AUTORELEASED([[self alloc] initAnimationWithDictionary:dict node:n]);
}

-(instancetype)initAnimationWithDictionary:(NSDictionary*)dict node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)n{
    if(self = [super init]){
        
        node = n;
        
        _repetitions = [dict intForKey:@"repetitions"];
        _totalFrames = [dict floatForKey:@"totalFrames"];
        _name = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
        _active = [dict intForKey:@"active"];
        _fps = [dict floatForKey:@"fps"];
        
        _properties = [[NSMutableArray alloc] init];
        NSDictionary* propDictInfo = [dict objectForKey:@"properties"];
        for(NSDictionary* apInf in [propDictInfo objectEnumerator])
        {
            LHAnimationProperty* prop = [LHAnimationProperty animationPropertyWithDictionary:apInf
                                                                                   animation:self];
            
            [_properties addObject:prop];
        }
        
        if(_active){
            [self restart];
            [self setAnimating:YES];
        }
        
        currentRepetition = 0;
    }
    return self;
}

-(id<LHNodeAnimationProtocol, LHNodeProtocol>)node{
    return node;
}

-(NSString*)name{
    return _name;
}

-(BOOL)isActive{
    return _active;
}

-(void)setActive:(BOOL)val{
    _active = val;
    if(_active){
        [node setActiveAnimation:self];
    }
    else{
        [node setActiveAnimation:nil];
    }
}

-(float)totalTime{
    return _totalFrames*(1.0f/_fps);
}


-(float)currentFrame{
    return currentTime/(1.0f/_fps);
}
-(void)setCurrentFrame:(int)val{
    [self updateTimeWithValue:((float)val)*(1.0f/_fps)];
}

-(void)resetOneShotFrames{
    [self resetOneShotFramesStartingFromFrameNumber:0];
}

-(void)resetOneShotFramesStartingFromFrameNumber:(NSInteger)frameNumber{
    for(LHAnimationProperty* prop in _properties)
    {
        NSArray* frames = [prop keyFrames];
        for(LHFrame* frm in frames){
            if([frm frameNumber] >= frameNumber){
                [frm setWasShot:NO];
            }
        }
    }
}
-(void)setAnimating:(bool)val{
    animating = val;
}
-(bool)animating{
    return animating;
}

-(void)restart{
    [self resetOneShotFrames];
    currentRepetition = 0;
    currentTime = 0;
}

-(void)updateTimeWithDelta:(float)delta{
    if(animating)
        [self setCurrentTime:[self currentTime] + delta];
}
-(void)updateTimeWithValue:(float)val{
    [self setCurrentTime:val];
}

-(int)repetitions{
    return _repetitions;
}

-(int)currentRepetition{
    return currentRepetition;
}

-(void)setCurrentTime:(float)val{
    
    currentTime = val;
    
    [self animateNodeToTime:currentTime];
    
    if(currentTime > [self totalTime] && animating)
    {
        if(currentRepetition < [self repetitions] + 1)//dont grow this beyound num of repetitions as
            ++currentRepetition;
        
        
        if(![self didFinishAllRepetitions]){
            currentTime = 0.0f;
            [self resetOneShotFrames];
            [[node scene] didFinishedRepetitionOnAnimation:self];
        }
        else{
            [node setActiveAnimation:nil];
            [[node scene] didFinishedPlayingAnimation:self];
        }
    }
    previousTime = currentTime;
}

-(float)currentTime{
    return currentTime;
}
-(BOOL)didFinishAllRepetitions{
    if([self repetitions] == 0)
        return NO;
    
    if(animating && currentRepetition >= [self repetitions]){
        return true;
    }
    return false;
}

-(void)animateNodeToTime:(float)time
{
    if([self didFinishAllRepetitions]){
        return;
    }
    
    if(node)
    {
        if(time > [self totalTime]){
            time = [self totalTime];
        }
     
        for(LHAnimationProperty* prop in [_properties reverseObjectEnumerator])
        {
            for(LHAnimationProperty* subprop in [prop allSubproperties]){
                [self updateNodeWithAnimationProperty:subprop time:time];
            }
            [self updateNodeWithAnimationProperty:prop time:time];
        }
    }
}

-(void)updateNodeWithAnimationProperty:(LHAnimationProperty*)prop
                                  time:(float)time
{
    NSArray* frames = [prop keyFrames];
    
    LHFrame* beginFrm = nil;
    LHFrame* endFrm = nil;
    
    for(LHFrame* frm in frames)
    {
        if([frm frameNumber]*(1.0f/_fps) <= time){
            beginFrm = frm;
        }
        
        if([frm frameNumber]*(1.0f/_fps) > time){
            endFrm = frm;
            break;//exit for
        }
    }
    
    
    __weak id<LHNodeAnimationProtocol, LHNodeProtocol> animNode = node;
    if([prop isSubproperty] && [prop subpropertyNode]){
        animNode = [prop subpropertyNode];
    }

    if([prop isKindOfClass:[LHChildrenPositionsProperty class]])
    {
        [self animateNodeChildrenPositionsToTime:time
                                      beginFrame:beginFrm
                                        endFrame:endFrm
                                            node:animNode
                                        property:prop];
    }
    else if([prop isKindOfClass:[LHPositionProperty class]])
    {
        [self animateNodePositionToTime:time
                             beginFrame:beginFrm
                               endFrame:endFrm
                                   node:animNode];
    }
    ////////////////////////////////////////////////////////////////////
    else if([prop isKindOfClass:[LHChildrenRotationsProperty class]])
    {
        [self animateNodeChildrenRotationsToTime:time
                                      beginFrame:beginFrm
                                        endFrame:endFrm
                                            node:animNode
                                        property:prop
         ];
    }
    else if([prop isKindOfClass:[LHRotationProperty class]])
    {
        [self animateNodeRotationToTime:time
                             beginFrame:beginFrm
                               endFrame:endFrm
                                   node:animNode];
    }
    else if([prop isKindOfClass:[LHChildrenScalesProperty class]])
    {
        [self animateNodeChildrenScalesToTime:time
                                   beginFrame:beginFrm
                                     endFrame:endFrm
                                         node:animNode
                                     property:prop];
    }
    else if([prop isKindOfClass:[LHScaleProperty class]])
    {
        [self animateNodeScaleToTime:time
                          beginFrame:beginFrm
                            endFrame:endFrm
                                node:animNode];
    }
    else if([prop isKindOfClass:[LHChildrenOpacitiesProperty class]])
    {
        [self animateNodeChildrenOpacitiesToTime:time
                                      beginFrame:beginFrm
                                        endFrame:endFrm
                                            node:animNode
                                        property:prop];
    }
    else if([prop isKindOfClass:[LHOpacityProperty class]])
    {
        [self animateNodeOpacityToTime:time
                            beginFrame:beginFrm
                              endFrame:endFrm
                                  node:animNode];
    }
    else if([prop isKindOfClass:[LHSpriteFrameProperty class]])
    {
        [self animateSpriteFrameChangeWithFrame:beginFrm
                                      forSprite:animNode];
    }
    else if([prop isKindOfClass:[LHCameraActivateProperty class]] && [node isKindOfClass:[LHCamera class]])
    {
        [self animateCameraActivationWithFrame:beginFrm];
    }
}

-(LHScene*)scene{
    if(!_scene){
        _scene = [node scene];
    }
    return _scene;
}

-(CGPoint)convertFramePosition:(CGPoint)newPos
                       forNode:(SKNode*)animNode
{
    if([animNode isKindOfClass:[LHCamera class]]){
        
        CGSize winSize = [[self scene] designResolutionSize];
        return CGPointMake(winSize.width*0.5  - newPos.x,
                           -newPos.y - winSize.height*0.5);
        
    }
    
    LHScene* scene = [self scene];
    CGPoint offset = [scene designOffset];
    
    if([animNode parent] == nil ||
       [animNode parent] == scene ||
       [animNode parent] == [scene gameWorldNode] ||
       [animNode parent] == [scene backUINode] ||
       [animNode parent] == [scene uiNode]
       )
    {
        CGSize winSize = [[self scene] designResolutionSize];
        newPos =  CGPointMake(newPos.x,
                              winSize.height + newPos.y);
        
        newPos.x += offset.x;
        newPos.y += offset.y;
    }
    
    SKSpriteNode* p = (SKSpriteNode*)[animNode parent];
    if([p isKindOfClass:[SKSpriteNode class]]){
        CGPoint anc = [p anchorPoint];
        newPos.x -= p.size.width*(anc.x - 0.5f);
        newPos.y -= p.size.height*(anc.y- 0.5f);
    }
    
    return newPos;
}

-(void)animateNodeChildrenPositionsToTime:(float)time
                               beginFrame:(LHFrame*)beginFrm
                                 endFrame:(LHFrame*)endFrm
                                     node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
                                 property:(LHAnimationProperty*)prop
{
    //here we handle positions
    LHPositionFrame* beginFrame = (LHPositionFrame*)beginFrm;
    LHPositionFrame* endFrame   = (LHPositionFrame*)endFrm;

    NSArray* children = [animNode childrenOfType:[SKNode class]];

    if(beginFrame && endFrame)
    {
        double beginTime = [beginFrame frameNumber]*(1.0/_fps);
        double endTime = [endFrame frameNumber]*(1.0/_fps);
        
        double framesTimeDistance = endTime - beginTime;
        double timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                CGPoint beginPosition   = [beginFrame positionForUUID:[child uuid]];
                CGPoint endPosition     = [endFrame positionForUUID:[child uuid]];
                
                //lets calculate the new node position based on the start - end and unit time
                double newX = beginPosition.x + (endPosition.x - beginPosition.x)*timeUnit;
                double newY = beginPosition.y + (endPosition.y - beginPosition.y)*timeUnit;
                
                CGPoint newPos = CGPointMake(newX, -newY);
                newPos = [self convertFramePosition:newPos
                                            forNode:(SKNode*)child];
                [child setPosition:newPos];
            }
        }
    }
    else if(beginFrame)
    {
        //we only have begin frame so lets set positions based on this frame
        for(LHNode* child in children)
        {
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                CGPoint beginPosition = [beginFrame positionForUUID:[child uuid]];
                
                CGPoint newPos = CGPointMake(beginPosition.x, -beginPosition.y);
                
                newPos = [self convertFramePosition:newPos
                                            forNode:(SKNode*)child];
                
                [child setPosition:newPos];
            }
        }
    }
}


-(void)animateNodePositionToTime:(float)time
                      beginFrame:(LHFrame*)beginFrm
                        endFrame:(LHFrame*)endFrm
                            node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
{
    //here we handle positions
    LHPositionFrame* beginFrame = (LHPositionFrame*)beginFrm;
    LHPositionFrame* endFrame   = (LHPositionFrame*)endFrm;
    
    if(beginFrame && endFrame)
    {
        double beginTime = [beginFrame frameNumber]*(1.0/_fps);
        double endTime = [endFrame frameNumber]*(1.0/_fps);
        
        double framesTimeDistance = endTime - beginTime;
        double timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        CGPoint beginPosition = [beginFrame positionForUUID:[animNode uuid]];
        CGPoint endPosition = [endFrame positionForUUID:[animNode uuid]];
        
        //lets calculate the new node position based on the start - end and unit time
        double newX = beginPosition.x + (endPosition.x - beginPosition.x)*timeUnit;
        double newY = beginPosition.y + (endPosition.y - beginPosition.y)*timeUnit;

        CGPoint newPos = CGPointMake(newX, -newY);
        newPos = [self convertFramePosition:newPos
                                    forNode:(SKNode*)animNode];
    
        [animNode setPosition:newPos];
        
        
    }
    else if(beginFrame)
    {
        //we only have begin frame so lets set positions based on this frame
        CGPoint beginPosition = [beginFrame positionForUUID:[animNode uuid]];
        
        CGPoint newPos = CGPointMake(beginPosition.x, -beginPosition.y);
        
        newPos = [self convertFramePosition:newPos
                                    forNode:(SKNode*)animNode];
        
        [animNode setPosition:newPos];
    }
}

-(void)animateNodeChildrenRotationsToTime:(float)time
                               beginFrame:(LHFrame*)beginFrm
                                 endFrame:(LHFrame*)endFrm
                                     node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
                                 property:(LHAnimationProperty*)prop
{
    LHRotationFrame* beginFrame    = (LHRotationFrame*)beginFrm;
    LHRotationFrame* endFrame      = (LHRotationFrame*)endFrm;
    
    NSArray* children = [animNode childrenOfType:[SKNode class]];
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                float beginRotation = [beginFrame rotationForUUID:[child uuid]];
                float endRotation   = [endFrame rotationForUUID:[child uuid]];
                
                float shortest_angle = fmodf( (fmodf( (endRotation - beginRotation), 360.0f) + 540.0f), 360.0) - 180.0f;
                
                //lets calculate the new value based on the start - end and unit time
                float newRotation = beginRotation + shortest_angle*timeUnit;
                [child setZRotation:LH_DEGREES_TO_RADIANS(-newRotation)];
            }
        }
    }
    else if(beginFrame)
    {
        for(LHNode* child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                //we only have begin frame so lets set value based on this frame
                float beginRotation = [beginFrame rotationForUUID:[child uuid]];
                [child setZRotation:LH_DEGREES_TO_RADIANS(-beginRotation)];
            }
        }
    }
}


-(void)animateNodeRotationToTime:(float)time
                      beginFrame:(LHFrame*)beginFrm
                        endFrame:(LHFrame*)endFrm
                            node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
{
    LHRotationFrame* beginFrame    = (LHRotationFrame*)beginFrm;
    LHRotationFrame* endFrame      = (LHRotationFrame*)endFrm;
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        float beginRotation = [beginFrame rotationForUUID:[animNode uuid]];
        float endRotation   = [endFrame rotationForUUID:[animNode uuid]];
        
        float shortest_angle = fmodf( (fmodf( (endRotation - beginRotation), 360.0f) + 540.0f), 360.0) - 180.0f;
        
        //lets calculate the new value based on the start - end and unit time
        float newRotation = beginRotation + shortest_angle*timeUnit;
        
        [animNode setZRotation:LH_DEGREES_TO_RADIANS(-newRotation)];
    }
    else if(beginFrame)
    {
        //we only have begin frame so lets set value based on this frame
        float beginRotation = [beginFrame rotationForUUID:[animNode uuid]];
        [animNode setZRotation:LH_DEGREES_TO_RADIANS(-beginRotation)];
    }
}

-(void)animateNodeChildrenScalesToTime:(float)time
                            beginFrame:(LHFrame*)beginFrm
                              endFrame:(LHFrame*)endFrm
                                  node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
                              property:(LHAnimationProperty*)prop
{
    //here we handle scale
    LHScaleFrame* beginFrame    = (LHScaleFrame*)beginFrm;
    LHScaleFrame* endFrame      = (LHScaleFrame*)endFrm;
    
    NSArray* children = [animNode childrenOfType:[SKNode class]];
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children)
        {
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                CGSize beginScale = [beginFrame scaleForUUID:[child uuid]];
                CGSize endScale = [endFrame scaleForUUID:[child uuid]];
                
                //lets calculate the new node scale based on the start - end and unit time
                float newX = beginScale.width + (endScale.width - beginScale.width)*timeUnit;
                float newY = beginScale.height + (endScale.height - beginScale.height)*timeUnit;

                [child setXScale:newX];
                [child setYScale:newY];
            }
        }
    }
    else if(beginFrame)
    {
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                CGSize beginScale = [beginFrame scaleForUUID:[child uuid]];
                [child setXScale:beginScale.width];
                [child setYScale:beginScale.height];
            }
        }
    }
}

-(void)animateNodeScaleToTime:(float)time
                   beginFrame:(LHFrame*)beginFrm
                     endFrame:(LHFrame*)endFrm
                         node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
{
    //here we handle scale
    LHScaleFrame* beginFrame    = (LHScaleFrame*)beginFrm;
    LHScaleFrame* endFrame      = (LHScaleFrame*)endFrm;
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        CGSize beginScale = [beginFrame scaleForUUID:[animNode uuid]];
        CGSize endScale = [endFrame scaleForUUID:[animNode uuid]];
        
        //lets calculate the new node scale based on the start - end and unit time
        float newX = beginScale.width + (endScale.width - beginScale.width)*timeUnit;
        float newY = beginScale.height + (endScale.height - beginScale.height)*timeUnit;
        
        [animNode setXScale:newX];
        [animNode setYScale:newY];
    }
    else if(beginFrame)
    {
        CGSize beginScale = [beginFrame scaleForUUID:[animNode uuid]];
        [animNode setXScale:beginScale.width];
        [animNode setYScale:beginScale.height];
    }
}


-(void)animateNodeChildrenOpacitiesToTime:(float)time
                               beginFrame:(LHFrame*)beginFrm
                                 endFrame:(LHFrame*)endFrm
                                     node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
                                 property:(LHAnimationProperty*)prop
{
    //here we handle sprites opacity
    LHOpacityFrame* beginFrame    = (LHOpacityFrame*)beginFrm;
    LHOpacityFrame* endFrame      = (LHOpacityFrame*)endFrm;
    
    NSArray* children = [node childrenOfType:[SKNode class]];
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                float beginValue = [beginFrame opacityForUUID:[child uuid]];
                float endValue = [endFrame opacityForUUID:[child uuid]];
                
                //lets calculate the new value based on the start - end and unit time
                float newValue = beginValue + (endValue - beginValue)*timeUnit;
                
                [child setAlpha:newValue/255.0f];
            }
        }
    }
    else if(beginFrame)
    {
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                //we only have begin frame so lets set value based on this frame
                float beginValue = [beginFrame opacityForUUID:[child uuid]];
                [child setAlpha:beginValue/255.0f];
            }
        }
    }
}


-(void)animateNodeOpacityToTime:(float)time
                     beginFrame:(LHFrame*)beginFrm
                       endFrame:(LHFrame*)endFrm
                           node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
{
    //here we handle sprites opacity
    LHOpacityFrame* beginFrame    = (LHOpacityFrame*)beginFrm;
    LHOpacityFrame* endFrame      = (LHOpacityFrame*)endFrm;
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        float beginValue = [beginFrame opacityForUUID:[animNode uuid]];
        float endValue = [endFrame opacityForUUID:[animNode uuid]];
        
        //lets calculate the new value based on the start - end and unit time
        float newValue = beginValue + (endValue - beginValue)*timeUnit;
                
        [animNode setAlpha:newValue/255.0f];
    }
    else if(beginFrame)
    {
        //we only have begin frame so lets set value based on this frame
        float beginValue = [beginFrame opacityForUUID:[animNode uuid]];
        [animNode setAlpha:beginValue/255.0f];
    }
}

-(void)animateSpriteFrameChangeWithFrame:(LHFrame*)beginFrm
                               forSprite:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
{
    LHSprite* sprite = [animNode isKindOfClass:[LHSprite class]] ? (LHSprite*)animNode : nil;
    if(!sprite)return;
    
    LHSpriteFrame* beginFrame = (LHSpriteFrame*)beginFrm;
    if(beginFrame && sprite)
    {
        if(animating)
        {
            if(![beginFrame wasShot])
            {
                [sprite setSpriteFrameWithName:[beginFrame spriteFrameName]];
                [beginFrame setWasShot:YES];
            }
        }
        else{
            [sprite setSpriteFrameWithName:[beginFrame spriteFrameName]];
        }
    }
}

-(void)animateCameraActivationWithFrame:(LHFrame*)beginFrm
{
    LHFrame* beginFrame = (LHFrame*)beginFrm;
    if(beginFrame)
    {
        if(animating)
        {
            if(![beginFrame wasShot])
            {
                [(LHCamera*)node setActive:YES];
                [beginFrame setWasShot:YES];
            }
        }
        else{
            [(LHCamera*)node setActive:YES];
        }
    }
}

@end
