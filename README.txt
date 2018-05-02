The sequence of actions to install a proxy-server Squid to Linux CentOS versions 6.X or 7.X and Debian versions 7.X 8.X or 9.X when using the script squid-setup.sh

1. Put via sftp to a VPS server into the /root directory with root permissions the script squid-setup.sh 
2. Go on via ssh to VPS server with root user.
2. Once the command prompt appears in your terminal session on your VPS server, check the file squid-setup.sh in your directory with the command: ls -la
3. Install for file squid-setup.sh execute permission with the command: chmod 755 squid-setup.sh
4. Please open the script in any text editor to register IP addresses, which will be allowed access to the proxy server. The IP addresses must be entered one after another into parentheses by a space in the 9th line beginning with SRCLIST:

example: SRCLIST=(1.1.1.1 2.2.2.2 3.3.3.3)

5. Run the script squid-setup.sh: ./squid-setup.sh
6. In the process of the script will happen one stop for user request the port of proxy-server. If you click the key Enter, will use the default values test:test and port:3128.
7. When the script finishes, the screen will display the list of IP addresses, on which will be available proxy server in the format: IP-address:port.
