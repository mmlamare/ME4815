function [inches] = pixelToPosition(pixel,scale, offset)
    inches = pixel / scale + offset;
end

