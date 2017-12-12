function [moveLcmd] = makeMoveL(TargetID, vel, z, tool, workobj)   
    moveLcmd = 'MoveL Target_' + TargetID + ',' + vel + ',' + z + ',' + tool + '\\' + 'WObj:=' + workobj + ';\r\n';
end

