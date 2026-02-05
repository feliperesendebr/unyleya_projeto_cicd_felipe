# Indicando imagem base

#FROM nginx:alpine

# Copia arquivos da aplicação web para pasta de publicação do Nginx
#COPY . /usr/share/nginx/html/
#COPY Web.config /etc/nginx/conf.d/Web.config
#COPY index.html /usr/share/nginx/html/index.html

FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019
##WORKDIR /inetpub/wwwroot
##COPY . .

WORKDIR /app
COPY . .

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]
RUN Import-Module WebAdministration; \
    Set-ItemProperty 'IIS:\Sites\Default Web Site' -Name physicalPath -Value 'C:\app'