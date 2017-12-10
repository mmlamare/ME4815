function [RapidString] = makeTargetCode(ID, xCoord, yCoord, zCoord)
    RapidString = "CONST robtarget Target_" + ID + ":=[[" + xCoord + "," + yCoord + "," + zCoord + "],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];\r\n";
end

