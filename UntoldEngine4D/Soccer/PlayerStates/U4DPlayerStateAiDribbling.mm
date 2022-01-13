//
//  U4DPlayerStateAiDribbling.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 1/10/22.
//  Copyright © 2022 Untold Engine Studios. All rights reserved.
//

#include "U4DPlayerStateAiDribbling.h"
#include "U4DGameConfigs.h"
#include "U4DPlayerStateDribbling.h"
#include "U4DPlayerStateIntercept.h"
#include "U4DPlayerStateFree.h"
#include "U4DPlayerStateFlock.h"
#include "U4DPlayerStateMark.h"
#include "U4DTeam.h"
#include "U4DPathAnalyzer.h"
#include "U4DBall.h"
#include "U4DFoot.h"
#include "U4DAABB.h"
#include "U4DMessageDispatcher.h"
#include "U4DTeamStateAttacking.h"
#include "U4DTeamStateDefending.h"


namespace U4DEngine {

U4DPlayerStateAiDribbling* U4DPlayerStateAiDribbling::instance=0;

U4DPlayerStateAiDribbling::U4DPlayerStateAiDribbling(){
    name="Ai Dribbling";
}

U4DPlayerStateAiDribbling::~U4DPlayerStateAiDribbling(){
    
}

U4DPlayerStateAiDribbling* U4DPlayerStateAiDribbling::sharedInstance(){
    
    if (instance==0) {
        instance=new U4DPlayerStateAiDribbling();
    }
    
    return instance;
    
}

void U4DPlayerStateAiDribbling::enter(U4DPlayer *uPlayer){
    
    U4DGameConfigs *gameConfigs=U4DGameConfigs::sharedInstance();
    
    //play the idle animation
    U4DEngine::U4DAnimation *currentAnimation=uPlayer->runningAnimation;
    
    if (currentAnimation!=nullptr) {
        uPlayer->animationManager->setAnimationToPlay(currentAnimation);
    }
    
    
    U4DTeam *team=uPlayer->getTeam();
    
    team->setActivePlayer(uPlayer);
    
    U4DTeam *oppositeTeam=team->getOppositeTeam();
    
    team->changeState(U4DTeamStateAttacking::sharedInstance());
    oppositeTeam->changeState(U4DTeamStateDefending::sharedInstance());
    
    uPlayer->foot->kineticAction->resumeCollisionBehavior();
    
    //set speed
    uPlayer->arriveBehavior.setMaxSpeed(gameConfigs->getParameterForKey("arriveMaxSpeed"));

    //set the distance to stop
    uPlayer->arriveBehavior.setTargetRadius(gameConfigs->getParameterForKey("arriveStopRadius"));

    //set the distance to start slowing down
    uPlayer->arriveBehavior.setSlowRadius(gameConfigs->getParameterForKey("arriveSlowRadius"));
    
    //set the avoidance max speed
//    uPlayer->avoidanceBehavior.setMaxSpeed(gameConfigs->getParameterForKey("markAvoidanceMaxSpeed"));
//
//    uPlayer->avoidanceBehavior.setTimeParameter(gameConfigs->getParameterForKey("markAvoidanceTimeParameter"));
    
    //get the closest point to the goal post and steer towards it
    U4DEngine::U4DPoint3n minPoint(-38.0,-1.3,-4.8);
    U4DEngine::U4DPoint3n maxPoint(-36.0,3.2,4.5);
    
    U4DEngine::U4DAABB aabb(minPoint,maxPoint);
    
    U4DEngine::U4DPoint3n pos=uPlayer->getAbsolutePosition().toPoint();
    
    U4DEngine::U4DPoint3n closestPoint;
    
    aabb.closestPointOnAABBToPoint(pos, closestPoint);
    
    uPlayer->naiveNavDirection=closestPoint.toVector();
    
    team->setActivePlayer(uPlayer);
    
    //inform teammates to flock
    std::vector<U4DPlayer*> teammates=team->getTeammatesForPlayer(uPlayer);
    U4DMessageDispatcher *messageDispatcher=U4DMessageDispatcher::sharedInstance();
    
    for(auto n: teammates){
        messageDispatcher->sendMessage(0.0, uPlayer, n, msgSupport);
    }
}

void U4DPlayerStateAiDribbling::execute(U4DPlayer *uPlayer, double dt){
    
    U4DGameConfigs *gameConfigs=U4DGameConfigs::sharedInstance();
    
    uPlayer->updateFootSpaceWithAnimation(uPlayer->runningAnimation);
    
    //U4DPathAnalyzer *pathAnalyzer=U4DPathAnalyzer::sharedInstance();
    
    U4DBall *ball=U4DBall::sharedInstance();
    
    U4DVector3n ballPosition=ball->getAbsolutePosition();
    ballPosition.y=uPlayer->getAbsolutePosition().y;
    
    U4DEngine::U4DVector3n steerToBallVelocity=uPlayer->arriveBehavior.getSteering(uPlayer->kineticAction, ballPosition);
    
    //compute the final velocity
    U4DEngine::U4DVector3n finalVelocity=uPlayer->arriveBehavior.getSteering(uPlayer->kineticAction, uPlayer->naiveNavDirection);
    
    finalVelocity=steerToBallVelocity*0.5+finalVelocity*0.5;
    
//    U4DEngine::U4DVector3n avoidanceBehavior=uPlayer->avoidanceBehavior.getSteering(uPlayer->kineticAction);
//
//    if (uPlayer->kineticAction->getModelHasCollidedBroadPhase()) {
//        finalVelocity=finalVelocity*0.8+avoidanceBehavior*0.2;
//    }
    //set the final y-component to zero
    finalVelocity.y=0.0;
    
    if(!(finalVelocity==U4DEngine::U4DVector3n(0.0,0.0,0.0))){
        
        uPlayer->applyVelocity(finalVelocity, dt);
        
        uPlayer->setViewDirection(finalVelocity);
        
    }
    
    uPlayer->foot->kineticAction->resumeCollisionBehavior();
    
    //if the player is facing the opposite way, then make the kick
    //go the opposite way to force the player to turn around
    U4DEngine::U4DVector3n viewDir=uPlayer->getViewInDirection();
    float d=viewDir.dot(uPlayer->naiveNavDirection);
    
    if (d<-0.75) {
        finalVelocity*=-1.0;
    }
    
    //if (uPlayer->foot->kineticAction->getModelHasCollided()) {
        
    finalVelocity.normalize();
    uPlayer->foot->setKickBallParameters(gameConfigs->getParameterForKey("dribblingBallSpeed"),finalVelocity);

    //}
}

void U4DPlayerStateAiDribbling::exit(U4DPlayer *uPlayer){
    
}

bool U4DPlayerStateAiDribbling::isSafeToChangeState(U4DPlayer *uPlayer){
    
    return true;
}

bool U4DPlayerStateAiDribbling::handleMessage(U4DPlayer *uPlayer, Message &uMsg){
    
    switch (uMsg.msg) {
        
        case msgMark:
        {
            uPlayer->changeState(U4DPlayerStateMark::sharedInstance());
        }
            break;
            
        default:
            break;
    }
    
    return false;
    
}

}
