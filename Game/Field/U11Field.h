//
//  U11Field.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 1/28/17.
//  Copyright © 2017 Untold Game Studio. All rights reserved.
//

#ifndef U11Field_hpp
#define U11Field_hpp

#include <stdio.h>
#include "U4DGameObject.h"
#include "U11Ball.h"
#include "U4DAABB.h"

class U11Field:public U4DEngine::U4DGameObject {
    
private:
    
    U11Ball *soccerBall;
    
public:
    U11Field();
    
    ~U11Field();
    
    void init(const char* uName, const char* uBlenderFile);
    
    void setSoccerBall(U11Ball *uSoccerBall);
    
    void update(double dt);
    
};
#endif /* U11Field_hpp */
