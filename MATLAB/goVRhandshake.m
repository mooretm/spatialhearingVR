function VRconnection = goVRhandshake()
% set up the connection
portnumber = 4012;
VRconnection = tcpip('0.0.0.0',portnumber,'NetworkRole','server');
fprintf('Opening VRconnection, please connect to this server IP %s:%d\n',...
    char(java.net.InetAddress.getLocalHost.getHostAddress),portnumber);
fopen(VRconnection);
fprintf('Connected\n');
end