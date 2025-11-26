# define a container image based on the official Microsoft Server Core image as base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# copy and extract JRE from zip file
# download JDK 25 from https://download.oracle.com/java/25/latest/jdk-25_windows-x64_bin.zip
COPY setup/jdk-25_windows-x64_bin.zip C:/TEMP/jre.zip

# extract JRE
RUN mkdir C:\Java && \
    tar -xf C:\TEMP\jre.zip -C C:\TEMP && \
    for /d %i in (C:\TEMP\jdk*) do move "%i" C:\Java\jre && \
    rmdir /S /Q C:\TEMP

# verify Java installation
RUN dir C:\Java\jre\bin\java.exe

# set environment variables
ENV JAVA_HOME=C:\\Java\\jre
ENV PATH=C:\\Java\\jre\\bin;C:\\Windows\\system32;C:\\Windows;C:\\Windows\\System32\\Wbem;C:\\Windows\\System32\\WindowsPowerShell\\v1.0

# copy ActiveMQ Classic distribution to the container
# download ActiveMQ Classic 5.19.1 from https://dlcdn.apache.org//activemq/5.19.1/apache-activemq-5.19.1-bin.zip
COPY setup/apache-activemq-5.19.1-bin.zip C:/TEMP/apache/apache-activemq-5.19.1-bin.zip

# unzip ActiveMQ Classic distribution
RUN mkdir C:\ActiveMQ
RUN C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "Expand-Archive -Path C:\TEMP\apache\apache-activemq-5.19.1-bin.zip -DestinationPath C:\ActiveMQ"
RUN rmdir /S /Q C:\TEMP

# Configure ActiveMQ to listen on all interfaces (0.0.0.0 instead of 127.0.0.1)
RUN powershell -Command "(Get-Content 'C:\ActiveMQ\apache-activemq-5.19.1\conf\jetty.xml') -replace '127.0.0.1', '0.0.0.0' | Set-Content 'C:\ActiveMQ\apache-activemq-5.19.1\conf\jetty.xml'"

# expose activemq ports
EXPOSE 61616 5672 8161 61613 61614 1883

# set working directory
WORKDIR "C:\ActiveMQ\apache-activemq-5.19.1\bin"

# start ActiveMQ in foreground
CMD ["activemq.bat", "start"]
# CMD ["ping", "-t", "localhost"]





