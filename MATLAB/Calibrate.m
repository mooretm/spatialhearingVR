p = presenter;
p = add_device(p,'RP2','GB','dich_sig.rcx',50000);

Fs = 48828;
Dur = 9;

[~,~,mySig] = doRampedTones(1000,Dur,0.02,0,0,Fs);

p = set_tag_val(p,'SigL',mySig(:,1));
p = set_tag_val(p,'SigR',mySig(:,2));
p = set_tag_val(p,'SigSamps',length(mySig));

for ii = 1:30
    %disp(ii)
    soft_trig(p,1);
    pause(1);
end

