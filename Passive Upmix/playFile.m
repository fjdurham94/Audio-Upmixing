function playFile( filename )
%Uses the dsp.AudioPlayer object to play surround sound audio

    %Set up AudioPlayer object
    if (exist('H','var') ~= 1) || H.DeviceName ~= 'USB Sound Device'
        H = dsp.AudioPlayer;
        H.DeviceName = 'USB Sound Device'; %My 5.1 soundcard
    end

    %dsp.AudioFileReader to read it back and play out
    FR = dsp.AudioFileReader(filename);
    while ~isDone(FR)
        readIn = step(FR);
        step(H, readIn);
    end

end

