function playFile( filename )
%Uses the dsp.AudioPlayer object to play surround sound audio

    fprintf('Attempting to configure USB Sound Device\n');
    %Set up AudioPlayer object
    if (exist('H','var') ~= 1) || H.DeviceName ~= 'USB Sound Device'
        H = dsp.AudioPlayer;
        H.DeviceName = 'USB Sound Device'; %My 5.1 soundcard
    end
    
    %Changing the channel mapping to match the dsp.AudioFileWriter
    H.ChannelMappingSource = 'Property';
    H.ChannelMapping = [1 2 4 3 5 6];
    
    %dsp.AudioFileReader to read it back and play out
    FR = dsp.AudioFileReader(filename);
    fprintf('Playing...\n');
    while ~isDone(FR)
        readIn = step(FR);
        step(H, readIn);
    end

end

