function PCA(inputfile)
    %  Demonstrate the principle component analysis used in ProLogic 2
    sin = audioread(inputfile);
    l_log = log(sin(:,1));
    r_log = log(sin(:,2));
    plot(r_log, l_log)
end