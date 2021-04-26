//
//  MessageDispatcher.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 9/2/20.
//  Copyright © 2020 Untold Engine Studios. All rights reserved.
//

#include "MessageDispatcher.h"
#include "UserCommonProtocols.h"
#include "Player.h"
#include "Team.h"

MessageDispatcher* MessageDispatcher::instance=0;

MessageDispatcher::MessageDispatcher(){
    
}

MessageDispatcher::~MessageDispatcher(){
    
}

MessageDispatcher* MessageDispatcher::sharedInstance(){
    
    if (instance==0) {
        
        instance=new MessageDispatcher();
        
    }
    
    return instance;
}


void MessageDispatcher::sendMessage(double uDelay, Player *uSenderPlayer, Player *uReceiverPlayer, int uMsg){
    
    //if the receiver player is null, then don't send message
    
    if (uReceiverPlayer!=nullptr) {
        //create the message
        Message message;
        
        message.senderPlayer=uSenderPlayer;
        message.receiverPlayer=uReceiverPlayer;
        message.msg=uMsg;
        
        //send the message
        uReceiverPlayer->handleMessage(message); 
        
    }
    
}

void MessageDispatcher::sendMessage(double uDelay, Team *uTeam, Player *uReceiverPlayer, int uMsg){
    
    //if the receiver player is null, then don't send message
    
    if (uReceiverPlayer!=nullptr) {
        //create the message
        Message message;
        
        message.team=uTeam;
        message.receiverPlayer=uReceiverPlayer;
        message.msg=uMsg;
        
        //send the message
        uReceiverPlayer->handleMessage(message);
        
    }
}

void MessageDispatcher::sendMessage(double uDelay, Team *uReceiverTeam, int uMsg){
    
    //if the receiver team is null, then don't send message
    
    if (uReceiverTeam!=nullptr) {
        //create the message
        Message message;
        
        message.receiverTeam=uReceiverTeam;
        message.msg=uMsg;
        
        //send the message
        uReceiverTeam->handleMessage(message);
        
    }
}

void MessageDispatcher::sendMessage(double uDelay, Player *uSenderPlayer, Player *uReceiverPlayer, int uMsg, void* uExtraInfo){
    
}
