MODULE MattMove
	! Test code for picking and placing objects in a loop    
    CONST num zTab := 147;
    CONST num zCon := 22.1;
    CONST robtarget pZeros := [[0,0,0],[0,0,-1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];   

    ! format is xi, yi, xf, yf, yaw angle change;
    VAR num aPnP{5};
    !VAR string myStrArr := "[-100,300,550,0,45]";
    VAR bool ok;
    
    PROC MattMain()
        TPWrite "------S------";
        TPWrite In_str;
        
        IF In_str = "0" THEN
            TPWrite "Empty string";
            TPWrite "In_str: " + In_str + "   Out_str: " + Out_str; 
        ELSEIF Out_str = "DONE" THEN
            TPWrite "Not yet sent";
            TPWrite "In_str: " + In_str + "   Out_str: " + Out_str; 
        ELSE
            ok := StrToVal(IN_str,aPnP);
            TPWrite ValToStr(aPnP{1}) + " " + ValToStr(aPnP{2}) + " " + ValToStr(aPnP{3}) + " " + ValToStr(aPnP{4}) + " " + ValToStr(aPnP{5});
            In_Str := "0";
            
            MoveToCalibPos;
            PrintCurPose;
            MattTurnVacOff;
            
            WaitTime(2.0);
            !PickNPlaceXYA aPnP{1}, aPnP{2}, aPnP{3}, aPnP{4}, aPnP{5};
            
            MoveToCalibPos;
            Out_Str := "DONE";
            TPWrite "In_str: " + In_str + "   Out_str: " + Out_str;  
        ENDIF
        
        TPWrite "-------F------";
        
    ENDPROC

    PROC PickNPlaceXYA(num xi, num yi, num xf, num yf, num angle)
        VAR robtarget pPick := pZeros;
        VAR robtarget pPlace := pZeros;       
        VAR num upOff := 80;
        VAR speeddata spdFast := v150;
        VAR speeddata spdMidi := v50;
        VAR speeddata spdSlow := v20;
        pPick.trans := [xi,yi,zCon];
        pPlace.trans := [xf,yf,zTab];
        pPlace.rot := OrientZYX(180 + angle,0,180);               
        
        TPWrite "Starting PNP xya";
        PrintPose(pPick);
        PrintPose(pPlace);
        
        ! Picking
        MoveJ Offs(pPick,0,0,upOff),    spdFast, fine, tSCup;  
        MoveL pPick,                    spdSlow, fine, tSCup;
        MattTurnVacOn;
        TPWrite "Vac on";   
        WaitTime 0.5;
        MoveL Offs(pPick,0,0,200),      spdMidi, fine, tSCup;
        
        ! Move just above the target place
        ! Angle anticlockwise
        MoveJ Offs(pPlace,0,0,upOff),   spdFast, fine, tSCup;
        MoveL pPlace,                   spdSlow, fine, tSCup;
        MattTurnVacOff;
        TPWrite "Vac off";  
        MoveJ Offs(pPlace,0,0, 100),    spdMidi, fine, tSCup;
    ENDPROC
    
    PROC PrintCurPose()
        PrintPose CRobT(\Tool:=tSCup);
    ENDPROC
    
    PROC MattTurnVacOn()
        ! Set VacRun on.
        SetDO DO10_1, 1;
        SetDO DO10_2, 1;
    ENDPROC
    
    PROC MattTurnVacOff()
        ! Set VacRun off.
        SetDO DO10_2, 0;
        SetDO DO10_1, 0;
    ENDPROC
    
    PROC PrintPose(robtarget P)
        TPWrite "x: " + NumToStr(P.trans.x,2) +
                " y: " + NumToStr(P.trans.y,2) +
                " z: " + NumToStr(P.trans.z,2) +
                " Q: " + NumToStr(P.rot.q1,3) +
                ", " + NumToStr(P.rot.q2,3) +
                ", " + NumToStr(P.rot.q3,3) +
                ", " + NumToStr(P.rot.q4,3);         
    ENDPROC
    
    PROC PrintJoint(jointtarget J)
        TPWrite "Joints = "  + NumToStr(J.robax.rax_1, 3) +
                ", " + NumToStr(J.robax.rax_2, 3) +
                ", " + NumToStr(J.robax.rax_3, 3) +
                ", " + NumToStr(J.robax.rax_4, 3) +
                ", " + NumToStr(J.robax.rax_5, 3) +
                ", " + NumToStr(J.robax.rax_6, 3);
    ENDPROC
ENDMODULE