//
//  LHCamera.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHCamera.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHAnimation.h"
#import "SKNode+Transforms.h"
#import "LHGameWorldNode.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(CGPoint)designOffset;
-(CGSize)designResolutionSize;
@end

@implementation LHCamera
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    
    BOOL wasUpdated;
    BOOL _active;
    BOOL _restricted;
    
    NSString* _followedNodeUUID;
    __weak SKNode<LHNodeAnimationProtocol, LHNodeProtocol>* _followedNode;
    
    
    BOOL zooming;
    float startZoomValue;
    float reachZoomValue;
    float reachZoomTime;
    float minZoomValue;
    NSTimeInterval zoomStartTime;
    
    BOOL lookingAt;
    BOOL resetingLookAt;
    CGPoint lookAtPosition;
    __weak SKNode* _lookAtNode;
    
    CGPoint startLookAtPosition;
    float lookAtTime;
    NSTimeInterval lookAtStartTime;
    
    BOOL _zoomsOnPinch;
    
    CGPoint _centerPosition;//camera pos or followed node position (used by resetLookAt)
    CGPoint _viewPosition;//actual camera view position
    
    CGPoint previousFollowedPosition;
    CGPoint previousDirectionVector;
    
    CGPoint directionalOffset;
    CGPoint directionalOffsetToReach;
    float directionMultiplierX;
    float directionMultiplierY;
    
    BOOL reachingOffsetX;
    BOOL reachingOffsetY;
    
    BOOL lockX;
    BOOL lockY;
    BOOL smoothMovement;
    CGSize importantArea;
    
    CGPoint offset;//user offset
}

-(BOOL)wasUpdated{
    return wasUpdated;
}

-(void)dealloc{
    _followedNode = nil;
    LH_SAFE_RELEASE(_followedNodeUUID);
    
    _lookAtNode = nil;
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    

    LH_SUPER_DEALLOC();
}


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                             scene:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                      scene:prnt]);
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                             scene:(SKNode*)prnt{
    
    
    if(self = [super init]){
        
        wasUpdated = false;
        
        [prnt addChild:self];
        [self setName:[dict objectForKey:@"name"]];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        NSString* followedUUID = [dict objectForKey:@"followedNodeUUID"];
        if(followedUUID){
            _followedNodeUUID = [[NSString alloc] initWithString:followedUUID];
        }
        
        _active = [dict boolForKey:@"activeCamera"];
        _restricted = [dict boolForKey:@"restrictToGameWorld"];
        
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
        
        
        CGSize winSize = [[self scene] size];

        CGRect worldRect = [(LHScene*)[self scene] gameWorldRect];
        

        CGSize worldSize = worldRect.size;
        if(worldSize.width < 0)
            worldSize.width = -worldSize.width;
        
        if(worldSize.height < 0)
            worldSize.height = -worldSize.height;
        

        minZoomValue = 0.1;
        if([self restrictedToGameWorld]){
            if(winSize.width < worldSize.width || winSize.height < worldSize.height){
                minZoomValue = winSize.height/worldSize.height;
                if(minZoomValue < winSize.width/worldSize.width){
                    minZoomValue = winSize.width/worldSize.width;
                }
            }
        }
        
        if([dict objectForKey:@"offset"])//all this properties were added at the same time
        {
            _zoomsOnPinch = [dict boolForKey:@"zoomOnPinchOrScroll"];
            
            lockX = [dict boolForKey:@"lockX"];
            lockY = [dict boolForKey:@"lockY"];
            importantArea = [dict sizeForKey:@"importantArea"];
            smoothMovement = [dict boolForKey:@"smoothMovement"];
            offset = [dict pointForKey:@"offset"];
            
            float zoomVal = [dict floatForKey:@"zoomValue"];
            [self setZoomValue:zoomVal];
        }
        
    }
    
    return self;
}

-(BOOL)isActive{
    return _active;
}
-(void)resetActiveState{
    _active = NO;
}
-(void)setActive:(BOOL)value{
    
    NSMutableArray* cameras = [(LHScene*)[self scene] childrenOfType:[LHCamera class]];
    
    for(LHCamera* cam in cameras){
        [cam resetActiveState];
    }
    _active = value;
    [self setSceneView];
}

