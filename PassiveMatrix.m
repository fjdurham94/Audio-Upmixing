function output = PassiveMatrix(left, right, Fs)
    % Applies a passive matrix upmix to a two channel input with sampling
    % frequence Fs, output is returned in a Lx6 matrix where L is the
    % length of the input
    
    c=(left+right)/sqrt(2);

    % Low pass for the LFE at 120Hz ITU-R 775
    fprintf('Filtering LFE above 120Hz\n');
    lpfspec120Hz = fdesign.lowpass('Fp,Fst,Ap,Ast',120,250,0.1,50,Fs);
    lpf120Hz = design(lpfspec120Hz, 'equiripple');
    LFE=filter(lpf120Hz, c);

    % 90phase shift on the rear pair
    fprintf('Applying phase shift to surround channel\n');
    rl=(left-right)/sqrt(2); %3dB attenuation to maintain constant acoustic energy
    rl=imag(hilbert(rl));%the imaginary part of a hilbert transform is a +90 degree phase shift of the original

    rr = -rl; % Take the antiphase of the difference signal, same as -90 phase shift of r-l
    
    % LPF applied to surround channel to give the idea of the sound being
    % further away. 7Khz taken from Dolby Pro Logic operation section 1.2
    fprintf('Applying 7kHz LPF to surround channels\n');
    lpfspec7kHz = fdesign.lowpass('Fp,Fst,Ap,Ast',7000,7500,0.1,50,Fs); % Generates LPF specification object
    lpf7kHz = design(lpfspec7kHz, 'equiripple'); % Creates filter from specification obj
    rl = filter(lpf7kHz, rl);
    rr = filter(lpf7kHz, rr);
    
    % Bring together for a 6 channel output
    output = [left, right, c, LFE, rl, rr];
return