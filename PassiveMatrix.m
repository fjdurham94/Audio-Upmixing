function output = PassiveMatrix(left, right, Fs)
    % Applies a passive matrix upmix to a two channel input with sampling
    % frequence Fs, output is returned in a Lx6 matrix where L is the
    % length of the input. 
    % Surround channel needs to be phase deleayed and
    % filtered at 7khz after this function to allow the active upmixer to
    % perform dominance detection.
    
    c=(left+right)/sqrt(2);

    % Low pass for the LFE at 120Hz ITU-R 775
    fprintf('Filtering LFE above 120Hz\n');
    lpfspec120Hz = fdesign.lowpass('Fp,Fst,Ap,Ast',120,250,0.1,50,Fs);
    lpf120Hz = design(lpfspec120Hz, 'equiripple');
    LFE=filter(lpf120Hz, c);

    rl=(left-right)/sqrt(2); %3dB attenuation to maintain constant acoustic energy

    rr = -rl; % Take the antiphase of the difference signal, same as -90 phase shift of r-l

    
    % Bring together for a 6 channel output
    output = [left, right, c, LFE, rl, rr];
return