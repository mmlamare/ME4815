function [moveLcmd] = makeMoveL(TargetID, vel, z, tool, workobj)   
    moveLcmd = "Target_" + TargetID + "," + vel + "," + z + tool + "\\" + "WObj:=" + workobj + ";\r\n";
end

