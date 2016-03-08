function output = PassiveMatrix(left, right)
    % Applies a passive matrix upmix to a two channel input with sampling
    % frequence Fs, output is returned in a Lx6 matrix where L is the
    % length of the input. 
    % Surround channel needs to be phase deleayed and
    % filtered at 7khz after this function to allow the active upmixer to
    % perform dominance detection.
    %fprintf('Applying passive matrix\n');
    
    c=(left+right)/sqrt(2);

    % Take the LFE as the centre channel for now, LPF to be applied after
    % this function.
    LFE = c;

    rl=(left-right)/sqrt(2); %3dB attenuation to maintain constant acoustic energy

    rr = -rl; % Take the antiphase of the difference signal, same as -90 phase shift of r-l
    
    % Bring together for a 6 channel output
    output = [left, right, c, LFE, rl, rr];
return