# Indicando imagem base

#FROM nginx:alpine

# Copia arquivos da aplicação web para pasta de publicação do Nginx
#COPY . /usr/share/nginx/html/
#COPY Web.config /etc/nginx/conf.d/Web.config
#COPY index.html /usr/share/nginx/html/index.html

FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019
WORKDIR /inetpub/wwwroot
COPY . .
EXPOSE 80