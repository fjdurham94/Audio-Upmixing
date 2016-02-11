function PassiveUpmix(inputFile)
    outputFile = makeOutputFileName(inputFile,'5_1_mix')
    outputFile_2_1 = makeOutputFileName(inputFile,'2_1_mix');
    %Passive Upmix from 2 channel to 5.1 surround

    %Set up AudioPlayer object
    %H = dsp.AudioPlayer;
    %H.DeviceName = 'USB Sound Device'; %My 5.1 soundcard
    %set(H,'ChannelMappingSource','Property');
    %H.ChannelMapping = [1 2 4 3 5 6]; %This then matches the FileWriter
    %flac ouput

    %Read in an audio file
    fprintf('Reading file [%s]\n', inputFile);
    [input,Fs]=audioread(inputFile);

    inL=input(:,1);
    inR=input(:,2);

    c=(inL+inR)/sqrt(2);

    %Low pass for the sub (500Hz?)
    s=c;

    %90phase shift on the rear pair
    fprintf('Applying phase shift to surround channel 1 of 2\n');
    %rl=inL-inR;
    rl=(inL-inR)/sqrt(2); %3dB attenuation to maintain constant acoustic energy
    rl=imag(hilbert(rl));%the imaginary part of a hilbert transform is a 90 degree phase shift of the original

    fprintf('Applying phase shift to surround channel 2 of 2\n');
    %rr=inR-inL;
    rr=(inR-inL)/sqrt(2); %3dB attenuation to maintain constant acoustic energy
    rr=imag(hilbert(rr));

    %bring together for a 6 channel output
    upMix = [inL,inR,c,s,rl,rr];
    
    %version with L R and Sub for comparison
    z = zeros(size(inL));
    mix2_1 = [inL,inR,z,s,z,z];

    %dsp.AudioFileWriter to save as a 5.1 flac
    fprintf('Writing 5.1 mix to file [%s]\n' ,outputFile);
    FW = dsp.AudioFileWriter(outputFile, 'FileFormat', 'FLAC');
    step(FW, upMix);
    release(FW);
    
    fprintf('Writing 2.1 mix to file [%s]\n' ,outputFile_2_1);
    FW = dsp.AudioFileWriter(outputFile_2_1, 'FileFormat', 'FLAC');
    step(FW, mix2_1);
    release(FW);
    
    %Play out the upmix
    %step(H,upMix);
    %{
    %function to play the output file
    playFile('output.flac')
    %}
    
    fprintf('DONE!\n');
end

function outputFile = makeOutputFileName(fileName,mix)
    dot_locs = strfind(fileName,'.');
    last_dot = dot_locs(end);
    outputFile = [fileName(1:last_dot-1) mix '.flac'];
end