function audio = filtersAndDelay( audio, Fs )
% This function applies the nessecary LPFs and phase delays to the 5.1
% audio channel output from either a passive or active upmix
%   Audio must contain all 6 channels. Fs is the sampling frequency of the
%   audio data. The rear right channel is taken as the antiphase of the
%   rear left.

    % Low pass for the LFE at 120Hz ITU-R 775
    fprintf('Filtering LFE above 120Hz\n'); COMMENTED FOR SPEED
    lpfspec120Hz = fdesign.lowpass('Fp,Fst,Ap,Ast',120,250,0.1,50,Fs);
    lpf120Hz = design(lpfspec120Hz, 'equiripple');
    audio=filter(lpf120Hz, audio(:,4));
    
    % 90phase shift on the rear pair
    fprintf('Applying phase shift to surround channel\n');
    audio(:,5) = imag(hilbert(audio(:,5))); % The imaginary part of a hilbert transform is a +90 degree phase shift of the original
    audio(:,6) = -audio(:,5);
    
    % LPF applied to surround channel to give the idea of the sound being
    % further away. 7Khz taken from Dolby Pro Logic operation section 1.2
    fprintf('Applying 7kHz LPF to surround channels\n');
    lpfspec7kHz = fdesign.lowpass('Fp,Fst,Ap,Ast',7000,7500,0.1,50,Fs); % Generates LPF specification object
    lpf7kHz = design(lpfspec7kHz, 'equiripple'); % Creates filter from specification obj
    audio(:,5) = filter(lpf7kHz, audio(:,5));
    audio(:,6) = filter(lpf7kHz, audio(:,6));
end