-(SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)followedNode{
    if(_followedNodeUUID && _followedNode == nil){
        _followedNode = (SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[(LHScene*)[self scene] childNodeWithUUID:_followedNodeUUID];
        if(_followedNode){
            LH_SAFE_RELEASE(_followedNodeUUID);
        }
    }
    return _followedNode;
}
-(void)followNode:(SKNode<LHNodeAnimationProtocol, LHNodeProtocol>*)node{
    _followedNode = node;
}

-(BOOL)restrictedToGameWorld{
    return _restricted;
}
-(void)setRestrictedToGameWorld:(BOOL)val{
    _restricted = val;
}

-(void)setOffsetUnit:(CGPoint)val{
    offset = val;
}

-(CGPoint)offsetUnit{
    return offset;
}

-(void)setImportantAreaUnit:(CGSize)val;{
    importantArea = val;
}
-(CGSize)importantAreaUnit{
    return importantArea;
}

-(void)setLockX:(BOOL)val{
    lockX = val;
}
-(BOOL)lockX{
    return lockX;
}

-(void)setLockY:(BOOL)val{
    lockY = val;
}
-(BOOL)lockY{
    return lockY;
}

-(BOOL)smoothMovement{
    return smoothMovement;
}
-(void)setSmoothMovement:(BOOL)val{
    smoothMovement = val;
}

-(void)setPosition:(CGPoint)position{
    if(_active){
        
        CGPoint transPoint = [self transformToRestrictivePosition:position];
        
        if(lockX){
            transPoint.x = position.x;
        }
        if(lockY){
            transPoint.y = position.y;
        }
        
        [super setPosition:transPoint];
        
        //[super setPosition:[self transformToRestrictivePosition:position]];
    }
    else{
        [super setPosition:position];
    }
}

-(void)setSceneView{
    if(_active)
    {
        CGPoint transPoint = [self transformToRestrictivePosition:[self position]];
        
        LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
        
        if(zooming)
        {
            NSTimeInterval currentTimer = [NSDate timeIntervalSinceReferenceDate];
            float zoomUnit = (currentTimer - zoomStartTime)/reachZoomTime;
            float deltaZoom = startZoomValue + (reachZoomValue - startZoomValue)*zoomUnit;
            
            if(reachZoomValue < minZoomValue){
                reachZoomValue = minZoomValue;
            }
            
            [gwNode setScale:deltaZoom];
            
            if(zoomUnit >= 1.0f){
                gwNode.xScale = reachZoomValue;
                gwNode.yScale = reachZoomValue;
                zooming = false;
            }
        }
        
        [gwNode setPosition:transPoint];
        
        //CGPoint transPoint = [self transformToRestrictivePosition:[self position]];
        //[[[self scene] gameWorldNode] setPosition:transPoint];
    }
}

-(CGPoint)transformToRestrictivePosition:(CGPoint)position
{
    LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
    
    CGPoint transPoint = position;
    
    _viewPosition = transPoint;
    _centerPosition = transPoint;
    
    CGSize winSize = [(LHScene*)[self scene] size];
    CGPoint halfWinSize = CGPointMake(winSize.width * 0.5f, winSize.height * 0.5f);
    
    SKNode* followed = [self followedNode];
    if(followed){
        
        CGPoint gwNodePos = [followed position];
        if([followed parent] != gwNode)
        {
            CGPoint worldPoint = [followed convertToWorldSpaceAR:CGPointZero];
            gwNodePos = [gwNode convertToNodeSpaceAR:worldPoint];
        }
        
        _viewPosition = gwNodePos;
        _centerPosition = transPoint;
        
        CGPoint scaledMidpoint = CGPointMake(gwNodePos.x * gwNode.xScale, gwNodePos.y*gwNode.xScale);// ccpMult(gwNodePos, gwNode.scale);
        CGPoint followedPos = CGPointMake(halfWinSize.x - scaledMidpoint.x, halfWinSize.y - scaledMidpoint.y);// ccpSub(halfWinSize, scaledMidpoint);
        
        
        if(!lockX){
            transPoint.x = followedPos.x;
            transPoint.x += directionalOffset.x;
        }
        if(!lockY){
            transPoint.y = followedPos.y;
            transPoint.y += directionalOffset.y;
        }
        
        transPoint.x += offset.x*winSize.width;
        transPoint.y += offset.y*winSize.height;
    }
    
    
    NSTimeInterval currentTimer = [NSDate timeIntervalSinceReferenceDate];
    float lookAtUnit = (currentTimer - lookAtStartTime)/lookAtTime;
    
    if(lookingAt)
    {
        if(_lookAtNode)
        {
            CGPoint worldPoint = [_lookAtNode convertToWorldSpaceAR:CGPointZero];
            lookAtPosition = [gwNode convertToNodeSpaceAR:worldPoint];
        }
        
        float newX = startLookAtPosition.x + (lookAtPosition.x - startLookAtPosition.x)*lookAtUnit;
        float newY = startLookAtPosition.y + (lookAtPosition.y - startLookAtPosition.y)*lookAtUnit;
        CGPoint gwNodePos = CGPointMake(newX, newY);
        
        if(lookAtUnit >= 1.0f){
            gwNodePos = lookAtPosition;
        }
        
        _viewPosition = gwNodePos;
        
        CGPoint scaledMidpoint = CGPointMake(gwNodePos.x* gwNode.xScale, gwNodePos.y * gwNode.xScale);// ccpMult(gwNodePos, gwNode.scale);
        transPoint = CGPointMake(halfWinSize.x - scaledMidpoint.x, halfWinSize.y - scaledMidpoint.y);//ccpSub(halfWinSize, scaledMidpoint);
    }
    
    if(resetingLookAt)
    {
        float newX = startLookAtPosition.x + (_centerPosition.x - startLookAtPosition.x)*lookAtUnit;
        float newY = startLookAtPosition.y + (_centerPosition.y - startLookAtPosition.y)*lookAtUnit;
        CGPoint gwNodePos = CGPointMake(newX, newY);
        
        if(lookAtUnit >= 1.0f){
            gwNodePos = lookAtPosition;
            resetingLookAt = false;
            lookingAt = false;
            _lookAtNode = nil;
        }
        
        _viewPosition = gwNodePos;
        
        CGPoint scaledMidpoint = CGPointMake(gwNodePos.x* gwNode.xScale, gwNodePos.y * gwNode.xScale);// ccpMult(gwNodePos, gwNode.scale);
        transPoint = CGPointMake(halfWinSize.x - scaledMidpoint.y, halfWinSize.y - scaledMidpoint.y);// ccpSub(halfWinSize, scaledMidpoint);
    }
    
    
    
    
    float x = transPoint.x;
    float y = transPoint.y;
    
    CGRect worldRect = [(LHScene*)[self scene] gameWorldRect];
    
    worldRect.origin.x *= gwNode.xScale;
    worldRect.origin.y *= gwNode.xScale;
    worldRect.size.width *= gwNode.xScale;
    worldRect.size.height *= gwNode.xScale;
    
    if(!CGRectEqualToRect(CGRectZero, worldRect) && [self restrictedToGameWorld]){
        
        x = MAX(x, winSize.width*0.5 - (worldRect.origin.x + worldRect.size.width - winSize.width *0.5));
        x = MIN(x, winSize.width*0.5 - (worldRect.origin.x + winSize.width *0.5));
        
        y = MIN(y, winSize.height*0.5 - (worldRect.origin.y + worldRect.size.height + (winSize.height*0.5)));
        y = MAX(y, winSize.height*0.5 - (worldRect.origin.y - winSize.height*0.5));
    }
    
    transPoint.x = x;
    transPoint.y = y;
    
    return transPoint;
}

#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

- (void)update:(NSTimeInterval)currentTime delta:(float)dt{

    if(![self isActive])return;
 
    SKNode* followed = [self followedNode];
    if(followed){
        
        CGSize winSize = [(LHScene*)[self scene] size];
        
        CGPoint curPosition = [followed position];
        if(CGPointEqualToPoint(previousFollowedPosition, CGPointZero)){
            previousFollowedPosition = curPosition;
            
            directionalOffset.x = importantArea.width * winSize.width * 0.5;
            directionalOffset.y = importantArea.height * winSize.height * 0.5;
        }
        
        if(!CGPointEqualToPoint(curPosition, previousFollowedPosition))
        {
            CGPoint direction = CGPointMake(curPosition.x - previousFollowedPosition.x, curPosition.y - previousFollowedPosition.y);
            
            if(CGPointEqualToPoint(previousDirectionVector, CGPointZero)){
                previousDirectionVector = direction;
            }
            
            float followedDeltaX = curPosition.x - previousFollowedPosition.x;
            float followedDeltaY = curPosition.y - previousFollowedPosition.y;
            
            float filteringFactor = 0.50;
            
            
            
            if(reachingOffsetX)
            {
                float lastOffset = directionalOffset.x;
                
                directionalOffset.x -= followedDeltaX;//XYXY
                
                if(smoothMovement)
                    directionalOffset.x = directionalOffset.x * filteringFactor + lastOffset * (1.0 - filteringFactor);
                
                if(directionMultiplierX > 0)
                {
                    if(directionalOffset.x  < directionalOffsetToReach.x)
                    {
                        directionalOffset.x = directionalOffsetToReach.x;
                        reachingOffsetX = false;
                    }
                }
                else
                {
                    if(directionalOffset.x > directionalOffsetToReach.x)
                    {
                        directionalOffset.x = directionalOffsetToReach.x;
                        reachingOffsetX = false;
                    }
                }
            }
            
            if(direction.x/previousDirectionVector.x <= 0 || (direction.x == 0 && previousDirectionVector.x == 0))
            {
                if(direction.x >= 0){
                    directionMultiplierX = 1.0f;//XYXY
                }
                else{
                    directionMultiplierX = -1.0f;//XYXY
                }
                
                directionalOffsetToReach.x = -importantArea.width * winSize.width * 0.5 * directionMultiplierX;
                reachingOffsetX = true;
            }
            
            
            if(reachingOffsetY)
            {
                float lastOffset = directionalOffset.y;
                directionalOffset.y -= followedDeltaY;//XYXY
                
                if(smoothMovement)
                    directionalOffset.y = directionalOffset.y * filteringFactor + lastOffset * (1.0 - filteringFactor);
                
                if(directionMultiplierY > 0)
                {
                    if(directionalOffset.y  > directionalOffsetToReach.y)
                    {
                        directionalOffset.y = directionalOffsetToReach.y;
                        reachingOffsetY = false;
                    }
                }
                else
                {
                    if(directionalOffset.y < directionalOffsetToReach.y)
                    {
                        directionalOffset.y = directionalOffsetToReach.y;
                        reachingOffsetY = false;
                    }
                }
            }
            
            //to change sign, change sign on XYXY lines
            
            if(direction.y/previousDirectionVector.y <= 0 || (direction.y == 0 && previousDirectionVector.y == 0))
            {
                if(direction.y >= 0){
                    directionMultiplierY = -1.0f;//XYXY
                }
                else{
                    directionMultiplierY = 1.0f;//XYXY
                }
                
                directionalOffsetToReach.y = importantArea.height * winSize.height * 0.5 * directionMultiplierY;
                
                reachingOffsetY = true;
            }
            
            previousDirectionVector = direction;
        }
        
        
        previousFollowedPosition = curPosition;
    }

    
    [_animationProtocolImp update:currentTime delta:dt];
    
    if([self followedNode]){
        CGPoint pt = [self transformToRestrictivePosition:[[self followedNode] position]];
        [self setPosition:pt];
    }
    [self setSceneView];
    
    wasUpdated = true;
}

-(void)zoomByValue:(float)value inSeconds:(float)second
{
    if(_active)
    {
        zooming = true;
        reachZoomTime = second;
        startZoomValue = [[[self scene] gameWorldNode] xScale];
        reachZoomValue = value + startZoomValue;
        
        if(reachZoomValue < minZoomValue){
            reachZoomValue = minZoomValue;
        }
        zoomStartTime = [NSDate timeIntervalSinceReferenceDate];
    }
}

-(void)zoomToValue:(float)value inSeconds:(float)second
{
    if(_active)
    {
        zooming = true;
        reachZoomTime = second;
        startZoomValue = [[[self scene] gameWorldNode] xScale];
        reachZoomValue = value;
        
        if(reachZoomValue < minZoomValue){
            reachZoomValue = minZoomValue;
        }
        zoomStartTime = [NSDate timeIntervalSinceReferenceDate];
    }
}

-(float)zoomValue
{
    return [[[self scene] gameWorldNode] xScale];
}

-(void)setZoomValue:(float)val
{
    CGPoint transPoint = [self transformToRestrictivePosition:[self position]];
    LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
    [gwNode setScale:val];
    [gwNode setPosition:transPoint];
}


-(void)lookAtPosition:(CGPoint)gwPosition inSeconds:(float)seconds
{
    if(lookingAt == true){
        NSLog(@"Camera is already looking somewhere. Please first reset lookAt by calling resetLookAt");
        return;
    }
    
    lookAtPosition = gwPosition;
    startLookAtPosition = _viewPosition;
    
    lookAtStartTime = [NSDate timeIntervalSinceReferenceDate];
    lookAtTime = seconds;
    lookingAt = true;
}

-(void)lookAtNode:(SKNode*)node inSeconds:(float)seconds
{
    if(lookingAt == true){
        NSLog(@"Camera is already looking somewhere. Please first reset lookAt by calling resetLookAt");
        return;
    }
    
    _lookAtNode = node;
    
    startLookAtPosition = _viewPosition;
    
    lookAtStartTime = [NSDate timeIntervalSinceReferenceDate];
    lookAtTime = seconds;
    lookingAt = true;
}

-(void)resetLookAt
{
    [self resetLookAtInSeconds:0];
}

-(void)resetLookAtInSeconds:(float)seconds
{
    if(lookingAt != true){
        NSLog(@"[ lookAtPosition: inSeconds:] must be used first. Cannot reset camera look.");
        return;
    }
    
    startLookAtPosition = lookAtPosition;
    
    if(_lookAtNode)
    {
        LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
        CGPoint worldPoint = [_lookAtNode convertToWorldSpaceAR:CGPointZero];
        startLookAtPosition = [gwNode convertToNodeSpaceAR:worldPoint];
        _lookAtNode = nil;
    }
    
    lookAtPosition = _centerPosition;
    
    lookAtStartTime = [NSDate timeIntervalSinceReferenceDate];
    lookAtTime = seconds;
    lookingAt = true;
    resetingLookAt = true;
}

-(BOOL)isLookingAt{
    return lookingAt;
}

-(void)setUsePinchOrScrollWheelToZoom:(BOOL)value{
    _zoomsOnPinch = value;
}

-(BOOL)usePinchOrScrollWheelToZoom{
    return _zoomsOnPinch;
}

-(void)pinchZoomWithScaleDelta:(float)delta center:(CGPoint)scaleCenter
{
    LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
    
    float newScale = [gwNode xScale] + delta;
    
    if(newScale < minZoomValue){
        newScale = minZoomValue;
    }
    
    scaleCenter = [gwNode convertToNodeSpaceAR:scaleCenter];
    
    CGPoint oldCenterPoint = CGPointMake(scaleCenter.x * [gwNode xScale], scaleCenter.y * gwNode.xScale);
    gwNode.xScale = newScale;
    gwNode.yScale = newScale;
    
    CGPoint newCenterPoint = CGPointMake(scaleCenter.x * [gwNode xScale], scaleCenter.y * gwNode.xScale);
    
    CGPoint centerPointDelta = CGPointMake(oldCenterPoint.x - newCenterPoint.x, oldCenterPoint.y - newCenterPoint.y);
    self.position = CGPointMake(self.position.x + centerPointDelta.x,self.position.y + centerPointDelta.y);
    
    [self update:0 delta:0];
}

#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
